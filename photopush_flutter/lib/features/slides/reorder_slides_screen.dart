import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import '../../l10n/app_localizations.dart';
import 'slide_repository.dart';
import 'asset_thumbnail.dart';
import '../albums/album_repository.dart';

class ReorderSlidesScreen extends ConsumerStatefulWidget {
  final Album album;

  const ReorderSlidesScreen({super.key, required this.album});

  @override
  ConsumerState<ReorderSlidesScreen> createState() =>
      _ReorderSlidesScreenState();
}

class _ReorderSlidesScreenState extends ConsumerState<ReorderSlidesScreen> {
  List<Slide>? _items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slidesAsync = ref.watch(albumSlidesProvider(widget.album.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reorganizeAlbum),
      ),
      body: slidesAsync.when(
        data: (slides) {
          if (slides.isEmpty) {
            return Center(
              child: Text(
                l10n.emptyAlbumHelp,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          // Initialize or sync local list if needed
          final currentItems = _items ?? List.of(slides);
          _items = currentItems;

          return ReorderableListView.builder(
            itemCount: currentItems.length,
            onReorderItem: (oldIndex, newIndex) async {
              setState(() {
                final item = currentItems.removeAt(oldIndex);
                currentItems.insert(newIndex, item);
              });

              final repo = ref.read(slideRepositoryProvider);
              await repo.reorderSlides(widget.album.id, currentItems);
              ref.invalidate(albumSlidesProvider(widget.album.id));
              ref.invalidate(albumListProvider);
            },
            itemBuilder: (context, index) {
              final slide = currentItems[index];
              return _SlideReorderTile(
                key: ValueKey(slide.id),
                album: widget.album,
                slide: slide,
                index: index,
                onDelete: () => _confirmDelete(slide, l10n),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _confirmDelete(Slide slide, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteSlideConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = ref.read(slideRepositoryProvider);
      await repo.moveToTrash(slide.id);
      setState(() {
        _items?.removeWhere((s) => s.id == slide.id);
      });
      ref.invalidate(albumSlidesProvider(widget.album.id));
      ref.invalidate(albumListProvider);
    }
  }
}

class _SlideReorderTile extends ConsumerWidget {
  final Album album;
  final Slide slide;
  final int index;
  final VoidCallback onDelete;

  const _SlideReorderTile({
    super.key,
    required this.album,
    required this.slide,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pinCountAsync = ref.watch(slidePinCountProvider(slide.id));

    Widget thumbnail;
    if (slide.kind == 'photo' && slide.assetId != null) {
      thumbnail = SizedBox(
        width: 48,
        height: 48,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AssetThumbnail(assetId: slide.assetId!),
        ),
      );
    } else {
      thumbnail = Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.notes),
      );
    }

    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          thumbnail,
        ],
      ),
      title: Text(
        slide.title.isEmpty ? l10n.untitledSlide : slide.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: pinCountAsync.when(
        data: (count) => Text(
          slide.kind == 'photo'
              ? l10n.pinCount(count)
              : (slide.commentText ?? ''),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        loading: () => const SizedBox.shrink(),
        error: (e, st) => const SizedBox.shrink(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
          const Icon(Icons.drag_handle),
        ],
      ),
    );
  }
}
