import FlutterMacOS
import AppKit
import GameKit

public class SwiftGamesServicesPlugin: NSObject, FlutterPlugin {

  // MARK: - Properties

  var viewController: NSViewController {
    return NSApplication.shared.windows.first!.contentViewController!
  }

  private var isAuthenticated: Bool {
    get { return GKLocalPlayer.local.isAuthenticated }
  }

  // MARK: - Authenticate

  func authenticateUser(result: @escaping FlutterResult) {
    let player = GKLocalPlayer.local
    player.authenticateHandler = { vc, error in
      guard error == nil else {
        result(error?.localizedDescription ?? "")
        return
      }
      if let vc = vc {
        self.viewController.presentAsSheet(vc)
      } else if player.isAuthenticated {
        result("success")
      } else {
        result("error")
      }
    }
  }

  // MARK: - Leaderboard

  func showLeaderboardWith(identifier: String) {
    let vc = GKGameCenterViewController(state: .leaderboards)
    vc.gameCenterDelegate = self
    // 'viewState' was deprecated in macOS 11.0: Use -initWithState: instead
    //  vc.viewState = .achievements
    // 'leaderboardIdentifier' was deprecated in macOS 11.0: Use -initWithLeaderboard: instead
    // vc.leaderboardIdentifier = identifier
    self.viewController.presentAsSheet(vc)
  }

  func report(score: Int64, leaderboardID: String, result: @escaping FlutterResult) {
    let reportedScore = GKScore(leaderboardIdentifier: leaderboardID)
    reportedScore.value = score
    GKScore.report([reportedScore]) { (error) in
      guard error == nil else {
        result(error?.localizedDescription ?? "")
        return
      }
      result("success")
    }
  }

  // MARK: - Achievements

  func showAchievements() {
    let vc = GKGameCenterViewController(state: .achievements)
    vc.gameCenterDelegate = self
    // 'viewState' was deprecated in macOS 11.0: Use -initWithState: instead
    // vc.viewState = .achievements
    self.viewController.presentAsSheet(vc)
  }

  func report(achievementID: String, percentComplete: Double, result: @escaping FlutterResult) {
    let achievement = GKAchievement(identifier: achievementID)
    achievement.percentComplete = percentComplete
    achievement.showsCompletionBanner = true
    GKAchievement.report([achievement]) { (error) in
      guard error == nil else {
        result(error?.localizedDescription ?? "")
        return
      }
      result("success")
    }
  }
  
  // MARK: - AccessPoint

  func showAccessPoint(location: String) {
    if #available(iOS 14.0, *) {
      var gkLocation: GKAccessPoint.Location = .topLeading
      switch location {
      case "topLeading":
        gkLocation = .topLeading
      case "topTrailing":
        gkLocation = .topTrailing
      case "bottomLeading":
        gkLocation = .bottomLeading
      case "bottomTrailing":
        gkLocation = .bottomTrailing
      default:
        break
      }
      GKAccessPoint.shared.location = gkLocation
      GKAccessPoint.shared.isActive = true
    }
  }
  
  func hideAccessPoint() {
    if #available(iOS 14.0, *) {
      GKAccessPoint.shared.isActive = false
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
      result("success")
    case "showLeaderboards":
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      showLeaderboardWith(identifier: leaderboardID)
      result("success")
    case "signIn":
      authenticateUser(result: result)
    case "isSignedIn":
      result(isAuthenticated)
    case "hideAccessPoint":
      hideAccessPoint()
    case "showAccessPoint":
      let location = (arguments?["location"] as? String) ?? ""
      showAccessPoint(location: location)
    default:
      result("unimplemented")
      break
    }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "games_services", binaryMessenger: registrar.messenger)
    let instance = SwiftGamesServicesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
}

// // MARK: - GKGameCenterControllerDelegate

extension SwiftGamesServicesPlugin: GKGameCenterControllerDelegate {
  public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismiss(true)
  }
}
