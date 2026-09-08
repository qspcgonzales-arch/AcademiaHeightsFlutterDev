import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Explains the touch controls (the Java version used the keyboard).
class ControlsScreen extends StatelessWidget {
  const ControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controls')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.gapM),
          children: const [
            ListTile(
              leading: Icon(Icons.gamepad),
              title: Text('Virtual joystick'),
              subtitle: Text('Drag the joystick (bottom-left) to walk around.'),
            ),
            ListTile(
              leading: Icon(Icons.touch_app),
              title: Text('Interact'),
              subtitle: Text(
                'Tap the interact button to talk, pick up a book, or advance '
                'dialogue.',
              ),
            ),
            ListTile(
              leading: Icon(Icons.menu),
              title: Text('Menu'),
              subtitle: Text(
                'Tap the menu icon (top-right) to open Settings, Save/Load, '
                'or Progress.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
