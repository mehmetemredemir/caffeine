package com.caffeine.timer.util

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/** Native copy of the "My presets" list from Flutter — exists so the Quick
 * Settings Tile's long-click menu (which runs without a Flutter engine) can read it. */
object PresetPrefs {
    private const val PREFS_NAME = "caffeine_preset_prefs"
    private const val KEY_PRESETS = "presets_json"

    data class PresetEntry(val label: String, val durationSeconds: Int)

    fun savePresets(context: Context, presets: List<PresetEntry>) {
        val array = JSONArray()
        presets.forEach {
            val obj = JSONObject()
            obj.put("label", it.label)
            obj.put("durationSeconds", it.durationSeconds)
            array.put(obj)
        }
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit().putString(KEY_PRESETS, array.toString()).apply()
    }

    fun getPresets(context: Context): List<PresetEntry> {
        val json = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_PRESETS, null) ?: return emptyList()
        return try {
            val array = JSONArray(json)
            (0 until array.length()).map { i ->
                val obj = array.getJSONObject(i)
                PresetEntry(obj.getString("label"), obj.getInt("durationSeconds"))
            }
        } catch (e: Exception) {
            emptyList()
        }
    }
}
