import 'player_data.dart';

class LeaderboardScoreData {
  final int rank;
  final String displayScore;
  final int rawScore;
  final int timestampMillis;
  final PlayerData scoreHolder;
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

  factory LeaderboardScoreData.fromJson(Map<String, dynamic> json) {
    return LeaderboardScoreData(
      rank: json["rank"],
      displayScore: json["displayScore"],
      rawScore: json["rawScore"],
      timestampMillis: json["timestampMillis"],
      scoreHolder: PlayerData.fromJson(json["scoreHolder"]),
      token: (json["token"] as String?)?.replaceAll("\n", ""),
    );
  }
}
