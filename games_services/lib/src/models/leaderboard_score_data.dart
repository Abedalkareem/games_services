import 'player_data.dart';

class LeaderboardScoreData {
  /// The player's position on the leaderboard.
  final int rank;

  /// The formatted string representation of the score provided by the platform.
  /// May contain additional formatting.
  final String displayScore;

  /// The player's score as an integer.
  final int rawScore;

  /// The timestamp in milliseconds representing when the score was achieved.
  final int timestampMillis;

  /// Data about the player that holds the score and rank.
  final PlayerData scoreHolder;

  /// Corresponds to `context` on iOS and 'scoreTag` on Android.
  final String? token;

  // provided to maintain backwards compatibility
  @Deprecated('Use scoreHolder.displayName instead.')
  String get scoreHolderDisplayName => scoreHolder.displayName;
  @Deprecated('Use scoreHolder.iconImage instead.')
  String? get scoreHolderIconImage => scoreHolder.iconImage;

  const LeaderboardScoreData({
    required this.rank,
    required this.displayScore,
    required this.rawScore,
    required this.timestampMillis,
    required this.scoreHolder,
    this.token,
  });

  factory LeaderboardScoreData.fromJson(Map<String, dynamic> json) =>
      LeaderboardScoreData(
        rank: json["rank"],
        displayScore: json["displayScore"],
        rawScore: json["rawScore"],
        timestampMillis: json["timestampMillis"],
        scoreHolder: PlayerData.fromJson(json["scoreHolder"]),
        token: (json["token"] as String?)?.replaceAll("\n", ""),
      );
}
