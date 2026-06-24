
#if os(iOS) || os(tvOS)
import Flutter
#else
import FlutterMacOS
#endif

enum Messages {
  static let alreadyAuthenticated = "Player already authenticated"
  static let authenticatedSuccessfully = "Player authenticated successfully"
  static let success = "Success"
}
