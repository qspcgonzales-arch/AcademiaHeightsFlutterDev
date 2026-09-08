import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../formatting.dart';
import '../models/save_file.dart';
import '../routes.dart';
import '../services/save_service.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';

/// In-game Save / Load screen: Quick Save, load or delete a save, and the
/// Auto Save switch.
class SaveLoadScreen extends StatefulWidget {
  const SaveLoadScreen({super.key});

  @override
  State<SaveLoadScreen> createState() => _SaveLoadScreenState();
}

class _SaveLoadScreenState extends State<SaveLoadScreen> {
  // Set in didChangeDependencies(), before build() runs.
  late SaveService _saveService;
  late GameState _game;

  List<SaveFile> _saves = const [];
  bool _autoSaveOn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _saveService = context.read<SaveService>();
    _game = context.read<GameState>();
    _autoSaveOn = _saveService.autoSaveEnabled;
    _reloadSaves();
  }

  void _reloadSaves() {
    setState(() {
      _saves = _saveService.listSaves();
    });
  }

  Future<void> _quickSave() async {
    await _game.save();
    if (!mounted) return;
    _reloadSaves();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game saved.')),
    );
  }

  Future<void> _setAutoSave(bool turnOn) async {
    await _saveService.setAutoSaveEnabled(turnOn);
    setState(() {
      _autoSaveOn = turnOn;
    });
  }

  void _loadSave(SaveFile save) {
    _game.loadGame(save);
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.gameplay,
      ModalRoute.withName(Routes.mainMenu),
    );
  }

  Future<void> _deleteSave(SaveFile save) async {
    await _saveService.delete(save.slotId);
    _reloadSaves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save / Load')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.gapM),
          children: [
            SwitchListTile(
              title: const Text('Auto Save'),
              subtitle: const Text('Save automatically after each exam.'),
              value: _autoSaveOn,
              onChanged: (turnOn) => _setAutoSave(turnOn),
            ),
            const Divider(),
            FilledButton.icon(
              onPressed: _game.hasActiveRun ? _quickSave : null,
              icon: const Icon(Icons.save),
              label: const Text('Quick Save'),
            ),
            const SizedBox(height: AppTheme.gapM),
            Text(
              'Saved games',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.gapS),
            if (_saves.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppTheme.gapM),
                child: Text('No saved games yet.'),
              )
            else
              for (final save in _saves)
                Card(
                  child: ListTile(
                    title: Text(save.playerName),
                    subtitle: Text(formatDateTime(save.savedAt)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          tooltip: 'Load',
                          onPressed: () => _loadSave(save),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete',
                          onPressed: () => _deleteSave(save),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
