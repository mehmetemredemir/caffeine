package com.caffeine.timer.tile

import android.graphics.drawable.Icon
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.content.Intent
import com.caffeine.timer.R
import com.caffeine.timer.service.ScreenAwakeForegroundService
import com.caffeine.timer.service.WakeSessionState
import com.caffeine.timer.util.LocaleContextWrapper
import com.caffeine.timer.util.TileDurationPrefs

class ScreenAwakeTileService : TileService() {

    private val stateListener: (WakeSessionState) -> Unit = { state -> updateTile(state) }

    override fun onStartListening() {
        super.onStartListening()
        ScreenAwakeForegroundService.addListener(stateListener)
    }

    override fun onStopListening() {
        ScreenAwakeForegroundService.removeListener(stateListener)
        super.onStopListening()
    }

    override fun onClick() {
        super.onClick()
        val currentlyActive = ScreenAwakeForegroundService.currentState.isActive
        if (currentlyActive) {
            sendServiceAction(ScreenAwakeForegroundService.ACTION_STOP, null)
        } else {
            val defaultMillis = TileDurationPrefs.getDefaultDurationMillis(this)
            if (defaultMillis == null) {
                sendServiceAction(ScreenAwakeForegroundService.ACTION_START_INDEFINITE, null)
            } else {
                sendServiceAction(ScreenAwakeForegroundService.ACTION_START_TIMED, defaultMillis)
            }
        }
    }

    private fun sendServiceAction(action: String, durationMillis: Long?) {
        val intent = Intent(this, ScreenAwakeForegroundService::class.java).apply {
            this.action = action
            if (durationMillis != null) {
                putExtra(ScreenAwakeForegroundService.EXTRA_DURATION_MILLIS, durationMillis)
            }
        }
        startForegroundService(intent)
    }

    private fun updateTile(state: WakeSessionState) {
        val tile = qsTile ?: return
        val res = LocaleContextWrapper.wrap(this)

        tile.state = if (state.isActive) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.label = res.getString(R.string.tile_label)
        tile.icon = Icon.createWithResource(this, R.drawable.ic_tile_caffeine)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.subtitle = when {
                !state.isActive -> null
                state.mode.name == "INDEFINITE" -> res.getString(R.string.tile_subtitle_on)
                else -> res.getString(R.string.tile_subtitle_timing)
            }
        }

        tile.updateTile()
    }
}
