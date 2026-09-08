import 'dart:convert';

import 'player_profile.dart';

/// One row of the leaderboard. The rank number is worked out when the screen
/// draws the list, after sorting, so it isn't stored here.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.playerName,
    required this.averagePercent,
    required this.level,
    required this.quizzesTaken,
    required this.updatedAt,
  });

  final String playerName;
  final int averagePercent;
  final int level;
  final int quizzesTaken;
  final DateTime updatedAt;

  /// Builds a row from the player's current profile.
  static LeaderboardEntry fromProfile(PlayerProfile profile) {
    return LeaderboardEntry(
      playerName: profile.name,
      averagePercent: profile.averagePercent,
      level: profile.level,
      quizzesTaken: profile.quizzesTaken,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'averagePercent': averagePercent,
      'level': level,
      'quizzesTaken': quizzesTaken,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String encode() => jsonEncode(toJson());

  static LeaderboardEntry fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerName: json['playerName'] as String,
      averagePercent: json['averagePercent'] as int,
      level: json['level'] as int,
      quizzesTaken: json['quizzesTaken'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static LeaderboardEntry decode(String stored) {
    final Map<String, dynamic> json =
        jsonDecode(stored) as Map<String, dynamic>;
    return LeaderboardEntry.fromJson(json);
  }
}
