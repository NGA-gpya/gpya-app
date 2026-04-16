import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/dashboard/document_model.dart';
import 'package:myapp/src/features/dashboard/document_filter_provider.dart';
import 'package:myapp/src/features/dashboard/favorites_provider.dart';
import 'package:myapp/widgets/app_header.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('No se pudo lanzar $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocumentsAsync = ref.watch(filteredDocumentsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final theme = Theme.of(context);

    const phoneNumber = "525583252920";
    const message = "Hola quiero más información sobre...";
    final whatsappUrl =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
            child: Text(
              'Centro de Información',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: const Text('Todas'),
                    selected: selectedCategory == null,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                    },
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: theme.colorScheme.primary,
                  ),
                ),
                ...DocumentCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category.shortName),
                      selected: selectedCategory == category,
                      onSelected: (_) {
                        ref.read(selectedCategoryProvider.notifier).state = category;
                      },
                      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
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
              data: (documents) => _buildDocumentsList(context, theme, documents),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorWidget(theme, err.toString()),
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
        padding: const EdgeInsets.all(32.0),
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
            Icon(Icons.search_off_rounded, size: 60, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('No se encontraron documentos', style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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

class _DocumentCardState extends ConsumerState<_DocumentCard> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _filePath;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkFileExists();
  }

  Future<void> _checkFileExists() async {
    final savePath = await _resolveSavePath();
    if (savePath == null) return;
    final file = File(savePath);
    if (!mounted) return;
    setState(() {
      _filePath = savePath;
      _isDownloaded = file.existsSync();
    });
  }

  Future<void> _showPermissionDialog(String title, String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ACEPTAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile() async {
    try {
      if (Platform.isAndroid) {
        // Mostrar diálogo de explicación previo
        await _showPermissionDialog(
          'Permiso de Almacenamiento',
          'GPYA necesita acceder a tu carpeta de descargas para guardar el documento seleccionado.',
        );

        // Pedir permiso
        if (await Permission.manageExternalStorage.request().isDenied && 
            await Permission.storage.request().isDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso denegado. No se puede guardar el archivo.')),
            );
          }
          return;
        }
      }

      setState(() {
        _isDownloading = true;
        _progress = 0.0;
      });

      final dio = Dio();
      final savePath = await _resolveSavePath();
      if (savePath == null) throw Exception('No se pudo determinar la ruta de guardado');

      await dio.download(
        widget.document.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDownloaded = true;
          _filePath = savePath;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Documento guardado en Downloads: ${widget.document.title}')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar: $e')),
        );
      }
    }
  }

  Future<void> _openFile() async {
    if (_filePath != null) {
      final result = await OpenFilex.open(_filePath!);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el archivo: ${result.message}')),
        );
      }
    }
  }

  Future<String?> _resolveSavePath() async {
    Directory? baseDir;
    String fileName = widget.document.title
        .replaceAll(RegExp(r'[^\w\s\.-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');

    if (Platform.isAndroid) {
      // Ruta estándar de Android Downloads
      baseDir = Directory('/storage/emulated/0/Download');
      if (!baseDir.existsSync()) {
        baseDir = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      baseDir = await getDownloadsDirectory();
    }

    if (baseDir == null) return null;
    if (!baseDir.existsSync()) baseDir.createSync(recursive: true);

    return '${baseDir.path}/$fileName.pdf';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(favoritesProvider).contains(widget.document.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIconForCategory(widget.document.category), color: theme.colorScheme.primary, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.document.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(widget.document.category.shortName, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey),
                  onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(widget.document.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.document.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (_isDownloading)
              LinearProgressIndicator(value: _progress)
            else
              Align(
                alignment: Alignment.centerRight,
                child: _isDownloaded
                    ? ElevatedButton.icon(onPressed: _openFile, icon: const Icon(Icons.visibility), label: const Text('Abrir'))
                    : ElevatedButton.icon(onPressed: _downloadFile, icon: const Icon(Icons.download), label: const Text('Descargar')),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.seguridad: return Icons.security_rounded;
      case DocumentCategory.salud: return Icons.health_and_safety_rounded;
      case DocumentCategory.organizacion: return Icons.business_rounded;
      case DocumentCategory.especificas: return Icons.description_rounded;
    }
  }
}
