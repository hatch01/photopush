import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/models.dart';

/// Result of loading an album from disk.
@immutable
sealed class AlbumLoadResult {
  const AlbumLoadResult();

  /// The name of the album folder.
  String get albumName;

  /// Absolute filesystem path to the album directory.
  String get directoryPath;

  /// Whether the album loaded successfully.
  bool get isSuccess => this is AlbumLoadSuccess;

  /// Whether the album was corrupted or unreadable.
  bool get isCorrupted => this is AlbumLoadCorrupted;

  /// Returns the loaded [Album], or null if corrupted.
  Album? get albumOrNull => switch (this) {
    AlbumLoadSuccess(:final album) => album,
    AlbumLoadCorrupted() => null,
  };
}

/// Represents an album successfully loaded and validated from disk.
@immutable
final class AlbumLoadSuccess extends AlbumLoadResult {
  const AlbumLoadSuccess(this.album, {required this.directoryPath});

  /// The fully parsed and validated [Album].
  final Album album;

  @override
  final String directoryPath;

  @override
  String get albumName => album.name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumLoadSuccess &&
          runtimeType == other.runtimeType &&
          album == other.album &&
          directoryPath == other.directoryPath;

  @override
  int get hashCode => Object.hash(album, directoryPath);

  @override
  String toString() => 'AlbumLoadSuccess("${album.name}")';
}

/// Represents an album folder that exists on disk but whose `album.json`
/// was corrupted, unreadable, or invalid.
@immutable
final class AlbumLoadCorrupted extends AlbumLoadResult {
  const AlbumLoadCorrupted({
    required this.albumName,
    required this.directoryPath,
    required this.error,
    this.stackTrace,
    this.rawContent,
  });

  @override
  final String albumName;

  @override
  final String directoryPath;

  /// The error encountered when reading or parsing the album.
  final Object error;

  /// The stack trace if available.
  final StackTrace? stackTrace;

  /// The raw content read from the file before failure, if accessible.
  final String? rawContent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumLoadCorrupted &&
          runtimeType == other.runtimeType &&
          albumName == other.albumName &&
          directoryPath == other.directoryPath &&
          error.toString() == other.error.toString();

  @override
  int get hashCode => Object.hash(albumName, directoryPath, error.toString());

  @override
  String toString() => 'AlbumLoadCorrupted("$albumName", error: $error)';
}

/// Service managing the persistence and atomic storage of albums on disk.
class AlbumStorageService {
  AlbumStorageService({Future<Directory> Function()? baseDirectoryResolver})
    : _baseDirectoryResolver =
          baseDirectoryResolver ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _baseDirectoryResolver;

  static const String albumFileName = 'album.json';
  static const String albumTmpFileName = 'album.json.tmp';
  static const String imagesFolderName = 'images';
  static const String albumsFolderName = 'albums';

  /// Resolves the root directory containing all albums: `<documents>/albums/`.
  Future<Directory> get albumsDirectory async {
    final baseDir = await _baseDirectoryResolver();
    final albumsDir = Directory(p.join(baseDir.path, albumsFolderName));
    if (!albumsDir.existsSync()) {
      albumsDir.createSync(recursive: true);
    }
    return albumsDir;
  }

  /// Returns the [Directory] for a given album name (without creating it).
  Future<Directory> getAlbumDirectory(String albumName) async {
    final root = await albumsDirectory;
    return Directory(p.join(root.path, albumName.trim()));
  }

  /// Returns the `images/` directory inside a given album.
  Future<Directory> getImagesDirectory(String albumName) async {
    final albumDir = await getAlbumDirectory(albumName);
    return Directory(p.join(albumDir.path, imagesFolderName));
  }

  /// Checks whether an album folder exists on disk (case-insensitive check).
  Future<bool> albumExists(String albumName) async {
    final root = await albumsDirectory;
    if (!root.existsSync()) return false;

    final targetNormalized = albumName.trim().toLowerCase();
    for (final entity in root.listSync(followLinks: false)) {
      if (entity is Directory) {
        final currentName = p.basename(entity.path).toLowerCase();
        if (currentName == targetNormalized) {
          return true;
        }
      }
    }
    return false;
  }

