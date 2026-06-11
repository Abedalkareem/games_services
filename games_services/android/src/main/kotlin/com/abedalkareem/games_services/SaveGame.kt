package com.abedalkareem.games_services

import android.app.Activity
import android.content.Intent
import android.graphics.BitmapFactory
import android.util.Log
import com.abedalkareem.games_services.models.SavedGame
import com.abedalkareem.games_services.util.AppImageLoader
import com.abedalkareem.games_services.util.Messages
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.abedalkareem.games_services.util.errorMessage
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.SnapshotsClient
import com.google.android.gms.games.snapshot.Snapshot
import com.google.android.gms.games.snapshot.SnapshotMetadata
import com.google.android.gms.games.snapshot.SnapshotMetadataChange
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class SaveGame(private var activityPluginBinding: ActivityPluginBinding) :
  PluginRegistry.ActivityResultListener {

  //region Variables
  private val tag = "SaveGame"

  private val imageLoader = AppImageLoader()
  private val snapshotsClient: SnapshotsClient
    get() {
      return PlayGames.getSnapshotsClient(activityPluginBinding.activity)
    }

  private var result: MethodChannel.Result? = null
  //endregion

  //region Public Methods
  fun showSavedGames(activity: Activity?, title: String, allowNew: Boolean, allowDelete: Boolean, maxResults: Int, result: MethodChannel.Result) {
    val onSuccessListener: ((Intent) -> Unit) = { intent ->
      this.result = result
      activityPluginBinding.addActivityResultListener(this)
      activity?.startActivityForResult(intent, 9001)
    }
    val onFailureListener: ((Exception) -> Unit) = {
      result.error(PluginError.FailedToShowSavedGames.errorCode(), it.message, null)
    }
    snapshotsClient.getSelectSnapshotIntent(title, allowNew, allowDelete, maxResults)
      .addOnSuccessListener(onSuccessListener)
      .addOnFailureListener(onFailureListener)
  }

  fun getSavedGames(activity: Activity?, forceRefresh: Boolean, ignoreImages: Boolean, result: MethodChannel.Result) {
    activity ?: return
    Log.d(tag, "[GetSavedGames] Start loading all saved games")
    snapshotsClient.load(forceRefresh)
      .addOnSuccessListener { annotatedData ->

        val gson = Gson()
        val data = annotatedData.get()
        if (data == null) {
          Log.d(tag, "[GetSavedGames] Something went wrong data is null")
          result.error(
            PluginError.FailedToGetSavedGames.errorCode(),
            PluginError.FailedToGetSavedGames.errorMessage(),
            null
          )
          return@addOnSuccessListener
        }
        val handler = CoroutineExceptionHandler { _, exception ->
          result.error(
            PluginError.FailedToShowSavedGames.errorCode(),
            exception.localizedMessage,
            null
          )
        }
        CoroutineScope(Dispatchers.Main + handler).launch {
          val items = data.map { item -> 
            val coverImage = if (!ignoreImages) item.coverImageUri?.let { imageLoader.loadImageFromUri(activity, it) } else null
            SavedGame(
              name = item.uniqueName,
              modificationDate = item.lastModifiedTimestamp,
              deviceName = item.deviceName,
              description = item.description,
              playedTimeMillis = item.playedTime,
              coverImage = coverImage
            )
          }
          
          Log.d(tag, "[GetSavedGames] Loaded successfully")
          val string = gson.toJson(items) ?: ""
          result.success(string)
          data.release()
        }
      }
      .addOnFailureListener {
        Log.d(tag, "[GetSavedGames] Something went wrong ${it.localizedMessage}")
        result.error(
          PluginError.FailedToGetSavedGames.errorCode(),
          it.localizedMessage,
          null
        )
      }
  }

  fun saveGame(
    data: String,
    desc: String?,
    name: String,
    coverImage: ByteArray?,
    playedTimeMillis: Long?,
    result: MethodChannel.Result
  ) {
    Log.d(tag, "[SaveGame] Start saving game")
    val metadataChangeBuilder = SnapshotMetadataChange.Builder()
    if (desc != null) {
      metadataChangeBuilder.setDescription(desc)
    }
    if (playedTimeMillis != null) {
      metadataChangeBuilder.setPlayedTimeMillis(playedTimeMillis)
    }
    if (coverImage != null) {
      val bitmap = BitmapFactory.decodeByteArray(coverImage, 0, coverImage.size)
      if (bitmap != null) {
        metadataChangeBuilder.setCoverImage(bitmap)
      } else {
        Log.d(tag, "[SaveGame] Failed to decode the cover image bytes, skipping it")
      }
    }
    val metadataChange = metadataChangeBuilder.build()
    snapshotsClient.open(name, true, SnapshotsClient.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED)
      .addOnSuccessListener { annotatedData ->
        val snapshot = annotatedData.data

        if (snapshot != null) {
          // Set the data payload for the snapshot
          snapshot.snapshotContents.writeBytes(data.toByteArray())

          Log.d(tag, "[SaveGame] Start commit")
          // Commit the operation
          snapshotsClient.commitAndClose(snapshot, metadataChange)
            .addOnSuccessListener {
              Log.d(tag, "[SaveGame] Saved successfully")
              result.success(Messages.SUCCESS)
            }
            .addOnFailureListener {
              Log.d(tag, "[SaveGame] Something went wrong while commit ${it.localizedMessage}")
              result.error(PluginError.FailedToSaveGame.errorCode(), it.localizedMessage, null)
            }
        } else {
          Log.d(tag, "[SaveGame] Something went wrong snapshot is null $annotatedData")
          result.error(
            PluginError.FailedToSaveGame.errorCode(),
            PluginError.FailedToSaveGame.errorMessage(),
            null
          )
        }
      }
      .addOnFailureListener {
        Log.d(tag, "[SaveGame] Failed with error ${it.localizedMessage}")
        result.error(
          PluginError.FailedToSaveGame.errorCode(),
          it.localizedMessage,
          null
        )
      }
  }

  fun deleteGame(name: String, result: MethodChannel.Result) {
    Log.d(tag, "[DeleteGame] Start delete game")
    // Open the saved game using its name.
    snapshotsClient.open(name, false, SnapshotsClient.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED)
      .addOnFailureListener {
        Log.d(tag, "[DeleteGame] Open failed with error ${it.localizedMessage}")
        result.error(
          PluginError.FailedToDeleteSavedGame.errorCode(),
          it.localizedMessage ?: "",
          null
        )
      }
      .continueWith { snapshotOrConflict ->
        val snapshot = snapshotOrConflict.result.data
        Log.d(tag, "[DeleteGame] Got result")
        if (snapshot?.metadata == null) {
          Log.d(tag, "[DeleteGame] Meta data is null $snapshot")
          result.error(
            PluginError.FailedToDeleteSavedGame.errorCode(),
            PluginError.FailedToDeleteSavedGame.errorMessage(),
            null
          )
          return@continueWith
        }
        Log.d(tag, "[DeleteGame] Start deleting snapshot")
        snapshotsClient.delete(snapshot.metadata)
          .addOnSuccessListener {
            Log.d(tag, "[DeleteGame] Deleted successfully")
            result.success(it)
          }
          .addOnFailureListener {
            Log.d(tag, "[DeleteGame] Something went wrong deleting snapshot ${it.localizedMessage}")
            result.error(
              PluginError.FailedToDeleteSavedGame.errorCode(),
              it.localizedMessage ?: "",
              null
            )
          }
      }
  }

  fun loadGame(name: String, result: MethodChannel.Result) {
    Log.d(tag, "[LoadGame] Load game started")
    // Open the saved game using its name.
    snapshotsClient.open(name, false, SnapshotsClient.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED)
      .addOnFailureListener {
        Log.d(
          tag,
          "[LoadGame] Failed to open a game with name ${name}, error ${it.localizedMessage}"
        )
        result.error(
          PluginError.FailedToLoadGame.errorCode(),
          it.localizedMessage ?: "",
          null
        )
      }
      .continueWith {
        val snapshot = it.result.data
        Log.d(tag, "[LoadGame] Got the result")
        // Opening the snapshot was a success and any conflicts have been resolved.
        try {
          // Extract the raw data from the snapshot.
          val value = snapshot?.snapshotContents?.readFully()
          if (value != null) {
            Log.d(tag, "[LoadGame] Loaded game successfully")
            result.success(String(value))
          } else {
            Log.d(tag, "[LoadGame] Failed to read fully $snapshot")
            result.error(
              PluginError.FailedToLoadGame.errorCode(),
              PluginError.FailedToLoadGame.errorMessage(),
              null
            )
          }
        } catch (exception: Exception) {
          Log.d(tag, "[LoadGame] Something went wrong ${exception.localizedMessage}")
          result.error(
            PluginError.FailedToLoadGame.errorCode(), exception.localizedMessage ?: "",
            null
          )
        }
      }
  }
  //endregion

  // handle result from Platform saved game selection
  override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {
    activityPluginBinding.removeActivityResultListener(this)
    if (requestCode == 9001) {
      if (resultCode == Activity.RESULT_OK && intent != null) {
        val gson = Gson()
        if (intent.hasExtra(SnapshotsClient.EXTRA_SNAPSHOT_NEW)) {
          result?.success(null)
          result = null
        } else {
          val data = intent.getParcelableExtra<SnapshotMetadata>(SnapshotsClient.EXTRA_SNAPSHOT_METADATA)
          if(data == null) {
            result?.error(
              PluginError.FailedToLoadGame.errorCode(),
              PluginError.FailedToLoadGame.errorMessage(),
              null
            )
            result = null
          } else {
            val handler = CoroutineExceptionHandler { _, exception ->
              result?.error(
                PluginError.FailedToLoadGame.errorCode(),
                exception.localizedMessage,
                null
              )
              result = null
            }

            CoroutineScope(Dispatchers.Main + handler).launch {
              val coverImage = data.coverImageUri?.let {
                imageLoader.loadImageFromUri(activityPluginBinding.activity, it)
              }
              val savedGame = SavedGame(
                name = data.uniqueName,
                modificationDate = data.lastModifiedTimestamp,
                deviceName = data.deviceName,
                description = data.description,
                playedTimeMillis = data.playedTime,
                coverImage = coverImage
              )
              val string = gson.toJson(savedGame) ?: ""
              result?.success(string)
              result = null
            }
          }
        }
      } else {
        result?.error(
          PluginError.OperationCanceled.errorCode(),
          PluginError.OperationCanceled.errorMessage(),
          null
        )
        result = null
      }
      return true
    } else {
      return false
    }
  }
}
