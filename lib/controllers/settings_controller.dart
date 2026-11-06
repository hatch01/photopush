import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Manages the application settings and persists them using [SharedPreferences].
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs);

  final SharedPreferences _prefs;

  // Keys for SharedPreferences
  static const _themeModeKey = 'theme_mode';
  static const _defaultPinColorKey = 'default_pin_color';
  static const _defaultPinSizeKey = 'default_pin_size';
  static const _defaultImageStorageKey = 'default_image_storage';
  static const _autoSaveEnabledKey = 'auto_save_enabled';

  // State properties
  late ThemeMode _themeMode;
  late PinColor _defaultPinColor;
  late double _defaultPinSize;
  late ImageStorageType _defaultImageStorage;
  late bool _autoSaveEnabled;

  /// Loads the initial settings from disk.
  Future<void> loadSettings() async {
    // Load ThemeMode (0: system, 1: light, 2: dark)
    // Default to dark as per CDC recommendation
    final themeIndex = _prefs.getInt(_themeModeKey) ?? ThemeMode.dark.index;
    _themeMode = ThemeMode.values.elementAt(
      themeIndex.clamp(0, ThemeMode.values.length - 1),
    );

    // Load Pin preferences
    final colorStr = _prefs.getString(_defaultPinColorKey);
    _defaultPinColor = PinColor.fromString(colorStr); // Defaults to yellow

    _defaultPinSize = _prefs.getDouble(_defaultPinSizeKey) ?? 1.5;

    // Load Storage preferences
    final storageStr = _prefs.getString(_defaultImageStorageKey);
    _defaultImageStorage = ImageStorageType.fromString(
      storageStr,
    ); // Defaults to internal

    // Load AutoSave
    _autoSaveEnabled = _prefs.getBool(_autoSaveEnabledKey) ?? true;

    notifyListeners();
  }

  // Getters
  ThemeMode get themeMode => _themeMode;
  PinColor get defaultPinColor => _defaultPinColor;
  double get defaultPinSize => _defaultPinSize;
  ImageStorageType get defaultImageStorage => _defaultImageStorage;
  bool get autoSaveEnabled => _autoSaveEnabled;

  // Setters
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _prefs.setInt(_themeModeKey, newThemeMode.index);
  }

  Future<void> updateDefaultPinColor(PinColor? newColor) async {
    if (newColor == null || newColor == _defaultPinColor) return;
    _defaultPinColor = newColor;
    notifyListeners();
    await _prefs.setString(_defaultPinColorKey, newColor.name);
  }

  Future<void> updateDefaultPinSize(double? newSize) async {
    if (newSize == null || newSize == _defaultPinSize) return;
    _defaultPinSize = newSize;
    notifyListeners();
    await _prefs.setDouble(_defaultPinSizeKey, newSize);
  }

  Future<void> updateDefaultImageStorage(ImageStorageType? newStorage) async {
    if (newStorage == null || newStorage == _defaultImageStorage) return;
    _defaultImageStorage = newStorage;
    notifyListeners();
    await _prefs.setString(_defaultImageStorageKey, newStorage.value);
  }

  Future<void> updateAutoSaveEnabled(bool? enabled) async {
    if (enabled == null || enabled == _autoSaveEnabled) return;
    _autoSaveEnabled = enabled;
    notifyListeners();
    await _prefs.setBool(_autoSaveEnabledKey, enabled);
  }
}
