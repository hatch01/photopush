import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'asset_repository.dart';

class PhotoSlideViewer extends ConsumerWidget {
  final Slide slide;
  final VoidCallback onTap;

  const PhotoSlideViewer({
    super.key,
    required this.slide,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (slide.assetId == null) {
      return const Center(child: Text('No Image attached'));
    }

    final repo = ref.watch(assetRepositoryProvider);

    return GestureDetector(
      onTap: onTap,
      child: FutureBuilder<Asset?>(
        future: Asset.db.findById(repo.session, slide.assetId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final asset = snapshot.data;
          if (asset?.localPath != null && File(asset!.localPath!).existsSync()) {
            return InteractiveViewer(
              minScale: 1.0,
              maxScale: 6.0,
              child: Image.file(
                File(asset.localPath!),
                fit: BoxFit.contain, // Letterbox pour s'adapter à l'écran
                width: double.infinity,
                height: double.infinity,
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Image not found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}