import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_theme.dart';

/// The leaderboard: Rank, Player, Average %, Level, Quizzes taken. Rows come
/// back already sorted best-first, so the rank is just the row number.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LeaderboardEntry> entries =
        context.read<LeaderboardService>().entries();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: SafeArea(child: _buildBody(entries)),
    );
  }

  Widget _buildBody(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) {
      return const Center(child: Text('No scores yet. Pass an exam!'));
    }

    // The table can be wider than the phone, so allow sideways scrolling.
    return SingleChildScrollView(
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
            for (int i = 0; i < entries.length; i++)
              _row(rank: i + 1, entry: entries[i]),
          ],
        ),
      ),
    );
  }

  DataRow _row({required int rank, required LeaderboardEntry entry}) {
    return DataRow(
      cells: [
        DataCell(Text('$rank')),
        DataCell(Text(entry.playerName)),
        DataCell(Text('${entry.averagePercent}')),
        DataCell(Text('${entry.level}')),
        DataCell(Text('${entry.quizzesTaken}')),
      ],
    );
  }
}
