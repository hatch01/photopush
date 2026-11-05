import 'package:flutter_test/flutter_test.dart';
import 'package:photopush/models/models.dart';

void main() {
  group('Album', () {
    test('creates album with valid name and default version', () {
      final album = Album(
        name: 'Mon Voyage en Islande',
        coverPath: 'cover.jpg',
      );

      expect(album.version, 1);
      expect(album.name, 'Mon Voyage en Islande');
      expect(album.coverPath, 'cover.jpg');
      expect(album.isEmpty, isTrue);
      expect(album.slideCount, 0);
      expect(album.firstSlide, isNull);
    });

    test('validates album name constraints', () {
      expect(Album.isValidName('Voyage 2026'), isTrue);
      expect(Album.isValidName(''), isFalse);
      expect(Album.isValidName('   '), isFalse);
      expect(Album.isValidName('A' * 81), isFalse);
      expect(Album.isValidName('A' * 80), isTrue);

      // Forbidden filesystem characters
      expect(Album.isValidName('Voyage/2026'), isFalse);
      expect(Album.isValidName(r'Voyage\2026'), isFalse);
      expect(Album.isValidName('Voyage:2026'), isFalse);
      expect(Album.isValidName('Voyage*2026'), isFalse);
      expect(Album.isValidName('Voyage?2026'), isFalse);
      expect(Album.isValidName('Voyage"2026'), isFalse);
      expect(Album.isValidName('Voyage<2026'), isFalse);
      expect(Album.isValidName('Voyage>2026'), isFalse);
      expect(Album.isValidName('Voyage|2026'), isFalse);
    });

    test('sanitizes album name', () {
      expect(
        Album.sanitizeName('  Mon / Beau : Voyage * 2026 ?  '),
        'Mon  Beau  Voyage  2026',
      );
    });

    test('throws ArgumentError on invalid album name instantiation', () {
      expect(() => Album(name: ''), throwsArgumentError);
      expect(() => Album(name: 'A' * 85), throwsArgumentError);
      expect(() => Album(name: 'Invalid/Name'), throwsArgumentError);
    });

    test('serializes and deserializes full album with slides and pins (round-trip)', () {
      final pin1 = Pin(
        id: 'p1',
        x: 0.25,
        y: 0.75,
        size: 1.5,
        color: PinColor.yellow,
        type: PinType.both,
        text: 'Chalet',
        targetSlideId: 'slide-2',
      );

      final slide1 = Slide(
        id: 'slide-1',
        type: SlideType.photo,
        title: 'Vue d ensemble',
        comment: 'Jour 1',
        image: const ImageSource(
          storageType: ImageStorageType.internal,
          path: 'images/p1.jpg',
        ),
        pins: [pin1],
      );

      final slide2 = Slide(
        id: 'slide-2',
        type: SlideType.comment,
        title: 'Chalet interieur',
        comment: 'Tres chaleureux',
      );

      final originalAlbum = Album(
        id: 'album-island',
        name: 'Islande 2026',
        createdAt: DateTime.utc(2026, 10, 15, 12, 0, 0),
        updatedAt: DateTime.utc(2026, 10, 15, 14, 30, 0),
        coverPath: 'cover.jpg',
        slides: [slide1, slide2],
      );

      final json = originalAlbum.toJson();
      final reconstructed = Album.fromJson(json);

      expect(reconstructed, equals(originalAlbum));
      expect(reconstructed.id, originalAlbum.id);
      expect(reconstructed.name, originalAlbum.name);
      expect(reconstructed.version, 1);
      expect(reconstructed.slideCount, 2);
      expect(reconstructed.findSlideById('slide-1'), equals(slide1));
      expect(reconstructed.findSlideById('slide-2'), equals(slide2));
      expect(reconstructed.findSlideById('non-existent'), isNull);
      expect(reconstructed.getSlideIndex('slide-1'), 0);
      expect(reconstructed.getSlideIndex('slide-2'), 1);
      expect(reconstructed.getSlideIndex('non-existent'), -1);
    });

    test('validate detects missing images and orphan pin links', () {
      final orphanPin = Pin(
        id: 'p-orphan',
        x: 0.5,
        y: 0.5,
        type: PinType.link,
        targetSlideId: 'missing-slide-id',
      );

      final slideWithOrphanPin = Slide(
        id: 's1',
        type: SlideType.photo,
        title: 'Slide 1',
        image: const ImageSource(
          storageType: ImageStorageType.internal,
          path: 'images/s1.jpg',
        ),
        pins: [orphanPin],
      );

      final photoSlideWithoutImage = Slide(
        id: 's2',
        type: SlideType.photo,
        title: 'Slide 2 No Image',
      );

      final album = Album(
        name: 'Test Diagnostics',
        slides: [slideWithOrphanPin, photoSlideWithoutImage],
      );

      final issues = album.validate();
      expect(issues.length, 2);
      expect(
        issues.any((msg) => msg.contains('marked as photo but has no image')),
        isTrue,
      );
      expect(
        issues.any((msg) => msg.contains('points to non-existent target')),
        isTrue,
      );
    });
    test('cleanOrphanPins detaches broken links', () {
      final orphanPin = Pin(
        id: 'p-orphan',
        x: 0.5,
        y: 0.5,
        text: 'Keep my text',
        type: PinType.both,
        targetSlideId: 'missing-slide-id',
      );

      final slide = Slide(
        id: 's1',
        type: SlideType.photo,
        image: const ImageSource(
          storageType: ImageStorageType.internal,
          path: 'images/s1.jpg',
        ),
        pins: [orphanPin],
      );

      final album = Album(name: 'Cleaning Test', slides: [slide]);

      expect(album.validate().isNotEmpty, isTrue);

      final cleanedAlbum = album.cleanOrphanPins();
      final cleanedPin = cleanedAlbum.slides.first.pins.first;

      expect(cleanedPin.targetSlideId, isNull);
      expect(cleanedPin.hasLink, isFalse);
      expect(cleanedPin.hasText, isTrue);
      expect(cleanedPin.text, 'Keep my text');
      expect(cleanedAlbum.validate(), isEmpty);
    });

    test('copyWith allows clearing coverPath with null', () {
      final album = Album(name: 'Island', coverPath: 'cover.jpg');
      final updated = album.copyWith(coverPath: null);

      expect(updated.coverPath, isNull);
      expect(updated.name, 'Island');
    });
  });
}
