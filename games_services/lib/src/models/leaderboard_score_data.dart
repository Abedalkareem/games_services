class LeaderboardScoreData {
  final int rank;
  final String displayScore;
  final int rawScore;
  final int timestampMillis;
  final String scoreHolderDisplayName;
  final String? scoreHolderIconImage;

  const LeaderboardScoreData({
    required this.rank,
    required this.displayScore,
    required this.rawScore,
    required this.timestampMillis,
    required this.scoreHolderDisplayName,
    this.scoreHolderIconImage,
  });

  factory LeaderboardScoreData.fromJson(Map<String, dynamic> json) {
    return LeaderboardScoreData(
      rank: json["rank"],
      displayScore: json["displayScore"],
      rawScore: json["rawScore"],
      timestampMillis: json["timestampMillis"],
      scoreHolderDisplayName: json["scoreHolderDisplayName"],
      scoreHolderIconImage:
          (json["scoreHolderIconImage"] as String?)?.replaceAll("\n", ""),
    );
  }
}
