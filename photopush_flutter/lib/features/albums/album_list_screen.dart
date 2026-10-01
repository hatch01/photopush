import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'create_album_sheet.dart';
import 'album_repository.dart';
import 'trash_screen.dart';
import '../slides/slide_viewer_screen.dart';
import 'album_cover_mosaic.dart';

import 'package:animations/animations.dart';
import 'package:photopush_client/photopush_client.dart';

// ... (in _AlbumListMenu enum and start of AlbumListScreen)

enum _AlbumListMenu { trash }

class AlbumListScreen extends ConsumerWidget {
  const AlbumListScreen({super.key});

  void _showAlbumMenu(
    BuildContext context,
    WidgetRef ref,
    Album album,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.rename),
              onTap: () async {
                Navigator.pop(context);
                final repo = ref.read(albumRepositoryProvider);
                final newName = await CreateAlbumSheet.show(
                  context,
                  initialName: album.name,
                );
                if (newName != null && newName != album.name) {
                  final existing = await repo.findByName(newName);
                  if (existing != null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.albumNameExistsError)),
                      );
                    }
                    return;
                  }
                  await repo.rename(album.id, newName);
                  ref.invalidate(albumListProvider);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: Text(l10n.duplicate),
              onTap: () async {
                Navigator.pop(context);
                final repo = ref.read(albumRepositoryProvider);
                final newName = '${album.name} (Copy)';
                final existing = await repo.findByName(newName);
                if (existing != null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.albumNameExistsError)),
                    );
                  }
                  return;
                }
                await repo.duplicate(album.id, newName);
                ref.invalidate(albumListProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                l10n.moveToTrash,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final repo = ref.read(albumRepositoryProvider);
                await repo.moveToTrash(album.id);
                ref.invalidate(albumListProvider);
                ref.invalidate(trashedAlbumListProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final albumsAsyncValue = ref.watch(albumListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => ref.refresh(albumListProvider.future),
          ),
          PopupMenuButton<_AlbumListMenu>(
            onSelected: (value) {
              if (value == _AlbumListMenu.trash) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TrashScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _AlbumListMenu.trash,
                child: Text(l10n.trash),
              ),
            ],
          ),
        ],
      ),
      body: albumsAsyncValue.when(
        data: (albums) {
          if (albums.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  l10n.emptyAlbumListHelp,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.85,
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return OpenContainer(
                closedElevation: 2.0,
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                closedColor: Theme.of(context).colorScheme.surface,
                openBuilder: (context, _) => SlideViewerScreen(album: album),
                closedBuilder: (context, openContainer) => InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  onTap: openContainer,
                  onLongPress: () {
                    _showAlbumMenu(context, ref, album, l10n);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: AlbumCoverMosaic(
                              albumId: album.id,
                              fallbackCoverAssetId: album.coverAssetId,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            4.0,
                            8.0,
                            4.0,
                            4.0,
                          ),
                          child: Text(
                            album.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final name = await CreateAlbumSheet.show(context);
          if (name != null) {
            final repo = ref.read(albumRepositoryProvider);

            // Check uniqueness
            final existing = await repo.findByName(name);
            if (existing != null) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.albumNameExistsError)),
                );
              }
              return;
            }

            await repo.create(name);
            ref.invalidate(albumListProvider);

            // Route to slide viewer of the newly created album
            final newAlbum = await repo.findByName(name);
            if (context.mounted && newAlbum != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SlideViewerScreen(album: newAlbum),
                ),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
