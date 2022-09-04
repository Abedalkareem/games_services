class Auth: BaseGamesServices {
  
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
  
}

