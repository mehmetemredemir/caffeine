package com.caffeine.timer.util

import android.content.Context
import android.content.res.Configuration
import java.util.Locale

/**
 * Lets native UI pieces that are not tied to the Flutter engine (notification,
 * Tile, dialog Activity) resolve strings according to the in-app selected language.
 */
object LocaleContextWrapper {
    fun wrap(context: Context): Context {
        val languageCode = LocalePrefs.getLanguageCode(context)
        val locale = Locale(languageCode)
        val config = Configuration(context.resources.configuration)
        config.setLocale(locale)
        return context.createConfigurationContext(config)
    }
}
