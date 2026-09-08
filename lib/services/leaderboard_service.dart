import 'package:shared_preferences/shared_preferences.dart';

import '../models/leaderboard_entry.dart';

/// On-device leaderboard. One entry per player name; the best (highest
/// average) wins if a name is submitted twice. No network — see the
/// proposal's delimitations.
class LeaderboardService {
  LeaderboardService(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'leaderboard.entries';

  List<LeaderboardEntry> entries() {
    final raw = _prefs.getStringList(_key) ?? const [];
    final parsed = <LeaderboardEntry>[];
    for (final line in raw) {
      try {
        parsed.add(LeaderboardEntry.decode(line));
      } catch (_) {
        // Skip corrupt rows.
      }
    }
    parsed.sort((a, b) {
      final byScore = b.averagePercent.compareTo(a.averagePercent);
      if (byScore != 0) return byScore;
      return b.level.compareTo(a.level);
    });
    return parsed;
  }

  Future<void> submit(LeaderboardEntry entry) async {
    final current = entries().toList();
    final existingIndex =
        current.indexWhere((e) => e.playerName == entry.playerName);
    if (existingIndex >= 0) {
      if (entry.averagePercent <= current[existingIndex].averagePercent) {
        return; // Keep the better run.
      }
      current[existingIndex] = entry;
    } else {
      current.add(entry);
    }
    await _prefs.setStringList(
      _key,
      [for (final e in current) e.encode()],
    );
  }

  Future<void> clear() => _prefs.remove(_key);
}
