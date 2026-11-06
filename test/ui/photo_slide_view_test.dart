import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:photopush/controllers/album_detail_controller.dart';
import 'package:photopush/models/models.dart';
import 'package:photopush/services/services.dart';
import 'package:photopush/ui/widgets/photo_slide_view.dart';
import 'package:photopush/ui/widgets/pin_editor_dialog.dart';
import 'package:photopush/ui/widgets/pin_view.dart';

void main() {
  group('US-3 : PhotoSlideView (Interactive Pins Overlay)', () {
    late Directory tempRootDir;
    late AlbumStorageService storageService;
    late Album album;
    late AlbumDetailController controller;
    late File photoFile;

    setUp(() {
      tempRootDir = Directory.systemTemp.createTempSync('slide_ui_test_');
      storageService = AlbumStorageService(
        baseDirectoryResolver: () async => tempRootDir,
      );

      final albumDir = Directory(
        p.join(tempRootDir.path, 'albums', 'Test Punaise UI'),
      );
      albumDir.createSync(recursive: true);

      final imagesDir = Directory(p.join(albumDir.path, 'images'));
      imagesDir.createSync(recursive: true);

      photoFile = File(p.join(imagesDir.path, 'img.jpg'));
      photoFile.writeAsBytesSync(
        img.encodeJpg(img.Image(width: 800, height: 600)),
      );

      final slide1 = Slide(
        id: 's1',
        title: 'Vue 1',
        image: const ImageSource(
          storageType: ImageStorageType.internal,
          path: 'images/img.jpg',
        ),
      );

      album = Album(name: 'Test Punaise UI', slides: [slide1]);
      storageService.saveAlbum(album);

      controller = AlbumDetailController(
        initialAlbum: album,
        storageService: storageService,
      );
    });

    tearDown(() {
      if (tempRootDir.existsSync()) {
        tempRootDir.deleteSync(recursive: true);
      }
    });

    Future<void> pumpSlide(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: AnimatedBuilder(
                animation: controller,
                builder: (ctx, _) {
                  return PhotoSlideView(
                    slide: controller.currentSlide!,
                    controller: controller,
                    onToggleComment: () {},
                  );
                },
              ),
            ),
          ),
        ),
      );
      // Let the FutureBuilder complete
      await tester.pumpAndSettle();
    }

    testWidgets('tapping image opens pin editor and creates a pin', (
      tester,
    ) async {
      await pumpSlide(tester);

      // Verify no pins initially
      expect(find.byType(PinView), findsNothing);

      final gestureDetector = find.descendant(
        of: find.byType(LayoutBuilder),
        matching: find.byType(GestureDetector).first,
      );

      // We extract the onTapUp callback directly because tapping through
      // the Stack sometimes fails to hit the background detector in tests.
      final GestureDetector gd = tester.widget(gestureDetector);
      gd.onTapUp!(
        TapUpDetails(
          kind: PointerDeviceKind.touch,
          globalPosition: const Offset(400, 300),
          localPosition: const Offset(400, 300),
        ),
      );
      await tester.pumpAndSettle();

      // Pin editor dialog should appear
      expect(find.byType(PinEditorDialog), findsOneWidget);
      expect(find.text('Éditer la punaise'), findsOneWidget);

      // Enter text
      await tester.enterText(find.byType(TextField).last, 'Bulle de texte');
      await tester.pump();

      // Save
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Pin should now be rendered
      expect(find.byType(PinView), findsOneWidget);
      expect(controller.currentSlide!.pins.length, 1);
      final createdPin = controller.currentSlide!.pins.first;

      expect(createdPin.text, 'Bulle de texte');
    });

    testWidgets('tapping an existing pin opens its bubble', (tester) async {
      await controller.addPin(Pin(x: 0.5, y: 0.5, text: 'Secret !'));
      await pumpSlide(tester);

      expect(find.byType(PinView), findsOneWidget);
      expect(find.text('Secret !'), findsNothing); // bubble hidden by default

      // Find the gesture detector wrapping the PinView
      final internalPinGdFinder = find.descendant(
        of: find.byType(PinView),
        matching: find.byType(GestureDetector),
      );
      final GestureDetector internalGd = tester.widget(
        internalPinGdFinder.first,
      );
      internalGd.onTap!();

      await tester.pumpAndSettle();

      // Bubble is now visible
      expect(find.text('Secret !'), findsOneWidget);
    });

    testWidgets('long pressing a pin opens the editor and allows deletion', (
      tester,
    ) async {
      await controller.addPin(Pin(x: 0.5, y: 0.5, text: 'To delete'));
      await pumpSlide(tester);

      expect(find.byType(PinView), findsOneWidget);

      final pinGestureFinder = find.ancestor(
        of: find.byType(PinView),
        matching: find.byType(GestureDetector),
      );

      final GestureDetector pinGd = tester.widget(pinGestureFinder.first);
      pinGd.onLongPress!();

      await tester.pumpAndSettle();

      expect(find.byType(PinEditorDialog), findsOneWidget);

      // Delete
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      expect(find.byType(PinView), findsNothing);
      expect(controller.currentSlide!.pins.isEmpty, isTrue);
    });
  });
}
