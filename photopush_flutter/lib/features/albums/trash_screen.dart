import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'album_repository.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final trashedAlbumsAsync = ref.watch(trashedAlbumListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trash),
      ),
      body: trashedAlbumsAsync.when(
        data: (albums) {
          if (albums.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  l10n.emptyTrashHelp,
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
                trailing: TextButton(
                  onPressed: () async {
                    final repo = ref.read(albumRepositoryProvider);
                    await repo.restoreFromTrash(album.id);
                    ref.invalidate(trashedAlbumListProvider);
                    ref.invalidate(albumListProvider);
                  },
                  child: Text(l10n.restore),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}