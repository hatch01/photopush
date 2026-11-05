import 'package:flutter/foundation.dart';

/// Storage strategy for an image.
enum ImageStorageType {
  /// Copied inside the album directory under `images/`.
  internal('internal'),

  /// Directly linked from the device's system gallery.
  gallery('gallery');

  const ImageStorageType(this.value);

  final String value;

  static ImageStorageType fromString(String? value) {
    if (value == null) return ImageStorageType.internal;
    final normalized = value.trim().toLowerCase();
    for (final type in ImageStorageType.values) {
      if (type.value == normalized) {
        return type;
      }
    }
    return ImageStorageType.internal;
  }
}

/// Represents the source of an image used by a slide.
@immutable
class ImageSource {
  const ImageSource({
    required this.storageType,
    required this.path,
    this.originalFileName,
    this.fileSize,
  });

  /// Storage location type (copied in app directory or linked to gallery).
  final ImageStorageType storageType;

  /// Relative path inside album (e.g. 'images/photo_001.jpg') or gallery URI/ID.
  final String path;

  /// Original file name before import (optional).
  final String? originalFileName;

  /// File size in bytes (optional, useful for delta comparison).
  final int? fileSize;

  /// Whether this image is copied inside the album directory.
  bool get isInternal => storageType == ImageStorageType.internal;

  /// Whether this image is linked to the external gallery.
  bool get isGallery => storageType == ImageStorageType.gallery;

  ImageSource copyWith({
    ImageStorageType? storageType,
    String? path,
    String? originalFileName,
    int? fileSize,
  }) {
    return ImageSource(
      storageType: storageType ?? this.storageType,
      path: path ?? this.path,
      originalFileName: originalFileName ?? this.originalFileName,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storageType': storageType.value,
      'path': path,
      if (originalFileName != null) 'originalFileName': originalFileName,
      if (fileSize != null) 'fileSize': fileSize,
    };
  }

  factory ImageSource.fromJson(Map<String, dynamic> json) {
    return ImageSource(
      storageType: ImageStorageType.fromString(json['storageType'] as String?),
      path: json['path'] as String? ?? '',
      originalFileName: json['originalFileName'] as String?,
      fileSize: json['fileSize'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageSource &&
          runtimeType == other.runtimeType &&
          storageType == other.storageType &&
          path == other.path &&
          originalFileName == other.originalFileName &&
          fileSize == other.fileSize;

  @override
  int get hashCode =>
      Object.hash(storageType, path, originalFileName, fileSize);

  @override
  String toString() =>
      'ImageSource(type: ${storageType.value}, path: $path, size: $fileSize)';
}
