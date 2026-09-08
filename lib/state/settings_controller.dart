import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted user preferences (audio levels, mute). Kept separate from
/// [AudioController], which actually plays sound.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs);

  final SharedPreferences _prefs;

  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _muted = false;

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get muted => _muted;

  double get effectiveMusicVolume => _muted ? 0 : _musicVolume;
  double get effectiveSfxVolume => _muted ? 0 : _sfxVolume;

  void load() {
    _musicVolume = _prefs.getDouble('settings.musicVolume') ?? _musicVolume;
    _sfxVolume = _prefs.getDouble('settings.sfxVolume') ?? _sfxVolume;
    _muted = _prefs.getBool('settings.muted') ?? _muted;
    notifyListeners();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0, 1);
    notifyListeners();
    await _prefs.setDouble('settings.musicVolume', _musicVolume);
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0, 1);
    notifyListeners();
    await _prefs.setDouble('settings.sfxVolume', _sfxVolume);
  }

  Future<void> setMuted(bool value) async {
    _muted = value;
    notifyListeners();
    await _prefs.setBool('settings.muted', _muted);
  }
}
