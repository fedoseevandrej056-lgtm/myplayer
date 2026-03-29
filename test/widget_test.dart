import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:god_tier_music_player/main_app.dart';

void main() {
  testWidgets('God Tier Music Player smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GodTierMusicPlayer());

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
