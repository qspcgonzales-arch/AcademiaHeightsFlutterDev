import 'package:shared_preferences/shared_preferences.dart';

import '../models/save_file.dart';

/// Reads and writes saved games to `shared_preferences`.
///
/// Each save is one JSON string stored under `save.slot.<id>`. A separate
/// list under `save.index` holds every slot id so the Load Game screen knows
/// what exists.
class SaveService {
  SaveService(this._prefs);

  final SharedPreferences _prefs;

  static const String _indexKey = 'save.index';
  static const String _slotPrefix = 'save.slot.';
  static const String _autoSaveKey = 'save.autoSaveEnabled';

  /// The list of saved slot ids ("?? const []" = empty list if none yet).
  List<String> _slotIds() => _prefs.getStringList(_indexKey) ?? const [];

  /// Every saved game, most recently saved first.
  List<SaveFile> listSaves() {
    final List<SaveFile> saves = [];

    for (final String slotId in _slotIds()) {
      final String? raw = _prefs.getString('$_slotPrefix$slotId');
      if (raw == null) continue;
      try {
        saves.add(SaveFile.decode(raw));
      } catch (_) {
        // A save we can't read is skipped instead of crashing the list.
      }
    }

    // Newest first.
    saves.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return saves;
  }

  SaveFile? load(String slotId) {
    final String? raw = _prefs.getString('$_slotPrefix$slotId');
    if (raw == null) return null;
    return SaveFile.decode(raw);
  }

  Future<void> save(SaveFile file) async {
    await _prefs.setString('$_slotPrefix${file.slotId}', file.encode());

    // Add the slot id to the index if it's a new slot.
    final List<String> ids = List<String>.from(_slotIds());
    if (!ids.contains(file.slotId)) {
      ids.add(file.slotId);
      await _prefs.setStringList(_indexKey, ids);
    }
  }

  Future<void> delete(String slotId) async {
    await _prefs.remove('$_slotPrefix$slotId');

    final List<String> ids = List<String>.from(_slotIds());
    ids.remove(slotId);
    await _prefs.setStringList(_indexKey, ids);
  }

  bool get autoSaveEnabled => _prefs.getBool(_autoSaveKey) ?? false;

  Future<void> setAutoSaveEnabled(bool enabled) {
    return _prefs.setBool(_autoSaveKey, enabled);
  }
}
