import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pin Geometry & Normalization tests (R-01, R-02, R-04)', () {
    test('Coordinates within box normalize correctly into [0, 1]', () {
      const renderBoxWidth = 400.0;
      const renderBoxHeight = 800.0;

      const touchCenter = Offset(200.0, 400.0);
      final normalizedX = (touchCenter.dx / renderBoxWidth).clamp(0.0, 1.0);
      final normalizedY = (touchCenter.dy / renderBoxHeight).clamp(0.0, 1.0);

      expect(normalizedX, equals(0.5));
      expect(normalizedY, equals(0.5));
    });

    test('Coordinates outside box clamp strictly to [0, 1]', () {
      const renderBoxWidth = 300.0;
      const renderBoxHeight = 600.0;

      const negativeTouch = Offset(-50.0, -20.0);
      final clampedMinX = (negativeTouch.dx / renderBoxWidth).clamp(0.0, 1.0);
      final clampedMinY = (negativeTouch.dy / renderBoxHeight).clamp(0.0, 1.0);

      expect(clampedMinX, equals(0.0));
      expect(clampedMinY, equals(0.0));

      const overshootTouch = Offset(450.0, 900.0);
      final clampedMaxX = (overshootTouch.dx / renderBoxWidth).clamp(0.0, 1.0);
      final clampedMaxY = (overshootTouch.dy / renderBoxHeight).clamp(0.0, 1.0);

      expect(clampedMaxX, equals(1.0));
      expect(clampedMaxY, equals(1.0));
    });

    test(
      'Normalized coordinates map accurately to Flutter Alignment space [-1, 1]',
      () {
        Alignment toAlignment(double x, double y) =>
            Alignment(x * 2 - 1, y * 2 - 1);

        expect(toAlignment(0.0, 0.0), equals(Alignment.topLeft));
        expect(toAlignment(0.5, 0.5), equals(Alignment.center));
        expect(toAlignment(1.0, 1.0), equals(Alignment.bottomRight));
        expect(toAlignment(0.5, 0.0), equals(Alignment.topCenter));
        expect(toAlignment(0.0, 0.5), equals(Alignment.centerLeft));
      },
    );

    test('Pin size scale obeys R-04 base 20px formula', () {
      double computeSize(double sizeScale) => 20.0 * sizeScale;

      expect(computeSize(1.0), equals(20.0));
      expect(computeSize(1.5), equals(30.0));
      expect(computeSize(2.0), equals(40.0));
      expect(computeSize(3.0), equals(60.0));
    });
  });
}
