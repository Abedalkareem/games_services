package com.abedalkareem.games_services

import android.app.Activity
import android.util.Log
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.games.AchievementsClient
import com.google.android.gms.games.Games
import com.google.android.gms.games.LeaderboardsClient
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class GamesServicesPlugin(val activity: Activity) : MethodCallHandler {

    private var googleSignInClient: GoogleSignInClient? = null
    private var achievementClient: AchievementsClient? = null
    private var leaderboardsClient: LeaderboardsClient? = null

    init {
        initGoogleClientAndSignin()
    }

    private fun initGoogleClientAndSignin() {
        googleSignInClient = GoogleSignIn.getClient(activity, GoogleSignInOptions.Builder(
                GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN).build())
    }

    fun silentSignIn() {
        googleSignInClient?.silentSignIn()?.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                achievementClient = Games.getAchievementsClient(activity, task.result!!)
                leaderboardsClient = Games.getLeaderboardsClient(activity, task.result!!)
            } else {
                Log.e("Error", "signInError", task.exception)
            }
        }
    }

    fun signIn() {
        activity.startActivityForResult(googleSignInClient?.signInIntent, 0)
    }

    fun showAchievements() {
        achievementClient?.achievementsIntent?.addOnSuccessListener { intent ->
            activity.startActivityForResult(intent, 0)
        }
    }

    fun showLeaderboards() {
        leaderboardsClient?.allLeaderboardsIntent?.addOnSuccessListener { intent ->
            activity.startActivityForResult(intent, 0)
        }
    }

    fun submitScore(leaderboardID: String, score: Long) {
        leaderboardsClient?.submitScore(leaderboardID, score)
    }

    fun unlock(achievementID: String) {
        achievementClient?.unlock(achievementID)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            call.method == "unlock" -> {
                unlock(call.argument<String>("achievementID") ?: "")
                result.success(null)
            }
            call.method == "submitScore" -> {
                val leaderboardID = call.argument<String>("leaderboardID") ?: ""
                val score = call.argument<Long>("score") ?: 0
                submitScore(leaderboardID, score)
                result.success(null)
            }
            call.method == "showLeaderboards" -> {
                showLeaderboards()
                result.success(null)
            }
            call.method == "showAchievements" -> {
                showAchievements()
                result.success(null)
            }
            call.method == "signIn" -> {
                signIn()
                result.success(null)
            }
            call.method == "silentSignIn" -> {
                silentSignIn()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "games_services")
            channel.setMethodCallHandler(GamesServicesPlugin(registrar.activity()))
        }
    }
}
