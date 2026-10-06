package com.caffeine.timer

import android.content.Intent
import com.caffeine.timer.service.AppWatcherService
import com.caffeine.timer.service.ScreenAwakeForegroundService
import com.caffeine.timer.service.WakeSessionState
import com.caffeine.timer.util.AppWatchPrefs
import com.caffeine.timer.util.BatteryOptimizationHelper
import com.caffeine.timer.util.InstalledAppsHelper
import com.caffeine.timer.util.LocalePrefs
import com.caffeine.timer.util.NotificationPermissionHelper
import com.caffeine.timer.util.OverlayPermissionHelper
import com.caffeine.timer.util.PresetPrefs
import com.caffeine.timer.util.TileDurationPrefs
import com.caffeine.timer.util.UsageStatsPermissionHelper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

class MainActivity : FlutterActivity() {

    private val wakeMethodChannelName = "com.caffeine.timer/screen_wake"
    private val wakeEventChannelName = "com.caffeine.timer/screen_wake_events"
    private val permissionChannelName = "com.caffeine.timer/permissions"
    private val settingsChannelName = "com.caffeine.timer/settings"
    private val appWatchChannelName = "com.caffeine.timer/app_watch"
    private val appWatchEventChannelName = "com.caffeine.timer/app_watch_events"
    private val installedAppsChannelName = "com.caffeine.timer/installed_apps"

    private var wakeEventSink: EventChannel.EventSink? = null
    private var appWatchEventSink: EventChannel.EventSink? = null

    private val wakeStateListener: (WakeSessionState) -> Unit = { state -> sendWakeState(state) }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // --- Wake control ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, wakeMethodChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startTimed" -> {
                        val millis = (call.argument<Number>("durationMillis"))?.toLong() ?: 0L
                        val intent = Intent(this, ScreenAwakeForegroundService::class.java).apply {
                            action = ScreenAwakeForegroundService.ACTION_START_TIMED
                            putExtra(ScreenAwakeForegroundService.EXTRA_DURATION_MILLIS, millis)
                        }
                        startForegroundService(intent)
                        result.success(null)
                    }
                    "startIndefinite" -> {
                        val intent = Intent(this, ScreenAwakeForegroundService::class.java).apply {
                            action = ScreenAwakeForegroundService.ACTION_START_INDEFINITE
                        }
                        startForegroundService(intent)
                        result.success(null)
                    }
                    "stop" -> {
                        val intent = Intent(this, ScreenAwakeForegroundService::class.java).apply {
                            action = ScreenAwakeForegroundService.ACTION_STOP
                        }
                        startService(intent)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, wakeEventChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    wakeEventSink = sink
                    ScreenAwakeForegroundService.addListener(wakeStateListener)
                }
                override fun onCancel(arguments: Any?) {
                    ScreenAwakeForegroundService.removeListener(wakeStateListener)
                    wakeEventSink = null
                }
            })

        // --- Permissions ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, permissionChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isIgnoringBatteryOptimizations" ->
                        result.success(BatteryOptimizationHelper.isIgnoringBatteryOptimizations(this))
                    "requestIgnoreBatteryOptimizations" -> {
                        BatteryOptimizationHelper.requestIgnoreBatteryOptimizations(this)
                        result.success(null)
                    }
                    "hasUsageStatsPermission" ->
                        result.success(UsageStatsPermissionHelper.hasUsageStatsPermission(this))
                    "openUsageAccessSettings" -> {
                        UsageStatsPermissionHelper.openUsageAccessSettings(this)
                        result.success(null)
                    }
                    "hasNotificationPermission" ->
                        result.success(NotificationPermissionHelper.hasPermission(this))
                    "requestNotificationPermission" -> {
                        NotificationPermissionHelper.requestPermission(this)
                        result.success(null)
                    }
                    "hasOverlayPermission" ->
                        result.success(OverlayPermissionHelper.canDrawOverlays(this))
                    "requestOverlayPermission" -> {
                        OverlayPermissionHelper.requestOverlayPermission(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // --- Settings: language + default tile duration + preset sync ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, settingsChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setLocale" -> {
                        val code = call.argument<String>("languageCode") ?: "en"
                        LocalePrefs.setLanguageCode(this, code)
                        result.success(null)
                    }
                    "setDefaultTileDuration" -> {
                        val millis = call.argument<Number>("durationMillis")?.toLong()
                        TileDurationPrefs.setDefaultDurationMillis(this, millis)
                        result.success(null)
                    }
                    "getDefaultTileDuration" ->
                        result.success(TileDurationPrefs.getDefaultDurationMillis(this))
                    "syncPresets" -> {
                        val presetsArg = call.argument<List<Map<String, Any>>>("presets") ?: emptyList()
                        val entries = presetsArg.map {
                            PresetPrefs.PresetEntry(
                                label = it["label"] as String,
                                durationSeconds = (it["durationSeconds"] as Number).toInt()
                            )
                        }
                        PresetPrefs.savePresets(this, entries)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // --- Installed apps (for the App Selector screen) — runs on a background thread ---
        val installedAppsTaskQueue = flutterEngine.dartExecutor.binaryMessenger.makeBackgroundTaskQueue()
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            installedAppsChannelName,
            StandardMethodCodec.INSTANCE,
            installedAppsTaskQueue
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" ->
                    result.success(InstalledAppsHelper.getLaunchableApps(this))
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    result.success(
                        if (packageName == null) null
                        else InstalledAppsHelper.getAppIconBase64(this, packageName)
                    )
                }
                else -> result.notImplemented()
            }
        }

        // --- App-specific wakelock (supports a per-app custom duration) ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appWatchChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val targetsArg = call.argument<List<Map<String, Any?>>>("targets") ?: emptyList()
                        val targets = targetsArg.map {
                            AppWatchPrefs.Target(
                                packageName = it["packageName"] as String,
                                durationMillis = (it["durationSeconds"] as? Number)?.toLong()?.times(1000)
                            )
                        }
                        val intent = Intent(this, AppWatcherService::class.java).apply {
                            action = AppWatcherService.ACTION_START_WATCHING
                            putExtra(AppWatcherService.EXTRA_TARGETS_JSON, AppWatchPrefs.toJson(targets))
                        }
                        startForegroundService(intent)
                        result.success(null)
                    }
                    "stop" -> {
                        val intent = Intent(this, AppWatcherService::class.java).apply {
                            action = AppWatcherService.ACTION_STOP_WATCHING
                        }
                        startService(intent)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, appWatchEventChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    appWatchEventSink = sink
                    AppWatcherService.listener = { state ->
                        runOnUiThread {
                            appWatchEventSink?.success(
                                mapOf(
                                    "isWatching" to state.isWatching,
                                    "activePackage" to state.activePackage
                                )
                            )
                        }
                    }
                }
                override fun onCancel(arguments: Any?) {
                    AppWatcherService.listener = null
                    appWatchEventSink = null
                }
            })
    }

    private fun sendWakeState(state: WakeSessionState) {
        runOnUiThread {
            wakeEventSink?.success(
                mapOf(
                    "isActive" to state.isActive,
                    "mode" to state.mode.name,
                    "remainingMillis" to state.remainingMillis,
                    "totalMillis" to state.totalMillis,
                    "boundPackage" to state.boundPackage
                )
            )
        }
    }
}
