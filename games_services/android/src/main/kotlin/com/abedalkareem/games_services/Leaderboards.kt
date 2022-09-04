package com.abedalkareem.games_services

import android.app.Activity
import android.content.Intent
import com.abedalkareem.games_services.models.LeaderboardScoreData
import com.abedalkareem.games_services.util.AppImageLoader
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.abedalkareem.games_services.util.errorMessage
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.games.Games
import com.google.android.gms.games.LeaderboardsClient
import com.google.android.gms.games.leaderboard.LeaderboardVariant
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class Leaderboards {

  private val imageLoader = AppImageLoader()
  private var activityPluginBinding: ActivityPluginBinding
  private var leaderboardsClient: LeaderboardsClient? = null
    get() {
      val lastSignedInAccount =
        GoogleSignIn.getLastSignedInAccount(activityPluginBinding.activity) ?: return null
      return Games.getLeaderboardsClient(activityPluginBinding.activity, lastSignedInAccount)
    }

  constructor(activityPluginBinding: ActivityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding
  }

  fun showLeaderboards(activity: Activity?, leaderboardID: String, result: MethodChannel.Result) {
    val onSuccessListener: ((Intent) -> Unit) = { intent ->
      activity?.startActivityForResult(intent, 0)
      result.success(null)
    }
    val onFailureListener: ((Exception) -> Unit) = {
      result.error(PluginError.leaderboardNotFound.errorCode(), "${it.message}", null)
    }
    if (leaderboardID.isEmpty()) {
      leaderboardsClient?.allLeaderboardsIntent
        ?.addOnSuccessListener(onSuccessListener)
        ?.addOnFailureListener(onFailureListener)
    } else {
      leaderboardsClient
        ?.getLeaderboardIntent(leaderboardID)
        ?.addOnSuccessListener(onSuccessListener)
        ?.addOnFailureListener(onFailureListener)
    }
  }

  fun loadLeaderboardScores(
    activity: Activity?,
    leaderboardID: String,
    span: Int,
    leaderboardCollection: Int,
    maxResults: Int,
    result: MethodChannel.Result
  ) {
    activity ?: return
    leaderboardsClient?.loadTopScores(leaderboardID, span, leaderboardCollection, maxResults)
      ?.addOnCompleteListener { task ->
        val data = task.result.get()
        if (data == null) {
          result.error(
            PluginError.failedToLoadLeaderboardScores.errorCode(),
            PluginError.failedToLoadLeaderboardScores.errorMessage(),
            null
          )
          return@addOnCompleteListener
        }
        val handler = CoroutineExceptionHandler { _, exception ->
          result.error(
            PluginError.failedToLoadLeaderboardScores.errorCode(),
            exception.localizedMessage,
            null
          )
        }

        CoroutineScope(Dispatchers.Main + handler).launch {
          val achievements = mutableListOf<LeaderboardScoreData>()
          for (item in data.scores) {
            val lockedImage =
              item.scoreHolderIconImageUri.let { imageLoader.loadImageFromUri(activity, it) }
            achievements.add(
              LeaderboardScoreData(
                item.rank,
                item.displayScore,
                item.rawScore,
                item.timestampMillis,
                item.scoreHolderDisplayName,
                lockedImage,
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
          PluginError.failedToLoadLeaderboardScores.errorCode(),
          PluginError.failedToLoadLeaderboardScores.errorMessage(),
          null
        )
      }
  }

  fun submitScore(leaderboardID: String, score: Int, result: MethodChannel.Result) {
    leaderboardsClient?.submitScoreImmediate(leaderboardID, score.toLong())?.addOnSuccessListener {
      result.success(null)
    }?.addOnFailureListener {
      result.error(PluginError.failedToSendScore.errorCode(), it.localizedMessage, null)
    }
  }

  fun getPlayerScore(leaderboardID: String, result: MethodChannel.Result) {
    leaderboardsClient
      ?.loadCurrentPlayerLeaderboardScore(
        leaderboardID,
        LeaderboardVariant.TIME_SPAN_ALL_TIME,
        LeaderboardVariant.COLLECTION_PUBLIC
      )
      ?.addOnSuccessListener {
        val score = it.get()
        if (score != null) {
          result.success(score.rawScore)
        } else {
          result.error(
            PluginError.failedToGetScore.errorCode(),
            PluginError.failedToGetScore.errorMessage(),
            null
          )
        }
      }?.addOnFailureListener {
        result.error(PluginError.failedToGetScore.errorCode(), it.localizedMessage, null)
      }
  }
}