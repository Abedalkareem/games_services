import Flutter
import UIKit
import GameKit

public class SwiftGamesServicesPlugin: NSObject, FlutterPlugin {

  // MARK: - Properties

  var viewController: UIViewController {
    return UIApplication.shared.keyWindow!.rootViewController!
  }

  // MARK: - Authenticate

  func authenticateUser() {
    let player = GKLocalPlayer.localPlayer()
    player.authenticateHandler = { vc, error in
      guard error == nil else {
        print(error?.localizedDescription ?? "")
        return
      }
      if let vc = vc {
        self.viewController.present(vc, animated: true, completion: nil)
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

  func report(score: Int64, leaderboardID: String) {
    let reportedScore = GKScore(leaderboardIdentifier: leaderboardID)
    reportedScore.value = score
    GKScore.report([reportedScore]) { (error) in
      guard error == nil else {
        print(error?.localizedDescription ?? "")
        return
      }
      print("The score submitted to the game center")
    }
  }

  // MARK: - Achievements

  func showAchievements() {
    let vc = GKGameCenterViewController()
    vc.gameCenterDelegate = self
    vc.viewState = .achievements
    viewController.present(vc, animated: true, completion: nil)
  }

  func report(achievementID: String, percentComplete: Double) {
    let achievement = GKAchievement(identifier: achievementID)
    achievement.percentComplete = percentComplete
    achievement.showsCompletionBanner = true
    GKAchievement.report([achievement]) { (error) in
      print(error?.localizedDescription ?? "")
    }
  }

  // MARK: - FlutterPlugin

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any]
    switch call.method {
    case "unlock":
      let achievementID = (arguments?["achievementID"] as? String) ?? ""
      let percentComplete = (arguments?["percentComplete"] as? Double) ?? 0.0
      report(achievementID: achievementID, percentComplete: percentComplete)
    case "submitScore":
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      let score = (arguments?["score"] as? Double) ?? 0.0
      report(score: Int64(score), leaderboardID: leaderboardID)
    case "showAchievements":
      showAchievements()
    case "showLeaderboards":
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      showLeaderboardWith(identifier: leaderboardID)
    case "signIn":
      authenticateUser()
    default:
      break
    }
    result("iOS \(viewController)")
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
