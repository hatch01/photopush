import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'asset_repository.dart';

class AssetThumbnail extends ConsumerWidget {
  final UuidValue assetId;
  final double width;
  final double height;

  const AssetThumbnail({
    super.key,
    required this.assetId,
    this.width = 50,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A FutureProvider family to fetch asset by ID would be better,
    // but for simplicity we'll just read from DB in a FutureBuilder.
    final repo = ref.watch(assetRepositoryProvider);

    return FutureBuilder<Asset?>(
      future: Asset.db.findById(repo.session, assetId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            width: width,
            height: height,
            child: const ColoredBox(color: Colors.grey),
          );
        }

        final asset = snapshot.data!;
        if (asset.localPath != null && File(asset.localPath!).existsSync()) {
          return Image.file(
            File(asset.localPath!),
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        }

        return SizedBox(
          width: width,
          height: height,
          child: const ColoredBox(color: Colors.red), // Image not found state
        );
      },
    );
  }
}
