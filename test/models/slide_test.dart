import 'package:flutter_test/flutter_test.dart';
import 'package:photopush/models/models.dart';

void main() {
  group('Slide', () {
    test('creates photo slide with pins and enforces title limits', () {
      final pin = Pin(id: 'pin-1', x: 0.2, y: 0.3, text: 'Point 1');
      const longTitle =
          'This title is intentionally way too long for a single slide title limit';
      final slide = Slide(
        id: 'slide-1',
        type: SlideType.photo,
        title: longTitle,
        comment: 'Nice day',
        image: const ImageSource(
          storageType: ImageStorageType.internal,
          path: 'images/001.jpg',
        ),
        pins: [pin],
      );

      expect(slide.id, 'slide-1');
      expect(slide.isPhoto, isTrue);
      expect(slide.isComment, isFalse);
      expect(slide.title.length, 40);
      expect(slide.hasImage, isTrue);
      expect(slide.hasPins, isTrue);
      expect(slide.hasComment, isTrue);
      expect(slide.pins.length, 1);
    });

    test('creates comment slide without image', () {
      final slide = Slide(
        id: 'slide-comment',
        type: SlideType.comment,
        title: 'Notes',
        comment: 'Full text comment here',
      );

      expect(slide.isComment, isTrue);
      expect(slide.isPhoto, isFalse);
      expect(slide.hasImage, isFalse);
      expect(slide.hasPins, isFalse);
      expect(slide.hasComment, isTrue);
    });

    test('serializes and deserializes cleanly (round-trip)', () {
      final original = Slide(
        id: 'slide-trip',
        type: SlideType.photo,
        title: 'Summit',
        comment: 'Reached after 4 hours',
        image: const ImageSource(
          storageType: ImageStorageType.internal,
          path: 'images/summit.jpg',
        ),
        pins: [Pin(id: 'p1', x: 0.5, y: 0.5, text: 'Summit flag')],
      );

      final json = original.toJson();
      final fromJson = Slide.fromJson(json);

      expect(fromJson, equals(original));
      expect(fromJson.pins.first, equals(original.pins.first));
    });

    test('pins list is immutable', () {
      final pin = Pin(x: 0.1, y: 0.2);
      final slide = Slide(pins: [pin]);

      expect(() => slide.pins.add(Pin(x: 0.3, y: 0.4)), throwsUnsupportedError);
    });

    test('copyWith allows clearing comment and image with null', () {
      final slide = Slide(
        title: 'Title',
        comment: 'Comment to clear',
        image: const ImageSource(
          storageType: ImageStorageType.internal,
          path: 'images/001.jpg',
        ),
      );

      final updated = slide.copyWith(comment: null, image: null);
      expect(updated.comment, isNull);
      expect(updated.image, isNull);
      expect(updated.title, 'Title');
    });
  });
}
