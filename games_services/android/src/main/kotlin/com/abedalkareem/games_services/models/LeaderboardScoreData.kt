package com.abedalkareem.games_services.models

data class LeaderboardScoreData(
  val rank: Long,
  val displayScore: String,
  val rawScore: Long,
  val timestampMillis: Long,
  val scoreHolderDisplayName: String,
  val scoreHolderIconImage: String?
)