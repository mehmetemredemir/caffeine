package com.caffeine.timer.util

import android.app.Activity
import android.app.AppOpsManager
import android.content.Intent
import android.os.Build
import android.os.Process
import android.provider.Settings

object UsageStatsPermissionHelper {

    fun hasUsageStatsPermission(activity: Activity): Boolean {
        val appOps = activity.getSystemService(Activity.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                activity.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                activity.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun openUsageAccessSettings(activity: Activity) {
        activity.startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
    }
}
