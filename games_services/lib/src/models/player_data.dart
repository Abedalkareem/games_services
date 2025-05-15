import 'package:games_services_platform_interface/models.dart';

import '../player.dart';

export 'package:games_services_platform_interface/models.dart' show PlayerData;

// Resuse `PlayerData` class from platform interface to avoid redundancy. Adds
// the `hiResImage` getter.
extension PlayerDataX on PlayerData {
  /// Retrieve player's high resolution profile photo.
  Future<String?> get hiResImage => Player.getPlayerHiResImage();
}
