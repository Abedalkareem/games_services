import 'package:games_services_platform_interface/models.dart';

/// Mutable authentication state for a single PlayFab session.
class PlayFabSession {
  String? sessionTicket;
  String? entityToken;
  String? entityId;
  String? entityType;
  String? playFabId;

  /// The most recently resolved player, cached so the [GamesServicesPlayFab]
  /// `player` stream can replay it to new listeners.
  PlayerData? player;

  bool get isSignedIn => sessionTicket != null;

  /// The `title_player_account` entity, as PlayFab's File/Object APIs expect it.
  Map<String, dynamic>? get entity =>
      entityId == null ? null : {"Id": entityId, "Type": entityType};

  void clear() {
    sessionTicket = null;
    entityToken = null;
    entityId = null;
    entityType = null;
    playFabId = null;
    player = null;
  }
}
