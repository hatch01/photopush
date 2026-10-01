import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'create_album_sheet.dart';
import 'album_repository.dart';
import 'trash_screen.dart';

enum _AlbumListMenu { trash }

class AlbumListScreen extends ConsumerWidget {
  const AlbumListScreen({super.key});

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
          return ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return ListTile(
                title: Text(album.name),
                onTap: () {
                  // TODO: Route to slide viewer
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    final repo = ref.read(albumRepositoryProvider);
                    if (value == 'rename') {
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
                    } else if (value == 'duplicate') {
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
                    } else if (value == 'trash') {
                      await repo.moveToTrash(album.id);
                      ref.invalidate(albumListProvider);
                      ref.invalidate(trashedAlbumListProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text(l10n.rename),
                    ),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Text(l10n.duplicate),
                    ),
                    PopupMenuItem(
                      value: 'trash',
                      child: Text(l10n.moveToTrash),
                    ),
                  ],
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
            // TODO: Route to slide editor
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}