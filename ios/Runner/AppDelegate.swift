import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let documentSaveChannelName = "com.grupopadillayaguilar.gpya/document_save"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let documentSaveChannel = FlutterMethodChannel(
      name: documentSaveChannelName,
      binaryMessenger: controller.binaryMessenger
    )

    documentSaveChannel.setMethodCallHandler { [weak controller] call, result in
      guard call.method == "saveDocument" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard
        let arguments = call.arguments as? [String: Any],
        let filePath = arguments["filePath"] as? String
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "filePath es obligatorio.",
            details: nil
          )
        )
        return
      }

      let fileUrl = URL(fileURLWithPath: filePath)
      let activityController = UIActivityViewController(
        activityItems: [fileUrl],
        applicationActivities: nil
      )

      activityController.completionWithItemsHandler = { _, completed, _, error in
        if let error {
          result(
            FlutterError(
              code: "save_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
          return
        }

        if completed {
          result(true)
        } else {
          result(
            FlutterError(
              code: "save_cancelled",
              message: "User cancelled document save.",
              details: nil
            )
          )
        }
      }

      if let popover = activityController.popoverPresentationController {
        popover.sourceView = controller?.view
        let bounds = controller?.view.bounds ?? .zero
        popover.sourceRect = CGRect(
          x: bounds.midX,
          y: bounds.maxY - 1,
          width: 0,
          height: 0
        )
      }

      controller?.present(activityController, animated: true)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
