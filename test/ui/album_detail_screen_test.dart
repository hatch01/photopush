import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopush/controllers/album_detail_controller.dart';
import 'package:photopush/controllers/settings_controller.dart';
import 'package:photopush/models/models.dart';
import 'package:photopush/services/services.dart';
import 'package:photopush/ui/screens/album_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('US-2 : AlbumDetailScreen (Slides Viewing & Editing)', () {
    late Directory tempRootDir;
    late AlbumStorageService storageService;
    late Album album;
    late AlbumDetailController controller;
    late SettingsController settingsController;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'auto_save_enabled':
            false, // Disable auto-save timer to prevent test leaks
      });
      final prefs = await SharedPreferences.getInstance();
      settingsController = SettingsController(prefs);
      await settingsController.loadSettings();

      tempRootDir = Directory.systemTemp.createTempSync(
        'album_detail_ui_test_',
      );
      storageService = AlbumStorageService(
        baseDirectoryResolver: () async => tempRootDir,
      );
      album = Album(name: 'Mon Album Test');
      await storageService.saveAlbum(album);

      controller = AlbumDetailController(
        initialAlbum: album,
        storageService: storageService,
        settingsController: settingsController,
      );
    });

    tearDown(() {
      if (tempRootDir.existsSync()) {
        tempRootDir.deleteSync(recursive: true);
      }
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlbumDetailScreen(
            album: album,
            controller: controller,
            settingsController: settingsController,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('displays empty state when album has no slides', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(find.text('Album vide'), findsOneWidget);
      expect(find.text('Ajouter une diapositive'), findsOneWidget);
    });

    testWidgets('adds a comment slide and displays its typography', (
      tester,
    ) async {
      await pumpScreen(tester);

      // Tap "Ajouter une diapositive"
      await tester.tap(find.text('Ajouter une diapositive'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Ajouter un commentaire'), findsOneWidget);

      // Tap "Ajouter un commentaire"
      await tester.tap(find.text('Ajouter un commentaire'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Nouvelle diapositive texte'), findsOneWidget);

      // Entrer le commentaire
      await tester.enterText(
        find.widgetWithText(TextField, 'Commentaire ou récit'),
        'Magnifique coucher de soleil sur les fjords norvégiens.',
      );
      await tester.pump();

      // Valider
      await tester.tap(find.text('Ajouter'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Vérifier l'affichage du texte et du titre par défaut
      expect(find.text('Titre 1'), findsOneWidget);
      expect(
        find.text('Magnifique coucher de soleil sur les fjords norvégiens.'),
        findsOneWidget,
      );
      expect(find.text('Album vide'), findsNothing);
    });

    testWidgets('modifies current slide title', (tester) async {
      await controller.addCommentSlide(commentText: 'Un commentaire');

      await pumpScreen(tester);

      expect(find.text('Titre 1'), findsOneWidget);

      // Toucher le titre dans l'AppBar
      await tester.tap(find.text('Titre 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Modifier le titre'), findsOneWidget);

      // Remplacer le titre
      await tester.enterText(
        find.byType(TextField).last,
        'Journée Inoubliable',
      );
      await tester.pump();

      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Journée Inoubliable'), findsOneWidget);
      expect(find.text('Titre 1'), findsNothing);
    });

    testWidgets('deletes slide via AppBar action', (tester) async {
      await controller.addCommentSlide(commentText: 'Slide to delete');

      await pumpScreen(tester);

      expect(find.text('Slide to delete'), findsOneWidget);

      // Tap options menu icon (more_vert is implicitly added by PopupMenuButton if no icon is specified, but wait, I didn't specify an icon so it uses more_vert)
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap 'Supprimer' in the menu
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      expect(find.text('Supprimer la diapositive'), findsOneWidget);

      // Confirm
      await tester.tap(find.text('Supprimer').last);
      await tester.pumpAndSettle();

      expect(find.text('Slide to delete'), findsNothing);
      expect(find.text('Album vide'), findsOneWidget);
    });
  });
}
