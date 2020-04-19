package com.abedalkareem.games_services

import android.app.Activity
import android.util.Log
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.games.AchievementsClient
import com.google.android.gms.games.Games
import com.google.android.gms.games.LeaderboardsClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

private const val CHANNEL_NAME = "games_services"

class GamesServicesPlugin(private var activity: Activity? = null) : FlutterPlugin, MethodCallHandler, ActivityAware {

    //region Variables
    private var googleSignInClient: GoogleSignInClient? = null
    // JRMARKHAM
    // add account variable to collect player information
    // add functionality to existing authenticaton code
    private var account: GoogleSignInAccount? = null

    private var achievementClient: AchievementsClient? = null
    private var leaderboardsClient: LeaderboardsClient? = null

    private var channel: MethodChannel? = null
    //endregion

    //region SignIn
    private fun silentSignIn(result: Result) {
        val activity = activity ?: return
        googleSignInClient = GoogleSignIn.getClient(activity, GoogleSignInOptions.Builder(
                GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN).build())

        // JRMARKHAM
        // set account from previous login
        account = GoogleSignIn.getLastSignedInAccount(activity)

        googleSignInClient?.silentSignIn()?.addOnCompleteListener { task ->
            account = task.result
            val googleSignInAccount = task.result
            if (task.isSuccessful && googleSignInAccount != null) {
                achievementClient = Games.getAchievementsClient(activity, googleSignInAccount)
                leaderboardsClient = Games.getLeaderboardsClient(activity, googleSignInAccount)
                result.success("success")
            } else {
                Log.e("Error", "signInError", task.exception)
                result.error("error", task.exception?.message ?: "", null)
            }
        }
    }
    //endregion

    //region Achievements
    private fun showAchievements(result: Result) {
        achievementClient?.achievementsIntent?.addOnSuccessListener { intent ->
            activity?.startActivityForResult(intent, 0)
            result.success("success")
        }?.addOnFailureListener {
            result.error("error", "${it.message}", null)
        }
    }

    private fun unlock(achievementID: String, result: Result) {
        achievementClient?.unlock(achievementID)
        result.success("success")
    }
    //endregion

    //region Leaderboards
    private fun showLeaderboards(result: Result) {
        leaderboardsClient?.allLeaderboardsIntent?.addOnSuccessListener { intent ->
            activity?.startActivityForResult(intent, 0)
            result.success("success")
        }?.addOnFailureListener {
            result.error("error", "${it.message}", null)
        }
    }

    private fun submitScore(leaderboardID: String, score: Int, result: Result) {
        leaderboardsClient?.submitScore(leaderboardID, score.toLong())
        result.success("success")
    }
    //endregion

    // JRMARKHAM
    // player info method
    //region playerID
    private fun getPlayerID(result: Result) {
        if(account == null){
            result.error("error", "account not logged in.", null)
            return
        }
        result.success(account!!.id)
    }
    //endregion

    //region displayName
    private fun getDisplayName(result: Result) {
        if(account == null){
            result.error("error", "account not logged in.", null)
            return
        }
        result.success(account!!.displayName)
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
        val handler = GamesServicesPlugin(activity)
        channel?.setMethodCallHandler(handler)
    }

    private fun teardownChannel() {
        channel?.setMethodCallHandler(null)
        channel = null
    }
    //endregion

    //region ActivityAware
    override fun onDetachedFromActivity() {
        teardownChannel()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }
    //endregion

    //region MethodCallHandler
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "unlock" -> {
                unlock(call.argument<String>("achievementID") ?: "", result)
            }
            "submitScore" -> {
                val leaderboardID = call.argument<String>("leaderboardID") ?: ""
                val score = call.argument<Int>("value") ?: 0
                submitScore(leaderboardID, score, result)
            }
            "showLeaderboards" -> {
                showLeaderboards(result)
            }
            "showAchievements" -> {
                showAchievements(result)
            }
            "silentSignIn" -> {
                silentSignIn(result)
            }
            // JRMARKHAM
            // new method for player info
            "playerID" -> {
                getPlayerID(result)
            }
            "displayName" -> {
                getDisplayName(result)
            }


            else -> result.notImplemented()
        }
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            channel.setMethodCallHandler(GamesServicesPlugin(registrar.activity()))
        }
    }
    //endregion
}