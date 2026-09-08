import 'dart:convert';

import 'player_profile.dart';

/// A saved game: a [PlayerProfile] plus the info the Load Game list shows.
///
/// Stored as one JSON string in `shared_preferences`. If the saved shape ever
/// changes, raise [currentSchemaVersion] and handle the old version in
/// [fromJson] so existing saves still load.
class SaveFile {
  const SaveFile({
    required this.slotId,
    required this.profile,
    required this.savedAt,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  /// Identifies the save slot (e.g. `slot_1700000000000`).
  final String slotId;
  final PlayerProfile profile;
  final DateTime savedAt;
  final int schemaVersion;

  String get playerName => profile.name;

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'slotId': slotId,
      'savedAt': savedAt.toIso8601String(),
      'profile': profile.toJson(),
    };
  }

  /// Turns this save into the JSON string that goes into storage.
  String encode() => jsonEncode(toJson());

  static SaveFile fromJson(Map<String, dynamic> json) {
    return SaveFile(
      slotId: json['slotId'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
      schemaVersion: (json['schemaVersion'] as int?) ?? currentSchemaVersion,
      profile: PlayerProfile.fromJson(
        json['profile'] as Map<String, dynamic>,
      ),
    );
  }

  /// Builds a save from the JSON string read back from storage.
  static SaveFile decode(String stored) {
    final Map<String, dynamic> json =
        jsonDecode(stored) as Map<String, dynamic>;
    return SaveFile.fromJson(json);
  }
}
