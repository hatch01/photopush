import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopush/controllers/settings_controller.dart';
import 'package:photopush/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsController (US-8 : Preferences & Theme)', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('loads default values if no preferences exist', () async {
      final controller = SettingsController(prefs);
      await controller.loadSettings();

      expect(
        controller.themeMode,
        ThemeMode.dark,
      ); // Default is dark based on CDC
      expect(controller.defaultPinColor, PinColor.yellow);
      expect(controller.defaultPinSize, 1.5);
      expect(controller.defaultImageStorage, ImageStorageType.internal);
      expect(controller.autoSaveEnabled, isTrue);
    });

    test('updates theme mode and persists it', () async {
      final controller = SettingsController(prefs);
      await controller.loadSettings();

      await controller.updateThemeMode(ThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);
      expect(prefs.getInt('theme_mode'), ThemeMode.light.index);
    });

    test('updates default pin color and persists it', () async {
      final controller = SettingsController(prefs);
      await controller.loadSettings();

      await controller.updateDefaultPinColor(PinColor.purple);
      expect(controller.defaultPinColor, PinColor.purple);
      expect(prefs.getString('default_pin_color'), PinColor.purple.name);
    });

    test('loads previously saved settings', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.system.index,
        'default_pin_color': 'blue',
        'default_pin_size': 2.5,
        'default_image_storage': 'gallery',
        'auto_save_enabled': false,
      });
      final populatedPrefs = await SharedPreferences.getInstance();

      final controller = SettingsController(populatedPrefs);
      await controller.loadSettings();

      expect(controller.themeMode, ThemeMode.system);
      expect(controller.defaultPinColor, PinColor.blue);
      expect(controller.defaultPinSize, 2.5);
      expect(controller.defaultImageStorage, ImageStorageType.gallery);
      expect(controller.autoSaveEnabled, isFalse);
    });
  });
}
