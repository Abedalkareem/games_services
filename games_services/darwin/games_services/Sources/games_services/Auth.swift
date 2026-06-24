import GameKit
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

class Auth: BaseGamesServices {
  
  // MARK: - Properties
  
  var isAuthenticated: Bool {
    currentPlayer.isAuthenticated
  }
  
  // MARK: - Private Properties
  
  private var eventSink: FlutterEventSink?
  private var result: FlutterResult?
  private var isHandlerSet = false
  
  // MARK: - Public Methods
  
  func authenticateUser(result: @escaping FlutterResult) {
    
    log("Please add the Game Center capability to your project. If you already have done that please ignore this message.")
    
    // handler should only be set once. if set, the user is authenticated,
    // the handler is in use, or the user should authenticate from GameCenter
    // via device settings. this also prevents previous issues with this method
    // not returning on subsequent calls
    if (isHandlerSet) {
      if (isAuthenticated || self.result != nil) {
        result(Messages.alreadyAuthenticated)
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
    currentPlayer.authenticateHandler = { [weak self] viewController, error in
      guard let self else { return }
      if let viewController {
        self.viewController?.show(viewController)
      } else if let error, !self.isAuthenticated {
        self.eventSink?(error.flutterError(code: .failedToAuthenticate))
        self.result?(error.flutterError(code: .failedToAuthenticate))
        self.result = nil
      } else {
        self.triggerNewPlayerEvent(shouldUpdateResults: true)
      }
    }
    isHandlerSet = true
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
      result(Messages.success)
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }
  
  func hideAccessPoint(result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      GKAccessPoint.shared.isActive = false
      result(Messages.success)
    } else {
      result(PluginError.notSupportedForThisOSVersion.flutterError())
    }
  }
  
  func fetchIdentityVerificationSignature(result: @escaping FlutterResult) {
    currentPlayer.fetchItems(forIdentityVerificationSignature: { (publicKeyURL, signature, salt, timestamp, error) in
      guard error == nil else {
        result(error?.flutterError(code: .failedToFetchIdentityVerification))
        return
      }
      
      let verificationData: [String: Any] = [
        "publicKeyURL": publicKeyURL?.absoluteString ?? "",
        "signature": signature?.base64EncodedString() ?? "",
        "salt": salt?.base64EncodedString() ?? "",
        "timestamp": timestamp
      ]
      
      result(verificationData)
    })
  }
  
  // MARK: - Private Methods
  
  private func triggerNewPlayerEvent(shouldUpdateResults: Bool = false) {
    let isPersistent = self.currentPlayer.scopedIDsArePersistent()
    var player = PlayerData(
      displayName: self.currentPlayer.alias,
      playerID: isPersistent ? self.currentPlayer.gamePlayerID : nil,
      teamPlayerID: isPersistent ? self.currentPlayer.teamPlayerID : nil,
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
      withCompletionHandler: { [weak self] image, error in
        guard let self else { return }
        guard error == nil else {
          if let data = try? JSONEncoder().encode(player) {
            self.eventSink?(String(data: data, encoding: String.Encoding.utf8))
          }
          if shouldUpdateResults {
            self.result?(Messages.authenticatedSuccessfully)
            self.result = nil
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
          self.eventSink?(String(data: data, encoding: String.Encoding.utf8))
        }
        if shouldUpdateResults {
          self.result?(Messages.authenticatedSuccessfully)
          self.result = nil
        }
      }
    )
  }
}

// MARK: - FlutterStreamHandler

extension Auth: FlutterStreamHandler {
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    guard isAuthenticated else {
      events(nil)
      return nil
    }
    triggerNewPlayerEvent()
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}
