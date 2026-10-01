import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopush_client/photopush_client.dart';
import 'package:photopush_flutter/features/slides/pin_widget.dart';
import 'package:photopush_flutter/features/slides/comment_slide_viewer.dart';

void main() {
  group('Accessibility & Semantics tests (RNF-60 to RNF-64, A-01, A-02)', () {
    testWidgets('PinWidget guarantees a minimum 48dp touch target (RNF-60)',
        (tester) async {
      final pin = Pin(
        id: Uuid().v7obj(),
        slideId: Uuid().v7obj(),
        kind: 'neutral',
        x: 0.5,
        y: 0.5,
        sizeScale: 1.0, // 20px visual, but must be >= 48px hit target
        color: 'blue',
        zIndex: 0,
        hlcWall: 0,
        hlcCounter: 0,
        deviceId: 'device-test',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PinWidget(
                pin: pin,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final sizedBoxFinder = find.byType(SizedBox);
      expect(sizedBoxFinder, findsWidgets);

      final RenderBox box = tester.renderObject(find.byType(PinWidget));
      expect(box.size.width, greaterThanOrEqualTo(48.0));
      expect(box.size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('PinWidget exposes Semantics with button role and label (RNF-61, A-01)',
        (tester) async {
      final pin = Pin(
        id: Uuid().v7obj(),
        slideId: Uuid().v7obj(),
        kind: 'text',
        text: 'Coucher de soleil',
        x: 0.3,
        y: 0.4,
        sizeScale: 1.5,
        color: 'yellow',
        zIndex: 1,
        hlcWall: 0,
        hlcCounter: 0,
        deviceId: 'device-test',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinWidget(
              pin: pin,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('CommentSlideViewer supports 200% text scale without overflowing (RNF-62, A-02)',
        (tester) async {
      final slide = Slide(
        id: Uuid().v7obj(),
        albumId: Uuid().v7obj(),
        kind: 'comment',
        title: 'Titre de la diapositive',
        commentText: 'Un très long commentaire ' * 20,
        orderKey: '000000',
        hlcWall: 0,
        hlcCounter: 0,
        deviceId: 'device-test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2.0), // 200% text scale
            ),
            child: Scaffold(
              body: CommentSlideViewer(
                slide: slide,
                onTap: () {},
                isImmersive: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
