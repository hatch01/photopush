import 'package:flutter_test/flutter_test.dart';
import 'package:photopush/models/models.dart';

void main() {
  group('Pin', () {
    test('creates pin with clamped coordinates and valid size', () {
      final pin = Pin(
        id: 'pin-123',
        x: -0.5,
        y: 1.5,
        size: 4.0,
        color: PinColor.blue,
        text: 'Hello Pin',
      );

      expect(pin.id, 'pin-123');
      expect(pin.x, 0.0);
      expect(pin.y, 1.0);
      expect(pin.size, 3.0);
      expect(pin.color, PinColor.blue);
      expect(pin.type, PinType.info);
      expect(pin.hasText, isTrue);
      expect(pin.hasLink, isFalse);
    });

    test('infers pin type correctly based on text and targetSlideId', () {
      final infoPin = Pin(x: 0.1, y: 0.2, text: 'Some text');
      expect(infoPin.type, PinType.info);
      expect(infoPin.hasText, isTrue);
      expect(infoPin.hasLink, isFalse);

      final linkPin = Pin(x: 0.1, y: 0.2, targetSlideId: 'slide-target');
      expect(linkPin.type, PinType.link);
      expect(linkPin.hasText, isFalse);
      expect(linkPin.hasLink, isTrue);

      final bothPin = Pin(
        x: 0.1,
        y: 0.2,
        text: 'Some text',
        targetSlideId: 'slide-target',
      );
      expect(bothPin.type, PinType.both);
      expect(bothPin.hasText, isTrue);
      expect(bothPin.hasLink, isTrue);
    });

    test('throws ArgumentError on NaN or infinite coordinates', () {
      expect(() => Pin(x: double.nan, y: 0.5), throwsArgumentError);
      expect(() => Pin(x: 0.5, y: double.infinity), throwsArgumentError);
    });

    test('serializes and deserializes cleanly (round-trip)', () {
      final original = Pin(
        id: 'pin-456',
        x: 0.354,
        y: 0.789,
        size: 2.5,
        color: PinColor.purple,
        type: PinType.both,
        text: 'Beautiful view from the peak',
        targetSlideId: 'slide-mountain-view',
      );

      final json = original.toJson();
      final reconstructed = Pin.fromJson(json);

      expect(reconstructed, equals(original));
      expect(reconstructed.id, original.id);
      expect(reconstructed.x, original.x);
      expect(reconstructed.y, original.y);
      expect(reconstructed.size, original.size);
      expect(reconstructed.color, original.color);
      expect(reconstructed.type, original.type);
      expect(reconstructed.text, original.text);
      expect(reconstructed.targetSlideId, original.targetSlideId);
    });

    test(
      'PinColor parses names and French labels and falls back gracefully',
      () {
        expect(PinColor.fromString('black'), PinColor.black);
        expect(PinColor.fromString('noir'), PinColor.black);
        expect(PinColor.fromString('green'), PinColor.green);
        expect(PinColor.fromString('vert'), PinColor.green);
        expect(PinColor.fromString('unknown_color'), PinColor.yellow);
        expect(PinColor.fromString(null), PinColor.yellow);
      },
    );

    test('copyWith updates fields as expected', () {
      final pin = Pin(x: 0.2, y: 0.3, text: 'Original');
      final updated = pin.copyWith(text: 'Updated', color: PinColor.green);

      expect(updated.text, 'Updated');
      expect(updated.color, PinColor.green);
      expect(updated.x, pin.x);
      expect(updated.id, pin.id);
    });

    test('copyWith allows clearing text and targetSlideId with null', () {
      final pin = Pin(x: 0.1, y: 0.2, text: 'Text', targetSlideId: 'target');
      final updated = pin.copyWith(text: null, targetSlideId: null);

      expect(updated.text, isNull);
      expect(updated.targetSlideId, isNull);
    });
  });
}
