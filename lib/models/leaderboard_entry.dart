import 'dart:convert';

import 'player_profile.dart';

/// One row of the Leaderboard: Rank, Player Name, Average Score, Level,
/// Quizzes Taken. Rank is assigned at display time after sorting.
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

  factory LeaderboardEntry.fromProfile(PlayerProfile profile) =>
      LeaderboardEntry(
        playerName: profile.name,
        averagePercent: profile.averagePercent,
        level: profile.level,
        quizzesTaken: profile.quizzesTaken,
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'averagePercent': averagePercent,
        'level': level,
        'quizzesTaken': quizzesTaken,
        'updatedAt': updatedAt.toIso8601String(),
      };

  String encode() => jsonEncode(toJson());

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        playerName: json['playerName'] as String,
        averagePercent: json['averagePercent'] as int,
        level: json['level'] as int,
        quizzesTaken: json['quizzesTaken'] as int,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  factory LeaderboardEntry.decode(String source) =>
      LeaderboardEntry.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
