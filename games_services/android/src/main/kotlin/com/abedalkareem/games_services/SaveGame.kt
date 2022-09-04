package com.abedalkareem.games_services

import android.app.Activity
import com.abedalkareem.games_services.models.SavedGame
import com.abedalkareem.games_services.util.PluginError
import com.abedalkareem.games_services.util.errorCode
import com.abedalkareem.games_services.util.errorMessage
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.games.Games
import com.google.android.gms.games.SnapshotsClient
import com.google.android.gms.games.snapshot.SnapshotMetadataChange
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class SaveGame {

  private var activityPluginBinding: ActivityPluginBinding
  private val snapshotsClient: SnapshotsClient?
    get() {
      val lastSignedInAccount =
        GoogleSignIn.getLastSignedInAccount(activityPluginBinding.activity) ?: return null
      return Games.getSnapshotsClient(activityPluginBinding.activity, lastSignedInAccount)
    }

  constructor(activityPluginBinding: ActivityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding
  }

  fun getSavedGames(result: MethodChannel.Result) {
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

  fun saveGame(
    data: String, desc: String, name: String, result: MethodChannel.Result
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

  fun deleteGame(name: String, result: MethodChannel.Result) {
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

  fun loadGame(name: String, result: MethodChannel.Result) {
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
}