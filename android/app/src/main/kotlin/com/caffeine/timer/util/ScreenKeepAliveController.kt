package com.caffeine.timer.util

import android.content.Context
import android.graphics.PixelFormat
import android.os.PowerManager
import android.provider.Settings
import android.view.View
import android.view.WindowManager

/**
 * Uses an invisible 1x1 window + FLAG_KEEP_SCREEN_ON when the overlay permission is
 * granted (the exact same mechanism Activities use, fully respected by the system).
 * Falls back to a legacy screen WakeLock when the permission is missing (less reliable
 * on some devices).
 */
class ScreenKeepAliveController(private val context: Context) {

    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var overlayView: View? = null
    private var legacyWakeLock: PowerManager.WakeLock? = null

    fun acquire() {
        if (Settings.canDrawOverlays(context)) acquireOverlay() else acquireLegacyWakeLock()
    }

    fun release() {
        releaseOverlay()
        releaseLegacyWakeLock()
    }

    private fun acquireOverlay() {
        if (overlayView != null) return
        val view = View(context)
        val params = WindowManager.LayoutParams(
            1, 1,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            PixelFormat.TRANSLUCENT
        )
        try {
            windowManager.addView(view, params)
            overlayView = view
        } catch (e: Exception) {
            acquireLegacyWakeLock()
        }
    }

    private fun releaseOverlay() {
        overlayView?.let {
            try { windowManager.removeView(it) } catch (_: Exception) { }
        }
        overlayView = null
    }

    private fun acquireLegacyWakeLock() {
        if (legacyWakeLock?.isHeld == true) return
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        @Suppress("DEPRECATION")
        legacyWakeLock = pm.newWakeLock(
            PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ON_AFTER_RELEASE,
            "Caffeine::LegacyScreenWakeLock"
        ).apply { setReferenceCounted(false); acquire() }
    }

    private fun releaseLegacyWakeLock() {
        legacyWakeLock?.let { if (it.isHeld) it.release() }
        legacyWakeLock = null
    }
}
