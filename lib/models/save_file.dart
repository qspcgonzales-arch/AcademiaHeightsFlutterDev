import 'dart:convert';

import 'player_profile.dart';

/// A saved run: a [PlayerProfile] plus metadata for the Load Game list.
///
/// Persisted as a JSON string in `shared_preferences`. Bump [schemaVersion]
/// and handle the old shape in [SaveFile.fromJson] if the structure changes.
class SaveFile {
  const SaveFile({
    required this.slotId,
    required this.profile,
    required this.savedAt,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  /// Unique per save slot (e.g. `slot_1`, or a timestamp-based id).
  final String slotId;
  final PlayerProfile profile;
  final DateTime savedAt;
  final int schemaVersion;

  String get playerName => profile.name;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'slotId': slotId,
        'savedAt': savedAt.toIso8601String(),
        'profile': profile.toJson(),
      };

  String encode() => jsonEncode(toJson());

  factory SaveFile.fromJson(Map<String, dynamic> json) => SaveFile(
        slotId: json['slotId'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
        schemaVersion:
            json['schemaVersion'] as int? ?? currentSchemaVersion,
        profile:
            PlayerProfile.fromJson(json['profile'] as Map<String, dynamic>),
      );

  factory SaveFile.decode(String source) =>
      SaveFile.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
