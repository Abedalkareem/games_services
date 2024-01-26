class PlayerData {
  // can be null on Android due to privacy settings
  final String? playerID;
  final String displayName;
  // only available from GameCenter
  final String? teamPlayerID;
  final String? iconImage;

  const PlayerData({
    required this.playerID,
    required this.displayName,
    this.teamPlayerID,
    this.iconImage,
  });

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      playerID: json["playerID"],
      displayName: json["displayName"],
      teamPlayerID: json["teamPlayerID"],
      iconImage: (json["iconImage"] as String?)?.replaceAll("\n", ""),
    );
  }
}
