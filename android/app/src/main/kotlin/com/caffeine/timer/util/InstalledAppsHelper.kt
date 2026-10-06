package com.caffeine.timer.util

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import java.io.ByteArrayOutputStream

object InstalledAppsHelper {

    /** Returns only apps visible in the launcher (i.e. apps the user actually knows about). */
    fun getLaunchableApps(context: Context): List<Map<String, String>> {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfos = pm.queryIntentActivities(intent, PackageManager.MATCH_ALL)
        val ownPackage = context.packageName

        return resolveInfos
            .filter { it.activityInfo.packageName != ownPackage }
            .filter { !isPureSystemApp(pm, it.activityInfo.packageName) }
            .map {
                mapOf(
                    "packageName" to it.activityInfo.packageName,
                    "appName" to it.loadLabel(pm).toString()
                )
            }
            .distinctBy { it["packageName"] }
            .sortedBy { it["appName"] }
    }

fun getAppIconBase64(context: Context, packageName: String): String? {
    return try {
        val drawable = context.packageManager.getApplicationIcon(packageName)
        val bitmap = drawableToBitmap(drawable, maxSize = 128)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
        Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    } catch (e: Exception) {
        null
    }
}


    /** Hides pure system apps (e.g. Settings, Camera); still shows updated
     * system apps (e.g. factory-installed apps that were later updated via Play Store). */
    private fun isPureSystemApp(pm: PackageManager, packageName: String): Boolean {
        return try {
            val info = pm.getApplicationInfo(packageName, 0)
            val isSystem = info.flags and ApplicationInfo.FLAG_SYSTEM != 0
            val isUpdated = info.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0
            isSystem && !isUpdated
        } catch (e: Exception) {
            false
        }
    }

   private fun drawableToBitmap(drawable: Drawable, maxSize: Int): Bitmap {
    val width = drawable.intrinsicWidth.coerceAtLeast(1)
    val height = drawable.intrinsicHeight.coerceAtLeast(1)
    val scale = if (maxOf(width, height) > maxSize) maxSize.toFloat() / maxOf(width, height) else 1f
    val targetW = (width * scale).toInt().coerceAtLeast(1)
    val targetH = (height * scale).toInt().coerceAtLeast(1)
    val bitmap = Bitmap.createBitmap(targetW, targetH, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    drawable.setBounds(0, 0, canvas.width, canvas.height)
    drawable.draw(canvas)
    return bitmap
}
}
