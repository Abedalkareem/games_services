#if os(iOS) || os(tvOS)
import Flutter
import UIKit
#else
import FlutterMacOS
#endif
import GameKit

public class SwiftGamesServicesPlugin: NSObject, FlutterPlugin {
  
  // MARK: - Properties

  private let player = Player()
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
    case .isSignedIn:
      result(auth.isAuthenticated)
    case .loadAchievements:
      achievements.loadAchievements(result: result)
    case .showAchievements:
      achievements.showAchievements(result: result)
    case .unlock:
      let achievementID = (arguments?["achievementID"] as? String) ?? ""
      let percentComplete = (arguments?["percentComplete"] as? Double) ?? 0.0
      achievements.report(achievementID: achievementID, percentComplete: percentComplete, result: result)
    case .showLeaderboards:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      leaderboards.showLeaderboardWith(identifier: leaderboardID, result: result)
    case .getPlayerScore:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      leaderboards.getPlayerScore(leaderboardID: leaderboardID, result: result)
    case .loadLeaderboardScores:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      let span = (arguments?["span"] as? Int) ?? 0
      let leaderboardCollection = (arguments?["leaderboardCollection"] as? Int) ?? 0
      let maxResults = (arguments?["maxResults"] as? Int) ?? 10
      leaderboards.loadLeaderboardScores(leaderboardID: leaderboardID,
                            span: span,
                            leaderboardCollection: leaderboardCollection,
                            maxResults: maxResults,
                            result: result)
    case .submitScore:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      let score = (arguments?["value"] as? Int) ?? 0
      leaderboards.report(score: score, leaderboardID: leaderboardID, result: result)
    case .hideAccessPoint:
      player.hideAccessPoint(result: result)
    case .showAccessPoint:
      let location = (arguments?["location"] as? String) ?? ""
      player.showAccessPoint(location: location, result: result)
    case .getPlayerID:
      player.getPlayerID(result: result)
    case .getPlayerName:
      player.getPlayerName(result: result)
    case .playerIsUnderage:
      player.isUnderage(result: result)
    case .playerIsMultiplayerGamingRestricted:
      player.isMultiplayerGamingRestricted(result: result)
    case .playerIsPersonalizedCommunicationRestricted:
      player.isPersonalizedCommunicationRestricted(result: result)
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
  }
}
