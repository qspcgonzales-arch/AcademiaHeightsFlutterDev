import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/save_file.dart';
import '../routes.dart';
import '../services/save_service.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Lists existing save files (player name + date/time saved) and resumes one.
class LoadGameScreen extends StatefulWidget {
  const LoadGameScreen({super.key});

  @override
  State<LoadGameScreen> createState() => _LoadGameScreenState();
}

class _LoadGameScreenState extends State<LoadGameScreen> {
  late List<SaveFile> _saves;

  @override
  void initState() {
    super.initState();
    _saves = context.read<SaveService>().listSaves();
  }

  String _formatWhen(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  void _load(SaveFile file) {
    context.read<GameState>().loadGame(file);
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.gameplay,
      ModalRoute.withName(Routes.mainMenu),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Load Game')),
      body: SafeArea(
        child: _saves.isEmpty
            ? const Center(child: Text('No save files yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppTheme.gapM),
                itemCount: _saves.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppTheme.gapS),
                itemBuilder: (context, index) {
                  final save = _saves[index];
                  return Card(
                    child: ListTile(
                      title: Text(save.playerName),
                      subtitle: Text(_formatWhen(save.savedAt)),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => _load(save),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
