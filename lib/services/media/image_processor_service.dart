import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Service responsible for resizing and saving images within constraints (<= 2048 px).
class ImageProcessorService {
  const ImageProcessorService();

  static const int defaultMaxLongEdge = 2048;
  static const int defaultCoverDimension = 400;

  /// Optimizes and copies an image to the album's `images/` folder.
  /// If width or height exceeds [maxLongEdge], the image is downscaled proportionally.
  Future<File> processAndSaveImage({
    required File sourceFile,
    required Directory targetImagesDir,
    int maxLongEdge = defaultMaxLongEdge,
    String? preferredFileName,
  }) async {
    if (!targetImagesDir.existsSync()) {
      targetImagesDir.createSync(recursive: true);
    }

    final bytes = sourceFile.readAsBytesSync();
    final decoded = img.decodeImage(bytes);

    final String fileName = preferredFileName ?? 'img_${const Uuid().v4()}.jpg';
    final targetFile = File(p.join(targetImagesDir.path, fileName));

    if (decoded == null) {
      // If image decoding fails, copy source bytes directly as fallback
      sourceFile.copySync(targetFile.path);
      return targetFile;
    }

    img.Image processed = decoded;

    // Check if downscale is needed
    if (decoded.width > maxLongEdge || decoded.height > maxLongEdge) {
      if (decoded.width >= decoded.height) {
        processed = img.copyResize(decoded, width: maxLongEdge);
      } else {
        processed = img.copyResize(decoded, height: maxLongEdge);
      }
    }

    final encoded = img.encodeJpg(processed, quality: 85);
    targetFile.writeAsBytesSync(encoded, flush: true);
    return targetFile;
  }

  /// Generates the album cover thumbnail (`cover.jpg`) from a source photo file.
  Future<File> generateCoverThumbnail({
    required File photoFile,
    required Directory albumDir,
    int maxDimension = defaultCoverDimension,
  }) async {
    if (!albumDir.existsSync()) {
      albumDir.createSync(recursive: true);
    }

    final bytes = photoFile.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    final targetFile = File(p.join(albumDir.path, 'cover.jpg'));

    if (decoded == null) {
      photoFile.copySync(targetFile.path);
      return targetFile;
    }

    img.Image thumbnail = decoded;
    if (decoded.width > maxDimension || decoded.height > maxDimension) {
      if (decoded.width >= decoded.height) {
        thumbnail = img.copyResize(decoded, width: maxDimension);
      } else {
        thumbnail = img.copyResize(decoded, height: maxDimension);
      }
    }

    final encoded = img.encodeJpg(thumbnail, quality: 80);
    targetFile.writeAsBytesSync(encoded, flush: true);
    return targetFile;
  }
}
