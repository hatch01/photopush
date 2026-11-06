import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../models/models.dart';
import 'album_storage_service.dart';

/// Service responsible for compressing and decompressing albums into `.photopush` archives.
class ArchiveService {
  const ArchiveService(this._storageService);

  final AlbumStorageService _storageService;

  /// Creates a `.photopush` archive from an album folder.
  ///
  /// Gallery-linked images are temporarily copied inside the archive to ensure portability.
  Future<File> createArchive(String albumName, {Directory? outputDir}) async {
    final albumDir = await _storageService.getAlbumDirectory(albumName);
    if (!albumDir.existsSync()) {
      throw FileSystemException('Album directory not found', albumDir.path);
    }

    // 1. Create an isolated temporary copy of the album directory for archiving
    final tempStagingDir = Directory(
      p.join(Directory.systemTemp.path, 'staging_${const Uuid().v4()}'),
    );
    tempStagingDir.createSync(recursive: true);

    // Copy all existing files
    for (final entity in albumDir.listSync(recursive: true)) {
      if (entity is File) {
        final relative = p.relative(entity.path, from: albumDir.path);
        if (relative.endsWith('.tmp')) continue; // skip tmp files
        final dest = File(p.join(tempStagingDir.path, relative));
        dest.parent.createSync(recursive: true);
        entity.copySync(dest.path);
      }
    }

    // 2. Fetch the album model to find gallery-linked images
    final loadResult = await _storageService.loadAlbumFromDirectory(albumDir);
    if (loadResult is AlbumLoadSuccess) {
      bool albumModified = false;
      final album = loadResult.album;
      final newSlides = List<Slide>.from(album.slides);

      for (var i = 0; i < newSlides.length; i++) {
        final slide = newSlides[i];
        if (slide.image != null && slide.image!.isGallery) {
          final originalFile = File(slide.image!.path);
          if (originalFile.existsSync()) {
            final fileName = 'gal_${const Uuid().v4()}.jpg';
            final newRelativePath = p.join('images', fileName);
            final destFile = File(p.join(tempStagingDir.path, newRelativePath));

            destFile.parent.createSync(recursive: true);
            originalFile.copySync(destFile.path);

            // Update the slide in the cloned album model to point to the internal copy
            final newImageSource = slide.image!.copyWith(
              storageType: ImageStorageType.internal,
              path: newRelativePath.replaceAll('\\', '/'),
            );
            newSlides[i] = slide.copyWith(image: newImageSource);
            albumModified = true;
          }
        }
      }

      // If we converted gallery links to internal, overwrite the album.json in the staging dir
      if (albumModified) {
        final updatedAlbum = album.copyWith(slides: newSlides);
        final jsonFile = File(
          p.join(tempStagingDir.path, AlbumStorageService.albumFileName),
        );
        final jsonContent = const JsonEncoder.withIndent('  ')
            .convert(updatedAlbum.toJson());
        jsonFile.writeAsStringSync(jsonContent);
      }
    }

    // 3. Zip the staging directory
    final encoder = ZipFileEncoder();
    final outDir = outputDir ?? Directory.systemTemp;
    final archiveFile = File(p.join(outDir.path, '$albumName.photopush'));

    encoder.create(archiveFile.path);
    encoder.addDirectory(tempStagingDir, includeDirName: false);
    encoder.close();

    // 4. Cleanup staging directory
    try {
      tempStagingDir.deleteSync(recursive: true);
    } catch (_) {}

    return archiveFile;
  }

  /// Extracts a `.photopush` archive into the application's storage.
  ///
  /// Throws a [StateError] if the archive is invalid (missing album.json).
  /// [targetAlbumName] can be provided to resolve naming collisions.
  Future<String> importArchive(
    File archiveFile, {
    String? targetAlbumName,
  }) async {
    // 1. Unzip to a temporary directory to validate
    final tempExtractDir = Directory(
      p.join(Directory.systemTemp.path, 'import_${const Uuid().v4()}'),
    );
    tempExtractDir.createSync(recursive: true);

    try {
      final bytes = archiveFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Simple Zip Slip vulnerability prevention and extraction
      for (final file in archive) {
        final filePath = file.name;
        if (filePath.contains('..')) {
          throw const FormatException(
            'Invalid archive structure (Zip Slip vulnerability detected).',
          );
        }

        if (file.isFile) {
          final data = file.content as List<int>;
          final targetFile = File(p.join(tempExtractDir.path, filePath));
          targetFile.parent.createSync(recursive: true);
          targetFile.writeAsBytesSync(data);
        }
      }

      // 2. Validate extracted content
      final jsonFile = File(
        p.join(tempExtractDir.path, AlbumStorageService.albumFileName),
      );
      if (!jsonFile.existsSync()) {
        throw const FormatException('Invalid archive: missing album.json.');
      }

      // Load it to see if it's readable
      final loadResult = await _storageService.loadAlbumFromDirectory(
        tempExtractDir,
      );
      if (loadResult is! AlbumLoadSuccess) {
        throw const FormatException(
          'Invalid archive: album.json is corrupted.',
        );
      }

      // 3. Move to permanent storage
      final finalName = targetAlbumName ?? loadResult.album.name;
      final finalDir = await _storageService.getAlbumDirectory(finalName);

      if (finalDir.existsSync()) {
        throw StateError('An album with name "$finalName" already exists.');
      }

      tempExtractDir.renameSync(finalDir.path);

      return finalName;
    } finally {
      if (tempExtractDir.existsSync()) {
        try {
          tempExtractDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    }
  }
}
