import 'package:games_services/src/models/player_data.dart';

class LeaderboardScoreData {
  final int rank;
  final String displayScore;
  final int rawScore;
  final int timestampMillis;
  final PlayerData scoreHolder;

  // TODO: deprecate in favor of accessing PlayerData properties directly
  // provided to maintain backwards compatibility
  String get scoreHolderDisplayName => scoreHolder.displayName;
  String? get scoreHolderIconImage => scoreHolder.iconImage;

  const LeaderboardScoreData({
    required this.rank,
    required this.displayScore,
    required this.rawScore,
    required this.timestampMillis,
    required this.scoreHolder,
  });

  factory LeaderboardScoreData.fromJson(Map<String, dynamic> json) {
    return LeaderboardScoreData(
      rank: json["rank"],
      displayScore: json["displayScore"],
      rawScore: json["rawScore"],
      timestampMillis: json["timestampMillis"],
      scoreHolder: PlayerData.fromJson(json["scoreHolder"]),
    );
  }
}
