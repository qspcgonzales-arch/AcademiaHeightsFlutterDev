import 'package:shared_preferences/shared_preferences.dart';

import '../models/leaderboard_entry.dart';

/// The on-device leaderboard (no network — see the proposal's delimitations).
///
/// Rows are stored as a list of JSON strings under one key. There is one row
/// per player name; submitting the same name again keeps whichever run had
/// the higher average.
class LeaderboardService {
  LeaderboardService(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'leaderboard.entries';

  /// All rows, best score first.
  List<LeaderboardEntry> entries() {
    // "?? const []" means "use an empty list if nothing is saved yet".
    final List<String> rawRows = _prefs.getStringList(_key) ?? const [];

    final List<LeaderboardEntry> rows = [];
    for (final String row in rawRows) {
      try {
        rows.add(LeaderboardEntry.decode(row));
      } catch (_) {
        // A row we can't read is skipped instead of crashing the screen.
      }
    }

    _sortByScore(rows);
    return rows;
  }

  /// Adds or updates the row for this player, then saves.
  Future<void> submit(LeaderboardEntry entry) async {
    final List<LeaderboardEntry> rows = entries();

    int existingIndex = -1;
    for (int i = 0; i < rows.length; i++) {
      if (rows[i].playerName == entry.playerName) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex == -1) {
      rows.add(entry);
    } else {
      final LeaderboardEntry existing = rows[existingIndex];
      if (entry.averagePercent <= existing.averagePercent) {
        return; // The saved run is as good or better — leave it.
      }
      rows[existingIndex] = entry;
    }

    final List<String> rawRows = [];
    for (final LeaderboardEntry row in rows) {
      rawRows.add(row.encode());
    }
    await _prefs.setStringList(_key, rawRows);
  }

  Future<void> clear() => _prefs.remove(_key);

  /// Highest average first; ties broken by higher level.
  void _sortByScore(List<LeaderboardEntry> rows) {
    rows.sort((a, b) {
      if (a.averagePercent != b.averagePercent) {
        return b.averagePercent - a.averagePercent;
      }
      return b.level - a.level;
    });
  }
}
