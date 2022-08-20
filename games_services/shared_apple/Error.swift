
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
    case .failedToSendAchievement:
      return "Failed to send the achievement"
    case .failedToAuthenticate:
      return "Failed to authenticate"
    case .notSupportedForThisOSVersion:
      return "Not supported for this OS version"
    case .leaderboardNotFound:
      return "Leaderboard not found"
    }
  }
  
  case failedToSendScore = "failed_to_send_score"
  case failedToSendAchievement = "failed_to_send_achievement"
  case failedToAuthenticate = "failed_to_authenticate"
  case notSupportedForThisOSVersion = "not_supported_for_this_os_version"
  case leaderboardNotFound = "leaderboard_not_found"
  
  func flutterError() -> FlutterError {
    return FlutterError(code: rawValue,
                        message: errorDescription,
                        details: errorDescription)
  }
}
