package com.abedalkareem.games_services

import android.app.Activity
import com.abedalkareem.games_services.util.AppImageLoader
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.google.android.gms.games.PlayGames
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class Player {

  fun getPlayerID(activity: Activity?, result: MethodChannel.Result) {
    activity ?: return
    PlayGames.getPlayersClient(activity)
      .currentPlayerId.addOnSuccessListener {
        result.success(it)
      }.addOnFailureListener {
        result.error(PluginError.FailedToGetPlayerId.errorCode(), it.localizedMessage, null)
      }
  }

  fun getPlayerName(activity: Activity?, result: MethodChannel.Result) {
    activity ?: return
    PlayGames.getPlayersClient(activity)
      .currentPlayer
      .addOnSuccessListener { player ->
        result.success(player.displayName)
      }.addOnFailureListener {
        result.error(PluginError.FailedToGetPlayerName.errorCode(), it.localizedMessage, null)
      }
  }

  fun getPlayerProfileImage(activity: Activity?, result: MethodChannel.Result, hiRes: Boolean = true) {
    activity ?: return
    PlayGames.getPlayersClient(activity)
      .currentPlayer
      .addOnSuccessListener { player ->
        val handler = CoroutineExceptionHandler { _, exception ->
          result.error(
            PluginError.FailedToGetPlayerProfileImage.errorCode(),
            exception.localizedMessage,
            null
          )
        }
        CoroutineScope(Dispatchers.Main + handler).launch {
          val image = (if (hiRes) player.hiResImageUri
              else player.iconImageUri)?.let { AppImageLoader().loadImageFromUri(activity, it) }
          result.success(image)
        }
      }.addOnFailureListener {
        result.error(PluginError.FailedToGetPlayerProfileImage.errorCode(), it.localizedMessage, null)
      }
  }
}