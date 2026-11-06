import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/services.dart';

/// Screen allowing the user to manage disk space and clean up orphan files.
class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key, this.storageService});

  final AlbumStorageService? storageService;

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  late final AlbumStorageService _storageService;

  bool _isLoading = true;
  String? _error;
  List<AlbumDiskSpaceInfo> _albumInfos = [];

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService ?? AlbumStorageService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _storageService.loadAllAlbums();
      final infos = <AlbumDiskSpaceInfo>[];

      for (final result in results) {
        if (result is AlbumLoadSuccess) {
          final info = await _storageService.getAlbumDiskSpaceInfo(
            result.albumName,
          );
          infos.add(info);
        }
      }

      if (mounted) {
        setState(() {
          _albumInfos = infos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors de l\'analyse des fichiers : $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCleanAlbum(
    String albumName,
    AlbumDiskSpaceInfo info,
  ) async {
    if (info.orphanCount == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nettoyer l\'album'),
        content: Text(
          'Voulez-vous supprimer définitivement ${info.orphanCount} fichier(s) inutile(s) ?\n'
          'Espace libéré : ${_formatBytes(info.orphanBytes)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Nettoyer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await _storageService.purgeOrphanFiles(albumName);
        await _loadData(); // Refresh all

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Album "$albumName" nettoyé avec succès.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du nettoyage : $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 O';
    if (bytes < 1024) return '$bytes O';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} Ko';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Fichiers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: _buildBody(colorScheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_albumInfos.isEmpty) {
      return const Center(child: Text('Aucun album valide trouvé.'));
    }

    final totalSpace = _albumInfos.fold<int>(
      0,
      (sum, info) => sum + info.totalBytes,
    );
    final totalOrphanSpace = _albumInfos.fold<int>(
      0,
      (sum, info) => sum + info.orphanBytes,
    );

    return Column(
      children: [
        // Global Summary
        Container(
          padding: const EdgeInsets.all(24),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    _formatBytes(totalSpace),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Espace total',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    _formatBytes(totalOrphanSpace),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: totalOrphanSpace > 0 ? colorScheme.error : null,
                    ),
                  ),
                  Text(
                    'Espace à libérer',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // List of Albums
        Expanded(
          child: ListView.builder(
            itemCount: _albumInfos.length,
            itemBuilder: (context, index) {
              final info = _albumInfos[index];
              return ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(
                  info.albumName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${info.imageCount} image(s) • ${_formatBytes(info.totalBytes)}',
                ),
                trailing: info.orphanCount > 0
                    ? OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                        ),
                        onPressed: () =>
                            _handleCleanAlbum(info.albumName, info),
                        icon: const Icon(
                          Icons.cleaning_services_rounded,
                          size: 18,
                        ),
                        label: Text(
                          'Purger (${_formatBytes(info.orphanBytes)})',
                        ),
                      )
                    : Icon(Icons.check_circle, color: colorScheme.primary),
              );
            },
          ),
        ),
      ],
    );
  }
}
