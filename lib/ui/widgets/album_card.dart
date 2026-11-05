import 'dart:io';

import 'package:flutter/material.dart';

import '../../controllers/albums_controller.dart';
import '../../services/services.dart';

/// Card displaying an album in the grid/list with thumbnail, metadata and action menu.
class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.result,
    required this.controller,
    required this.onTap,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
  });

  final AlbumLoadResult result;
  final AlbumsController controller;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (result is AlbumLoadCorrupted) {
      final corrupted = result as AlbumLoadCorrupted;
      return Card(
        elevation: 2,
        color: colorScheme.errorContainer.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colorScheme.error,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      corrupted.albumName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onErrorContainer,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'delete') onDelete();
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Supprimer',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Album illisible / corrompu',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fichier album.json invalide',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final album = (result as AlbumLoadSuccess).album;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FutureBuilder<File?>(
                future: controller.getCoverFile(album),
                builder: (context, snapshot) {
                  final coverFile = snapshot.data;
                  if (coverFile != null && coverFile.existsSync()) {
                    return Image.file(coverFile, fit: BoxFit.cover);
                  }
                  return Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.photo_library_outlined,
                        size: 48,
                        color: colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.photo_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              album.slideCount == 1
                                  ? '1 diapositive'
                                  : '${album.slideCount} diapositives',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatDate(album.updatedAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Options de l\'album',
                    icon: const Icon(Icons.more_vert),
                    onSelected: (val) {
                      switch (val) {
                        case 'rename':
                          onRename();
                          break;
                        case 'duplicate':
                          onDuplicate();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 12),
                            Text('Renommer'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy_outlined),
                            SizedBox(width: 12),
                            Text('Dupliquer'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Supprimer',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
