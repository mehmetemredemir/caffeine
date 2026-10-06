package com.caffeine.timer.service

import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import com.caffeine.timer.notification.WakeNotificationHelper
import com.caffeine.timer.util.AppWatchPrefs
import com.caffeine.timer.util.ScreenKeepAliveController

class AppWatcherService : Service() {

    companion object {
        const val ACTION_START_WATCHING = "com.caffeine.timer.action.START_WATCHING"
        const val ACTION_STOP_WATCHING = "com.caffeine.timer.action.STOP_WATCHING"
        const val EXTRA_TARGETS_JSON = "extra_targets_json"
        const val NOTIFICATION_ID = 43
        const val POLL_INTERVAL_MS = 1000L
        var listener: ((AppWatcherState) -> Unit)? = null
    }

    data class AppWatcherState(val isWatching: Boolean, val activePackage: String?)

    private lateinit var notificationHelper: WakeNotificationHelper
    private lateinit var usageStatsManager: UsageStatsManager
    private lateinit var keepAlive: ScreenKeepAliveController
    private val handler = Handler(Looper.getMainLooper())

    private var targets: List<AppWatchPrefs.Target> = emptyList()
    private var currentForegroundTracked: String? = null
    private var lastEventTimestamp: Long = System.currentTimeMillis()

    /** Fires when a per-app duration expires — releases the wakelock even if the
     * app is still in the foreground (watching continues; if the app is reopened,
     * the duration starts over). */
    private val expiryRunnable = Runnable {
        keepAlive.release()
        currentForegroundTracked = null
        listener?.invoke(AppWatcherState(isWatching = true, activePackage = null))
        notificationHelper.updateWatching(targets.size, null)
    }

    private val pollRunnable = object : Runnable {
        override fun run() {
            try {
                checkForegroundApp()
            } catch (e: Exception) {
                // Critical fix: a single transient error no longer stops the
                // entire watching loop forever.
            } finally {
                handler.postDelayed(this, POLL_INTERVAL_MS)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        notificationHelper = WakeNotificationHelper(this)
        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        keepAlive = ScreenKeepAliveController(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_WATCHING -> {
                val json = intent.getStringExtra(EXTRA_TARGETS_JSON)
                targets = if (json != null) AppWatchPrefs.parseTargetsJson(json)
                          else AppWatchPrefs.getTargets(this)
                AppWatchPrefs.saveTargets(this, targets)

                startForeground(NOTIFICATION_ID, notificationHelper.buildWatching(targets.size))
                lastEventTimestamp = System.currentTimeMillis()
                handler.removeCallbacks(pollRunnable)
                handler.removeCallbacks(expiryRunnable)
                handler.post(pollRunnable)
                listener?.invoke(AppWatcherState(isWatching = true, activePackage = null))
            }
            ACTION_STOP_WATCHING -> stopWatching()
            null -> {
                targets = AppWatchPrefs.getTargets(this)
                if (targets.isNotEmpty()) {
                    startForeground(NOTIFICATION_ID, notificationHelper.buildWatching(targets.size))
                    handler.post(pollRunnable)
                } else stopSelf()
            }
        }
        return START_STICKY
    }

    private fun checkForegroundApp() {
        if (targets.isEmpty()) return
        val trackedPackages = targets.map { it.packageName }.toSet()
        val now = System.currentTimeMillis()
        val events = usageStatsManager.queryEvents(lastEventTimestamp, now)
        val event = UsageEvents.Event()
        var latestForegroundPackage: String? = currentForegroundTracked

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val isForegroundEvent = event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND ||
                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
                    event.eventType == UsageEvents.Event.ACTIVITY_RESUMED)
            val isBackgroundEvent = event.eventType == UsageEvents.Event.MOVE_TO_BACKGROUND ||
                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
                    event.eventType == UsageEvents.Event.ACTIVITY_PAUSED)

            when {
                isForegroundEvent ->
                    latestForegroundPackage = if (trackedPackages.contains(event.packageName)) event.packageName else null
                isBackgroundEvent ->
                    if (event.packageName == currentForegroundTracked) latestForegroundPackage = null
            }
        }
        lastEventTimestamp = now

        if (latestForegroundPackage != currentForegroundTracked) {
            switchTrackedApp(latestForegroundPackage)
        }
    }

    private fun switchTrackedApp(newPackage: String?) {
        currentForegroundTracked = newPackage
        handler.removeCallbacks(expiryRunnable)

        if (newPackage == null) {
            keepAlive.release()
        } else {
            keepAlive.acquire()
            val duration = targets.find { it.packageName == newPackage }?.durationMillis
            if (duration != null) handler.postDelayed(expiryRunnable, duration)
        }
        listener?.invoke(AppWatcherState(isWatching = true, activePackage = currentForegroundTracked))
        notificationHelper.updateWatching(targets.size, currentForegroundTracked)
    }

    private fun stopWatching() {
        handler.removeCallbacks(pollRunnable)
        handler.removeCallbacks(expiryRunnable)
        keepAlive.release()
        targets = emptyList()
        currentForegroundTracked = null
        AppWatchPrefs.clear(this)
        listener?.invoke(AppWatcherState(isWatching = false, activePackage = null))
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        handler.removeCallbacks(pollRunnable)
        handler.removeCallbacks(expiryRunnable)
        keepAlive.release()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
