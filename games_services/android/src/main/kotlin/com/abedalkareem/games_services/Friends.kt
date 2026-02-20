package com.abedalkareem.games_services

import android.app.Activity
import android.content.Intent
import com.abedalkareem.games_services.models.PlayerData
import com.abedalkareem.games_services.util.AppImageLoader
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.abedalkareem.games_services.util.errorMessage
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.Player
import com.google.android.gms.games.PlayersClient
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import android.util.Log
import com.abedalkareem.games_services.util.Messages
import com.google.android.gms.games.FriendsResolutionRequiredException
import io.flutter.plugin.common.PluginRegistry

class Friends(private var activityPluginBinding: ActivityPluginBinding) :
  PluginRegistry.ActivityResultListener {

    //region Variables
    private val imageLoader = AppImageLoader()
    private val playersClient: PlayersClient
      get() {
        return PlayGames.getPlayersClient(activityPluginBinding.activity)
      }

    private var maxResults: Int? = null
    private var forceRefresh: Boolean? = null
    private var result: MethodChannel.Result? = null
    private var errorMessage: String? = null
    private var hasLoadedFriends: Boolean = false
    //endregion

    //region Public Methods
    fun getFriendsAccessStatus(result: MethodChannel.Result, forceRefresh: Boolean = false) {
      playersClient.getCurrentPlayer(forceRefresh).addOnSuccessListener { annotatedData ->
        val player = annotatedData.get()
        if (player == null && forceRefresh) {
          result.error(
            PluginError.NotAuthenticated.errorCode(),
            PluginError.NotAuthenticated.errorMessage(),
            null
          )
          return@addOnSuccessListener
        }
        Log.i("GamesServices", "forceRefresh: " + forceRefresh + "\n" + player.toString())
        Log.i("GamesServices", "status: " + player?.getCurrentPlayerInfo()?.friendsListVisibilityStatus.toString())
        when (player?.currentPlayerInfo?.friendsListVisibilityStatus) {
          Player.FriendsListVisibilityStatus.REQUEST_REQUIRED -> result.success("notDetermined")
          Player.FriendsListVisibilityStatus.FEATURE_UNAVAILABLE -> result.success("denied")
          Player.FriendsListVisibilityStatus.VISIBLE -> result.success("granted")
          else -> if (forceRefresh) result.success("unknown") else getFriendsAccessStatus(result, true)
        }
      }.addOnFailureListener {
        result.error(PluginError.NotAuthenticated.errorCode(), it.localizedMessage, null)
      }
    }

    fun loadFriends(
      activity: Activity?,
      pageSize: Int,
      forceRefresh: Boolean,
      result: MethodChannel.Result
    ) {
      activity ?: return

      (if (hasLoadedFriends && !forceRefresh) playersClient.loadMoreFriends(pageSize) 
      else playersClient.loadFriends(pageSize, forceRefresh)).addOnSuccessListener { annotatedData ->
        val data = annotatedData.get()
        if (data == null) {
          result.error(
            PluginError.FailedToLoadFriends.errorCode(),
            PluginError.FailedToLoadFriends.errorMessage(),
            null
          )
          return@addOnSuccessListener
        }
        val handler = CoroutineExceptionHandler { _, exception ->
          result.error(
            PluginError.FailedToLoadFriends.errorCode(),
            exception.localizedMessage,
            null
          )
        }

        CoroutineScope(Dispatchers.Main + handler).launch {
            val friends = mutableListOf<PlayerData>()
            for (item in data) {
                val playerIconImage = if (item.iconImageUri != null)
                  item.iconImageUri.let { imageLoader.loadImageFromUri(activity, it!!) }
                  else null
                friends.add(PlayerData(
                  item.displayName,
                  item.playerId,
                  playerIconImage
                ))
            }
            val gson = Gson()
            val string = gson.toJson(friends) ?: ""
            data.release()
            hasLoadedFriends = true
            result.success(string)
        }
      }
      .addOnFailureListener {
        if (it is FriendsResolutionRequiredException) {
          this.maxResults = maxResults
          this.forceRefresh = forceRefresh
          this.errorMessage = it.localizedMessage
          this.result = result
          val pendingIntent = it.resolution
          activityPluginBinding.addActivityResultListener(this)
          activity.startIntentSenderForResult(
            pendingIntent.intentSender,
            26703,
            null,
            0,
            0,
            0
          )
          Log.i("GamesServices", "Friends list access requested")
        } else {
          result.error(
            PluginError.FailedToLoadFriends.errorCode(),
            it.localizedMessage,
            null
          )
        }
      }
    }

    fun viewPlayerProfile(
      activity: Activity?,
      playerId: String,
      playerInGameName: String,
      localInGameName: String,
      result: MethodChannel.Result
    ) {
      activity ?: return

      (if (playerInGameName.isEmpty()) playersClient.getCompareProfileIntent(playerId)
      else playersClient.getCompareProfileIntentWithAlternativeNameHints(playerId, playerInGameName, localInGameName)
      ).addOnSuccessListener { intent -> 
        activity?.startActivityForResult(intent, 0)
        result.success(Messages.SUCCESS)
      }.addOnFailureListener {
        result.error(PluginError.FailedToLoadPlayer.errorCode(), it.message, null)
      }
    }

    fun searchForPlayer(activity: Activity?, result: MethodChannel.Result) {
      activity ?: return

      playersClient.playerSearchIntent.addOnSuccessListener { intent ->
        this.result = result
        activityPluginBinding.addActivityResultListener(this)
        activity?.startActivityForResult(intent, 9005)
      }.addOnFailureListener {
        result.error(PluginError.FailedToLoadPlayer.errorCode(), it.message, null)
      }
    }

    // handle result from friends list permission request OR player search
    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {
      activityPluginBinding.removeActivityResultListener(this)
      if (requestCode == 26703) {
        // retry loadFriends if permission granted, otherwise throw the original error
        if (resultCode == -1) {
          val max = maxResults
          val refresh = forceRefresh
          val res = result
          if (max != null && refresh != null && res != null) {
            loadFriends(activityPluginBinding.activity, max, refresh, res)
          }
        } else {
          result?.error(
            PluginError.FailedToLoadFriends.errorCode(),
            errorMessage,
            null,
          )
        }
        maxResults = null
        forceRefresh = null
        result = null
        errorMessage = null
        return true
      } else if (requestCode == 9005) {
        if (resultCode == Activity.RESULT_OK && intent != null) {
          val player = intent.getParcelableArrayListExtra<Player>(PlayersClient.EXTRA_PLAYER_SEARCH_RESULTS)?.first()
          val result = this.result
          this.result = null
          if (player == null) {
            result?.success(null)
          } else {
            val handler = CoroutineExceptionHandler { _, exception ->
              result?.error(
                PluginError.FailedToLoadPlayer.errorCode(),
                exception.localizedMessage,
                null
              )
            }

            CoroutineScope(Dispatchers.Main + handler).launch {
              val iconImage = if (player.iconImageUri != null)
                player.iconImageUri.let { imageLoader.loadImageFromUri(activityPluginBinding.activity, it!!) }
                else null
              val playerData = PlayerData(
                player.displayName,
                player.playerId,
                iconImage
              )
              val gson = Gson()
              val string = gson.toJson(playerData) ?: ""
              result?.success(string)
            }
          }
        } else {
          result?.success(null)
        }
        return true
      } else {
        return false
      }
    }
    //endregion
  }