import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopush/controllers/albums_controller.dart';
import 'package:photopush/controllers/settings_controller.dart';
import 'package:photopush/main.dart';
import 'package:photopush/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('PhotoPushApp initial smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsController = SettingsController(prefs);
    await settingsController.loadSettings();

    final tempDir = Directory.systemTemp.createTempSync(
      'photopush_smoke_test_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final controller = AlbumsController(
      storageService: AlbumStorageService(
        baseDirectoryResolver: () async => tempDir,
      ),
    );

    await controller.loadAlbums();
    await tester.pumpWidget(
      PhotoPushApp(
        controller: controller,
        settingsController: settingsController,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PhotoPush'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Aucun album photo'), findsOneWidget);
  });
}
