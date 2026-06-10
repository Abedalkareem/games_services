import 'dart:io' show Platform;

class Device {
  static var isPlatformAndroid = Platform.isAndroid;
  static var isPlatformIOS = Platform.isIOS;
  static var isPlatformMacOS = Platform.isMacOS;
  static var isPlatformWindows = Platform.isWindows;
}
