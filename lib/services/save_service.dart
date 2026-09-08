import 'package:shared_preferences/shared_preferences.dart';

import '../models/save_file.dart';

/// Reads and writes [SaveFile]s to `shared_preferences`. One JSON string per
/// slot, plus an index of slot ids so the Load Game screen can list them.
class SaveService {
  SaveService(this._prefs);

  final SharedPreferences _prefs;

  static const String _indexKey = 'save.index';
  static const String _slotPrefix = 'save.slot.';
  static const String _autoSaveKey = 'save.autoSaveEnabled';

  List<String> _slotIndex() => _prefs.getStringList(_indexKey) ?? const [];

  /// Slot ids, most recently saved first.
  List<SaveFile> listSaves() {
    final saves = <SaveFile>[];
    for (final id in _slotIndex()) {
      final raw = _prefs.getString('$_slotPrefix$id');
      if (raw == null) continue;
      try {
        saves.add(SaveFile.decode(raw));
      } catch (_) {
        // Corrupt slot — skip it rather than crash the list.
      }
    }
    saves.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return saves;
  }

  SaveFile? load(String slotId) {
    final raw = _prefs.getString('$_slotPrefix$slotId');
    if (raw == null) return null;
    return SaveFile.decode(raw);
  }

  Future<void> save(SaveFile file) async {
    await _prefs.setString('$_slotPrefix${file.slotId}', file.encode());
    final index = _slotIndex().toList();
    if (!index.contains(file.slotId)) {
      index.add(file.slotId);
      await _prefs.setStringList(_indexKey, index);
    }
  }

  Future<void> delete(String slotId) async {
    await _prefs.remove('$_slotPrefix$slotId');
    final index = _slotIndex().toList()..remove(slotId);
    await _prefs.setStringList(_indexKey, index);
  }

  bool get autoSaveEnabled => _prefs.getBool(_autoSaveKey) ?? false;

  Future<void> setAutoSaveEnabled(bool value) =>
      _prefs.setBool(_autoSaveKey, value);
}
