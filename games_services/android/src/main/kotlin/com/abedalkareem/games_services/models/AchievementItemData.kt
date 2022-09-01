package com.abedalkareem.games_services.models

data class AchievementItemData(
  val id: String,
  val name: String,
  val description: String,
  val lockedImage: String?,
  val unlockedImage: String?,
  val completedSteps: Int,
  val totalSteps: Int,
  val unlocked: Boolean,
)