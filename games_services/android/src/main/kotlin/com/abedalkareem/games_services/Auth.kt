package com.abedalkareem.games_services

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.abedalkareem.games_services.models.Method
import com.abedalkareem.games_services.models.PendingOperation
import com.abedalkareem.games_services.models.value
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.google.android.gms.auth.api.Auth
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.drive.Drive
import com.google.android.gms.games.AuthenticationResult
import com.google.android.gms.games.PlayGames
import com.google.android.gms.tasks.Task
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

private const val RC_SIGN_IN = 9000

class Auth : PluginRegistry.ActivityResultListener {

  private var googleSignInClient: GoogleSignInClient? = null
  private var pendingOperation: PendingOperation? = null

  fun isSignedIn(
    activity: Activity?,
    result: MethodChannel.Result
  ) {
    val value = activity?.let { GoogleSignIn.getLastSignedInAccount(it) } != null
    result.success(value)
  }

  fun silentSignIn(
    activity: Activity?,
    shouldEnableSavedGame: Boolean,
    result: MethodChannel.Result
  ) {
    activity ?: return
    if (!shouldEnableSavedGame) {
      signInV2(activity, result)
      return
    }
    val signInOption = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN)

    signInOption.requestScopes(Drive.SCOPE_APPFOLDER)

    googleSignInClient = activity.let { GoogleSignIn.getClient(it, signInOption.build()) }
    googleSignInClient?.silentSignIn()?.addOnCompleteListener { task ->
      pendingOperation = PendingOperation(Method.SilentSignIn.value(), result, activity)
      if (task.isSuccessful) {
        handleSignInResult(activity)
      } else {
        Log.e("Error", "signInError", task.exception)
        Log.i("ExplicitSignIn", "Trying explicit sign in")
        explicitSignIn(activity)
      }
    }
  }

  private fun signInV2(activity: Activity, result: MethodChannel.Result) {
    val gamesSignInClient = PlayGames.getGamesSignInClient(activity)
    pendingOperation = PendingOperation(Method.SilentSignIn.value(), result, activity)
    gamesSignInClient.isAuthenticated.addOnCompleteListener { isAuthenticatedTask: Task<AuthenticationResult> ->
      val isAuthenticated = isAuthenticatedTask.isSuccessful &&
        isAuthenticatedTask.result.isAuthenticated
      if (isAuthenticated) {
        handleSignInResult(activity)
      } else {
        gamesSignInClient.signIn().addOnSuccessListener {
          it?.let { result -> Log.i("PlayService", "isAuthenticated: ${result.isAuthenticated} toString: $result") }
          handleSignInResult(activity)
        }.addOnFailureListener {
          it.let { result -> Log.i("PlayService", "isAuthenticated: ${result.localizedMessage} toString: $result") }
          finishPendingOperationWithError(PluginError.FailedToAuthenticate.errorCode(), it.message ?: "")
        }
      }
    }
  }

  private fun explicitSignIn(activity: Activity?) {
    activity ?: return
    val signInOption = GoogleSignInOptions.Builder(
      GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN
    )
      .requestEmail()

    signInOption.requestScopes(Drive.SCOPE_APPFOLDER)

    googleSignInClient = GoogleSignIn.getClient(activity, signInOption.build())
    activity.startActivityForResult(googleSignInClient?.signInIntent, RC_SIGN_IN)
  }

  private fun handleSignInResult(activity: Activity?) {
    activity ?: return

    finishPendingOperationWithSuccess()
  }

  fun signOut(result: MethodChannel.Result) {
    googleSignInClient?.signOut()?.addOnCompleteListener { task ->
      if (task.isSuccessful) {
        result.success(null)
      } else {
        result.error(PluginError.FailedToSignOut.errorCode(), task.exception?.localizedMessage, null)
      }
    }
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

  //region ActivityResultListener
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == RC_SIGN_IN) {
      val result = data?.let { Auth.GoogleSignInApi.getSignInResultFromIntent(it) }
      val signInAccount = result?.signInAccount
      if (result?.isSuccess == true && signInAccount != null) {
        handleSignInResult(pendingOperation?.activity)
      } else {
        var message = result?.status?.statusMessage ?: ""
        if (message.isEmpty()) {
          message = "Something went wrong " + result?.status
        }
        finishPendingOperationWithError(PluginError.FailedToAuthenticate.errorCode(), message)
      }
      return true
    }
    return false
  }
  //endregion
}