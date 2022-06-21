package com.abedalkareem.games_services

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.view.Gravity

import com.google.android.gms.auth.api.Auth
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions

import com.google.android.gms.common.Scopes
import com.google.android.gms.common.api.Scope

import com.google.android.gms.games.AchievementsClient
import com.google.android.gms.games.Games
import com.google.android.gms.games.LeaderboardsClient

import com.google.android.gms.games.SnapshotsClient
import com.google.android.gms.games.snapshot.Snapshot
import com.google.android.gms.games.snapshot.SnapshotMetadataChange

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

private const val CHANNEL_NAME = "games_services"
private const val RC_SIGN_IN = 9000

class GamesServicesPlugin(private var activity: Activity? = null) : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {


  //region Variables
  private var googleSignInClient: GoogleSignInClient? = null
  private var achievementClient: AchievementsClient? = null
  private var leaderboardsClient: LeaderboardsClient? = null
  private var activityPluginBinding: ActivityPluginBinding? = null
  private var channel: MethodChannel? = null
  private var pendingOperation: PendingOperation? = null
  //endregion

  companion object {
    @JvmStatic
    fun registerWith(registrar: PluginRegistry.Registrar) {
      val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
      val plugin = GamesServicesPlugin(registrar.activity())
      channel.setMethodCallHandler(plugin)
      registrar.addActivityResultListener(plugin)
    }
  }

  //region SignIn
  private fun silentSignIn(result: Result) {
    val activity = activity ?: return

    val builder = GoogleSignInOptions.Builder(
            GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN)

    googleSignInClient = GoogleSignIn.getClient(activity, builder.requestScopes(Scope(Scopes.DRIVE_APPFOLDER)).build())

    googleSignInClient?.silentSignIn()?.addOnCompleteListener { task ->
      pendingOperation = PendingOperation(Methods.silentSignIn, result)
      if (task.isSuccessful) {
        val googleSignInAccount = task.result ?: return@addOnCompleteListener
        handleSignInResult(googleSignInAccount)
      } else {
        Log.e("Error", "signInError", task.exception)
        Log.i("ExplicitSignIn", "Trying explicit sign in")
        explicitSignIn()
      }
    }

  }

  private fun explicitSignIn() {
    val activity = activity ?: return
    val builder = GoogleSignInOptions.Builder(
            GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN)
            .requestEmail()
    googleSignInClient = GoogleSignIn.getClient(activity, builder.build())
    activity.startActivityForResult(googleSignInClient?.signInIntent, RC_SIGN_IN)
  }

  private fun handleSignInResult(googleSignInAccount: GoogleSignInAccount) {
    val activity = this.activity ?: return
    achievementClient = Games.getAchievementsClient(activity, googleSignInAccount)
    leaderboardsClient = Games.getLeaderboardsClient(activity, googleSignInAccount)

    // Set the popups view.
    val lastSignedInAccount = GoogleSignIn.getLastSignedInAccount(activity) ?: return
    val gamesClient = Games.getGamesClient(activity, lastSignedInAccount)
    gamesClient.setViewForPopups(activity.findViewById(android.R.id.content))
    gamesClient.setGravityForPopups(Gravity.TOP or Gravity.CENTER_HORIZONTAL)

    finishPendingOperationWithSuccess()
  }

  private val isSignedIn: Boolean get() {
    val activity = activity ?: return false
    return GoogleSignIn.getLastSignedInAccount(activity) != null
  }
  //endregion


  private fun loadFromGoogle(result: Result) {
        isBusy = true
        isLoading = true
        val user = googleSignInAccount.getLastSignedInAccount(this)
        if (user != null) {
            val snapshotsClient = Games.getSnapshotsClient(this, user)
            val conflictResolutionPolicy =
                SnapshotsClient.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED

            snapshotsClient.open(mainSaveName, true, conflictResolutionPolicy)
                .continueWith { task ->
                    val snapshot: Snapshot? = task.result.data
                    if (snapshot != null) {
                        try {
                            val contents =
                                String(snapshot.snapshotContents.readFully())
                            mainDartChannel.invokeMethod(
                                "loadFromGoogle",
                                contents
                            )
                            result?.success(contents)
                        } catch (e: IOException) {
                            Log.d("SAVES", "Error while reading Snapshot.", e)
                            result?.success("ERROR while loading data from google play")
                        }
                    }
                    isBusy = false
                    isLoading = false
                }
            } else {
                isBusy = false
                isLoading = false
            }
    }

