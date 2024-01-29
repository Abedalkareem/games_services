package com.abedalkareem.games_services

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

  private val snapshotsClient: SnapshotsClient
    get() {
      return PlayGames.getSnapshotsClient(activityPluginBinding.activity)
    }

  fun getSavedGames(result: MethodChannel.Result) {
    snapshotsClient.load(true)
      .addOnSuccessListener { annotatedData ->
        val gson = Gson()
        val data = annotatedData.get()
        if (data == null) {
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

        val string = gson.toJson(items) ?: ""
        result.success(string)
        data.release()
      }
      .addOnFailureListener {
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
    val metadataChange = SnapshotMetadataChange.Builder()
      .setDescription(desc)
      .build()
    snapshotsClient.open(name, true, SnapshotsClient.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED)
      .addOnSuccessListener { annotatedData ->
        val snapshot = annotatedData.data

        if (snapshot != null) {
          // Set the data payload for the snapshot
          snapshot.snapshotContents.writeBytes(data.toByteArray())

          // Commit the operation
          snapshotsClient.commitAndClose(snapshot, metadataChange)
            .addOnSuccessListener {
              result.success(null)
            }
            .addOnFailureListener {
              result.error(PluginError.FailedToSaveGame.errorCode(), it.localizedMessage, null)
            }
        } else {
          result.error(
            PluginError.FailedToSaveGame.errorCode(),
            PluginError.FailedToSaveGame.errorMessage(),
            null
          )
        }
      }
      .addOnFailureListener {
        result.error(
          PluginError.FailedToSaveGame.errorCode(),
          it.localizedMessage,
          null
        )
      }
  }

  fun deleteGame(name: String, result: MethodChannel.Result) {
    // Open the saved game using its name.
    snapshotsClient.open(name, false, SnapshotsClient.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED)
      .addOnFailureListener {
        result.error(
          PluginError.FailedToDeleteSavedGame.errorCode(),
          it.localizedMessage ?: "",
          null
        )
      }
      .continueWith { snapshotOrConflict ->
        val snapshot = snapshotOrConflict.result.data
        if (snapshot?.metadata == null) {
          result.error(
            PluginError.FailedToDeleteSavedGame.errorCode(),
            PluginError.FailedToDeleteSavedGame.errorMessage(),
            null
          )
          return@continueWith
        }
        snapshotsClient.delete(snapshot.metadata)
          .addOnSuccessListener {
            result.success(it)
          }
          .addOnFailureListener {
            result.error(
              PluginError.FailedToDeleteSavedGame.errorCode(),
              it.localizedMessage ?: "",
              null
            )
          }
      }
  }

  fun loadGame(name: String, result: MethodChannel.Result) {
    // Open the saved game using its name.
    snapshotsClient.open(name, false, SnapshotsClient.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED)
      .addOnFailureListener {
        result.error(
          PluginError.FailedToLoadGame.errorCode(),
          it.localizedMessage ?: "",
          null
        )
      }
      .continueWith {
        val snapshot = it.result.data

        // Opening the snapshot was a success and any conflicts have been resolved.
        try {
          // Extract the raw data from the snapshot.
          val value = snapshot?.snapshotContents?.readFully()
          if (value != null) {
            result.success(String(value))
          } else {
            result.error(
              PluginError.FailedToLoadGame.errorCode(),
              PluginError.FailedToLoadGame.errorMessage(),
              null
            )
          }
        } catch (exception: Exception) {
          result.error(
            PluginError.FailedToLoadGame.errorCode(), exception.localizedMessage ?: "",
            null
          )
        }
      }
  }
}