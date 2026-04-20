package com.grupopadillayaguilar.gpya

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val channelName = "com.grupopadillayaguilar.gpya/document_save"
    private val saveDocumentRequestCode = 4242
    private var pendingResult: MethodChannel.Result? = null
    private var pendingFilePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            if (call.method != "saveDocument") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val filePath = call.argument<String>("filePath")
            val suggestedFileName = call.argument<String>("suggestedFileName")
            val mimeType = call.argument<String>("mimeType") ?: "application/pdf"

            if (filePath.isNullOrBlank() || suggestedFileName.isNullOrBlank()) {
                result.error(
                    "invalid_arguments",
                    "filePath y suggestedFileName son obligatorios.",
                    null
                )
                return@setMethodCallHandler
            }

            if (pendingResult != null) {
                result.error("save_in_progress", "Ya hay un guardado en proceso.", null)
                return@setMethodCallHandler
            }

            pendingResult = result
            pendingFilePath = filePath

            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = mimeType
                putExtra(Intent.EXTRA_TITLE, suggestedFileName)
            }

            startActivityForResult(intent, saveDocumentRequestCode)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != saveDocumentRequestCode) {
            return
        }

        val methodResult = pendingResult
        val sourcePath = pendingFilePath

        pendingResult = null
        pendingFilePath = null

        if (methodResult == null || sourcePath == null) {
            return
        }

        if (resultCode != Activity.RESULT_OK) {
            methodResult.error("save_cancelled", "User cancelled document save.", null)
            return
        }

        val destinationUri = data?.data
        if (destinationUri == null) {
            methodResult.error("save_cancelled", "No destination was selected.", null)
            return
        }

        try {
            copyFileToUri(File(sourcePath), destinationUri)
            methodResult.success(true)
        } catch (exception: Exception) {
            methodResult.error(
                "save_failed",
                exception.message ?: "No se pudo guardar el documento.",
                null
            )
        }
    }

    @Throws(IOException::class)
    private fun copyFileToUri(file: File, uri: Uri) {
        contentResolver.openOutputStream(uri)?.use { outputStream ->
            FileInputStream(file).use { inputStream ->
                inputStream.copyTo(outputStream)
                outputStream.flush()
            }
        } ?: throw IOException("No se pudo abrir el destino seleccionado.")
    }
}
