import '../util/device.dart';

class Achievement {
  String? androidID;
  String iOSID;
  double percentComplete;
  int steps;

  String? get id {
    return Device.isPlatformAndroid ? androidID : iOSID;
  }

  Achievement(
      {this.androidID,
      this.iOSID = "",
      this.percentComplete = 100,
      this.steps = 0});
}
