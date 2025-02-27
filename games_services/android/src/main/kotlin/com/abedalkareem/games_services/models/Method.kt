package com.abedalkareem.games_services.models

enum class Method {
  Unlock, Increment, SubmitScore, ShowLeaderboards, ShowAchievements,
  LoadAchievements, SignIn, GetAuthCode, GetPlayerHiResImage, GetPlayerScore,
  GetPlayerScoreObject, SaveGame, LoadGame, GetSavedGames, DeleteGame, LoadLeaderboardScores
}

fun Method.value(): String {
  return "$this".lowercase()
}

fun methodsFrom(string: String): Method? {
  return Method.values().firstOrNull { it.value() == string.lowercase() }
}