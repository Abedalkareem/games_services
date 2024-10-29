#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

class Auth: BaseGamesServices {
    
  // track if previous sign in was cancelled (failed) for debugging
  // this prevents hanging on `signIn` when hot reloading
  #if DEBUG
    var debugSignInFailed = false
  #endif

  func authenticateUser(result: @escaping FlutterResult) {
    #if DEBUG
      if (self.debugSignInFailed && !isAuthenticated) {
        result(PluginError.failedToAuthenticate.flutterError())
        return
      }
    #endif

    if (isAuthenticated) {
      result(nil)
    } else {
      currentPlayer.authenticateHandler = { vc, error in
        guard error == nil else {
          #if DEBUG
            self.debugSignInFailed = true
          #endif
          result(error!.flutterError(code: .failedToAuthenticate))
          return
        }
        if let vc = vc {
          self.viewController.show(vc)
        } else {
          result(PluginError.failedToAuthenticate.flutterError())
        }
      }
    }
  }

  var isAuthenticated: Bool {
    currentPlayer.isAuthenticated
  }
  
}

