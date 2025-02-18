package com.abedalkareem.games_services

import android.app.Activity
import com.abedalkareem.games_services.models.Method
import com.abedalkareem.games_services.models.methodsFrom
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


private const val METHOD_CHANNEL_NAME = "games_services"
private const val EVENT_CHANNEL_NAME = "games_services.player"

class GamesServicesPlugin : FlutterPlugin,
  MethodCallHandler, ActivityAware {

  //region Variables
  private var activity: Activity? = null
  private var methodChannel: MethodChannel? = null
  private var eventChannel: EventChannel? = null
  private var activityPluginBinding: ActivityPluginBinding? = null
  private var leaderboards: Leaderboards? = null
  private var achievements: Achievements? = null
  private var saveGame: SaveGame? = null
  private var auth: Auth? = null
  //endregion

  //region FlutterPlugin
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    setupChannels(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    teardownChannels()
  }

  private fun setupChannels(messenger: BinaryMessenger) {
    methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
    methodChannel!!.setMethodCallHandler(this)
    eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
  }

  private fun teardownChannels() {
    methodChannel?.setMethodCallHandler(null)
    eventChannel?.setStreamHandler(null)
    methodChannel = null
    eventChannel = null
  }
  //endregion

  //region ActivityAware
  private fun disposeActivity() {
    activityPluginBinding = null
    leaderboards = null
    achievements = null
    saveGame = null
    auth = null
  }

  private fun init() {
    val activityPluginBinding = activityPluginBinding ?: return
    leaderboards = Leaderboards(activityPluginBinding)
    achievements = Achievements(activityPluginBinding)
    saveGame = SaveGame(activityPluginBinding)
    auth = Auth(activityPluginBinding)
    // streamHandler is set here instead of `setupChannels` to ensure
    // auth is initialized before being set
    eventChannel!!.setStreamHandler(auth)
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
    init()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }
  //endregion

  //region MethodCallHandler
  override fun onMethodCall(call: MethodCall, result: Result) {
    val method = methodsFrom(call.method)
    if (method == null) {
      result.notImplemented()
      return
    }
    when (method) {
      Method.SignIn -> {
        auth?.signIn(result)
      }
      Method.GetAuthCode -> {
        val clientID = call.argument<String>("clientID") ?: ""
        val forceRefreshToken = call.argument<Boolean>("forceRefreshToken") ?: false
        auth?.getAuthCode(clientID, forceRefreshToken, result)
      }
      Method.ShowAchievements -> {
        achievements?.showAchievements(activity, result)
      }
      Method.LoadAchievements -> {
        val forceRefresh = call.argument<Boolean>("forceRefresh") ?: false
        achievements?.loadAchievements(activity, forceRefresh, result)
      }
      Method.Unlock -> {
        val achievementID = call.argument<String>("achievementID") ?: ""
        achievements?.unlock(achievementID, result)
      }
      Method.Increment -> {
        val achievementID = call.argument<String>("achievementID") ?: ""
        val steps = call.argument<Int>("steps") ?: 1
        achievements?.increment(achievementID, steps, result)
      }
      Method.ShowLeaderboards -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        leaderboards?.showLeaderboards(activity, leaderboardID, result)
      }
      Method.LoadLeaderboardScores -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        val playerCentered = call.argument<Boolean>("playerCentered") ?: false
        val span = call.argument<Int>("span") ?: 0
        val leaderboardCollection = call.argument<Int>("leaderboardCollection") ?: 0
        val maxResults = call.argument<Int>("maxResults") ?: 0
        val forceRefresh = call.argument<Boolean>("forceRefresh") ?: false
        leaderboards?.loadLeaderboardScores(activity, leaderboardID, playerCentered, span, leaderboardCollection, maxResults, forceRefresh, result)
      }
      Method.SubmitScore -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        val scoreValue = call.argument<Any>("value") ?: 0L
        val score = if (scoreValue is Int) scoreValue.toLong() else scoreValue as Long
        val token = call.argument<String>("token") ?: ""
        leaderboards?.submitScore(leaderboardID, score, token, result)
      }
      Method.GetPlayerScore -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        leaderboards?.getPlayerScore(leaderboardID, result)
      }
      Method.GetPlayerScoreObject -> {
        val leaderboardID = call.argument<String>("leaderboardID") ?: ""
        val span = call.argument<Int>("span") ?: 0
        val leaderboardCollection = call.argument<Int>("leaderboardCollection") ?: 0
        leaderboards?.getPlayerScoreObject(activity, leaderboardID, span, leaderboardCollection, result)
      }
      Method.GetPlayerHiResImage -> {
        auth?.getPlayerProfileImage(result)
      }
      Method.SaveGame -> {
        val data = call.argument<String>("data") ?: ""
        val name = call.argument<String>("name") ?: ""
        saveGame?.saveGame(data, name, name, result)
      }
      Method.LoadGame -> {
        val name = call.argument<String>("name") ?: ""
        saveGame?.loadGame(name, result)
      }
      Method.GetSavedGames -> {
        val forceRefresh = call.argument<Boolean>("forceRefresh") ?: false
        saveGame?.getSavedGames(forceRefresh, result)
      }
      Method.DeleteGame -> {
        val name = call.argument<String>("name") ?: ""
        saveGame?.deleteGame(name, result)
      }
    }
  }
  //endregion
}
