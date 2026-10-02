import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photopush_client/photopush_client.dart';
import 'package:serverpod_database/serverpod_database.dart';
import '../../client.dart';

final archiveServiceProvider = Provider<ArchiveService>((ref) {
  return ArchiveService(dbSession);
});

class ArchiveService {
  final ClientDatabaseSession session;

  ArchiveService(this.session);

  /// Exports an album and all its associated media into a `.photopush` zip archive.
  Future<File> exportAlbum(UuidValue albumId) async {
    final album = await Album.db.findById(session, albumId);
    if (album == null) {
      throw Exception('Album not found');
    }

    final slides = await Slide.db.find(
      session,
      where: (t) => t.albumId.equals(albumId) & t.deletedAt.equals(null),
      orderBy: (t) => t.orderKey,
    );

    final List<Map<String, dynamic>> slidesData = [];
    final Set<UuidValue> assetIds = {};

    for (final slide in slides) {
      if (slide.assetId != null) {
        assetIds.add(slide.assetId!);
      }

      final pins = await Pin.db.find(
        session,
        where: (t) => t.slideId.equals(slide.id) & t.deletedAt.equals(null),
        orderBy: (t) => t.zIndex,
      );

      slidesData.add({
        'id': slide.id.toString(),
        'kind': slide.kind,
        'title': slide.title,
        'commentText': slide.commentText,
        'assetId': slide.assetId?.toString(),
        'orderKey': slide.orderKey,
        'pins': pins
            .map(
              (pin) => {
                'id': pin.id.toString(),
                'kind': pin.kind,
                'x': pin.x,
                'y': pin.y,
                'sizeScale': pin.sizeScale,
                'color': pin.color,
                'text': pin.text,
                'targetSlideId': pin.targetSlideId?.toString(),
                'zIndex': pin.zIndex,
              },
            )
            .toList(),
      });
    }

    final List<Map<String, dynamic>> assetsData = [];
    final List<Asset> assetsToPack = [];

    for (final assetId in assetIds) {
      final asset = await Asset.db.findById(session, assetId);
      if (asset != null) {
        assetsToPack.add(asset);
        final fileName = p.basename(asset.localPath ?? '${asset.id}.jpg');
        assetsData.add({
          'id': asset.id.toString(),
          'sha256': asset.sha256,
          'mimeType': asset.mimeType,
          'byteSize': asset.byteSize,
          'originalName': asset.originalName,
          'fileName': fileName,
        });
      }
    }

    final manifest = {
      'format': 'photopush',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'album': {
        'id': album.id.toString(),
        'name': album.name,
        'coverAssetId': album.coverAssetId?.toString(),
        'createdAt': album.createdAt.toIso8601String(),
      },
      'assets': assetsData,
      'slides': slidesData,
    };

    final archive = Archive();

    // 1. Add album.json
    final manifestBytes = utf8.encode(jsonEncode(manifest));
    archive.addFile(
      ArchiveFile('album.json', manifestBytes.length, manifestBytes),
    );

    // 2. Add media files
    for (final asset in assetsToPack) {
      if (asset.localPath != null) {
        final file = File(asset.localPath!);
        if (await file.exists()) {
          final fileBytes = await file.readAsBytes();
          final fileName = p.basename(asset.localPath!);
          archive.addFile(
            ArchiveFile('media/$fileName', fileBytes.length, fileBytes),
          );
        }
      }
    }

    // 3. Encode to ZIP
    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);

    // 4. Save to temporary directory
    final tempDir = await getTemporaryDirectory();
    final safeName = album.name.replaceAll(RegExp(r'[\\/:*?"<>| ]'), '_');
    final outFile = File(p.join(tempDir.path, '$safeName.photopush'));
    await outFile.writeAsBytes(zipBytes);

