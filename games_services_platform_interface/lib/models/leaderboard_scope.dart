import 'package:games_services_platform_interface/helpers.dart';

enum PlayerScope { global, friendsOnly }

extension PlayerScopeValue on PlayerScope {
  int get value {
    switch (this) {
      case PlayerScope.global:
        return 0;
      case PlayerScope.friendsOnly:
        return Helpers.isPlatformAndroid ? 3 : 1;
    }
  }
}
