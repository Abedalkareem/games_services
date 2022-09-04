package com.abedalkareem.games_services

import android.app.Activity
import com.abedalkareem.games_services.models.AchievementItemData
import com.abedalkareem.games_services.util.AppImageLoader
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.abedalkareem.games_services.util.errorMessage
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.games.AchievementsClient
import com.google.android.gms.games.Games
import com.google.android.gms.games.achievement.Achievement
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class Achievements {

  private val imageLoader = AppImageLoader()
  private var activityPluginBinding: ActivityPluginBinding
  private var achievementClient: AchievementsClient? = null
    get() {
      val lastSignedInAccount =
        GoogleSignIn.getLastSignedInAccount(activityPluginBinding.activity) ?: return null
      return Games.getAchievementsClient(activityPluginBinding.activity, lastSignedInAccount)
    }

  constructor(activityPluginBinding: ActivityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding
  }

  fun showAchievements(activity: Activity?, result: MethodChannel.Result) {
    achievementClient?.achievementsIntent?.addOnSuccessListener { intent ->
      activity?.startActivityForResult(intent, 0)
      result.success(null)
    }?.addOnFailureListener {
      result.error(PluginError.failedToShowAchievements.errorCode(), "${it.message}", null)
    }
  }

  fun unlock(achievementID: String, result: MethodChannel.Result) {
    achievementClient?.unlockImmediate(achievementID)?.addOnSuccessListener {
      result.success(null)
    }?.addOnFailureListener {
      result.error(PluginError.failedToSendAchievement.errorCode(), it.localizedMessage, null)
    }
  }

  fun increment(achievementID: String, count: Int, result: MethodChannel.Result) {
    achievementClient?.incrementImmediate(achievementID, count)
      ?.addOnSuccessListener {
        result.success(null)
      }?.addOnFailureListener {
        result.error(
          PluginError.failedToIncrementAchievements.errorCode(),
          it.localizedMessage,
          null
        )
      }
  }

  fun loadAchievements(activity: Activity?, result: MethodChannel.Result) {
    activity ?: return
    achievementClient?.load(true)
      ?.addOnCompleteListener { task ->
        val data = task.result.get()
        if (data == null) {
          result.error(
            PluginError.failedToLoadAchievements.errorCode(),
            PluginError.failedToLoadAchievements.errorMessage(),
            null
          )
          return@addOnCompleteListener
        }
        val handler = CoroutineExceptionHandler { _, exception ->
          result.error(
            PluginError.failedToLoadAchievements.errorCode(),
            exception.localizedMessage,
            null
          )
        }
        CoroutineScope(Dispatchers.Main + handler).launch {
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
          result.success(string)
        }
      }
      ?.addOnFailureListener {
        result.error(
          PluginError.failedToLoadAchievements.errorCode(),
          PluginError.failedToLoadAchievements.errorMessage(),
          null
        )
      }
  }

}