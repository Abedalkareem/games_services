package com.abedalkareem.games_services

import android.app.Activity
import android.content.Intent
import com.abedalkareem.games_services.models.LeaderboardScoreData
import com.abedalkareem.games_services.models.PlayerData
import com.abedalkareem.games_services.util.AppImageLoader
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.abedalkareem.games_services.util.errorMessage
import com.google.android.gms.games.LeaderboardsClient
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.leaderboard.LeaderboardVariant
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import android.util.Log
import com.google.android.gms.games.FriendsResolutionRequiredException
import io.flutter.plugin.common.PluginRegistry

class Leaderboards(private var activityPluginBinding: ActivityPluginBinding) :
  PluginRegistry.ActivityResultListener {

  private val imageLoader = AppImageLoader()
  private val leaderboardsClient: LeaderboardsClient
    get() {
      return PlayGames.getLeaderboardsClient(activityPluginBinding.activity)
    }

  // used to retry [loadLeaderboardScore] after being granted friends list access
  private var leaderboardID: String? = null;
  private var playerCentered: Boolean? = null;
  private var span: Int? = null;
  private var leaderboardCollection: Int? = null;
  private var maxResults: Int? = null;
  private var result: MethodChannel.Result? = null;
  private var errorMessage: String? = null;

  // handle result from friends list permission request
  override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {
    activityPluginBinding.removeActivityResultListener(this)
    return if (requestCode == 26703) {
      // retry loadLeaderboard if permission granted, otherwise throw the original error
      if (resultCode == -1 && leaderboardID != null) {
        loadLeaderboardScores(
          activityPluginBinding.activity,
          leaderboardID!!,
          playerCentered!!,
          span!!,
          leaderboardCollection!!,
          maxResults!!,
          result!!
        )
      } else {
        result?.error(
          PluginError.FailedToLoadLeaderboardScores.errorCode(),
          errorMessage,
          null,
        )
      }
      leaderboardID = null
      playerCentered = null
      span = null
      leaderboardCollection = null
      maxResults = null
      result = null
      errorMessage = null;
      true
    } else {
      false
    }
  }

  fun showLeaderboards(activity: Activity?, leaderboardID: String, result: MethodChannel.Result) {
    val onSuccessListener: ((Intent) -> Unit) = { intent ->
      activity?.startActivityForResult(intent, 0)
      result.success(null)
    }
    val onFailureListener: ((Exception) -> Unit) = {
      result.error(PluginError.LeaderboardNotFound.errorCode(), it.message, null)
    }
    if (leaderboardID.isEmpty()) {
      leaderboardsClient.allLeaderboardsIntent
        .addOnSuccessListener(onSuccessListener)
        .addOnFailureListener(onFailureListener)
    } else {
      leaderboardsClient
        .getLeaderboardIntent(leaderboardID)
        .addOnSuccessListener(onSuccessListener)
        .addOnFailureListener(onFailureListener)
    }
  }

//  private

  fun loadLeaderboardScores(
    activity: Activity?,
    leaderboardID: String,
    playerCentered: Boolean,
    span: Int,
    leaderboardCollection: Int,
    maxResults: Int,
    result: MethodChannel.Result
  ) {
    activity ?: return
    (if (playerCentered) leaderboardsClient.loadPlayerCenteredScores(leaderboardID, span, leaderboardCollection, maxResults)
        else leaderboardsClient.loadTopScores(leaderboardID, span, leaderboardCollection, maxResults))
      .addOnSuccessListener { annotatedData ->
        val data = annotatedData.get()

        if (data == null) {
          result.error(
            PluginError.FailedToLoadLeaderboardScores.errorCode(),
            PluginError.FailedToLoadLeaderboardScores.errorMessage(),
            null
          )
          return@addOnSuccessListener
        }
        val handler = CoroutineExceptionHandler { _, exception ->
          result.error(
            PluginError.FailedToLoadLeaderboardScores.errorCode(),
            exception.localizedMessage,
            null
          )
        }

        CoroutineScope(Dispatchers.Main + handler).launch {
          val scores = mutableListOf<LeaderboardScoreData>()
          for (item in data.scores) {
            val scoreHolderIconImage =
              item.scoreHolderIconImageUri.let { imageLoader.loadImageFromUri(activity, it) }
            scores.add(
              LeaderboardScoreData(
                item.rank,
                item.displayScore,
                item.rawScore,
                item.timestampMillis,
                PlayerData(
                  item.scoreHolderDisplayName,
                  item.scoreHolder?.playerId,
                  scoreHolderIconImage
                ),
                item.scoreTag
              )
            )
          }
          val gson = Gson()
          val string = gson.toJson(scores) ?: ""
          data.release()
          result.success(string)
        }
      }
      .addOnFailureListener {
        // handle friends list CONSENT_REQUIRED error to trigger permission request dialog
        if (it is FriendsResolutionRequiredException) {
          this.leaderboardID = leaderboardID
          this.playerCentered = playerCentered
          this.span = span
          this.leaderboardCollection = leaderboardCollection
          this.maxResults = maxResults
          this.result = result
          this.errorMessage = it.localizedMessage
          val pendingIntent = it.resolution
          activityPluginBinding.addActivityResultListener(this)
          activity.startIntentSenderForResult(
            pendingIntent.intentSender,
            26703,
            null,
            0,
            0,
            0
          )
          Log.i("GamesServices", "Friends list access requested")
        } else {
          result.error(
            PluginError.FailedToLoadLeaderboardScores.errorCode(),
            it.localizedMessage,
            null
          )
        }
      }
  }

  fun submitScore(leaderboardID: String, score: Int, token: String, result: MethodChannel.Result) {
    leaderboardsClient.submitScoreImmediate(leaderboardID, score.toLong(), token).addOnSuccessListener {
      result.success(null)
    }
      .addOnFailureListener {
      result.error(PluginError.FailedToSendScore.errorCode(), it.localizedMessage, null)
    }
  }

  fun getPlayerScore(leaderboardID: String, result: MethodChannel.Result) {
    leaderboardsClient
      .loadCurrentPlayerLeaderboardScore(
        leaderboardID,
        LeaderboardVariant.TIME_SPAN_ALL_TIME,
        LeaderboardVariant.COLLECTION_PUBLIC
      )
      .addOnSuccessListener {
        val score = it.get()
        if (score != null) {
          result.success(score.rawScore)
        } else {
          result.error(
            PluginError.FailedToGetScore.errorCode(),
            PluginError.FailedToGetScore.errorMessage(),
            null
          )
        }
      }
      .addOnFailureListener {
        result.error(PluginError.FailedToGetScore.errorCode(), it.localizedMessage, null)
      }
  }
  
  fun getPlayerScoreObject(
    activity: Activity?,
    leaderboardID: String,
    span: Int,
    leaderboardCollection: Int,
    result: MethodChannel.Result
  ) {
    activity ?: return
    leaderboardsClient?.loadCurrentPlayerLeaderboardScore(leaderboardID, span, leaderboardCollection)
      ?.addOnSuccessListener { snapshotResult ->
        val data = snapshotResult.get()
        if (data == null) {
          result.error(
            PluginError.FailedToGetScore.errorCode(),
            PluginError.FailedToGetScore.errorMessage(),
            null
          )
          return@addOnSuccessListener
        }
        val handler = CoroutineExceptionHandler { _, exception ->
          result.error(
            PluginError.FailedToGetScore.errorCode(),
            exception.localizedMessage,
            null
          )
        }

        CoroutineScope(Dispatchers.Main + handler).launch {
          val scoreHolderIconImage =
            data.scoreHolderIconImageUri.let { imageLoader.loadImageFromUri(activity, it) }

          val score = LeaderboardScoreData(
              data.rank,
              data.displayScore,
              data.rawScore,
              data.timestampMillis,
              PlayerData(
                  data.scoreHolderDisplayName,
                  data.scoreHolder?.playerId,
                  scoreHolderIconImage
              ),
              data.scoreTag
            )
                   
          val gson = Gson()
          val string = gson.toJson(score) ?: ""
          
          result.success(string)
        }
      }
      ?.addOnFailureListener {
        result.error(
          PluginError.FailedToGetScore.errorCode(),
          it.localizedMessage,
          null
        )
      }
  }  
}
