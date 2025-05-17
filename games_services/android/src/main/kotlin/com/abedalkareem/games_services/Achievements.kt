package com.abedalkareem.games_services

import android.app.Activity
import com.abedalkareem.games_services.models.AchievementItemData
import com.abedalkareem.games_services.util.AppImageLoader
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.abedalkareem.games_services.util.errorMessage
import com.google.android.gms.games.AchievementsClient
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.achievement.Achievement
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class Achievements(private var activityPluginBinding: ActivityPluginBinding) {

  private val imageLoader = AppImageLoader()
  private val achievementClient: AchievementsClient
    get() {
      return PlayGames.getAchievementsClient(activityPluginBinding.activity)
    }

  fun showAchievements(activity: Activity?, result: MethodChannel.Result) {
    achievementClient.achievementsIntent
      .addOnSuccessListener { intent ->
      activity?.startActivityForResult(intent, 0)
      result.success(null)
    }
      .addOnFailureListener {
      result.error(PluginError.FailedToShowAchievements.errorCode(), it.localizedMessage, null)
    }
  }

  fun unlock(achievementID: String, result: MethodChannel.Result) {
    achievementClient
      .unlockImmediate(achievementID)
      .addOnSuccessListener {
      result.success(null)
    }
      .addOnFailureListener {
      result.error(PluginError.FailedToSendAchievement.errorCode(), it.localizedMessage, null)
    }
  }

  fun increment(achievementID: String, count: Int, result: MethodChannel.Result) {
    achievementClient
      .incrementImmediate(achievementID, count)
      .addOnSuccessListener {
        result.success(null)
      }
      .addOnFailureListener {
        result.error(
          PluginError.FailedToIncrementAchievements.errorCode(),
          it.localizedMessage,
          null
        )
      }
  }

  fun loadAchievements(activity: Activity?, forceRefresh: Boolean, result: MethodChannel.Result) {
    activity ?: return
    achievementClient
      .load(forceRefresh)
      .addOnSuccessListener { annotatedData ->
        val data = annotatedData.get()

        if (data == null) {
          result.error(
            PluginError.FailedToLoadAchievements.errorCode(),
            PluginError.FailedToLoadAchievements.errorMessage(),
            null
          )
          return@addOnSuccessListener
        }
        val handler = CoroutineExceptionHandler { _, exception ->
          result.error(
            PluginError.FailedToLoadAchievements.errorCode(),
            exception.localizedMessage,
            null
          )
        }
        CoroutineScope(Dispatchers.IO + handler).launch {
          val achievements = mutableListOf<AchievementItemData>()
          for (item in data) {
            val lockedImage =
              item.revealedImageUri?.let { imageLoader.loadImageFromUri(activity, it) }
            val unlockedImage =
              item.unlockedImageUri?.let { imageLoader.loadImageFromUri(activity, it) }
            achievements.add(
              AchievementItemData(
                item.achievementId,
                item.name,
                item.description,
                lockedImage,
                unlockedImage,
                if (item.type == Achievement.TYPE_INCREMENTAL) item.currentSteps else 0,
                if (item.type == Achievement.TYPE_INCREMENTAL) item.totalSteps else 0,
                item.state == Achievement.STATE_UNLOCKED,
              )
            )
          }
          val gson = Gson()
          val string = gson.toJson(achievements) ?: ""
          data.release()
          withContext(Dispatchers.Main) {
            result.success(string)
          }
        }
      }
      .addOnFailureListener {
        result.error(
          PluginError.FailedToLoadAchievements.errorCode(),
          it.localizedMessage,
          null
        )
      }
  }

}
