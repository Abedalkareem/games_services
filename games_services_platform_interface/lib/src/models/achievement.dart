import '../util/device.dart';

class Achievement {
  String? androidID;
  String iOSID;
  bool showsCompletionBanner;
  double percentComplete;
  int steps;

  String? get id {
    return Device.isPlatformAndroid ? androidID : iOSID;
  }

  Achievement(
      {this.androidID, this.iOSID = "", this.showsCompletionBanner = true, this.percentComplete = 100, this.steps = 0});
}
