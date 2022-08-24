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
import com.google.android.gms.drive.Drive
import com.google.android.gms.games.AchievementsClient
import com.google.android.gms.games.Games
import com.google.android.gms.games.LeaderboardsClient
import com.google.android.gms.games.SnapshotsClient
import com.google.android.gms.games.leaderboard.LeaderboardVariant
import com.google.android.gms.games.snapshot.SnapshotMetadataChange
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener


private const val CHANNEL_NAME = "games_services"
private const val RC_SIGN_IN = 9000

class GamesServicesPlugin(private var activity: Activity? = null) : FlutterPlugin,
  MethodCallHandler, ActivityAware, ActivityResultListener {

  //region Variables
  private var googleSignInClient: GoogleSignInClient? = null
  private var snapshotsClient: SnapshotsClient? = null
  private var achievementClient: AchievementsClient? = null
  private var leaderboardsClient: LeaderboardsClient? = null
  private var activityPluginBinding: ActivityPluginBinding? = null
  private var channel: MethodChannel? = null
  private var pendingOperation: PendingOperation? = null

  //endregion

  //region SignIn
  private fun silentSignIn(shouldEnableSavedGame: Boolean, result: Result) {
    val activity = activity ?: return
    val signInOption = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN)

    if (shouldEnableSavedGame) {
      signInOption
        .requestScopes(Drive.SCOPE_APPFOLDER)
    }

    googleSignInClient = GoogleSignIn.getClient(activity, signInOption.build())
    googleSignInClient?.silentSignIn()?.addOnCompleteListener { task ->
      pendingOperation = PendingOperation(Methods.silentSignIn, result)
      if (task.isSuccessful) {
        val googleSignInAccount = task.result ?: return@addOnCompleteListener
        handleSignInResult(googleSignInAccount)
      } else {
        Log.e("Error", "signInError", task.exception)
        Log.i("ExplicitSignIn", "Trying explicit sign in")
        explicitSignIn(shouldEnableSavedGame)
      }
    }
  }

  private fun explicitSignIn(shouldEnableSavedGame: Boolean) {
    val activity = activity ?: return
    val signInOption = GoogleSignInOptions.Builder(
      GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN
    )
      .requestEmail()

    if (shouldEnableSavedGame) {
      signInOption
      .requestScopes(Drive.SCOPE_APPFOLDER)
    }

    googleSignInClient = GoogleSignIn.getClient(activity, signInOption.build())
    activity.startActivityForResult(googleSignInClient?.signInIntent, RC_SIGN_IN)
  }

  private fun handleSignInResult(googleSignInAccount: GoogleSignInAccount) {
    val activity = this.activity ?: return
    achievementClient = Games.getAchievementsClient(activity, googleSignInAccount)
    leaderboardsClient = Games.getLeaderboardsClient(activity, googleSignInAccount)
    snapshotsClient = Games.getSnapshotsClient(activity, googleSignInAccount)

    // Set the popups view.
    val lastSignedInAccount = GoogleSignIn.getLastSignedInAccount(activity) ?: return
    val gamesClient = Games.getGamesClient(activity, lastSignedInAccount)
    gamesClient.setViewForPopups(activity.findViewById(android.R.id.content))
    gamesClient.setGravityForPopups(Gravity.TOP or Gravity.CENTER_HORIZONTAL)

    finishPendingOperationWithSuccess(null)
  }

  private val isSignedIn: Boolean
    get() {
      val activity = activity ?: return false
      return GoogleSignIn.getLastSignedInAccount(activity) != null
    }
  //endregion

  //region User
  private fun getPlayerID(result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    val activity = activity ?: return
    val lastSignedInAccount = GoogleSignIn.getLastSignedInAccount(activity) ?: return
    Games.getPlayersClient(activity, lastSignedInAccount)
      .currentPlayerId.addOnSuccessListener {
        result.success(it)
      }.addOnFailureListener {
        result.error(PluginError.failedToGetPlayerId.errorCode(), it.localizedMessage, null)
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
        result.error(PluginError.failedToGetPlayerName.errorCode(), it.localizedMessage, null)
      }
  }
  //endregion

  //region SignOut
  private fun signOut(result: Result) {
    googleSignInClient?.signOut()?.addOnCompleteListener { task ->
      if (task.isSuccessful) {
        result.success(null)
      } else {
        result.error(PluginError.failedToSignout.errorCode(), "${task.exception}", null)
      }
    }
  }
  //endregion

  //region Save game

  private fun getSavedGames(result: Result) {
    snapshotsClient?.load(true)
      ?.addOnCompleteListener { task ->
        val gson = Gson()
        val data = task.result.get()
        if (data == null) {
          result.error(
            PluginError.failedToGetSavedGames.errorCode(),
            PluginError.failedToGetSavedGames.errorMessage(),
            null
          )
          return@addOnCompleteListener
        }
        val items = data
          .toList()
          .map { SavedGame(it.uniqueName, it.lastModifiedTimestamp, it.deviceName) }

        val string = gson.toJson(items) ?: ""
        result.success(string)
        data.release()
      }
  }

  private fun saveGame(
    data: String, desc: String, name: String, result: Result
  ) {
    val metadataChange = SnapshotMetadataChange.Builder()
      .setDescription(desc)
      .build()
    snapshotsClient?.open(name, true)
      ?.addOnCompleteListener { task ->
        val snapshot = task.result.data
        if (snapshot != null) {
          // Set the data payload for the snapshot
          snapshot.snapshotContents.writeBytes(data.toByteArray())

          // Commit the operation
          snapshotsClient?.commitAndClose(snapshot, metadataChange)
            ?.addOnSuccessListener {
              result.success(null)
            }
            ?.addOnFailureListener {
              result.error(PluginError.failedToSaveGame.errorCode(), it.localizedMessage, null)
            }
        } else {
          result.error(
            PluginError.failedToSaveGame.errorCode(),
            PluginError.failedToSaveGame.errorMessage(),
            null
          )
        }
      }
  }

  private fun deleteGame(name: String, result: Result) {
    // Open the saved game using its name.
    snapshotsClient?.open(name, false)
      ?.addOnFailureListener {
        result.error(
          PluginError.failedToDeleteSavedGame.errorCode(),
          it.localizedMessage ?: "",
          null
        )
      }
      ?.continueWith { snapshotOrConflict ->
        val snapshot = snapshotOrConflict.result.data
          if (snapshot?.metadata == null) {
            result.error(
              PluginError.failedToDeleteSavedGame.errorCode(),
              PluginError.failedToDeleteSavedGame.errorMessage(),
              null
            )
            return@continueWith
          }
          snapshotsClient?.delete(snapshot.metadata)
            ?.addOnSuccessListener {
              result.success(it)
            }
            ?.addOnFailureListener {
              result.error(
                PluginError.failedToDeleteSavedGame.errorCode(),
                it.localizedMessage ?: "",
                null
              )
            }
      }
  }

  private fun loadGame(name: String, result: Result) {
    // Open the saved game using its name.
    snapshotsClient?.open(name, false)
      ?.addOnFailureListener {
        result.error(
          PluginError.failedToLoadGame.errorCode(),
          it.localizedMessage ?: "",
          null
        )
      }
      ?.continueWith {
        val snapshot = it.result.data

        // Opening the snapshot was a success and any conflicts have been resolved.
        try {
          // Extract the raw data from the snapshot.
          val value = snapshot?.snapshotContents?.readFully()
          if (value != null) {
            result.success(String(value))
          } else {
            result.error(
              PluginError.failedToLoadGame.errorCode(),
              PluginError.failedToLoadGame.errorMessage(),
              null
            )
          }
        } catch (e: Exception) {
          result.error(
            PluginError.failedToLoadGame.errorCode(),
            e.localizedMessage ?: "",
            null
          )
        }
      }
  }

  //endregion

  //region Achievements & Leaderboards
  private fun showAchievements(result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    achievementClient?.achievementsIntent?.addOnSuccessListener { intent ->
      activity?.startActivityForResult(intent, 0)
      result.success(null)
    }?.addOnFailureListener {
      result.error(PluginError.failedToShowAchievements.errorCode(), "${it.message}", null)
    }
  }

  private fun unlock(achievementID: String, result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    achievementClient?.unlockImmediate(achievementID)?.addOnSuccessListener {
      result.success(null)
    }?.addOnFailureListener {
      result.error(PluginError.failedToSendAchievement.errorCode(), it.localizedMessage, null)
    }
  }

  private fun increment(achievementID: String, count: Int, result: Result) {
    showLoginErrorIfNotLoggedIn(result)
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

  private fun showLeaderboards(leaderboardID: String, result: Result) {
    showLoginErrorIfNotLoggedIn(result)
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

  private fun submitScore(leaderboardID: String, score: Int, result: Result) {
    showLoginErrorIfNotLoggedIn(result)
    leaderboardsClient?.submitScoreImmediate(leaderboardID, score.toLong())?.addOnSuccessListener {
      result.success(null)
    }?.addOnFailureListener {
      result.error(PluginError.failedToSendScore.errorCode(), it.localizedMessage, null)
    }
  }

  private fun getPlayerScore(leaderboardID: String, result: Result) {
    showLoginErrorIfNotLoggedIn(result)
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

  private fun showLoginErrorIfNotLoggedIn(result: Result) {
    if (achievementClient == null || leaderboardsClient == null) {
      result.error(
        PluginError.notAuthenticated.errorCode(),
        PluginError.notAuthenticated.errorMessage(),
        null
      )
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

  private fun finishPendingOperationWithSuccess(result: Any?) {
    Log.i(pendingOperation?.method, "success")
    pendingOperation?.result?.success(result)
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
        handleSignInResult(signInAccount)
      } else {
        var message = result?.status?.statusMessage ?: ""
        if (message.isEmpty()) {
          message = "Something went wrong " + result?.status
        }
        finishPendingOperationWithError(PluginError.failedToAuthenticate.errorCode(), message)
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
        val shouldEnableSavedGame = call.argument<Boolean>("shouldEnableSavedGame") ?: false
        silentSignIn(shouldEnableSavedGame, result)
      }
      Methods.isSignedIn -> {
        result.success(isSignedIn)
      }
      Methods.signOut -> {
        signOut(result)
      }
      Methods.getPlayerID -> {
        getPlayerID(result)
      }
      Methods.getPlayerName -> {
        getPlayerName(result)
      }
      Methods.getPlayerScore -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        getPlayerScore(leaderboardID, result)
      }
      Methods.saveGame -> {
        val data = call.argument<String>("data") ?: ""
        val name = call.argument<String>("name") ?: ""
        saveGame(data, name, name, result)
      }
      Methods.loadGame -> {
        val name = call.argument<String>("name") ?: ""
        loadGame(name, result)
      }
      Methods.getSavedGames -> {
        getSavedGames(result)
      }
      Methods.deleteGame -> {
        val name = call.argument<String>("name") ?: ""
        deleteGame(name, result)
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
  const val getPlayerID = "getPlayerID"
  const val getPlayerName = "getPlayerName"
  const val getPlayerScore = "getPlayerScore"
  const val signOut = "signOut"
  const val saveGame = "saveGame"
  const val loadGame = "loadGame"
  const val getSavedGames = "getSavedGames"
  const val deleteGame = "deleteGame"
}

data class SavedGame(
  val name: String?,
  val modificationDate: Long?,
  val deviceName: String?
)