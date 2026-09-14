// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:academia_heights/app.dart';
import 'package:academia_heights/state/settings_controller.dart';

void main() {
  testWidgets('app loads the title screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final SettingsController settings = SettingsController(preferences);

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsController>.value(
        value: settings,
        child: const AcademiaHeightsApp(),
      ),
    );

    expect(find.text('Academia Heights'), findsOneWidget);
    expect(find.text('Study. Explore. Graduate.'), findsOneWidget);
  });
}
