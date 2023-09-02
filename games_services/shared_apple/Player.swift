import GameKit

class Player: BaseGamesServices {
  
  // MARK: - Player Data

  func getPlayerID(result: @escaping FlutterResult) {
    if #available(iOS 12.4, *) {
      let gamePlayerID = currentPlayer.gamePlayerID
      result(gamePlayerID)
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }


  func getPlayerProfileImage(result: @escaping FlutterResult, size: GKPlayer.PhotoSize = GKPlayer.PhotoSize.normal) {
    currentPlayer.loadPhoto(
      for: size,
      withCompletionHandler: { image, error in
        guard error == nil else {
          result(error?.flutterError(code: .failedToGetPlayerProfileImage))
          return
        }
        #if os(macOS)
          let imageData = image?.tiffRepresentation
        #else
          let imageData = image?.pngData()
        #endif
        result(imageData?.base64EncodedString())
      }
    )
  }
  
  func getPlayerName(result: @escaping FlutterResult) {
    let gamePlayerAlias = currentPlayer.alias
    result(gamePlayerAlias)
  }

  func isUnderage(result: @escaping FlutterResult) {
    result(currentPlayer.isUnderage)
  }

  func isMultiplayerGamingRestricted(result: @escaping FlutterResult) {
    if #available(iOS 13.0, *) {
      result(currentPlayer.isMultiplayerGamingRestricted)
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }

  func isPersonalizedCommunicationRestricted(result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      result(currentPlayer.isPersonalizedCommunicationRestricted)
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
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
}
