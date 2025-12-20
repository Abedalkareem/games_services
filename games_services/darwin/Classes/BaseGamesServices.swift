import GameKit
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

public class BaseGamesServices: NSObject {
  
  // MARK: - Properties
  
#if os(iOS) || os(tvOS)
  var viewController: UIViewController? {
    let scenes = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
    let window = scenes
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    return window?.rootViewController
  }
#else
  var viewController: NSViewController? {
    return NSApp.keyWindow?.contentViewController
    ?? NSApp.mainWindow?.contentViewController
  }
#endif
  
  var currentPlayer: GKLocalPlayer {
    GKLocalPlayer.local
  }
  
}

// MARK: - GKGameCenterControllerDelegate

extension BaseGamesServices: GKGameCenterControllerDelegate {
  
  public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismiss()
  }
}
