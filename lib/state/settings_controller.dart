import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the player's audio settings (music level, sound-effects level, mute)
/// and saves them to `shared_preferences`. [AudioController] is the part that
/// actually plays sound.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs);

  final SharedPreferences _prefs;

  static const String _musicKey = 'settings.musicVolume';
  static const String _sfxKey = 'settings.sfxVolume';
  static const String _mutedKey = 'settings.muted';

  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _muted = false;

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get muted => _muted;

  /// The volume to actually play at: 0 while muted.
  double get effectiveMusicVolume {
    if (_muted) return 0;
    return _musicVolume;
  }

  double get effectiveSfxVolume {
    if (_muted) return 0;
    return _sfxVolume;
  }

  /// Loads saved settings, or keeps the defaults above if nothing is saved.
  void load() {
    _musicVolume = _prefs.getDouble(_musicKey) ?? _musicVolume;
    _sfxVolume = _prefs.getDouble(_sfxKey) ?? _sfxVolume;
    _muted = _prefs.getBool(_mutedKey) ?? _muted;
    notifyListeners();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = _inRange(value);
    notifyListeners();
    await _prefs.setDouble(_musicKey, _musicVolume);
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = _inRange(value);
    notifyListeners();
    await _prefs.setDouble(_sfxKey, _sfxVolume);
  }

  Future<void> setMuted(bool value) async {
    _muted = value;
    notifyListeners();
    await _prefs.setBool(_mutedKey, _muted);
  }

  /// Keeps a volume between 0 and 1.
  double _inRange(double value) {
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }
}
