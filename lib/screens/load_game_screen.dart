import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../formatting.dart';
import '../models/save_file.dart';
import '../routes.dart';
import '../services/save_service.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Lists the saved games (player name + when it was saved) and lets the
/// player continue one.
class LoadGameScreen extends StatefulWidget {
  const LoadGameScreen({super.key});

  @override
  State<LoadGameScreen> createState() => _LoadGameScreenState();
}

class _LoadGameScreenState extends State<LoadGameScreen> {
  // Filled in initState(), before build() runs.
  late List<SaveFile> _saves;

  @override
  void initState() {
    super.initState();
    _saves = context.read<SaveService>().listSaves();
  }

  void _continueFrom(SaveFile save) {
    context.read<GameState>().loadGame(save);

    // Go to gameplay, clearing the New/Load screen but keeping the menu
    // underneath so Back returns there.
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
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_saves.isEmpty) {
      return const Center(child: Text('No saved games yet.'));
    }

    return ListView(
      padding: const EdgeInsets.all(AppTheme.gapM),
      children: [
        for (final save in _saves)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.gapS),
            child: Card(
              child: ListTile(
                title: Text(save.playerName),
                subtitle: Text(formatDateTime(save.savedAt)),
                trailing: const Icon(Icons.play_arrow),
                onTap: () => _continueFrom(save),
              ),
            ),
          ),
      ],
    );
  }
}
