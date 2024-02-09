package com.abedalkareem.games_services.util

enum class PluginError {
  FailedToSendScore, FailedToGetScore, FailedToGetPlayerId, FailedToGetPlayerName,
  FailedToGetPlayerProfileImage, FailedToSendAchievement, FailedToShowAchievements,
  FailedToIncrementAchievements, FailedToLoadAchievements, FailedToAuthenticate,
  FailedToGetAuthCode, NotAuthenticated, NotSupportedForThisOSVersion, FailedToSaveGame,
  FailedToLoadGame, FailedToGetSavedGames, LeaderboardNotFound, FailedToDeleteSavedGame,
  FailedToLoadLeaderboardScores
}

fun PluginError.errorCode(): String {
  when (this) {
    PluginError.FailedToSendScore -> {
      return "failed_to_send_score"
    }
    PluginError.FailedToGetScore -> {
      return "failed_to_get_score"
    }
    PluginError.FailedToSendAchievement -> {
      return "failed_to_send_achievement"
    }
    PluginError.FailedToShowAchievements -> {
      return "failed_to_show_achievements"
    }
    PluginError.FailedToIncrementAchievements -> {
      return "failed_to_increment_achievements"
    }
    PluginError.FailedToLoadAchievements -> {
      return "failed_to_load_achievements"
    }
    PluginError.FailedToAuthenticate -> {
      return "failed_to_authenticate"
    }
    PluginError.FailedToGetAuthCode -> {
      return "failed_to_get_auth_code"
    }
    PluginError.NotSupportedForThisOSVersion -> {
      return "not_supported_for_this_os_version"
    }
    PluginError.LeaderboardNotFound -> {
      return "leaderboard_not_found"
    }
    PluginError.FailedToGetPlayerId -> {
      return "failed_to_get_player_id"
    }
    PluginError.FailedToGetPlayerName -> {
      return "failed_to_get_player_name"
    }
    PluginError.FailedToGetPlayerProfileImage -> {
      return "failed_to_get_player_profile_image"
    }
    PluginError.FailedToGetAuthCode -> {
      return "failed_to_get_auth_code"
    }
    PluginError.NotAuthenticated -> {
      return "not_authenticated"
    }
    PluginError.FailedToSaveGame -> {
      return "failed_to_save_game"
    }
    PluginError.FailedToLoadGame -> {
      return "failed_to_load_game"
    }
    PluginError.FailedToGetSavedGames -> {
      return "failed_to_get_saved_games"
    }
    PluginError.FailedToDeleteSavedGame -> {
      return "failed_to_delete_saved_game"
    }
    PluginError.FailedToLoadLeaderboardScores -> {
      return "failed_to_load_leaderboard_scores"
    }
  }
}

fun PluginError.errorMessage(): String {
  when (this) {
    PluginError.FailedToSendScore -> {
      return "Failed to send the score"
    }
    PluginError.FailedToGetScore -> {
      return "Failed to get the score"
    }
    PluginError.FailedToSendAchievement -> {
      return "Failed to send the achievement"
    }
    PluginError.FailedToShowAchievements -> {
      return "Failed to show achievements"
    }
    PluginError.FailedToIncrementAchievements -> {
      return "Failed to increment achievements"
    }
    PluginError.FailedToLoadAchievements -> {
      return "Failed to get the achievements list"
    }
    PluginError.FailedToAuthenticate -> {
      return "Failed to authenticate"
    }
    PluginError.FailedToGetAuthCode -> {
      return "Failed to get authCode"
    }
    PluginError.NotSupportedForThisOSVersion -> {
      return "Not supported for this OS version"
    }
    PluginError.LeaderboardNotFound -> {
      return "Leaderboard not found"
    }
    PluginError.FailedToGetPlayerId -> {
      return "Failed to get player id"
    }
    PluginError.FailedToGetPlayerName -> {
      return "Failed to get player name"
    }
    PluginError.FailedToGetPlayerProfileImage -> {
      return "Failed to get player profile image"
    }
    PluginError.FailedToGetAuthCode -> {
      return "Failed to get server auth code"
    }
    PluginError.NotAuthenticated -> {
      return "Player not authenticated, Please make sure to call signIn() first"
    }
    PluginError.FailedToSaveGame -> {
      return "Failed to save game"
    }
    PluginError.FailedToLoadGame -> {
      return "Failed to load game"
    }
    PluginError.FailedToGetSavedGames -> {
      return "Failed to get saved games"
    }
    PluginError.FailedToDeleteSavedGame -> {
      return "Failed to delete saved game"
    }
    PluginError.FailedToLoadLeaderboardScores -> {
      return "Failed to load leaderboard scores"
    }
  }
}
