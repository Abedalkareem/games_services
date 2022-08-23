
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

extension Error {
  func flutterError(code: PluginError) -> FlutterError {
    return FlutterError(code: code.rawValue,
                        message: self.localizedDescription,
                        details: self.localizedDescription)
  }
}

enum PluginError: String {
  
  var errorDescription: String? {
    switch self {
    case .failedToSendScore:
      return "Failed to send the score"
    case .failedToGetScore:
      return "Failed to get the score"
    case .failedToSendAchievement:
      return "Failed to send the achievement"
    case .failedToAuthenticate:
      return "Failed to authenticate"
    case .notSupportedForThisOSVersion:
      return "Not supported for this OS version"
    case .leaderboardNotFound:
      return "Leaderboard not found"
    case .failedToSaveGame:
      return "Failed to save game"
    case .failedToLoadGame:
      return "Failed to load game"
    case .failedToGetSavedGames:
      return "Failed to get saved games"
    case .failedToDeleteSavedGame:
      return "Failed to delete saved game"
    }
  }
  
  case failedToSendScore = "failed_to_send_score"
  case failedToGetScore = "failed_to_get_score"
  case failedToSendAchievement = "failed_to_send_achievement"
  case failedToAuthenticate = "failed_to_authenticate"
  case failedToSaveGame = "failed_to_save_game"
  case failedToLoadGame = "failed_to_load_game"
  case notSupportedForThisOSVersion = "not_supported_for_this_os_version"
  case leaderboardNotFound = "leaderboard_not_found"
  case failedToGetSavedGames = "failed_to_get_saved_games"
  case failedToDeleteSavedGame = "failed_to_delete_saved_game"
  func flutterError() -> FlutterError {
    return FlutterError(code: rawValue,
                        message: errorDescription,
                        details: errorDescription)
  }
}
