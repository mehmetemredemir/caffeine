package com.caffeine.timer.util

import android.content.Context

/** Default duration started by a single tap on the Quick Settings Tile (null = indefinite). */
object TileDurationPrefs {
    private const val PREFS_NAME = "caffeine_tile_prefs"
    private const val KEY_DURATION = "default_duration_millis"

    fun setDefaultDurationMillis(context: Context, millis: Long?) {
        val editor = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
        if (millis == null) editor.remove(KEY_DURATION) else editor.putLong(KEY_DURATION, millis)
        editor.apply()
    }

    fun getDefaultDurationMillis(context: Context): Long? {
        val value = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getLong(KEY_DURATION, -1L)
        return if (value <= 0L) null else value
    }
}
