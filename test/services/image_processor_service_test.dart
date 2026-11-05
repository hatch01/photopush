import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:photopush/services/services.dart';

void main() {
  group('ImageProcessorService', () {
    late Directory tempDir;
    const processor = ImageProcessorService();

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('img_proc_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    File createTestImageFile(String name, int width, int height) {
      final image = img.Image(width: width, height: height);
      // Fill with solid color
      img.fill(image, color: img.ColorRgb8(100, 150, 200));
      final bytes = img.encodeJpg(image);
      final file = File(p.join(tempDir.path, name));
      file.writeAsBytesSync(bytes);
      return file;
    }

    test('downscales large image exceeding 2048px on long edge', () async {
      final largeImage = createTestImageFile('large.jpg', 3000, 1500);
      final targetDir = Directory(p.join(tempDir.path, 'images'));

      final processed = await processor.processAndSaveImage(
        sourceFile: largeImage,
        targetImagesDir: targetDir,
        maxLongEdge: 2048,
      );

      expect(processed.existsSync(), isTrue);

      final decoded = img.decodeImage(processed.readAsBytesSync());
      expect(decoded, isNotNull);
      expect(decoded!.width, 2048);
      expect(decoded.height, 1024);
    });

    test('preserves dimensions when image is already within 2048px', () async {
      final smallImage = createTestImageFile('small.jpg', 800, 600);
      final targetDir = Directory(p.join(tempDir.path, 'images'));

      final processed = await processor.processAndSaveImage(
        sourceFile: smallImage,
        targetImagesDir: targetDir,
        maxLongEdge: 2048,
      );

      expect(processed.existsSync(), isTrue);

      final decoded = img.decodeImage(processed.readAsBytesSync());
      expect(decoded, isNotNull);
      expect(decoded!.width, 800);
      expect(decoded.height, 600);
    });

    test('generates cover thumbnail with max dimension 400px', () async {
      final photo = createTestImageFile('photo.jpg', 1600, 1200);

      final cover = await processor.generateCoverThumbnail(
        photoFile: photo,
        albumDir: tempDir,
        maxDimension: 400,
      );

      expect(cover.existsSync(), isTrue);
      expect(p.basename(cover.path), 'cover.jpg');

      final decoded = img.decodeImage(cover.readAsBytesSync());
      expect(decoded, isNotNull);
      expect(decoded!.width, 400);
      expect(decoded.height, 300);
    });
  });
}
