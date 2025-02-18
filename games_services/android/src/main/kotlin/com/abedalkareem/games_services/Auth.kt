package com.abedalkareem.games_services

import android.app.Activity
import android.content.Intent
import com.abedalkareem.games_services.models.Method
import com.abedalkareem.games_services.models.PendingOperation
import com.abedalkareem.games_services.models.PlayerData
import com.abedalkareem.games_services.models.value
import com.abedalkareem.games_services.util.AppImageLoader
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.google.android.gms.games.AuthenticationResult
import com.google.android.gms.games.GamesSignInClient
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.PlayersClient
import com.google.android.gms.tasks.Task
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

private const val RC_SIGN_IN = 9000

class Auth(private var activityPluginBinding: ActivityPluginBinding):
  EventChannel.StreamHandler {

  private val gamesSignInClient: GamesSignInClient
    get() {
      return PlayGames.getGamesSignInClient(activityPluginBinding.activity)
    }

  private val playersClient: PlayersClient
    get() {
      return PlayGames.getPlayersClient(activityPluginBinding.activity)
    }

  private val gson = Gson()
  private var pendingOperation: PendingOperation? = null
  private var eventSink: EventChannel.EventSink? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    gamesSignInClient.isAuthenticated.addOnCompleteListener { isAuthenticatedTask: Task<AuthenticationResult> ->
      val isAuthenticated = isAuthenticatedTask.isSuccessful &&
        isAuthenticatedTask.result.isAuthenticated
      if (isAuthenticated) {
        playersClient.currentPlayer.addOnSuccessListener { player ->
          var playerData = PlayerData(
            player.displayName,
            player.playerId,
            null
          )
          val handler = CoroutineExceptionHandler { _, exception ->
            events!!.success(gson.toJson(playerData) ?: "")
          }
          CoroutineScope(Dispatchers.Main + handler).launch {
            val image = player.iconImageUri?.let {
              AppImageLoader().loadImageFromUri(activityPluginBinding.activity, it)
            }
            playerData = playerData.copy(iconImage = image)
            events!!.success(gson.toJson(playerData) ?: "")
          }
        }.addOnFailureListener {
          events!!.error(PluginError.FailedToAuthenticate.errorCode(), "", null)
        }
      } else {
        events!!.error(PluginError.FailedToAuthenticate.errorCode(), "", null)
      }
    }
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }

  fun signIn(result: MethodChannel.Result) {
    pendingOperation = PendingOperation(Method.SignIn.value(), result, activityPluginBinding.activity)
    gamesSignInClient.signIn().addOnSuccessListener {
      it?.let { result ->
        if (result.isAuthenticated) {
          playersClient.currentPlayer.addOnSuccessListener { player ->
            var playerData = PlayerData(
              player.displayName,
              player.playerId,
              null
            )
            val handler = CoroutineExceptionHandler { _, exception ->
              eventSink?.success(gson.toJson(playerData) ?: "")
              finishPendingOperationWithSuccess()
            }
            CoroutineScope(Dispatchers.Main + handler).launch {
              val image = player.iconImageUri?.let {
                AppImageLoader().loadImageFromUri(activityPluginBinding.activity, it)
              }
              playerData = playerData.copy(iconImage = image)
              eventSink?.success(gson.toJson(playerData) ?: "")
              finishPendingOperationWithSuccess()
            }
          }.addOnFailureListener {
            finishPendingOperationWithError(PluginError.FailedToAuthenticate.errorCode(), it.message ?: "")
          }
        } else {
          finishPendingOperationWithError(PluginError.FailedToAuthenticate.errorCode(), "")
        }
      }
    }.addOnFailureListener {
      finishPendingOperationWithError(PluginError.FailedToAuthenticate.errorCode(), it.message ?: "")
    }
  }

  fun getAuthCode(clientID: String, forceRefreshToken: Boolean, result: MethodChannel.Result) {
    gamesSignInClient.requestServerSideAccess(clientID, forceRefreshToken).addOnSuccessListener {
      result.success(it)
    }.addOnFailureListener {
      result.error(PluginError.FailedToGetAuthCode.errorCode(), it.message ?: "", null)
    }
  }

  fun getPlayerProfileImage(result: MethodChannel.Result) {
    playersClient.currentPlayer.addOnSuccessListener { player ->
        val handler = CoroutineExceptionHandler { _, exception ->
          result.error(
            PluginError.FailedToGetPlayerProfileImage.errorCode(),
            exception.localizedMessage,
            null
          )
        }
        CoroutineScope(Dispatchers.Main + handler).launch {
          val image = player.hiResImageUri
              ?.let { AppImageLoader().loadImageFromUri(activityPluginBinding.activity, it) }
          result.success(image)
        }
      }.addOnFailureListener {
        result.error(PluginError.FailedToGetPlayerProfileImage.errorCode(), it.localizedMessage, null)
      }
  }

  //region PendingOperation
  private fun finishPendingOperationWithSuccess() {
    pendingOperation?.result?.success(null)
    pendingOperation = null
  }

  private fun finishPendingOperationWithError(errorCode: String, errorMessage: String) {
    eventSink?.error(PluginError.FailedToAuthenticate.errorCode(), errorMessage, null)
    pendingOperation?.result?.error(errorCode, errorMessage, null)
    pendingOperation = null
  }
  //endregion
}