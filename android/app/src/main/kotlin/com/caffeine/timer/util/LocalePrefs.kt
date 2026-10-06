package com.caffeine.timer.util

import android.content.Context

/** Carries the language selection from the Flutter side over to the native side. */
object LocalePrefs {
    private const val PREFS_NAME = "caffeine_locale_prefs"
    private const val KEY_LANGUAGE = "language_code"

    fun setLanguageCode(context: Context, code: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit().putString(KEY_LANGUAGE, code).apply()
    }

    fun getLanguageCode(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_LANGUAGE, "en") ?: "en"
    }
}
