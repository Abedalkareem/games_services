import GameKit
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

class Leaderboards: BaseGamesServices {
  
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
          guard let leaderboard = leaderboards.first else {
            result(PluginError.failedToLoadLeaderboardScores.flutterError())
            return
          }
          let (_, scores, _) = try await leaderboard.loadEntries(for: GKLeaderboard.PlayerScope(rawValue: leaderboardCollection) ?? .global,
                                                                 timeScope: GKLeaderboard.TimeScope(rawValue: span) ?? .allTime,
                                                                 range: NSRange(location: 1, length: maxResults))
          var items = [LeaderboardScoreData]()
          for item in scores {
            #if os(macOS)
            let imageData = try? await item.player.loadPhoto(for: .normal).tiffRepresentation
            #else
            let imageData = try? await item.player.loadPhoto(for: .normal).pngData()
            #endif
            let scoreHolderIconImage = imageData?.base64EncodedString()
            items.append(LeaderboardScoreData(rank: item.rank,
                                              displayScore: item.formattedScore,
                                              rawScore: item.score,
                                              timestampMillis: Int(item.date.timeIntervalSince1970),
                                              scoreHolder: PlayerData(
                                                displayName: item.player.displayName, playerID: item.player.gamePlayerID, teamPlayerID: item.player.teamPlayerID,
                                                iconImage: scoreHolderIconImage
                                              )))
          }
          if let data = try? JSONEncoder().encode(items) {
            let string = String(data: data, encoding: String.Encoding.utf8)
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
  
}

