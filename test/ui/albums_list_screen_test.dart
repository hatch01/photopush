import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopush/controllers/albums_controller.dart';
import 'package:photopush/services/services.dart';
import 'package:photopush/ui/screens/albums_list_screen.dart';

void main() {
  group('US-1 : AlbumsListScreen (UI & User Interactions)', () {
    late Directory tempRootDir;
    late AlbumStorageService storageService;
    late AlbumsController controller;

    setUp(() {
      tempRootDir = Directory.systemTemp.createTempSync('photopush_ui_test_');
      storageService = AlbumStorageService(
        baseDirectoryResolver: () async => tempRootDir,
      );
      controller = AlbumsController(storageService: storageService);
    });

    tearDown(() {
      if (tempRootDir.existsSync()) {
        tempRootDir.deleteSync(recursive: true);
      }
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await controller.loadAlbums();
      await tester.pumpWidget(
        MaterialApp(home: AlbumsListScreen(controller: controller)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets(
      'displays empty state with logo and action when no albums exist',
      (tester) async {
        await pumpScreen(tester);

        expect(find.text('PhotoPush'), findsOneWidget);
        expect(find.text('Aucun album photo'), findsOneWidget);
        expect(find.text('Créer un album'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets(
      'creates a new album through dialog and displays it in the list',
      (tester) async {
        await pumpScreen(tester);

        // Tap FAB "Nouvel album"
        await tester.tap(find.text('Nouvel album'));
        await tester.pumpAndSettle();

        expect(find.text('Nom de l\'album'), findsOneWidget);

        // Saisir un nom d'album
        await tester.enterText(find.byType(TextField).last, 'Islande 2026');
        await tester.pump();

        // Valider la création
        await tester.tap(find.text('Créer'));
        await tester.pumpAndSettle();

        // Vérifier que l'album est désormais affiché
        expect(find.text('Islande 2026'), findsOneWidget);
        expect(find.text('0 diapositives'), findsOneWidget);
        expect(find.text('Aucun album photo'), findsNothing);
      },
    );

    testWidgets('renames an album via context menu', (tester) async {
      await controller.createAlbum('Ancien Nom');

      await pumpScreen(tester);

      expect(find.text('Ancien Nom'), findsOneWidget);

      // Ouvrir le menu contextuel
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // Choisir "Renommer"
      await tester.tap(find.text('Renommer'));
      await tester.pumpAndSettle();

      expect(find.text('Renommer l\'album'), findsOneWidget);

      // Entrer le nouveau nom
      await tester.enterText(find.byType(TextField).last, 'Nouveau Nom');
      await tester.pump();

      await tester.tap(find.text('Renommer').last);
      await tester.pumpAndSettle();

      // Vérifier la mise à jour
      expect(find.text('Nouveau Nom'), findsOneWidget);
      expect(find.text('Ancien Nom'), findsNothing);
    });

    testWidgets('duplicates an album via context menu', (tester) async {
      await controller.createAlbum('Vacances');

      await pumpScreen(tester);

      expect(find.text('Vacances'), findsOneWidget);

      // Ouvrir menu contextuel
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // Choisir "Dupliquer"
      await tester.tap(find.text('Dupliquer'));
      await tester.pumpAndSettle();

      expect(find.text('Vacances'), findsOneWidget);
      expect(find.text('Vacances (copie)'), findsOneWidget);
    });

    testWidgets('deletes an album after confirmation', (tester) async {
      await controller.createAlbum('A Supprimer');

      await pumpScreen(tester);

      expect(find.text('A Supprimer'), findsOneWidget);

      // Ouvrir menu
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // Choisir Supprimer
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      expect(find.text('Supprimer l\'album'), findsOneWidget);

      // Confirmer
      await tester.tap(find.text('Supprimer définitivement'));
      await tester.pumpAndSettle();

      expect(find.text('A Supprimer'), findsNothing);
      expect(find.text('Aucun album photo'), findsOneWidget);
    });

    testWidgets('displays warning card for corrupted album without crashing', (
      tester,
    ) async {
      await controller.createAlbum('Album Valide');

      // Créer manuellement un dossier corrompu
      final corruptDir = await storageService.getAlbumDirectory('Album Bogue');
      corruptDir.createSync(recursive: true);
      final corruptFile = File('${corruptDir.path}/album.json');
      corruptFile.writeAsStringSync('BROKEN_NON_JSON');

      await pumpScreen(tester);

      expect(find.text('Album Valide'), findsOneWidget);
      expect(find.text('Album Bogue'), findsOneWidget);
      expect(find.text('Album illisible / corrompu'), findsOneWidget);
    });
  });
}
