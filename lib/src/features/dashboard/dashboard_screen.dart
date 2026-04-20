import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/features/dashboard/document_filter_provider.dart';
import 'package:myapp/src/features/dashboard/document_model.dart';
import 'package:myapp/src/features/dashboard/favorites_provider.dart';
import 'package:myapp/widgets/app_header.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

const MethodChannel _documentSaveChannel = MethodChannel(
  'com.grupopadillayaguilar.gpya/document_save',
);

class _NativeSaveResult {
  const _NativeSaveResult({
    required this.saved,
    required this.wasCancelled,
  });

  final bool saved;
  final bool wasCancelled;
}

Future<_NativeSaveResult> _showNativeSaveUi({
  required String filePath,
  required String suggestedFileName,
}) async {
  try {
    final saved =
        await _documentSaveChannel.invokeMethod<bool>('saveDocument', {
          'filePath': filePath,
          'suggestedFileName': suggestedFileName,
          'mimeType': 'application/pdf',
        }) ??
        false;

    return _NativeSaveResult(
      saved: saved,
      wasCancelled: !saved,
    );
  } on PlatformException catch (error) {
    if (error.code == 'save_cancelled') {
      return const _NativeSaveResult(saved: false, wasCancelled: true);
    }

    throw Exception(error.message ?? 'No se pudo guardar el documento.');
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('No se pudo lanzar $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocumentsAsync = ref.watch(filteredDocumentsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final theme = Theme.of(context);

    const phoneNumber = '525583252920';
    const message = 'Hola quiero más información sobre...';
    final whatsappUrl =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'Centro de Información',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Buscar documentos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todas'),
                    selected: selectedCategory == null,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                    },
                    selectedColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: theme.colorScheme.primary,
                  ),
                ),
                ...DocumentCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.shortName),
                      selected: selectedCategory == category,
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category;
                      },
                      selectedColor:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                      checkmarkColor: theme.colorScheme.primary,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredDocumentsAsync.when(
              data: (documents) =>
                  _buildDocumentsList(context, theme, documents),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  _buildErrorWidget(theme, err.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _launchUrl(whatsappUrl),
        backgroundColor: Colors.transparent,
        elevation: 0,
        tooltip: 'Contactar por WhatsApp',
        child: Image.asset('assets/icon/logo-wp.png'),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: theme.colorScheme.error,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              'Error de Conexión',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'No se pudo establecer conexión con el servidor de documentos. Detalle: $error',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList(
    BuildContext context,
    ThemeData theme,
    List<Document> documents,
  ) {
    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 60,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron documentos',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: documents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final doc = documents[index];
        return _DocumentCard(document: doc);
      },
    );
  }
}

class _DocumentCard extends ConsumerStatefulWidget {
  final Document document;

  const _DocumentCard({required this.document});

