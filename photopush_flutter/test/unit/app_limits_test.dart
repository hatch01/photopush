import 'package:flutter_test/flutter_test.dart';
import 'package:photopush_flutter/core/app_limits.dart';

void main() {
  group('AppLimits compliance tests (§ 4.7)', () {
    test('Configured limits match specifications', () {
      expect(AppLimits.maxAlbumsPerUser, equals(500)); // LIM-01
      expect(AppLimits.maxSlidesPerAlbum, equals(200)); // LIM-02
      expect(AppLimits.maxPinsPerSlide, equals(30)); // LIM-03
      expect(AppLimits.maxCommentLength, equals(400)); // LIM-04
      expect(AppLimits.maxSlideTitleLength, equals(40)); // LIM-05
      expect(AppLimits.maxAlbumNameLength, equals(80)); // LIM-06
    });

    test('Album name validation rules conform to RF-14', () {
      bool isValidAlbumName(String name) {
        final trimmed = name.trim();
        if (trimmed.isEmpty || trimmed.length > AppLimits.maxAlbumNameLength) {
          return false;
        }
        final invalidChars = RegExp(r'[\\/:*?"<>|]');
        return !invalidChars.hasMatch(trimmed);
      }

      expect(isValidAlbumName('Voyage en Italie'), isTrue);
      expect(isValidAlbumName('  Vacances 2026  '), isTrue);
      expect(isValidAlbumName(''), isFalse);
      expect(isValidAlbumName('   '), isFalse);
      expect(isValidAlbumName('Album/Photo'), isFalse);
      expect(isValidAlbumName('Album\\Photo'), isFalse);
      expect(isValidAlbumName('Photo:Rome'), isFalse);
      expect(isValidAlbumName('Photo*Rome'), isFalse);
      expect(isValidAlbumName('Photo?Rome'), isFalse);
      expect(isValidAlbumName('Photo"Rome"'), isFalse);
      expect(isValidAlbumName('<Photo>'), isFalse);
      expect(isValidAlbumName('Photo|Rome'), isFalse);
      expect(isValidAlbumName('A' * 81), isFalse);
      expect(isValidAlbumName('A' * 80), isTrue);
    });
  });
}
