package com.abedalkareem.games_services

import android.app.Activity
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.games.Games
import io.flutter.plugin.common.MethodChannel

class Player {

  fun getPlayerID(activity: Activity?, result: MethodChannel.Result) {
    activity ?: return
    val lastSignedInAccount = GoogleSignIn.getLastSignedInAccount(activity) ?: return
    Games.getPlayersClient(activity, lastSignedInAccount)
      .currentPlayerId.addOnSuccessListener {
        result.success(it)
      }.addOnFailureListener {
        result.error(PluginError.failedToGetPlayerId.errorCode(), it.localizedMessage, null)
      }
  }

  fun getPlayerName(activity: Activity?, result: MethodChannel.Result) {
    activity ?: return
    val lastSignedInAccount = GoogleSignIn.getLastSignedInAccount(activity) ?: return
    Games.getPlayersClient(activity, lastSignedInAccount)
      .currentPlayer
      .addOnSuccessListener { player ->
        result.success(player.displayName)
      }.addOnFailureListener {
        result.error(PluginError.failedToGetPlayerName.errorCode(), it.localizedMessage, null)
      }
  }
}