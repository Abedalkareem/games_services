package com.abedalkareem.games_services

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


private const val CHANNEL_NAME = "games_services"

class GamesServicesPlugin(private var activity: Activity? = null) : FlutterPlugin,
  MethodCallHandler, ActivityAware {

  //region Variables
  private var channel: MethodChannel? = null
  private var activityPluginBinding: ActivityPluginBinding? = null
  private var leaderboards: Leaderboards? = null
  private var achievements: Achievements? = null
  private var player: Player? = null
  private var saveGame: SaveGame? = null
  private var auth = Auth()
  //endregion

  private fun init() {
    val activityPluginBinding = activityPluginBinding ?: return
    leaderboards = Leaderboards(activityPluginBinding);
    achievements = Achievements(activityPluginBinding);
    saveGame = SaveGame(activityPluginBinding);
    player = Player();
  }

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
    activityPluginBinding?.removeActivityResultListener(auth)
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
    binding.addActivityResultListener(auth)
    init()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }
  //endregion

  //region MethodCallHandler
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      Methods.silentSignIn -> {
        val shouldEnableSavedGame = call.argument<Boolean>("shouldEnableSavedGame") ?: false
        auth.silentSignIn(activity, shouldEnableSavedGame, result)
      }
      Methods.isSignedIn -> {
        auth.isSignedIn(activity, result)
      }
      Methods.signOut -> {
        auth.signOut(result)
      }
      Methods.showAchievements -> {
        achievements?.showAchievements(activity, result)
      }
      Methods.loadAchievements -> {
        achievements?.loadAchievements(activity, result)
      }
      Methods.unlock -> {
        val achievementID = call.argument<String>("achievementID") ?: ""
        achievements?.unlock(achievementID, result)
      }
      Methods.increment -> {
        val achievementID = call.argument<String>("achievementID") ?: ""
        val steps = call.argument<Int>("steps") ?: 1
        achievements?.increment(achievementID, steps, result)
      }
      Methods.showLeaderboards -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        leaderboards?.showLeaderboards(activity, leaderboardID, result)
      }
      Methods.loadLeaderboardScores -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        val span = call.argument<Int>("span") ?: 0
        val leaderboardCollection = call.argument<Int>("leaderboardCollection") ?: 0
        val maxResults = call.argument<Int>("maxResults") ?: 0
        leaderboards?.loadLeaderboardScores(activity, leaderboardID, span, leaderboardCollection, maxResults, result)
      }
      Methods.submitScore -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        val score = call.argument<Int>("value") ?: 0
        leaderboards?.submitScore(leaderboardID, score, result)
      }
      Methods.getPlayerScore -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        leaderboards?.getPlayerScore(leaderboardID, result)
      }
      Methods.getPlayerID -> {
        player?.getPlayerID(activity, result)
      }
      Methods.getPlayerName -> {
        player?.getPlayerName(activity, result)
      }
      Methods.saveGame -> {
        val data = call.argument<String>("data") ?: ""
        val name = call.argument<String>("name") ?: ""
        saveGame?.saveGame(data, name, name, result)
      }
      Methods.loadGame -> {
        val name = call.argument<String>("name") ?: ""
        saveGame?.loadGame(name, result)
      }
      Methods.getSavedGames -> {
        saveGame?.getSavedGames(result)
      }
      Methods.deleteGame -> {
        val name = call.argument<String>("name") ?: ""
        saveGame?.deleteGame(name, result)
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
  const val loadAchievements = "loadAchievements"
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
  const val loadLeaderboardScores = "loadLeaderboardScores"
}
