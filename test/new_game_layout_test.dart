import 'package:academia_heights/screens/new_game_screen.dart';
import 'package:academia_heights/screens/main_menu_screen.dart';
import 'package:academia_heights/services/leaderboard_service.dart';
import 'package:academia_heights/services/save_service.dart';
import 'package:academia_heights/state/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('compact landscape menu keeps every action in view',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(914, 411);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MainMenuScreen()),
    );
    await tester.pumpAndSettle();

    final Rect quitBounds = tester.getRect(find.text('Quit'));
    expect(quitBounds.bottom, lessThanOrEqualTo(411));
    expect(tester.takeException(), isNull);
  });

  testWidgets('New Game form scrolls in a short landscape view with keyboard',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 400);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    SharedPreferences.setMockInitialValues({});
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final GameState gameState = GameState(
      saveService: SaveService(preferences),
      leaderboardService: LeaderboardService(preferences),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<GameState>.value(
        value: gameState,
        child: const MaterialApp(home: NewGameScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Start Game'), findsOneWidget);
    await tester.ensureVisible(find.text('Start Game'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
