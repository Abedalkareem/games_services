package com.abedalkareem.games_services.models

enum class Method {
  Unlock, Increment, SubmitScore, ShowLeaderboards, ShowAchievements,
  LoadAchievements, SignIn, IsSignedIn, GetPlayerID, GetPlayerName,
  GetPlayerHiResImage, GetPlayerIconImage, GetPlayerScore, SaveGame,
  LoadGame, GetSavedGames, DeleteGame, LoadLeaderboardScores, GetAuthCode
}

fun Method.value(): String {
  return "$this".lowercase()
}

fun methodsFrom(string: String): Method? {
  return Method.values().firstOrNull { it.value() == string.lowercase() }
}