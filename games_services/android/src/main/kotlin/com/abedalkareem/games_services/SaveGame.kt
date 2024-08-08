package com.abedalkareem.games_services

import android.util.Log
import com.abedalkareem.games_services.models.SavedGame
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.abedalkareem.games_services.util.errorMessage
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.SnapshotsClient
import com.google.android.gms.games.snapshot.SnapshotMetadataChange
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class SaveGame(private var activityPluginBinding: ActivityPluginBinding) {

  private val tag = "SaveGame"

  private val snapshotsClient: SnapshotsClient
    get() {
      return PlayGames.getSnapshotsClient(activityPluginBinding.activity)
    }

  fun getSavedGames(result: MethodChannel.Result) {
    Log.d(tag, "[GetSavedGames] Start loading all saved games")
    snapshotsClient.load(true)
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
        val items = data
          .toList()
          .map { SavedGame(it.uniqueName, it.lastModifiedTimestamp, it.deviceName) }

        Log.d(tag, "[GetSavedGames] Loaded successfully")
        val string = gson.toJson(items) ?: ""
        result.success(string)
        data.release()
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
    data: String, desc: String, name: String, result: MethodChannel.Result
  ) {
    Log.d(tag, "[SaveGame] Start saving game")
    val metadataChange = SnapshotMetadataChange.Builder()
      .setDescription(desc)
      .build()
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
              Log.d(tag, "[SaveGame] Loaded successfully")
              result.success(null)
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
        Log.d(tag, "[LoadGame] Failed to open a game with name ${name}, error ${it.localizedMessage}")
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
}