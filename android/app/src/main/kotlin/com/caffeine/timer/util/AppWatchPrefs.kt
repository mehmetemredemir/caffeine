package com.caffeine.timer.util

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object AppWatchPrefs {
    private const val PREFS_NAME = "caffeine_app_watch_prefs"
    private const val KEY_TARGETS = "targets_json"

    data class Target(val packageName: String, val durationMillis: Long?)

    fun saveTargets(context: Context, targets: List<Target>) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit().putString(KEY_TARGETS, toJson(targets)).apply()
    }

    fun getTargets(context: Context): List<Target> {
        val json = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_TARGETS, null) ?: return emptyList()
        return parseTargetsJson(json)
    }

    fun clear(context: Context) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit().clear().apply()
    }

    fun toJson(targets: List<Target>): String {
        val array = JSONArray()
        targets.forEach {
            val obj = JSONObject()
            obj.put("packageName", it.packageName)
            if (it.durationMillis != null) obj.put("durationMillis", it.durationMillis)
            array.put(obj)
        }
        return array.toString()
    }

    fun parseTargetsJson(json: String): List<Target> {
        return try {
            val array = JSONArray(json)
            (0 until array.length()).map { i ->
                val obj = array.getJSONObject(i)
                Target(
                    packageName = obj.getString("packageName"),
                    durationMillis = if (obj.has("durationMillis")) obj.getLong("durationMillis") else null
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }
}