    private fun saveToGoogle(
        result: MethodChannel.Result?,
        jsonData: String
    ): Task<SnapshotsClient.DataOrConflict<Snapshot>>? {
        isBusy = true
        val user = googleSignInAccount.getLastSignedInAccount(this)

        if (user != null) {
            val snapshotsClient: SnapshotsClient =
                Games.getSnapshotsClient(this, user)
            val conflictResolutionPolicy =
                SnapshotsClient.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED
            return snapshotsClient.open(mainSaveName, true, conflictResolutionPolicy)
                .addOnCompleteListener(this) { task ->
                    if (!task.result.isConflict) {
                        val snapshot = task.result.data
                        if (snapshot != null) {
                            snapshot.snapshotContents.writeBytes(jsonData.toByteArray())

                            snapshotsClient.commitAndClose(
                                snapshot,
                                SnapshotMetadataChange.EMPTY_CHANGE
                            )
                            Log.d("SAVES", "Saved game successfully")
                            result?.success(true)
                        } else {
                            Log.d("SAVES", "ERROR snapshot is null")
                            result?.error("0", "ERROR snapshot is null", "")
                        }
                        isBusy = false
                    } else {
                        isBusy = false
                        //TODO: resolve conflicts (occur very often!)
                        Log.d(
                            "SAVES",
                            "ERROR task.result.isConflict is true from saveJSONToGooglePlay"
                        )
                        result?.error(
                            "0",
                            "ERROR task.result.isConflict is true from saveJSONToGooglePlay",
                            ""
                        )
                    }
                }
        }

        result?.error("0", "ERROR (user == null) from saveJSONToGooglePlay", "")
        Log.d("SAVES", "ERROR (user == null) from saveJSONToGooglePlay")

        return null
    }


  //region User
  private fun getPlayerID(result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    val activity = activity ?: return
    val lastSignedInAccount = GoogleSignIn.getLastSignedInAccount(activity) ?: return
    Games.getPlayersClient(activity, lastSignedInAccount)
      .currentPlayerId.addOnSuccessListener {
        result.success(it)
      }.addOnFailureListener {
        result.error("error", it.localizedMessage, null)
      }
  }

  private fun getPlayerName(result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    val activity = activity ?: return
    val lastSignedInAccount = GoogleSignIn.getLastSignedInAccount(activity) ?: return
    Games.getPlayersClient(activity, lastSignedInAccount)
      .currentPlayer
      .addOnSuccessListener { player ->
        result.success(player.displayName)
      }.addOnFailureListener {
        result.error("error", it.localizedMessage, null)
      }
  }
  //endregion

  //region SignOut
  private fun signOut(result: Result) {
    googleSignInClient?.signOut()?.addOnCompleteListener { task ->
      if (task.isSuccessful) {
        result.success("success")
      } else {
        result.error("error", "${task.exception}", null)
      }
    }
  }
  //endregion

  //region Achievements & Leaderboards
  private fun showAchievements(result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    achievementClient?.achievementsIntent?.addOnSuccessListener { intent ->
      activity?.startActivityForResult(intent, 0)
      result.success("success")
    }?.addOnFailureListener {
      result.error("error", "${it.message}", null)
    }
  }

  private fun unlock(achievementID: String, result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    achievementClient?.unlockImmediate(achievementID)?.addOnSuccessListener {
      result.success("success")
    }?.addOnFailureListener {
      result.error("error", it.localizedMessage, null)
    }
  }

  private fun increment(achievementID: String, count: Int, result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    achievementClient?.incrementImmediate(achievementID, count)
            ?.addOnSuccessListener {
              result.success("success")
            }?.addOnFailureListener {
              result.error("error", it.localizedMessage, null)
            }
  }

