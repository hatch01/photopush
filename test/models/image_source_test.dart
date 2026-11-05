import 'package:flutter_test/flutter_test.dart';
import 'package:photopush/models/models.dart';

void main() {
  group('ImageSource', () {
    test('internal storage image source behaves correctly', () {
      const source = ImageSource(
        storageType: ImageStorageType.internal,
        path: 'images/photo_001.jpg',
        originalFileName: 'IMG_20261015.jpg',
        fileSize: 1048576,
      );

      expect(source.isInternal, isTrue);
      expect(source.isGallery, isFalse);
      expect(source.path, 'images/photo_001.jpg');
      expect(source.fileSize, 1048576);

      final json = source.toJson();
      final fromJson = ImageSource.fromJson(json);

      expect(fromJson, equals(source));
    });

    test('gallery storage image source behaves correctly', () {
      const source = ImageSource(
        storageType: ImageStorageType.gallery,
        path: 'content://media/external/images/media/42',
      );

      expect(source.isInternal, isFalse);
      expect(source.isGallery, isTrue);

      final json = source.toJson();
      final fromJson = ImageSource.fromJson(json);

      expect(fromJson, equals(source));
    });

    test(
      'ImageStorageType parses case-insensitively and falls back to internal',
      () {
        expect(
          ImageStorageType.fromString('internal'),
          ImageStorageType.internal,
        );
        expect(
          ImageStorageType.fromString('gallery'),
          ImageStorageType.gallery,
        );
        expect(
          ImageStorageType.fromString('GALLERY'),
          ImageStorageType.gallery,
        );
        expect(
          ImageStorageType.fromString('invalid'),
          ImageStorageType.internal,
        );
        expect(ImageStorageType.fromString(null), ImageStorageType.internal);
      },
    );
  });
}