  @override
  ConsumerState<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends ConsumerState<_DocumentCard>
    with WidgetsBindingObserver {
  bool _isDownloading = false;
  bool _isSaving = false;
  double _progress = 0;
  String? _filePath;
  bool _isDownloaded = false;
  int? _androidSdkInt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDownloadState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkFileExists();
    }
  }

  Future<void> _initializeDownloadState() async {
    await _loadPlatformInfo();
    await _checkFileExists();
  }

  Future<void> _loadPlatformInfo() async {
    if (!Platform.isAndroid) return;
    final info = await DeviceInfoPlugin().androidInfo;
    if (!mounted) return;
    setState(() {
      _androidSdkInt = info.version.sdkInt;
    });
  }

  bool get _usesNativeExportSheet {
    if (Platform.isIOS) return true;
    if (Platform.isAndroid) {
      return (_androidSdkInt ?? 0) >= 30;
    }
    return false;
  }

  String get _sanitizedFileName {
    final sanitized = widget.document.title
        .replaceAll(RegExp(r'[^\w\s\.-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    return '$sanitized.pdf';
  }

  Future<String?> _resolveCachedPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final baseDir = Directory('${dir.path}/downloads');
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }

    // Stable key so the cached file survives title changes.
    final safeId = widget.document.id.replaceAll(RegExp(r'[^\w\.-]'), '_');
    return '${baseDir.path}/$safeId.pdf';
  }

  Future<void> _checkFileExists() async {
    if (_usesNativeExportSheet) {
      final cachedPath = await _resolveCachedPath();
      if (cachedPath == null) return;

      final cachedFile = File(cachedPath);
      if (!mounted) return;
      setState(() {
        _filePath = cachedPath;
        _isDownloaded = cachedFile.existsSync();
      });
      return;
    }

    final savePath = await _resolveSavePath();
    if (savePath == null) return;

    final file = File(savePath);
    if (!mounted) return;

    setState(() {
      _filePath = savePath;
      _isDownloaded = file.existsSync();
    });
  }

  Future<bool> _requestStoragePermission(
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    if (!Platform.isAndroid) return true;
    if (_usesNativeExportSheet) return true;

    PermissionStatus status = await Permission.storage.status;
    if (status.isGranted) return true;

    status = await Permission.storage.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Activa el permiso de archivos en Ajustes para guardar documentos en Descargas.',
          ),
          action: SnackBarAction(
            label: 'Ajustes',
            onPressed: openAppSettings,
          ),
        ),
      );
      return false;
    }

    if (status.isDenied) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Se necesita el permiso de archivos para guardar documentos en Descargas.',
          ),
        ),
      );
    }

    return false;
  }

  Future<void> _downloadFile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final hasPermission = await _requestStoragePermission(scaffoldMessenger);
    if (!hasPermission) return;

    setState(() {
      _isDownloading = true;
      _isSaving = false;
      _progress = 0;
    });

    try {
      final dio = Dio();
      final savePath = _usesNativeExportSheet
          ? await _resolveCachedPath()
          : await _resolveSavePath();
      if (savePath == null) throw Exception('Ruta no válida');

      await dio.download(
        widget.document.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      if (_usesNativeExportSheet) {
        if (!mounted) return;

        setState(() {
          _isDownloading = false;
          _isSaving = true;
          _filePath = savePath;
        });

        final nativeSaveResult = await _showNativeSaveUi(
          filePath: savePath,
          suggestedFileName: _sanitizedFileName,
        );

        // If the user cancels the system sheet, delete the cached file so the UI
        // goes back to "Descargar". If saved, keep the cached copy for "Abrir".
        if (!nativeSaveResult.saved) {
          final cachedFile = File(savePath);
          if (await cachedFile.exists()) {
            await cachedFile.delete();
          }
        }

        if (!mounted) return;

        setState(() {
          _isSaving = false;
          _filePath = savePath;
          _isDownloaded = nativeSaveResult.saved;
          _progress = 0;
        });

        if (nativeSaveResult.saved) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Documento guardado correctamente usando la hoja del sistema.',
              ),
              backgroundColor: Color(0xFFD32F2F),
            ),
          );
        } else if (nativeSaveResult.wasCancelled) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Guardado cancelado por el usuario.'),
            ),
          );
        }

        return;
      }

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
        _filePath = savePath;
      });

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Documento guardado con éxito'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _isSaving = false;
        _progress = 0;
        if (_usesNativeExportSheet) {
          _filePath = null;
          _isDownloaded = false;
        }
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al descargar el documento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openFile() async {
    if (_filePath == null) return;

    final result = await OpenFilex.open(_filePath!);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir el archivo: ${result.message}'),
        ),
      );
      await _checkFileExists();
    }
  }

  Future<void> _deleteLocalCopy() async {
    final path = _filePath;
    if (path == null) return;

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      if (!mounted) return;
      setState(() {
        _isDownloaded = false;
        _progress = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descarga eliminada.')),
      );
      await _checkFileExists();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el archivo: $e')),
      );
    }
  }

  Future<String?> _resolveSavePath() async {
    Directory? baseDir;

    if (Platform.isAndroid) {
      if (_usesNativeExportSheet) {
        baseDir = await getTemporaryDirectory();
      } else {
        baseDir = Directory('/storage/emulated/0/Download');
        if (!baseDir.existsSync()) {
          baseDir = await getExternalStorageDirectory();
        }
      }
    } else if (Platform.isIOS) {
      baseDir = await getTemporaryDirectory();
    } else {
      baseDir = await getDownloadsDirectory();
    }

    if (baseDir == null) return null;
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }

    return '${baseDir.path}/$_sanitizedFileName';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(favoritesProvider).contains(
      widget.document.id,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForCategory(widget.document.category),
                  color: theme.colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.document.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.document.category.shortName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => ref
                      .read(favoritesProvider.notifier)
                      .toggleFavorite(widget.document.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.document.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (_isDownloading || _isSaving)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isDownloading)
                    LinearProgressIndicator(value: _progress)
                  else
                    const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    _isDownloading
                        ? 'Descargando... ${(_progress * 100).toStringAsFixed(0)}%'
                        : 'Guardando...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isDownloaded) ...[
                      ElevatedButton.icon(
                        onPressed: _openFile,
                        icon: const Icon(Icons.visibility),
                        label: const Text('Abrir'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Eliminar descarga',
                        onPressed: _deleteLocalCopy,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ] else
                      ElevatedButton.icon(
                        onPressed: _downloadFile,
                        icon: const Icon(Icons.download),
                        label: const Text('Descargar'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.seguridad:
        return Icons.security_rounded;
      case DocumentCategory.salud:
        return Icons.health_and_safety_rounded;
      case DocumentCategory.organizacion:
        return Icons.business_rounded;
      case DocumentCategory.especificas:
        return Icons.description_rounded;
    }
  }
}
