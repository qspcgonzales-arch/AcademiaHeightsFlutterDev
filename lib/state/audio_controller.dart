import 'package:flutter/foundation.dart';

import 'settings_controller.dart';

/// Thin wrapper around audio playback. Kept minimal for the scaffold — the
/// real implementation will use `flame_audio` (M5). Screens talk to this,
/// not to the audio package directly, so the backend can change later.
class AudioController extends ChangeNotifier {
  AudioController(this._settings) {
    _settings.addListener(_onSettingsChanged);
  }

  final SettingsController _settings;

  bool _musicPlaying = false;
  bool get musicPlaying => _musicPlaying;

  void _onSettingsChanged() {
    // TODO(M5): apply _settings.effectiveMusicVolume to the running track.
    notifyListeners();
  }

  /// Start background music for a screen/area. No-op until M5.
  void playMusic(String track) {
    _musicPlaying = true;
    notifyListeners();
  }

  void stopMusic() {
    _musicPlaying = false;
    notifyListeners();
  }

  /// Fire a one-shot sound effect. No-op until M5.
  void playSfx(String effect) {}

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }
}
