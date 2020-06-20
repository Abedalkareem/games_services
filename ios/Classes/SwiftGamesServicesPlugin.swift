import Flutter
import UIKit
import GameKit

struct ErrorConstants {
  static let submit_achievement_error :String = "SUBMIT_ACHIEVEMENT_ERROR"
  static let submit_score_error :String = "SUBMIT_SCORE_ERROR"
  static let view_achievement_error :String = "VIEW_ACHIEVEMENT_ERROR"
  static let view_leaderboard_error :String = "VIEW_LEADERBOARD_ERROR"
  static let login_error :String = "LOGIN_ERROR"
}

public class SwiftGamesServicesPlugin: NSObject, FlutterPlugin {

  // MARK: - Properties

  var viewController: UIViewController {
    return UIApplication.shared.keyWindow!.rootViewController!
  }

  // MARK: - Authenticate

  func authenticateUser(result: @escaping FlutterResult) {
    let player = GKLocalPlayer.local
    player.authenticateHandler = { vc, error in
      guard error == nil else {
        result()
        result(FlutterError.init(code: ErrorConstants.login_error, message: "Error: Authenticate Handler failed.", details: error?.localizedDescription ?? ""))
        return
      }
      if let vc = vc {
        self.viewController.present(vc, animated: true, completion: {
          if player.isAuthenticated {
            result()
          } else {
            result(FlutterError.init(code: ErrorConstants.login_error, message: "Error: User denied sign in.", details: nil))
          }
        })
      } else if player.isAuthenticated {
        result()
      } else {
        result(FlutterError.init(code: ErrorConstants.login_error, message: "Error: No view controller present, and not authenticated.", details: nil))
      }
    }
  }

  // MARK: - Leaderboard

  func showLeaderboardWith(identifier: String) {
    let vc = GKGameCenterViewController()
    vc.gameCenterDelegate = self
    vc.viewState = .achievements
    vc.leaderboardIdentifier = identifier
    viewController.present(vc, animated: true, completion: nil)
  }

  func report(score: Int64, leaderboardID: String, result: @escaping FlutterResult) {
    let reportedScore = GKScore(leaderboardIdentifier: leaderboardID)
    reportedScore.value = score
    GKScore.report([reportedScore]) { (error) in
      guard error == nil else {
        result(FlutterError.init(code: ErrorConstants.submit_score_error, message: "Error: Score report failed.", details: error?.localizedDescription ?? ""))
        return
      }
      result()
    }
  }

  // MARK: - Achievements

  func showAchievements() {
    let vc = GKGameCenterViewController()
    vc.gameCenterDelegate = self
    vc.viewState = .achievements
    viewController.present(vc, animated: true, completion: nil)
  }

  func report(achievementID: String, percentComplete: Double, result: @escaping FlutterResult) {
    let achievement = GKAchievement(identifier: achievementID)
    achievement.percentComplete = percentComplete
    achievement.showsCompletionBanner = true
    GKAchievement.report([achievement]) { (error) in
      guard error == nil else {
        result(FlutterError.init(code: ErrorConstants.submit_achievement_error, message: "Error: Achievement report failed.", details: error?.localizedDescription ?? ""))
        return
      }
      result()
    }
  }

  // MARK: - FlutterPlugin

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any]
    switch call.method {
    case "unlock":
      let achievementID = (arguments?["achievementID"] as? String) ?? ""
      let percentComplete = (arguments?["percentComplete"] as? Double) ?? 0.0
      report(achievementID: achievementID, percentComplete: percentComplete, result: result)
    case "submitScore":
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      let score = (arguments?["value"] as? Int) ?? 0
      report(score: Int64(score), leaderboardID: leaderboardID, result: result)
    case "showAchievements":
      showAchievements()
      result()
    case "showLeaderboards":
      let leaderboardID = (arguments?["iOSLeaderboardID"] as? String) ?? ""
      showLeaderboardWith(identifier: leaderboardID)
      result()
    case "signIn":
      authenticateUser(result: result)
    default:
      result(FlutterMethodNotImplemented)
      break
    }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "games_services", binaryMessenger: registrar.messenger())
    let instance = SwiftGamesServicesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
}

// MARK: - GKGameCenterControllerDelegate

extension SwiftGamesServicesPlugin: GKGameCenterControllerDelegate {

  public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }
}
