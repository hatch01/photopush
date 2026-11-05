import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopush/main.dart';

void main() {
  testWidgets('PhotoPushApp initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PhotoPushApp());

    expect(find.text('PhotoPush'), findsOneWidget);
    expect(find.text('Bienvenue dans PhotoPush'), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
  });
}
