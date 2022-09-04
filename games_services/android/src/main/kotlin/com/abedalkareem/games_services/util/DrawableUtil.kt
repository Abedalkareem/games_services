package com.abedalkareem.games_services.util

import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import java.io.ByteArrayOutputStream

fun Drawable.getBase64FromUri(): String {
  val bitmap = (this as? BitmapDrawable)?.bitmap
  val byteStream = ByteArrayOutputStream()
  bitmap?.compress(Bitmap.CompressFormat.PNG, 100, byteStream)
  val byteArray = byteStream.toByteArray()
  return Base64.encodeToString(byteArray, Base64.DEFAULT)
}