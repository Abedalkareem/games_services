import GameKit
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

class Friends: BaseGamesServices {

  func showFriendsList(result: @escaping FlutterResult) {
    if #available(iOS 15.0, macOS 12.0, *) {
        let viewController = GKGameCenterViewController(state: GKGameCenterViewControllerState.localPlayerFriendsList)
        viewController.gameCenterDelegate = self
        self.viewController?.show(viewController)
        result(Messages.success)
    } else {
        result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }

  func getFriendsAccessStatus(result: @escaping FlutterResult) {
    if #available(iOS 14.5, macOS 11.3, *) {
        Task {
            do {
                let authorizationStatus = try await GKLocalPlayer.local.loadFriendsAuthorizationStatus()
                switch(authorizationStatus) {
                    case .notDetermined:
                        result("notDetermined")
                    case .denied, .restricted:
                        result("denied")
                    case .authorized:
                        result("granted")
                    default:
                        result("unknown")
                }
            } catch {
                result(PluginError.missingDescriptionKey.flutterError())
            }
        }
    } else {
        result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }

  func loadFriends(result: @escaping FlutterResult) {
    if #available(iOS 14.5, macOS 11.3, *) {
        Task {
            do {
                let friends = try await GKLocalPlayer.local.loadFriends()
                var items = [PlayerData]()
                for player in friends {
#if os(macOS)
                    let imageData = try? await player.loadPhoto(for: .normal).tiffRepresentation
#else
                    let imageData = try? await player.loadPhoto(for: .normal).pngData()
#endif
                    let playerIconImage = imageData?.base64EncodedString()
                    items.append(PlayerData(
                        displayName: player.displayName,
                        playerID: player.gamePlayerID,
                        teamPlayerID: player.teamPlayerID,
                        iconImage: playerIconImage
                    ))
                }
                if let data = try? JSONEncoder().encode(items) {
                    let string = String(data: data, encoding: String.Encoding.utf8)
                    result(string)
                } else {
                    result(PluginError.failedToLoadFriends.flutterError())
                }
            } catch {
                result(PluginError.failedToLoadFriends.flutterError())
            }
        }
    } else {
        result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }

  func viewPlayerProfile(playerID: String, result: @escaping FlutterResult) {
    if (GKLocalPlayer.local.gamePlayerID == playerID) {
        let viewController = GKGameCenterViewController(state: GKGameCenterViewControllerState.localPlayerProfile)
        viewController.gameCenterDelegate = self
        self.viewController?.show(viewController)
        result(Messages.success)
    }

    if #available(iOS 18.0, macOS 15.0, *) {
        GKPlayer.loadPlayers(forIdentifiers: [playerID], withCompletionHandler: { players, error in
            guard let player = players?.first, error == nil else {
                result(PluginError.failedToLoadPlayer.flutterError())
                return
            }
            let viewController = GKGameCenterViewController(player: player)
            viewController.gameCenterDelegate = self
            self.viewController?.show(viewController)
            result(Messages.success)
        })
    } else {
        result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }

  func sendFriendRequest(result: @escaping FlutterResult) {
    if #available(iOS 15.0, macOS 12.0, *) {
        do {
            guard let viewController = self.viewController as? ViewController else {
                result(PluginError.failedToSendFriendRequest.flutterError())
                return
            }
            try await GKLocalPlayer.local.presentFriendRequestCreator(from: viewController)
            result(Messages.success)
        } catch {
            result(PluginError.failedToSendFriendRequest.flutterError())
        }
    } else {
        result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }
}