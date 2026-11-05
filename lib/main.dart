import 'package:flutter/material.dart';

import 'controllers/albums_controller.dart';
import 'ui/screens/albums_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PhotoPushApp());
}

class PhotoPushApp extends StatelessWidget {
  const PhotoPushApp({super.key, this.controller});

  final AlbumsController? controller;

  @override
  Widget build(BuildContext context) {
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
      themeMode: ThemeMode.dark,
      home: AlbumsListScreen(controller: controller),
    );
  }
}
