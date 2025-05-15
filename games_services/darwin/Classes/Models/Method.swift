import Foundation

enum Method: String {
  case unlock = "unlock"
  case submitScore = "submitScore"
  case showLeaderboards = "showLeaderboards"
  case showAchievements = "showAchievements"
  case getPlayerHiResImage = "getPlayerHiResImage"
  case getPlayerScore = "getPlayerScore"
  case getPlayerScoreObject = "getPlayerScoreObject"
  case showAccessPoint = "showAccessPoint"
  case hideAccessPoint = "hideAccessPoint"
  case signIn = "signIn"
  case saveGame = "saveGame"
  case loadGame = "loadGame"
  case getSavedGames = "getSavedGames"
  case deleteGame = "deleteGame"
  case loadAchievements = "loadAchievements"
  case resetAchievements = "resetAchievements"
  case loadLeaderboardScores = "loadLeaderboardScores"
}
