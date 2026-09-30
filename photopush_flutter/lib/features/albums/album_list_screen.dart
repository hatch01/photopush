import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'create_album_sheet.dart';
import 'album_repository.dart';

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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
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
                onLongPress: () {
                  // TODO: context menu
                },
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