import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import '../slides/asset_thumbnail.dart';
import '../slides/slide_repository.dart';

class AlbumCoverMosaic extends ConsumerWidget {
  final UuidValue albumId;
  final UuidValue? fallbackCoverAssetId;

  const AlbumCoverMosaic({
    super.key,
    required this.albumId,
    this.fallbackCoverAssetId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slidesAsync = ref.watch(albumSlidesProvider(albumId));

    return slidesAsync.when(
      data: (slides) {
        final photoSlides = slides
            .where((s) => s.kind == 'photo' && s.assetId != null)
            .take(4)
            .toList();

        if (photoSlides.isEmpty) {
          if (fallbackCoverAssetId != null) {
            return AssetThumbnail(
              assetId: fallbackCoverAssetId!,
              width: double.infinity,
              height: double.infinity,
            );
          }
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: Icon(Icons.photo_album, size: 48, color: Colors.grey),
            ),
          );
        }

        if (photoSlides.length == 1) {
          return AssetThumbnail(
            assetId: photoSlides[0].assetId!,
            width: double.infinity,
            height: double.infinity,
          );
        }

        // 2, 3 or 4 photos: clean 2x2 mosaic preview
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AssetThumbnail(
                        assetId: photoSlides[0].assetId!,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: AssetThumbnail(
                        assetId: photoSlides[1].assetId!,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: photoSlides.length > 2
                          ? AssetThumbnail(
                              assetId: photoSlides[2].assetId!,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Container(color: Colors.black12),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: photoSlides.length > 3
                          ? AssetThumbnail(
                              assetId: photoSlides[3].assetId!,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Container(color: Colors.black12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, st) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.broken_image, size: 48),
      ),
    );
  }
}
