import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:photopush_client/photopush_client.dart';
import 'asset_repository.dart';

final mediaServiceProvider = Provider<MediaService>((ref) {
  final repo = ref.watch(assetRepositoryProvider);
  return MediaService(repo);
});

class MediaService {
  final LocalAssetRepository _assetRepository;

  MediaService(this._assetRepository);

  Future<Asset> importMedia(XFile file) async {
    // Calculate SHA-256 hash using streaming to save memory
    final hash = await _calculateHash(file);
    final hexHash = hash.toString();

    // Check if asset already exists
    final existingAsset = await _assetRepository.findBySha256(hexHash);
    if (existingAsset != null) {
      return existingAsset;
    }

    // New asset - create sandbox directory
    final appDocsDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(appDocsDir.path, 'media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    // Generate unique ID and determine extension
    final assetId = Uuid().v7obj();
    final ext = p.extension(file.path);
    final targetFileName = '${assetId.toString()}$ext';
    final targetPath = p.join(mediaDir.path, targetFileName);

    // Copy file to sandbox
    await File(file.path).copy(targetPath);

    // Save asset metadata to SQLite
    final byteSize = await file.length();
    // A simplistic mime type resolution based on extension for the MVP
    final mimeType = _getMimeType(ext);

    return await _assetRepository.create(
      id: assetId,
      sha256: hexHash,
      localPath: targetPath,
      mimeType: mimeType,
      byteSize: byteSize,
      originalName: file.name,
    );
  }

  Future<Digest> _calculateHash(XFile file) async {
    final stream = file.openRead();
    return await sha256.bind(stream).first;
  }

  String _getMimeType(String extension) {
    final ext = extension.toLowerCase();
    if (ext == '.jpg' || ext == '.jpeg') return 'image/jpeg';
    if (ext == '.png') return 'image/png';
    if (ext == '.gif') return 'image/gif';
    if (ext == '.webp') return 'image/webp';
    return 'application/octet-stream';
  }
}
