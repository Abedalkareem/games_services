class PlayerData {
  /// Value can be `null` on Android due to privacy settings
  final String? playerID;
  final String displayName;
  final String? iconImage;

  /// only available from GameCenter
  final String? teamPlayerID;

  /// only available from GameCenter
  final bool? isUnderage,
      isMultiplayerGamingRestricted,
      isPersonalizedCommunicationRestricted;

  const PlayerData({
    required this.playerID,
    required this.displayName,
    this.iconImage,
    this.teamPlayerID,
    this.isUnderage,
    this.isMultiplayerGamingRestricted,
    this.isPersonalizedCommunicationRestricted,
  });

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      playerID: json["playerID"],
      displayName: json["displayName"],
      iconImage: (json["iconImage"] as String?)?.replaceAll("\n", ""),
      teamPlayerID: json["teamPlayerID"],
      isUnderage: json["isUnderage"],
      isMultiplayerGamingRestricted: json["isMultiplayerGamingRestricted"],
      isPersonalizedCommunicationRestricted:
          json["isPersonalizedCommunicationRestricted"],
    );
  }
}
