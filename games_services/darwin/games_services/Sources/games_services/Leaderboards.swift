import GameKit
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

class Leaderboards: BaseGamesServices {
  
  func showLeaderboardWith(identifier: String, span: Int, leaderboardCollection: Int, result: @escaping FlutterResult) {
    let viewController = GKGameCenterViewController(
      leaderboardID: identifier,
      playerScope: GKLeaderboard.PlayerScope(rawValue: leaderboardCollection) ?? .global,
      timeScope: GKLeaderboard.TimeScope(rawValue: span) ?? .allTime
    )
    viewController.gameCenterDelegate = self
    self.viewController?.show(viewController)
    result(Messages.success)
  }
  
  func report(score: Int, leaderboardID: String, token: String, result: @escaping FlutterResult) {
    GKLeaderboard.loadLeaderboards(IDs: [leaderboardID]) { leaderboards, error in
      guard error == nil else {
        result(error?.flutterError(code: .failedToSendScore))
        return
      }
      guard let leaderboard = leaderboards?.first else {
        log("[Report score] No leaderboard found")
        result(PluginError.leaderboardNotFound.flutterError())
        return
      }
      leaderboard.submitScore(score, context: Int(token) ?? 0, player: GKLocalPlayer.local) { error in
        guard error == nil else {
          result(error?.flutterError(code: .failedToSendScore))
          return
        }
        result(Messages.success)
      }
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
  
  func getPlayerScoreObject(leaderboardID: String, span: Int, leaderboardCollection: Int, result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      Task {
        do {
          let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
          guard let leaderboard = leaderboards.first else {
            result(PluginError.failedToGetScore.flutterError())
            return
          }
          let response = try await leaderboard.loadEntries(for: [currentPlayer],
                                                           timeScope: GKLeaderboard.TimeScope(rawValue: span) ?? .allTime)
          
          let (localPlayerEntry, _) = response
          
          if let localPlayerEntry {
#if os(macOS)
            let imageData = try? await localPlayerEntry.player.loadPhoto(for: .normal).tiffRepresentation
#else
            let imageData = try? await localPlayerEntry.player.loadPhoto(for: .normal).pngData()
#endif
            let scoreHolderIconImage = imageData?.base64EncodedString()
            let score = LeaderboardScoreData(rank: localPlayerEntry.rank,
                                             displayScore: localPlayerEntry.formattedScore,
                                             rawScore: localPlayerEntry.score,
                                             timestampMillis: Int(localPlayerEntry.date.timeIntervalSince1970),
                                             scoreHolder: PlayerData(
                                              displayName: localPlayerEntry.player.displayName,
                                              playerID: localPlayerEntry.player.gamePlayerID,
                                              teamPlayerID: localPlayerEntry.player.teamPlayerID,
                                              iconImage: scoreHolderIconImage
                                             ),
                                             token: String(localPlayerEntry.context))
            
            if let data = try? JSONEncoder().encode(score) {
              let string = String(data: data, encoding: String.Encoding.utf8)
              result(string)
            } else {
              result(PluginError.failedToGetScore.flutterError())
            }
          } else {
            result(PluginError.failedToGetScore.flutterError())
          }
        } catch {
          result(error.flutterError(code: .failedToGetScore))
        }
      }
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }
  
  func loadLeaderboardScores(leaderboardID: String, playerCentered: Bool, span: Int, leaderboardCollection: Int, maxResults: Int, result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      Task {
        do {
          let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
          guard let leaderboard = leaderboards.first else {
            result(PluginError.failedToLoadLeaderboardScores.flutterError())
            return
          }
          var startLocation = 1
          if (playerCentered) {
            let response = try await leaderboard.loadEntries(for: [currentPlayer],
                                                             timeScope: GKLeaderboard.TimeScope(rawValue: span) ?? .allTime)
            
            let (localPlayerEntry, _) = response
            if let localPlayerEntry {
              startLocation = localPlayerEntry.rank - maxResults / 2
              if (startLocation < 1) {
                startLocation = 1
              }
            }
          }
          let (_, scores, _) = try await leaderboard.loadEntries(for: GKLeaderboard.PlayerScope(rawValue: leaderboardCollection) ?? .global,
                                                                 timeScope: GKLeaderboard.TimeScope(rawValue: span) ?? .allTime,
                                                                 range: NSRange(location: startLocation, length: maxResults))
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
                                                displayName: item.player.displayName,
                                                playerID: item.player.gamePlayerID,
                                                teamPlayerID: item.player.teamPlayerID,
                                                iconImage: scoreHolderIconImage
                                              ),
                                              token: String(item.context)))
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
  
  func loadPreviousOccurrence(leaderboardID: String, span: Int, result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      Task {
        do {
          let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
          guard let leaderboard = try await leaderboards.first?.loadPreviousOccurrence() else {
            result(PluginError.failedToLoadPreviousOccurrence.flutterError())
            return
          }
          
          let response = try await leaderboard.loadEntries(for: [currentPlayer],
                                                           timeScope: GKLeaderboard.TimeScope(rawValue: span) ?? .allTime)
          
          let (previousEntry, _) = response
          
          if let previousEntry {
            // Load the previous occurrence of the score
#if os(macOS)
            let imageData = try? await previousEntry.player.loadPhoto(for: .normal).tiffRepresentation
#else
            let imageData = try? await previousEntry.player.loadPhoto(for: .normal).pngData()
#endif
            let scoreHolderIconImage = imageData?.base64EncodedString()
            let score = LeaderboardScoreData(rank: previousEntry.rank,
                                             displayScore: previousEntry.formattedScore,
                                             rawScore: previousEntry.score,
                                             timestampMillis: Int(previousEntry.date.timeIntervalSince1970),
                                             scoreHolder: PlayerData(
                                              displayName: previousEntry.player.displayName,
                                              playerID: previousEntry.player.gamePlayerID,
                                              teamPlayerID: previousEntry.player.teamPlayerID,
                                              iconImage: scoreHolderIconImage
                                             ),
                                             token: String(previousEntry.context))
            
            if let data = try? JSONEncoder().encode(score) {
              let string = String(data: data, encoding: String.Encoding.utf8)
              result(string)
            } else {
              result(PluginError.failedToLoadPreviousOccurrence.flutterError())
            }
            
          } else {
            result(PluginError.failedToLoadPreviousOccurrence.flutterError())
          }
        } catch {
          result(error.flutterError(code: .failedToLoadPreviousOccurrence))
        }
      }
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }
  
}

