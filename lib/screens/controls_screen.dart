import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Explains the touch controls (replaces the Java version's keyboard help).
class ControlsScreen extends StatelessWidget {
  const ControlsScreen({super.key});

  static const List<(IconData, String, String)> _controls = [
    (Icons.gamepad, 'Virtual joystick', 'Drag the joystick (bottom-left) to walk around.'),
    (Icons.touch_app, 'Interact', 'Tap the interact button to talk, pick up a book, or advance dialogue.'),
    (Icons.menu, 'Menu', 'Tap the menu icon (top-right) to open Settings, Save/Load, or Progress.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controls')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.gapM),
          children: [
            for (final (icon, title, body) in _controls)
              ListTile(
                leading: Icon(icon),
                title: Text(title),
                subtitle: Text(body),
              ),
          ],
        ),
      ),
    );
  }
}
