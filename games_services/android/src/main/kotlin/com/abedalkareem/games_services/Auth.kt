package com.abedalkareem.games_services

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.abedalkareem.games_services.models.Method
import com.abedalkareem.games_services.models.PendingOperation
import com.abedalkareem.games_services.models.value
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.google.android.gms.games.AuthenticationResult
import com.google.android.gms.games.PlayGames
import com.google.android.gms.tasks.Task
import io.flutter.plugin.common.MethodChannel

private const val RC_SIGN_IN = 9000

class Auth {

  private var pendingOperation: PendingOperation? = null

  fun isSignedIn(activity: Activity?, result: MethodChannel.Result) {
    activity ?: return
    val gamesSignInClient = PlayGames.getGamesSignInClient(activity)
    gamesSignInClient.isAuthenticated.addOnCompleteListener { isAuthenticatedTask: Task<AuthenticationResult> ->
      val isAuthenticated = isAuthenticatedTask.isSuccessful &&
        isAuthenticatedTask.result.isAuthenticated
      result.success(isAuthenticated)
    }
  }

  fun signIn(activity: Activity?, result: MethodChannel.Result) {
    activity ?: return
    val gamesSignInClient = PlayGames.getGamesSignInClient(activity)
    pendingOperation = PendingOperation(Method.SignIn.value(), result, activity)
    gamesSignInClient.signIn().addOnSuccessListener {
      it?.let { result -> Log.i("PlayService", "isAuthenticated: ${result.isAuthenticated} toString: $result") }
      handleSignInResult(activity)
    }.addOnFailureListener {
      it.let { result -> Log.i("PlayService", "isAuthenticated: ${result.localizedMessage} toString: $result") }
      finishPendingOperationWithError(PluginError.FailedToAuthenticate.errorCode(), it.message ?: "")
    }
  }

  fun getAuthCode(clientID: String, activity: Activity?, result: MethodChannel.Result) {
    activity ?: return
    val gamesSignInClient = PlayGames.getGamesSignInClient(activity)
    gamesSignInClient.requestServerSideAccess(clientID, false).addOnSuccessListener {
      result.success(it)
    }.addOnFailureListener {
      result.error(PluginError.FailedToGetAuthCode.errorCode(), it.message ?: "", null)
    }
  }

  private fun handleSignInResult(activity: Activity?) {
    activity ?: return
    finishPendingOperationWithSuccess()
  }

  //region PendingOperation
  private fun finishPendingOperationWithSuccess() {
    Log.i(pendingOperation?.method, "success")
    pendingOperation?.result?.success(null)
    pendingOperation = null
  }

  private fun finishPendingOperationWithError(errorCode: String, errorMessage: String) {
    Log.i(pendingOperation?.method, "error")
    pendingOperation?.result?.error(errorCode, errorMessage, null)
    pendingOperation = null
  }
  //endregion
}