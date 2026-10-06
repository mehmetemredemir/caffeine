package com.caffeine.timer.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.caffeine.timer.service.ScreenAwakeForegroundService

class StopActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val stopIntent = Intent(context, ScreenAwakeForegroundService::class.java).apply {
            action = ScreenAwakeForegroundService.ACTION_STOP
        }
        context.startService(stopIntent)
    }
}
