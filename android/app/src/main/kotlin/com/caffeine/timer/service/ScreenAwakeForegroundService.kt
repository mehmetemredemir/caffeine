package com.caffeine.timer.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.caffeine.timer.notification.WakeNotificationHelper
import com.caffeine.timer.util.ScreenKeepAliveController

class ScreenAwakeForegroundService : Service() {

    companion object {
        const val ACTION_START_TIMED = "com.caffeine.timer.action.START_TIMED"
        const val ACTION_START_INDEFINITE = "com.caffeine.timer.action.START_INDEFINITE"
        const val ACTION_STOP = "com.caffeine.timer.action.STOP"
        const val EXTRA_DURATION_MILLIS = "extra_duration_millis"
        const val NOTIFICATION_ID = 42

        private val listeners = mutableSetOf<(WakeSessionState) -> Unit>()
        var currentState: WakeSessionState = WakeSessionState()
            private set

        fun addListener(listener: (WakeSessionState) -> Unit) {
            listeners.add(listener)
            listener(currentState)
        }

        fun removeListener(listener: (WakeSessionState) -> Unit) {
            listeners.remove(listener)
        }

        private fun notifyListeners(state: WakeSessionState) {
            currentState = state
            listeners.forEach { it(state) }
        }
    }

    private lateinit var keepAlive: ScreenKeepAliveController
    private lateinit var notificationHelper: WakeNotificationHelper
    private lateinit var sessionManager: WakeSessionManager

    override fun onCreate() {
        super.onCreate()
        keepAlive = ScreenKeepAliveController(this)
        notificationHelper = WakeNotificationHelper(this)
     sessionManager = WakeSessionManager(
    onTick = { state ->
        notifyListeners(state)
        // notificationHelper.update(state) removed — the notification is now
        // updated by the system itself via its own chronometer.
    },
    onFinish = {
        notifyListeners(sessionManager.state)
        keepAlive.release()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }
)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    when (intent?.action) {
        ACTION_START_TIMED -> {
            val duration = intent.getLongExtra(EXTRA_DURATION_MILLIS, 0L)
            keepAlive.acquire()
            sessionManager.startTimed(duration)
            startForeground(NOTIFICATION_ID, notificationHelper.build(sessionManager.state))
        }
        ACTION_START_INDEFINITE -> {
            keepAlive.acquire()
            sessionManager.startIndefinite()
            startForeground(NOTIFICATION_ID, notificationHelper.build(sessionManager.state))
        }
        ACTION_STOP -> sessionManager.stop()
    }
    return START_STICKY
}

    override fun onDestroy() {
        keepAlive.release()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