    return outFile;
  }

  /// Imports an album from a `.photopush` zip file into SQLite and the local sandbox.
  Future<Album> importAlbum(File file) async {
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    ArchiveFile? manifestFile;
    final Map<String, ArchiveFile> mediaFiles = {};

    for (final entry in archive) {
      if (entry.isFile) {
        if (entry.name == 'album.json') {
          manifestFile = entry;
        } else if (entry.name.startsWith('media/')) {
          mediaFiles[p.basename(entry.name)] = entry;
        }
      }
    }

    if (manifestFile == null) {
      throw Exception('Invalid .photopush archive: missing album.json');
    }

    final manifestString = utf8.decode(manifestFile.content as List<int>);
    final manifest = jsonDecode(manifestString) as Map<String, dynamic>;

    final albumJson = manifest['album'] as Map<String, dynamic>;
    var albumName = albumJson['name'] as String;

    // Check uniqueness of album name, rename if collision
    var candidateName = albumName;
    var suffix = 1;
    while (true) {
      final existing = await Album.db.findFirstRow(
        session,
        where: (t) => t.name.ilike(candidateName) & t.deletedAt.equals(null),
      );
      if (existing == null) break;
      candidateName = '$albumName ($suffix)';
      suffix++;
    }

    final appDocsDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(appDocsDir.path, 'media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    // Extract media files and insert Assets
    final assetsJson = (manifest['assets'] as List<dynamic>?) ?? [];
    for (final a in assetsJson) {
      final aMap = a as Map<String, dynamic>;
      final assetId = UuidValue.fromString(aMap['id'] as String);
      final fileName = aMap['fileName'] as String;
      final sha256 = aMap['sha256'] as String;

      final targetPath = p.join(mediaDir.path, fileName);
      final targetFile = File(targetPath);

      if (!await targetFile.exists() && mediaFiles.containsKey(fileName)) {
        final archiveEntry = mediaFiles[fileName]!;
        await targetFile.writeAsBytes(archiveEntry.content as List<int>);
      }

      final existingAsset = await Asset.db.findById(session, assetId);
      if (existingAsset == null) {
        await Asset.db.insertRow(
          session,
          Asset(
            id: assetId,
            sha256: sha256,
            localPath: targetPath,
            mimeType: aMap['mimeType'] as String? ?? 'image/jpeg',
            byteSize: aMap['byteSize'] as int? ?? 0,
            originalName: aMap['originalName'] as String?,
            syncState: 'local',
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    // Insert Album
    final newAlbumId = Uuid().v7obj();
    final coverAssetId = albumJson['coverAssetId'] != null
        ? UuidValue.fromString(albumJson['coverAssetId'] as String)
        : null;

    final newAlbum = await Album.db.insertRow(
      session,
      Album(
        id: newAlbumId,
        name: candidateName,
        coverAssetId: coverAssetId,
        hlcWall: DateTime.now().millisecondsSinceEpoch,
        hlcCounter: 0,
        deviceId: 'TODO_LOCAL_DEVICE_ID',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // Map old slide IDs to new slide IDs to update pin links accurately
    final Map<String, UuidValue> slideIdMap = {};
    final slidesJson = (manifest['slides'] as List<dynamic>?) ?? [];

    for (final s in slidesJson) {
      final sMap = s as Map<String, dynamic>;
      final oldId = sMap['id'] as String;
      final newSlideId = Uuid().v7obj();
      slideIdMap[oldId] = newSlideId;

      final assetId = sMap['assetId'] != null
          ? UuidValue.fromString(sMap['assetId'] as String)
          : null;

      await Slide.db.insertRow(
        session,
        Slide(
          id: newSlideId,
          albumId: newAlbumId,
          kind: sMap['kind'] as String? ?? 'photo',
          title: sMap['title'] as String? ?? '',
          commentText: sMap['commentText'] as String?,
          assetId: assetId,
          orderKey: sMap['orderKey'] as String? ?? '000000',
          hlcWall: DateTime.now().millisecondsSinceEpoch,
          hlcCounter: 0,
          deviceId: 'TODO_LOCAL_DEVICE_ID',
          dirty: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    // Insert Pins with mapped slide and target IDs
    for (final s in slidesJson) {
      final sMap = s as Map<String, dynamic>;
      final oldSlideId = sMap['id'] as String;
      final newSlideId = slideIdMap[oldSlideId]!;
      final pinsJson = (sMap['pins'] as List<dynamic>?) ?? [];

      for (final p in pinsJson) {
        final pMap = p as Map<String, dynamic>;
        final oldTargetId = pMap['targetSlideId'] as String?;
        final newTargetId = oldTargetId != null
            ? slideIdMap[oldTargetId]
            : null;

        await Pin.db.insertRow(
          session,
          Pin(
            id: Uuid().v7obj(),
            slideId: newSlideId,
            kind: pMap['kind'] as String? ?? 'neutral',
            x: (pMap['x'] as num).toDouble(),
            y: (pMap['y'] as num).toDouble(),
            sizeScale: (pMap['sizeScale'] as num?)?.toDouble() ?? 1.0,
            color: pMap['color'] as String? ?? 'black',
            text: pMap['text'] as String?,
            targetSlideId: newTargetId,
            zIndex: pMap['zIndex'] as int? ?? 0,
            hlcWall: DateTime.now().millisecondsSinceEpoch,
            hlcCounter: 0,
            deviceId: 'TODO_LOCAL_DEVICE_ID',
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    return newAlbum;
  }
}
