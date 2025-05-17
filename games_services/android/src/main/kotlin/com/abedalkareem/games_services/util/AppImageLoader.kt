package com.abedalkareem.games_services.util

import android.app.Activity
import android.net.Uri
import android.os.Handler
import android.os.Looper
import com.google.android.gms.common.images.ImageManager
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class AppImageLoader {
  suspend fun loadImageFromUri(activity: Activity, uri: Uri): String =
    suspendCoroutine { continuation ->
      val imageManager = ImageManager.create(activity)
      Handler(Looper.getMainLooper()).post {
        imageManager.loadImage({ _, drawable, _ ->
          val baseString = drawable?.getBase64FromUri() ?: ""
          continuation.resume(baseString)
        }, uri)
      }
    }
}