  private fun showLeaderboards(leaderboardID: String, result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    val onSuccessListener: ((Intent) -> Unit) = { intent ->
      activity?.startActivityForResult(intent, 0)
      result.success("success")
    }
    val onFailureListener: ((Exception) -> Unit) = {
      result.error("error", "${it.message}", null)
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

  private fun submitScore(leaderboardID: String, score: Int, result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    leaderboardsClient?.submitScoreImmediate(leaderboardID, score.toLong())?.addOnSuccessListener {
      result.success("success")
    }?.addOnFailureListener {
      result.error("error", it.localizedMessage, null)
    }
  }

  private fun showLoginErrorIfNotLoggedIn(result: Result) {
    if (achievementClient == null || leaderboardsClient == null) {
      result.error("error", "Please make sure to call signIn() first", null)
    }
  }
  //endregion

  //region FlutterPlugin
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    setupChannel(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    teardownChannel()
  }

  private fun setupChannel(messenger: BinaryMessenger) {
    channel = MethodChannel(messenger, CHANNEL_NAME)
    channel?.setMethodCallHandler(this)
  }

  private fun teardownChannel() {
    channel?.setMethodCallHandler(null)
    channel = null
  }
  //endregion

  //region ActivityAware

  private fun disposeActivity() {
    activityPluginBinding?.removeActivityResultListener(this)
    activityPluginBinding = null
  }

  override fun onDetachedFromActivity() {
    disposeActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityPluginBinding = binding
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  //endregion

  //region PendingOperation
  private class PendingOperation constructor(val method: String, val result: Result)

  private fun finishPendingOperationWithSuccess() {
    Log.i(pendingOperation?.method, "success")
    pendingOperation?.result?.success("success")
    pendingOperation = null
  }

  private fun finishPendingOperationWithError(errorMessage: String) {
    Log.i(pendingOperation?.method, "error")
    pendingOperation?.result?.error("error", errorMessage, null)
    pendingOperation = null
  }
  //endregion

  //region ActivityResultListener
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == RC_SIGN_IN) {
      val result = data?.let { Auth.GoogleSignInApi.getSignInResultFromIntent(it) }
      val signInAccount = result?.signInAccount
      if (result?.isSuccess == true && signInAccount != null) {
        handleSignInResult(signInAccount)
      } else {
        var message = result?.status?.statusMessage ?: ""
        if (message.isEmpty()) {
          message = "Something went wrong " + result?.status
        }
        finishPendingOperationWithError(message)
      }
      return true
    }
    return false
  }
  //endregion

  //region MethodCallHandler
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      Methods.unlock -> {
        unlock(call.argument<String>("achievementID") ?: "", result)
      }
      Methods.increment -> {
        val achievementID = call.argument<String>("achievementID") ?: ""
        val steps = call.argument<Int>("steps") ?: 1
        increment(achievementID, steps, result)
      }
      Methods.submitScore -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        val score = call.argument<Int>("value") ?: 0
        submitScore(leaderboardID, score, result)
      }
      Methods.showLeaderboards -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        showLeaderboards(leaderboardID, result)
      }
      Methods.showAchievements -> {
        showAchievements(result)
      }
      Methods.silentSignIn -> {
        silentSignIn(result)
      }
      Methods.isSignedIn -> {
        result.success(isSignedIn)
      }
      Methods.signOut -> {
        signOut(result)
      }
      Methods.loadFromGoogle -> {
        loadFromGoogle(result)
      }
      Methods.saveToGoogle -> {
        saveToGoogle(result)
      }
      Methods.getPlayerID -> {
        getPlayerID(result)
      }
      Methods.getPlayerName -> {
        getPlayerName(result)
      }
      else -> result.notImplemented()
    }
  }
  //endregion
}

object Methods {
  const val unlock = "unlock"
  const val increment = "increment"
  const val submitScore = "submitScore"
  const val showLeaderboards = "showLeaderboards"
  const val showAchievements = "showAchievements"
  const val silentSignIn = "silentSignIn"
  const val isSignedIn = "isSignedIn"
  const val saveToGoogle = "saveToGoogle"
  const val loadFromGoogle = "loadFromGoogle"
  const val getPlayerID = "getPlayerID"
  const val getPlayerName = "getPlayerName"
  const val signOut = "signOut"
}