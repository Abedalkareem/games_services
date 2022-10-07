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
      result(nil)
    }
  }

  func isPersonalizedCommunicationRestricted(result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      result(currentPlayer.isPersonalizedCommunicationRestricted)
    } else {
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
}
