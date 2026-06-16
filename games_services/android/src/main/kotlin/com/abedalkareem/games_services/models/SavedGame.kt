package com.abedalkareem.games_services.models

data class SavedGame(
  val name: String?,
  val modificationDate: Long?,
  val deviceName: String?,
  val description: String? = null,
  val playedTimeMillis: Long? = null,
  val coverImage: String? = null
)