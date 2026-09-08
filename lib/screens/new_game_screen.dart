import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// New game: enter a player name (max 16 characters) and start.
class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _start() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    context.read<GameState>().startNewGame(name);
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
                controller: _name,
                autofocus: true,
                maxLength: AppTheme.maxPlayerNameLength,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Player name',
                  hintText: 'Up to 16 characters',
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _start(),
              ),
              const SizedBox(height: AppTheme.gapM),
              FilledButton(
                onPressed: _name.text.trim().isEmpty ? null : _start,
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
