import 'package:flutter/foundation.dart';

/// Represents a single file inside an album's directory.
@immutable
class AlbumFileItem {
  const AlbumFileItem({
    required this.path,
    required this.name,
    required this.sizeInBytes,
    required this.isImage,
    required this.isOrphan,
  });

  /// The absolute file path.
  final String path;

  /// The base name of the file (e.g., 'photo_001.jpg').
  final String name;

  /// The file size in bytes.
  final int sizeInBytes;

  /// Whether this file is stored in the `images/` directory.
  final bool isImage;

  /// Whether this image file is NOT referenced by the album's JSON.
  final bool isOrphan;
}

/// Represents the breakdown of disk space and files for an album.
@immutable
class AlbumDiskSpaceInfo {
  const AlbumDiskSpaceInfo({
    required this.albumName,
    required this.totalBytes,
    required this.imageCount,
    required this.orphanBytes,
    required this.orphanCount,
    required this.files,
  });

  /// Name of the album this info belongs to.
  final String albumName;

  /// Total disk space consumed by the entire album directory.
  final int totalBytes;

  /// Number of image files in the `images/` folder.
  final int imageCount;

  /// Disk space consumed by unreferenced orphan images and `.tmp` files.
  final int orphanBytes;

  /// Number of orphan files.
  final int orphanCount;

  /// Detailed list of files in the album.
  final List<AlbumFileItem> files;
}
