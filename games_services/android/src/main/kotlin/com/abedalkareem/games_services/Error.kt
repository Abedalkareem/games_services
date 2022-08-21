package com.abedalkareem.games_services

enum class PluginError {
  failedToSendScore, failedToGetScore, failedToGetPlayerId, failedToGetPlayerName,
  failedToSendAchievement, failedToShowAchievements, failedToIncrementAchievements,
  failedToAuthenticate, failedToSignout, notAuthenticated,
  notSupportedForThisOSVersion,
  leaderboardNotFound
}

fun PluginError.errorCode(): String {
  when (this) {
    PluginError.failedToSendScore -> {
      return "failed_to_send_score"
    }
    PluginError.failedToGetScore -> {
      return "failed_to_get_score"
    }
    PluginError.failedToSendAchievement -> {
      return "failed_to_send_achievement"
    }
    PluginError.failedToShowAchievements -> {
      return "failed_to_show_achievements"
    }
    PluginError.failedToIncrementAchievements -> {
      return "failed_to_increment_achievements"
    }
    PluginError.failedToAuthenticate -> {
      return "failed_to_authenticate"
    }
    PluginError.notSupportedForThisOSVersion -> {
      return "not_supported_for_this_os_version"
    }
    PluginError.leaderboardNotFound -> {
      return "leaderboard_not_found"
    }
    PluginError.failedToGetPlayerId -> {
      return "failed_to_get_player_id"
    }
    PluginError.failedToGetPlayerName -> {
      return "failed_to_get_player_name"
    }
    PluginError.failedToSignout -> {
      return "failed_to_sign_out"
    }
    PluginError.notAuthenticated -> {
      return "not_authenticated"
    }
  }
}

fun PluginError.errorMessage(): String {
  when (this) {
    PluginError.failedToSendScore -> {
      return "Failed to send the score"
    }
    PluginError.failedToGetScore -> {
      return "Failed to get the score"
    }
    PluginError.failedToSendAchievement -> {
      return "Failed to send the achievement"
    }
    PluginError.failedToShowAchievements -> {
      return "Failed to show achievements"
    }
    PluginError.failedToIncrementAchievements -> {
      return "Failed to increment achievements"
    }
    PluginError.failedToAuthenticate -> {
      return "Failed to authenticate"
    }
    PluginError.notSupportedForThisOSVersion -> {
      return "Not supported for this OS version"
    }
    PluginError.leaderboardNotFound -> {
      return "Leaderboard not found"
    }
    PluginError.failedToGetPlayerId -> {
      return "Failed to get player id"
    }
    PluginError.failedToGetPlayerName -> {
      return "Failed to get player name"
    }
    PluginError.failedToSignout -> {
      return "Failed to sign out"
    }
    PluginError.notAuthenticated -> {
      return "Player not authenticated, Please make sure to call signIn() first"
    }
  }
}