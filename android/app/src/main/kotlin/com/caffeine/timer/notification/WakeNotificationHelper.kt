package com.caffeine.timer.notification

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.caffeine.timer.R
import com.caffeine.timer.receiver.StopActionReceiver
import com.caffeine.timer.service.AppWatcherService
import com.caffeine.timer.service.ScreenAwakeForegroundService
import com.caffeine.timer.service.WakeMode
import com.caffeine.timer.service.WakeSessionState
import com.caffeine.timer.util.LocaleContextWrapper
import java.util.concurrent.TimeUnit
import android.graphics.drawable.Icon

class WakeNotificationHelper(private val context: Context) {

    private val channelId = "screen_awake_channel"
    private val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    private val localizedContext get() = LocaleContextWrapper.wrap(context)

    init {
        val channelName = localizedContext.getString(R.string.notification_channel_name)
        val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_LOW)
            .apply { setShowBadge(false) }
        manager.createNotificationChannel(channel)
    }

   fun build(state: WakeSessionState): Notification {
    val res = localizedContext
    val stopIntent = Intent(context, StopActionReceiver::class.java)
    val stopPendingIntent = PendingIntent.getBroadcast(
        context, 0, stopIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val builder = Notification.Builder(context, channelId)
        .setContentTitle(res.getString(R.string.notification_title))
        .setSmallIcon(R.drawable.ic_tile_caffeine)
        .setOngoing(true)
        .setOnlyAlertOnce(true)
        .addAction(
            Notification.Action.Builder(
                Icon.createWithResource(context, R.drawable.ic_tile_caffeine),
                res.getString(R.string.stop),
                stopPendingIntent
            ).build()
        )

    when (state.mode) {
        WakeMode.INDEFINITE -> {
            builder.setContentText(res.getString(R.string.notification_active_indefinite))
        }
        else -> {
            // The system renders the countdown itself — no need to call notify() every second.
            builder.setContentText(res.getString(R.string.notification_active_timed))
                .setShowWhen(true)
                .setUsesChronometer(true)
                .setChronometerCountDown(true)
                .setWhen(System.currentTimeMillis() + state.remainingMillis)
        }
    }
    return builder.build()
}

    fun update(state: WakeSessionState) {
        manager.notify(ScreenAwakeForegroundService.NOTIFICATION_ID, build(state))
    }

    fun buildWatching(trackedCount: Int, activePackage: String? = null): Notification {
        val res = localizedContext
        val stopIntent = Intent(context, AppWatcherService::class.java).apply {
            action = AppWatcherService.ACTION_STOP_WATCHING
        }
        val stopPendingIntent = PendingIntent.getService(
            context, 1, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val contentText = if (activePackage != null) {
            res.getString(R.string.notification_app_bound_active)
        } else {
            res.getString(R.string.notification_watching, trackedCount)
        }

        return NotificationCompat.Builder(context, channelId)
            .setContentTitle(res.getString(R.string.notification_title))
            .setContentText(contentText)
            .setSmallIcon(R.drawable.ic_tile_caffeine)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(0, res.getString(R.string.stop), stopPendingIntent)
            .build()
    }

    fun updateWatching(trackedCount: Int, activePackage: String?) {
        manager.notify(AppWatcherService.NOTIFICATION_ID, buildWatching(trackedCount, activePackage))
    }

    private fun formatMillis(millis: Long): String {
        val m = TimeUnit.MILLISECONDS.toMinutes(millis)
        val s = TimeUnit.MILLISECONDS.toSeconds(millis) % 60
        return String.format("%02d:%02d", m, s)
    }
}
