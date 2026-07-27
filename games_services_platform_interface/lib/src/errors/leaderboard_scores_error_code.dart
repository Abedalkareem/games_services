/// Stable `PlatformException.code` values returned while loading leaderboard
/// scores.
abstract final class LeaderboardScoresErrorCode {
  /// The player is not authenticated.
  static const notAuthenticated = 'not_authenticated';

  /// The player declined Google Play Games friends-list access.
  ///
  /// This code is only returned on Android.
  static const friendsListAccessDenied = 'friends_list_access_denied';

  /// The native operation was canceled.
  ///
  /// This code is only returned by GameKit.
  static const operationCanceled = 'operation_canceled';

  /// The scores could not be loaded for any other reason.
  static const failedToLoad = 'failed_to_load_leaderboard_scores';
}