  /// Atomically saves an album to disk:
  /// 1. Ensures the album folder exists.
  /// 2. If [previousName] is provided and differs, safely renames the folder.
  /// 3. Writes formatted JSON to `album.json.tmp` with disk flush.
  /// 4. Atomically renames `album.json.tmp` to `album.json`.
  Future<void> saveAlbum(Album album, {String? previousName}) async {
    final sanitizedName = album.name.trim();

    // Handle album directory rename if the name was changed
    if (previousName != null &&
        previousName.trim().isNotEmpty &&
        previousName.trim() != sanitizedName) {
      final oldDir = await getAlbumDirectory(previousName);
      final newDir = await getAlbumDirectory(sanitizedName);

      if (oldDir.existsSync()) {
        if (newDir.existsSync() &&
            oldDir.path.toLowerCase() != newDir.path.toLowerCase()) {
          throw StateError(
            'Cannot rename album to "$sanitizedName" because a folder with that name already exists.',
          );
        }
        oldDir.renameSync(newDir.path);
      }
    }

    final albumDir = await getAlbumDirectory(sanitizedName);
    if (!albumDir.existsSync()) {
      albumDir.createSync(recursive: true);
    }

    // Ensure images sub-folder exists
    final imagesDir = Directory(p.join(albumDir.path, imagesFolderName));
    if (!imagesDir.existsSync()) {
      imagesDir.createSync(recursive: true);
    }

    final jsonContent = const JsonEncoder.withIndent('  ')
        .convert(album.toJson());

    final tmpFile = File(p.join(albumDir.path, albumTmpFileName));
    final targetFile = File(p.join(albumDir.path, albumFileName));

    try {
      // Step 1: Write to temporary file with flush: true
      tmpFile.writeAsStringSync(jsonContent, flush: true);

      // Step 2: Atomic rename
      tmpFile.renameSync(targetFile.path);
    } catch (e, st) {
      developer.log(
        'Failed atomic save for album "${album.name}"',
        error: e,
        stackTrace: st,
      );
      // Clean up tmp file if it still exists
      if (tmpFile.existsSync()) {
        try {
          tmpFile.deleteSync();
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// Loads a single album by its folder name with recovery and failure tolerance.
  Future<AlbumLoadResult> loadAlbum(String albumName) async {
    final albumDir = await getAlbumDirectory(albumName);
    return loadAlbumFromDirectory(albumDir);
  }

  /// Loads an album from its directory.
  Future<AlbumLoadResult> loadAlbumFromDirectory(Directory albumDir) async {
    final folderName = p.basename(albumDir.path);
    final targetFile = File(p.join(albumDir.path, albumFileName));
    final tmpFile = File(p.join(albumDir.path, albumTmpFileName));

    String? content;

    try {
      // If target file doesn't exist or is empty, try recovering from .tmp
      if (!targetFile.existsSync() || targetFile.lengthSync() == 0) {
        if (tmpFile.existsSync() && tmpFile.lengthSync() > 0) {
          developer.log(
            'Recovering album "$folderName" from dangling .tmp file',
          );
          try {
            content = tmpFile.readAsStringSync();
            final dynamic json = jsonDecode(content);
            if (json is Map<String, dynamic>) {
              // Recovery valid: restore to album.json
              tmpFile.renameSync(targetFile.path);
              final album = Album.fromJson(json);
              return AlbumLoadSuccess(album, directoryPath: albumDir.path);
            }
          } catch (e) {
            developer.log(
              'Failed recovery from .tmp for album "$folderName": $e',
            );
          }
        }

        return AlbumLoadCorrupted(
          albumName: folderName,
          directoryPath: albumDir.path,
          error: FileSystemException(
            'Album file "$albumFileName" is missing or empty',
            targetFile.path,
          ),
        );
      }

      // Read target file
      content = targetFile.readAsStringSync();
      final dynamic decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Expected JSON object at root of album.json',
        );
      }

      final album = Album.fromJson(decoded);

      // Clean up dangling .tmp file if an old one remained from a previous run
      if (tmpFile.existsSync()) {
        try {
          tmpFile.deleteSync();
        } catch (_) {}
      }

      return AlbumLoadSuccess(album, directoryPath: albumDir.path);
    } catch (e, st) {
      developer.log(
        'Error reading album "$folderName"',
        error: e,
        stackTrace: st,
      );

      // Attempt fallback recovery from .tmp if target was corrupted
      if (tmpFile.existsSync() && tmpFile.lengthSync() > 0) {
        try {
          final tmpContent = tmpFile.readAsStringSync();
          final dynamic tmpDecoded = jsonDecode(tmpContent);
          if (tmpDecoded is Map<String, dynamic>) {
            final recoveredAlbum = Album.fromJson(tmpDecoded);
            // Restore tmp over corrupt target
            tmpFile.renameSync(targetFile.path);
            return AlbumLoadSuccess(
              recoveredAlbum,
              directoryPath: albumDir.path,
            );
          }
        } catch (_) {}
      }

      return AlbumLoadCorrupted(
        albumName: folderName,
        directoryPath: albumDir.path,
        error: e,
        stackTrace: st,
        rawContent: content,
      );
    }
  }

  /// Scans and loads all albums from `<baseDir>/albums/`.
  /// Corrupted albums are safely captured without aborting the load of others.
  Future<List<AlbumLoadResult>> loadAllAlbums() async {
    final root = await albumsDirectory;
    if (!root.existsSync()) return const [];

    final results = <AlbumLoadResult>[];
    final entities = root.listSync(followLinks: false);

    for (final entity in entities) {
      if (entity is Directory) {
        final result = await loadAlbumFromDirectory(entity);
        results.add(result);
      }
    }

    // Sort alphabetically by album name (case and accent insensitive)
    results.sort((a, b) {
      return a.albumName.toLowerCase().compareTo(b.albumName.toLowerCase());
    });

    return results;
  }

  /// Deletes an album folder and all its contents recursively.
  Future<void> deleteAlbum(String albumName) async {
    final albumDir = await getAlbumDirectory(albumName);
    if (albumDir.existsSync()) {
      albumDir.deleteSync(recursive: true);
    }
  }

  /// Duplicates an album folder on disk with a new unique album ID and name.
  Future<Album> duplicateAlbum(
    String sourceAlbumName, {
    String? targetAlbumName,
  }) async {
    final sourceDir = await getAlbumDirectory(sourceAlbumName);
    if (!sourceDir.existsSync()) {
      throw FileSystemException(
        'Source album folder does not exist',
        sourceDir.path,
      );
    }

    final loadResult = await loadAlbumFromDirectory(sourceDir);
    if (loadResult is! AlbumLoadSuccess) {
      throw StateError('Cannot duplicate corrupted album "$sourceAlbumName".');
    }

    final sourceAlbum = loadResult.album;
    final newName =
        targetAlbumName ?? await _generateUniqueDuplicateName(sourceAlbum.name);

    final newDir = await getAlbumDirectory(newName);
    if (newDir.existsSync()) {
      throw StateError('An album with name "$newName" already exists.');
    }

    newDir.createSync(recursive: true);

    // Copy all contents (images, cover, etc.) except album.json and album.json.tmp
    for (final entity in sourceDir.listSync(recursive: true)) {
      final relativePath = p.relative(entity.path, from: sourceDir.path);
      final destPath = p.join(newDir.path, relativePath);

      if (relativePath == albumFileName || relativePath == albumTmpFileName) {
        continue;
      }

      if (entity is Directory) {
        Directory(destPath).createSync(recursive: true);
      } else if (entity is File) {
        Directory(p.dirname(destPath)).createSync(recursive: true);
        entity.copySync(destPath);
      }
    }

    // Create cloned album instance with new ID and timestamps
    final duplicatedAlbum = sourceAlbum.copyWith(
      id: null, // triggers new UUID generation
      name: newName,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await saveAlbum(duplicatedAlbum);
    return duplicatedAlbum;
  }

  /// Renames an album folder and updates its `album.json`.
  Future<Album> renameAlbum(String oldName, String newName) async {
    final trimmedNewName = newName.trim();
    if (!Album.isValidName(trimmedNewName)) {
      throw ArgumentError.value(
        trimmedNewName,
        'newName',
        'Invalid album name',
      );
    }

    final loadResult = await loadAlbum(oldName);
    if (loadResult is! AlbumLoadSuccess) {
      throw StateError(
        'Cannot rename non-existent or corrupted album "$oldName".',
      );
    }

    if (oldName.toLowerCase() != trimmedNewName.toLowerCase()) {
      final alreadyExists = await albumExists(trimmedNewName);
      if (alreadyExists) {
        throw StateError(
          'An album with name "$trimmedNewName" already exists.',
        );
      }
    }

    final updatedAlbum = loadResult.album.copyWith(
      name: trimmedNewName,
      updatedAt: DateTime.now().toUtc(),
    );

    await saveAlbum(updatedAlbum, previousName: oldName);
    return updatedAlbum;
  }

  Future<String> _generateUniqueDuplicateName(String originalName) async {
    var candidate = '$originalName (copie)';
    var counter = 2;
    while (await albumExists(candidate)) {
      candidate = '$originalName (copie $counter)';
      counter++;
    }
    return candidate;
  }

  /// Analyzes the album directory to compute disk space, enumerate files,
  /// and identify unreferenced (orphan) images and dangling tmp files.
  Future<AlbumDiskSpaceInfo> getAlbumDiskSpaceInfo(String albumName) async {
    final albumDir = await getAlbumDirectory(albumName);
    if (!albumDir.existsSync()) {
      throw FileSystemException('Album directory not found', albumDir.path);
    }

    final loadResult = await loadAlbumFromDirectory(albumDir);
    final Album? validAlbum = loadResult.albumOrNull;

    final referencedRelativePaths = <String>{};
    if (validAlbum != null) {
      if (validAlbum.coverPath != null) {
        referencedRelativePaths.add(validAlbum.coverPath!);
      }
      // Add cover.jpg as naturally referenced if it exists and is used implicitly
      referencedRelativePaths.add('cover.jpg');

      for (final slide in validAlbum.slides) {
        if (slide.image != null && slide.image!.isInternal) {
          // Internal paths are typically stored as 'images/file.jpg'
          referencedRelativePaths.add(slide.image!.path.replaceAll('\\', '/'));
        }
      }
    }

    int totalBytes = 0;
    int imageCount = 0;
    int orphanBytes = 0;
    int orphanCount = 0;
    final files = <AlbumFileItem>[];

    for (final entity in albumDir.listSync(recursive: true)) {
      if (entity is File) {
        final relativePath = p
            .relative(entity.path, from: albumDir.path)
            .replaceAll('\\', '/');
        final size = entity.lengthSync();
        totalBytes += size;

        bool isImage = false;
        bool isOrphan = false;

        final isTmpFile = relativePath.endsWith('.tmp');

        if (relativePath.startsWith('$imagesFolderName/')) {
          isImage = true;
          imageCount++;
          if (!referencedRelativePaths.contains(relativePath)) {
            isOrphan = true;
          }
        } else if (isTmpFile) {
          isOrphan = true; // dangling tmp files are orphans
        }

        if (isOrphan) {
          orphanBytes += size;
          orphanCount++;
        }

        files.add(
          AlbumFileItem(
            path: entity.path,
            name: p.basename(entity.path),
            sizeInBytes: size,
            isImage: isImage,
            isOrphan: isOrphan,
          ),
        );
      }
    }

    return AlbumDiskSpaceInfo(
      albumName: albumName,
      totalBytes: totalBytes,
      imageCount: imageCount,
      orphanBytes: orphanBytes,
      orphanCount: orphanCount,
      files: files,
    );
  }

  /// Purges all unreferenced image files and dangling tmp files from the album directory,
  /// and detaches broken pin links.
  Future<AlbumDiskSpaceInfo> purgeOrphanFiles(String albumName) async {
    final info = await getAlbumDiskSpaceInfo(albumName);

    // 1. Delete physical orphan files
    for (final fileItem in info.files) {
      if (fileItem.isOrphan) {
        try {
          File(fileItem.path).deleteSync();
        } catch (e) {
          developer.log(
            'Failed to delete orphan file: ${fileItem.path}',
            error: e,
          );
        }
      }
    }

    // 2. Clean up broken pin links internally
    final loadResult = await loadAlbum(albumName);
    if (loadResult is AlbumLoadSuccess) {
      final cleanedAlbum = loadResult.album.cleanOrphanPins();
      // Only save if it actually modified the album
      if (cleanedAlbum != loadResult.album) {
        await saveAlbum(cleanedAlbum, previousName: albumName);
      }
    }

    // Return the updated state
    return await getAlbumDiskSpaceInfo(albumName);
  }
}
