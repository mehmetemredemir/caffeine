package com.caffeine.timer.util

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.Settings

object OverlayPermissionHelper {
    fun canDrawOverlays(activity: Activity): Boolean = Settings.canDrawOverlays(activity)

    fun requestOverlayPermission(activity: Activity) {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${activity.packageName}")
        )
        activity.startActivity(intent)
    }
}
