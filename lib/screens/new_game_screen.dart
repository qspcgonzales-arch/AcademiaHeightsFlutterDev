import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// Asks for a player name (up to 16 characters) and starts a new game.
class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _nameIsEmpty => _nameController.text.trim().isEmpty;

  void _startGame() {
    if (_nameIsEmpty) return;

    context.read<GameState>().startNewGame(_nameController.text);

    // Open gameplay; keep the main menu underneath so Back returns there.
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.gameplay,
      ModalRoute.withName(Routes.mainMenu),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Game')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.gapL),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                maxLength: AppTheme.maxPlayerNameLength,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Player name',
                  hintText: 'Up to 16 characters',
                ),
                // Rebuild so the Start button enables/disables as they type.
                onChanged: (text) => setState(() {}),
                onSubmitted: (text) => _startGame(),
              ),
              const SizedBox(height: AppTheme.gapM),
              FilledButton(
                onPressed: _nameIsEmpty ? null : _startGame,
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
