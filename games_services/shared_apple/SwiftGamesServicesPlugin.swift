#if os(iOS) || os(tvOS)
import Flutter
import UIKit
#else
import FlutterMacOS
#endif
import GameKit

public class SwiftGamesServicesPlugin: NSObject, FlutterPlugin {
  
  // MARK: - Properties
  
  private var viewController: ViewController {
#if os(iOS) || os(tvOS)
    UIApplication.shared.windows.first!.rootViewController!
#else
    NSApplication.shared.windows.first!.contentViewController!
#endif
  }
  
  private var isAuthenticated: Bool {
    GKLocalPlayer.local.isAuthenticated
  }
  
  private var currentPlayer: GKLocalPlayer {
    GKLocalPlayer.local
  }
  
  // MARK: - User
  
  func authenticateUser(result: @escaping FlutterResult) {
    currentPlayer.authenticateHandler = { vc, error in
      guard error == nil else {
        result(error?.flutterError(code: .failedToAuthenticate))
        return
      }
      if let vc = vc {
        self.viewController.show(vc)
      } else if self.currentPlayer.isAuthenticated {
        result(nil)
      } else {
        result(PluginError.failedToAuthenticate.flutterError())
      }
    }
  }
  
  func getPlayerID(result: @escaping FlutterResult) {
    if #available(iOS 12.4, *) {
      let gamePlayerID = currentPlayer.gamePlayerID
      result(gamePlayerID)
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }
  
  func getPlayerName(result: @escaping FlutterResult) {
    let gamePlayerAlias = currentPlayer.alias
    result(gamePlayerAlias)
  }
  
  // MARK: - Leaderboard
  
  func showLeaderboardWith(identifier: String, result: @escaping FlutterResult) {
    let viewController = GKGameCenterViewController()
    viewController.gameCenterDelegate = self
    viewController.viewState = .leaderboards
    viewController.leaderboardIdentifier = identifier
    self.viewController.show(viewController)
    result(nil)
  }
  
  func report(score: Int, leaderboardID: String, result: @escaping FlutterResult) {
    let reportedScore = GKScore(leaderboardIdentifier: leaderboardID)
    reportedScore.value = Int64(score)
    GKScore.report([reportedScore]) { (error) in
      guard error == nil else {
        result(error?.flutterError(code: .failedToSendScore))
        return
      }
      result(nil)
    }
  }
  
  // MARK: - Achievements
  
  func showAchievements(result: @escaping FlutterResult) {
    let viewController = GKGameCenterViewController()
    viewController.gameCenterDelegate = self
    viewController.viewState = .achievements
    self.viewController.show(viewController)
    result(nil)
  }
  
  func report(achievementID: String, percentComplete: Double, result: @escaping FlutterResult) {    
    let achievement = GKAchievement(identifier: achievementID)
    achievement.percentComplete = percentComplete
    achievement.showsCompletionBanner = true
    GKAchievement.report([achievement]) { (error) in
      guard error == nil else {
        result(error?.flutterError(code: .failedToSendAchievement))
        return
      }
      result(nil)
    }
  }
  
  // MARK: - AccessPoint
  
  func showAccessPoint(location: String, result: @escaping FlutterResult) {
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
      result(nil)
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }
  
  func hideAccessPoint(result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      GKAccessPoint.shared.isActive = false
      result(nil)
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }
  
  // MARK: - FlutterPlugin
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any]
    switch call.method {
    case Methods.unlock:
      let achievementID = (arguments?["achievementID"] as? String) ?? ""
      let percentComplete = (arguments?["percentComplete"] as? Double) ?? 0.0
      report(achievementID: achievementID, percentComplete: percentComplete, result: result)
    case Methods.submitScore:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      let score = (arguments?["value"] as? Int) ?? 0
      report(score: score, leaderboardID: leaderboardID, result: result)
    case Methods.showAchievements:
      showAchievements(result: result)
    case Methods.showLeaderboards:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      showLeaderboardWith(identifier: leaderboardID, result: result)
    case Methods.signIn:
      authenticateUser(result: result)
    case Methods.isSignedIn:
      result(isAuthenticated)
    case Methods.hideAccessPoint:
      hideAccessPoint(result: result)
    case Methods.showAccessPoint:
      let location = (arguments?["location"] as? String) ?? ""
      showAccessPoint(location: location, result: result)
    case Methods.getPlayerID:
      getPlayerID(result: result)
    case Methods.getPlayerName:
      getPlayerName(result: result)
    default:
      result(FlutterMethodNotImplemented)
      break
    }
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
#if os(iOS) || os(tvOS)
    let messenger = registrar.messenger()
#else
    let messenger = registrar.messenger
#endif
    let channel = FlutterMethodChannel(name: "games_services", binaryMessenger: messenger)
    let instance = SwiftGamesServicesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
}

// MARK: - GKGameCenterControllerDelegate

extension SwiftGamesServicesPlugin: GKGameCenterControllerDelegate {
  
  public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    self.viewController.dismiss(gameCenterViewController)
  }
}

// MARK: -

enum Methods {
  static let unlock = "unlock"
  static let submitScore = "submitScore"
  static let showLeaderboards = "showLeaderboards"
  static let showAchievements = "showAchievements"
  static let isSignedIn = "isSignedIn"
  static let getPlayerID = "getPlayerID"
  static let getPlayerName = "getPlayerName"
  static let showAccessPoint = "showAccessPoint"
  static let hideAccessPoint = "hideAccessPoint"
  static let signIn = "signIn"
}
