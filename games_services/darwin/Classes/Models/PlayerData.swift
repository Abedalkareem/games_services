struct PlayerData: Codable {
  var displayName: String
  var playerID: String
  var teamPlayerID: String
  var iconImage: String?
  var isUnderage: Bool?
  var isMultiplayerGamingRestricted: Bool?
  var isPersonalizedCommunicationRestricted: Bool?
}
