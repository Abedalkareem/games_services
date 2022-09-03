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
  
  func getPlayerScore(leaderboardID: String, result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      Task {
        do {
          let leaderboard = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
          let response = try await leaderboard.first?.loadEntries(for: [currentPlayer], timeScope: .allTime)
          let (localPlayerEntry, _) = response ?? (nil, nil)
          result(localPlayerEntry?.score ?? 0)
        } catch {
          result(error.flutterError(code: .failedToGetScore))
        }
      }
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }
  
  func loadLeaderboardScores(leaderboardID: String, span: Int, leaderboardCollection: Int, maxResults: Int, result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      Task {
        do {
          let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
          print("Start leaderboard \(leaderboards.count)")
          guard let leaderboard = leaderboards.first else {
            result(PluginError.failedToLoadLeaderboardScores.flutterError())
            return
          }
          let (_, scores, _) = try await leaderboard.loadEntries(for: GKLeaderboard.PlayerScope(rawValue: leaderboardCollection) ?? .global,
                                                                 timeScope: GKLeaderboard.TimeScope(rawValue: span) ?? .allTime,
                                                                 range: NSRange(location: 1, length: maxResults))
          print("Got scores \(scores.count)")
          var items = [LeaderboardScoreData]()
          for item in scores {
            print("Start parsing \(scores.count)")
            let imageData = try? await item.player.loadPhoto(for: .normal).pngData()
            let image = imageData?.base64EncodedString()
            items.append(LeaderboardScoreData(rank: item.rank,
                                              displayScore: item.formattedScore,
                                              rawScore: item.score,
                                              timestampMillis: Int(item.date.timeIntervalSince1970),
                                              scoreHolderDisplayName: item.player.displayName,
                                             scoreHolderIconImage: image))
          }
          if let data = try? JSONEncoder().encode(items) {
            let string = String(data: data, encoding: String.Encoding.utf8)
            print("Parsed")
            result(string)
          } else {
            result(PluginError.failedToLoadLeaderboardScores.flutterError())
          }
          
        } catch {
          result(error.flutterError(code: .failedToLoadLeaderboardScores))
        }
      }
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
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
  
  func loadAchievements(result: @escaping FlutterResult) {
    if #available(iOS 13.0, *) {
      Task {
        do {
          let achievements = try await GKAchievement.loadAchievements()
          let descriptions = try await GKAchievementDescription.loadAchievementDescriptions()
          
          let achievementsMap = descriptions.reduce(into: [GKAchievementDescription: GKAchievement?]()) { result, description in
            result[description] = achievements.first(where: { $0.identifier == description.identifier })
          }
          
          let incompleteAchievementImageData = GKAchievementDescription.incompleteAchievementImage()
          let incompleteAchievementImage = incompleteAchievementImageData.pngData()?.base64EncodedString()
          var items = [AchievementItemData]()
          for (description, achievement) in achievementsMap {
            let imageData = try? await description.loadImage().pngData()
            let image = imageData?.base64EncodedString()
            let isCompleted = achievement?.isCompleted ?? false
            let achievementDescription = isCompleted ? description.achievedDescription : description.unachievedDescription
            items.append(AchievementItemData(id: description.identifier,
                                             name: description.title,
                                             description: achievementDescription,
                                             lockedImage: incompleteAchievementImage,
                                             unlockedImage: image,
                                             completedSteps: Int(achievement?.percentComplete ?? 0),
                                             unlocked: isCompleted))
          }
          if let data = try? JSONEncoder().encode(items) {
            let string = String(data: data, encoding: String.Encoding.utf8)
            result(string)
          } else {
            result(PluginError.failedToLoadAchievements.flutterError())
          }
          
        } catch {
          result(error.flutterError(code: .failedToLoadAchievements))
        }
      }
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }
  
  // MARK: - Save game
  
  func saveGame(name: String, data: String, result: @escaping FlutterResult) {
    guard let data = data.data(using: .utf8) else {
      result(PluginError.failedToSaveGame.flutterError)
      return }
    currentPlayer.saveGameData(data, withName: name) { savedGame, error in
      guard error == nil else {
        result(error?.flutterError(code: .failedToSaveGame))
        return
      }
      result(nil)
    }
  }
  
  func getSavedGames(result: @escaping FlutterResult) {
    currentPlayer.fetchSavedGames(completionHandler: { savedGames, error in
      guard error == nil else {
        result(error?.flutterError(code: .failedToGetSavedGames))
        return
      }
      let items = savedGames?
        .map({ SavedGame(name: $0.name ?? "",
                         modificationDate: UInt64($0.modificationDate?.timeIntervalSince1970 ?? 0),
                         deviceName: $0.deviceName ?? "") }) ?? []
      if let data = try? JSONEncoder().encode(items) {
        print(data)
        let string = String(data: data, encoding: String.Encoding.utf8)
        result(string)
      } else {
        result(PluginError.failedToGetSavedGames.flutterError())
      }
    })
  }
  
  func loadGame(name: String, result: @escaping FlutterResult) {
    currentPlayer.fetchSavedGames(completionHandler: { savedGames, error in
      guard error == nil else {
        result(error?.flutterError(code: .failedToLoadGame))
        return
      }
      
      guard let item = savedGames?
        .first(where: { $0.name == name }) else {
        result(PluginError.failedToLoadGame.flutterError())
        return
      }
      item.loadData { data, error in
        guard let data = data, error == nil else {
          result(error?.flutterError(code: .failedToLoadGame))
          return
        }
        let string = String(data: data, encoding: String.Encoding.utf8)
        result(string)
      }
    })
  }
  
  func deleteGame(name: String, result: @escaping FlutterResult) {
    currentPlayer.deleteSavedGames(withName: name) { error in
      guard error == nil else {
        result(error?.flutterError(code: .failedToDeleteSavedGame))
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
    case Methods.getPlayerScore:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      getPlayerScore(leaderboardID: leaderboardID, result: result)
    case Methods.saveGame:
      let data = (arguments?["data"] as? String) ?? ""
      let name = (arguments?["name"] as? String) ?? ""
      saveGame(name: name, data: data, result: result)
    case Methods.loadGame:
      let name = (arguments?["name"] as? String) ?? ""
      loadGame(name: name, result: result)
    case Methods.getSavedGames:
      getSavedGames(result: result)
    case Methods.deleteGame:
      let name = (arguments?["name"] as? String) ?? ""
      deleteGame(name: name, result: result)
    case Methods.loadAchievements:
      loadAchievements(result: result)
    case Methods.loadLeaderboardScores:
      let leaderboardID = (arguments?["leaderboardID"] as? String) ?? ""
      let span = (arguments?["span"] as? Int) ?? 0
      let leaderboardCollection = (arguments?["leaderboardCollection"] as? Int) ?? 0
      let maxResults = (arguments?["maxResults"] as? Int) ?? 10
      loadLeaderboardScores(leaderboardID: leaderboardID,
                            span: span,
                            leaderboardCollection: leaderboardCollection,
                            maxResults: maxResults,
                            result: result)
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
    self.viewController.dismiss()
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
  static let getPlayerScore = "getPlayerScore"
  static let showAccessPoint = "showAccessPoint"
  static let hideAccessPoint = "hideAccessPoint"
  static let signIn = "signIn"
  static let saveGame = "saveGame"
  static let loadGame = "loadGame"
  static let getSavedGames = "getSavedGames"
  static let deleteGame = "deleteGame"
  static let loadAchievements = "loadAchievements"
  static let loadLeaderboardScores = "loadLeaderboardScores"
}

// MARK: -

struct SavedGame: Codable {
  var name: String
  var modificationDate: UInt64
  var deviceName: String
}

struct AchievementItemData: Codable {
  var id: String
  var name: String
  var description: String
  var lockedImage: String?
  var unlockedImage: String?
  var completedSteps: Int
  var totalSteps: Int = 100
  var unlocked: Bool
}

struct LeaderboardScoreData: Codable {
  var rank: Int
  var displayScore: String
  var rawScore: Int
  var timestampMillis: Int
  var scoreHolderDisplayName: String
  var scoreHolderIconImage: String?
}
