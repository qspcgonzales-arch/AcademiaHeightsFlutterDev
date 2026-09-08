import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_theme.dart';

/// Top players by Rank, Player Name, Average Score, Level, Quizzes Taken.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LeaderboardEntry> entries =
        context.read<LeaderboardService>().entries();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: SafeArea(
        child: entries.isEmpty
            ? const Center(child: Text('No scores yet. Pass an exam!'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.gapM),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Rank')),
                      DataColumn(label: Text('Player')),
                      DataColumn(label: Text('Avg %'), numeric: true),
                      DataColumn(label: Text('Level'), numeric: true),
                      DataColumn(label: Text('Quizzes'), numeric: true),
                    ],
                    rows: [
                      for (var i = 0; i < entries.length; i++)
                        DataRow(
                          cells: [
                            DataCell(Text('${i + 1}')),
                            DataCell(Text(entries[i].playerName)),
                            DataCell(Text('${entries[i].averagePercent}')),
                            DataCell(Text('${entries[i].level}')),
                            DataCell(Text('${entries[i].quizzesTaken}')),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
