#if os(iOS) || os(tvOS)
import Flutter
import UIKit
#else
import FlutterMacOS
#endif
import GameKit

public class SwiftGamesServicesPlugin: NSObject, FlutterPlugin {
  
  // MARK: - Properties

  private let auth = Auth()
  private let saveGame = SaveGame()
  private let achievements = Achievements()
  private let leaderboards = Leaderboards()

  // MARK: - FlutterPlugin
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let method = Method(rawValue: call.method) else {
      result(FlutterMethodNotImplemented)
      return
    }
    let arguments = call.arguments as? [String: Any]
    switch method {
    case .signIn:
      auth.authenticateUser(result: result)
    case .loadAchievements:
      achievements.loadAchievements(result: result)
    case .showAchievements:
      achievements.showAchievements(result: result)
    case .resetAchievements:
      achievements.resetAchievements(result: result)    
    case .unlock:
      let achievementID = (arguments?["achievementID"] as? String) ?? ""
      let percentComplete = (arguments?["percentComplete"] as? Double) ?? 0.0
      let showsCompletionBanner = (arguments?["showsCompletionBanner"] as? Bool) ?? true
      achievements.report(achievementID: achievementID, percentComplete: percentComplete, showsCompletionBanner: showsCompletionBanner, result: result)
    case .showLeaderboards:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      leaderboards.showLeaderboardWith(identifier: leaderboardID, result: result)
    case .getPlayerScore:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      leaderboards.getPlayerScore(leaderboardID: leaderboardID, result: result)
    case .getPlayerScoreObject:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      let span = (arguments?["span"] as? Int) ?? 0
      let leaderboardCollection = (arguments?["leaderboardCollection"] as? Int) ?? 0
      leaderboards.getPlayerScoreObject(leaderboardID: leaderboardID,
                            span: span,
                            leaderboardCollection: leaderboardCollection,
                            result: result)      
    case .loadLeaderboardScores:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      let playerCentered = (arguments?["playerCentered"] as? Bool) ?? false
      let span = (arguments?["span"] as? Int) ?? 0
      let leaderboardCollection = (arguments?["leaderboardCollection"] as? Int) ?? 0
      let maxResults = (arguments?["maxResults"] as? Int) ?? 10
      leaderboards.loadLeaderboardScores(leaderboardID: leaderboardID,
                            playerCentered: playerCentered,
                            span: span,
                            leaderboardCollection: leaderboardCollection,
                            maxResults: maxResults,
                            result: result)
    case .submitScore:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      let score = (arguments?["value"] as? Int) ?? 0
      let token = (arguments?["token"] as? String) ?? ""
      leaderboards.report(score: score, leaderboardID: leaderboardID, token: token, result: result)
    case .hideAccessPoint:
      auth.hideAccessPoint(result: result)
    case .showAccessPoint:
      let location = (arguments?["location"] as? String) ?? ""
      auth.showAccessPoint(location: location, result: result)
    case .getPlayerHiResImage:
      auth.getPlayerProfileImage(result: result)
    case .saveGame:
      let data = (arguments?["data"] as? String) ?? ""
      let name = (arguments?["name"] as? String) ?? ""
      saveGame.saveGame(name: name, data: data, result: result)
    case .loadGame:
      let name = (arguments?["name"] as? String) ?? ""
      saveGame.loadGame(name: name, result: result)
    case .getSavedGames:
      saveGame.getSavedGames(result: result)
    case .deleteGame:
      let name = (arguments?["name"] as? String) ?? ""
      saveGame.deleteGame(name: name, result: result)
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
    let eventChannel = FlutterEventChannel(name: "games_services.player", binaryMessenger: messenger)
    eventChannel.setStreamHandler(instance.auth)
  }
}
