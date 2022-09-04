package com.abedalkareem.games_services.models

import android.app.Activity
import io.flutter.plugin.common.MethodChannel

class PendingOperation constructor(val method: String, val result: MethodChannel.Result, val activity: Activity)
