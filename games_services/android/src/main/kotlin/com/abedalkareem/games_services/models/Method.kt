package com.abedalkareem.games_services.models

enum class Method {
  Unlock, Increment, SubmitScore, ShowLeaderboards, ShowAchievements,
  LoadAchievements, SilentSignIn, IsSignedIn, GetPlayerID, GetPlayerName,
  GetPlayerScore, SignOut, SaveGame, LoadGame, GetSavedGames, DeleteGame,
  LoadLeaderboardScores
}

fun Method.value(): String {
  return "$this".lowercase()
}

fun methodsFrom(string: String): Method? {
  return Method.values().firstOrNull { it.value() == string.lowercase() }
}