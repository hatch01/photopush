import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/albums_controller.dart';
import 'controllers/settings_controller.dart';
import 'ui/screens/albums_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final settingsController = SettingsController(prefs);
  await settingsController.loadSettings();

  runApp(PhotoPushApp(settingsController: settingsController));
}

class PhotoPushApp extends StatelessWidget {
  const PhotoPushApp({
    super.key,
    required this.settingsController,
    this.controller,
  });

  final SettingsController settingsController;
  final AlbumsController? controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return MaterialApp(
          title: 'PhotoPush',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F4E79),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F4E79),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: settingsController.themeMode,
          home: AlbumsListScreen(
            controller: controller,
            settingsController: settingsController,
          ),
        );
      },
    );
  }
}
