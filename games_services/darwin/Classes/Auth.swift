import GameKit
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

class Auth: BaseGamesServices, FlutterStreamHandler {
  
  private var eventSink: FlutterEventSink?
  private var result: FlutterResult?
  private var isHandlerSet = false

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    if (isAuthenticated) {
      var player = PlayerData(
        displayName: currentPlayer.alias,
        playerID: currentPlayer.gamePlayerID,
        teamPlayerID: currentPlayer.teamPlayerID,
        isUnderage: currentPlayer.isUnderage
      )
      if #available(iOS 13.0, *) {
        player.isMultiplayerGamingRestricted = currentPlayer.isMultiplayerGamingRestricted
      }
      if #available(iOS 14.0, *) {
        player.isPersonalizedCommunicationRestricted = currentPlayer.isPersonalizedCommunicationRestricted
      }
      currentPlayer.loadPhoto(
        for: GKPlayer.PhotoSize.small,
        withCompletionHandler: { image, error in
          guard error == nil else {
            if let data = try? JSONEncoder().encode(player) {
              events(String(data: data, encoding: String.Encoding.utf8))
            }
            return
          }
          #if os(macOS)
            let imageData = image?.tiffRepresentation
          #else
            let imageData = image?.pngData()
          #endif
          player.iconImage = imageData?.base64EncodedString()
          if let data = try? JSONEncoder().encode(player) {
            events(String(data: data, encoding: String.Encoding.utf8))
          }
        }
      )
    } else {
      events(nil)
    }
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  func authenticateUser(result: @escaping FlutterResult) {
    // handler should only be set once. if set, the user is authenticated,
    // the handler is in use, or the user should authenticate from GameCenter
    // via device settings. this also prevents previous issues with this method
    // not returning on subsequent calls
    if (isHandlerSet) {
      if (isAuthenticated || self.result != nil) {
        result(nil)
      } else {
        eventSink?(PluginError.failedToAuthenticate.flutterError())
        result(PluginError.failedToAuthenticate.flutterError())
      }
      return
    }
    // store result for use later in auth handler. this prevents the auth
    // method from returning before the GameCenter auth flow has completed,
    // allowing for guaranteed results in any following auth checks
    self.result = result
    currentPlayer.authenticateHandler = { vc, error in
        if let vc = vc {
          self.viewController.show(vc)
        } else if(error != nil) {
          self.eventSink?(error!.flutterError(code: .failedToAuthenticate))
          self.result?(error!.flutterError(code: .failedToAuthenticate))
          self.result = nil
        } else {
          var player = PlayerData(
            displayName: self.currentPlayer.alias,
            playerID: self.currentPlayer.gamePlayerID,
            teamPlayerID: self.currentPlayer.teamPlayerID,
            isUnderage: self.currentPlayer.isUnderage
          )
          if #available(iOS 13.0, *) {
            player.isMultiplayerGamingRestricted = self.currentPlayer.isMultiplayerGamingRestricted
          }
          if #available(iOS 14.0, *) {
            player.isPersonalizedCommunicationRestricted = self.currentPlayer.isPersonalizedCommunicationRestricted
          }
          self.currentPlayer.loadPhoto(
            for: GKPlayer.PhotoSize.small,
            withCompletionHandler: { image, error in
              guard error == nil else {
                if let data = try? JSONEncoder().encode(player) {
                  self.eventSink?(String(data: data, encoding: String.Encoding.utf8))
                }
                self.result?(nil)
                self.result = nil
                return
              }
              #if os(macOS)
                let imageData = image?.tiffRepresentation
              #else
                let imageData = image?.pngData()
              #endif
              player.iconImage = imageData?.base64EncodedString()
              if let data = try? JSONEncoder().encode(player) {
                self.eventSink?(String(data: data, encoding: String.Encoding.utf8))
              }
              self.result?(nil)
              self.result = nil
            }
          )
        }
    }
    isHandlerSet = true
  }

  var isAuthenticated: Bool {
    currentPlayer.isAuthenticated
  }

  func getPlayerProfileImage(result: @escaping FlutterResult) {
    currentPlayer.loadPhoto(
      for: GKPlayer.PhotoSize.normal,
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

