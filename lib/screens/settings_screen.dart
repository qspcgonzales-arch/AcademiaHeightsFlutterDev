import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/audio_controller.dart';
import '../state/settings_controller.dart';
import '../theme/app_theme.dart';

/// Audio settings: music volume, SFX volume, mute all, test sound.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings — Audio')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.gapM),
          children: [
            SwitchListTile(
              title: const Text('Mute all audio'),
              value: settings.muted,
              onChanged: settings.setMuted,
            ),
            const Divider(),
            _VolumeSlider(
              label: 'Music volume',
              value: settings.musicVolume,
              enabled: !settings.muted,
              onChanged: settings.setMusicVolume,
            ),
            _VolumeSlider(
              label: 'Sound effects volume',
              value: settings.sfxVolume,
              enabled: !settings.muted,
              onChanged: settings.setSfxVolume,
            ),
            const SizedBox(height: AppTheme.gapM),
            OutlinedButton.icon(
              onPressed: settings.muted
                  ? null
                  : () => context.read<AudioController>().playSfx('test'),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Test sound'),
            ),
            const SizedBox(height: AppTheme.gapL),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.controls),
              child: const Text('View controls'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          onChanged: enabled ? onChanged : null,
          label: '${(value * 100).round()}%',
          divisions: 20,
        ),
      ],
    );
  }
}
