class PlayerData {
  /// Value can be `null` on Android due to privacy settings or in the case of a
  /// GameCenter configuration issue, as GameCenter will provide a temporary ID
  /// which will not persist between game sessions.
  final String? playerID;
  final String displayName;
  final String? iconImage;

  /// Only available from GameCenter.
  /// May be null if there is GameCenter configuration issue, as GameCenter will
  /// provide a temporary ID which will not persist between game sessions.
  final String? teamPlayerID;

  /// Only available from GameCenter.
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

  factory PlayerData.fromJson(Map<String, dynamic> json) => PlayerData(
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
