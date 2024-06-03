
struct LeaderboardScoreData: Codable {
  var rank: Int
  var displayScore: String
  var rawScore: Int
  var timestampMillis: Int
  var scoreHolder: PlayerData
  var token: String?
}
