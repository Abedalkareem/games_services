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

class GamesServicesPlugin(private val activity: Activity) : MethodCallHandler {

    //region Variables
    private var googleSignInClient: GoogleSignInClient? = null
    private var achievementClient: AchievementsClient? = null
    private var leaderboardsClient: LeaderboardsClient? = null
    //endregion

    //region SignIn
    private fun silentSignIn(result: Result) {
        googleSignInClient = GoogleSignIn.getClient(activity, GoogleSignInOptions.Builder(
                GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN).build())
        googleSignInClient?.silentSignIn()?.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                achievementClient = Games.getAchievementsClient(activity, task.result!!)
                leaderboardsClient = Games.getLeaderboardsClient(activity, task.result!!)
                result.success("success")
            } else {
                Log.e("Error", "signInError", task.exception)
                result.error("error", task.exception?.message ?: "", task.exception)
            }
        }
    }

    private fun signIn(result: Result) {
        googleSignInClient = GoogleSignIn.getClient(activity, GoogleSignInOptions.Builder(
                GoogleSignInOptions.DEFAULT_SIGN_IN).build())
        activity.startActivityForResult(googleSignInClient?.signInIntent, 0)
        result.success("success")
    }
    //endregion

    //region Achievements
    private fun showAchievements(result: Result) {
        achievementClient?.achievementsIntent?.addOnSuccessListener { intent ->
            activity.startActivityForResult(intent, 0)
            result.success("success")
        }?.addOnFailureListener {
            result.error("error", "${it.message}", it)
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
            activity.startActivityForResult(intent, 0)
            result.success("success")
        }?.addOnFailureListener {
            result.error("error", "${it.message}", it)
        }
    }

    private fun submitScore(leaderboardID: String, score: Long, result: Result) {
        leaderboardsClient?.submitScore(leaderboardID, score)
        result.success("success")
    }
    //endregion

    //region MethodCallHandler
    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            call.method == "unlock" -> {
                unlock(call.argument<String>("achievementID") ?: "", result)
            }
            call.method == "submitScore" -> {
                val leaderboardID = call.argument<String>("leaderboardID") ?: ""
                val score = call.argument<Long>("score") ?: 0
                submitScore(leaderboardID, score, result)
            }
            call.method == "showLeaderboards" -> {
                showLeaderboards(result)
            }
            call.method == "showAchievements" -> {
                showAchievements(result)
            }
            call.method == "signIn" -> {
                signIn(result)
            }
            call.method == "silentSignIn" -> {
                silentSignIn(result)
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
    //endregion

}
