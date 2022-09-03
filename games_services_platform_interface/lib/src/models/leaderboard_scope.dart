import 'package:games_services_platform_interface/src/util/device.dart';

enum PlayerScope { global, friendsOnly }

extension PlayerScopeValue on PlayerScope {
  int get value {
    switch (this) {
      case PlayerScope.global:
        return 0;
      case PlayerScope.friendsOnly:
        return Device.isPlatformAndroid ? 3 : 1;
    }
  }
}
