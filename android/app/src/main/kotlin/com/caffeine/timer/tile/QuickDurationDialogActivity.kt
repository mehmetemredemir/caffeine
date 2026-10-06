package com.caffeine.timer.tile

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import androidx.appcompat.app.AppCompatActivity
import com.caffeine.timer.R
import com.caffeine.timer.service.ScreenAwakeForegroundService
import com.caffeine.timer.util.LocaleContextWrapper
import com.caffeine.timer.util.PresetPrefs
import java.util.concurrent.TimeUnit

class QuickDurationDialogActivity : AppCompatActivity() {

    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(LocaleContextWrapper.wrap(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_quick_duration)

        findViewById<Button>(R.id.btn5).setOnClickListener { startTimed(5 * 60) }
        findViewById<Button>(R.id.btn10).setOnClickListener { startTimed(10 * 60) }
        findViewById<Button>(R.id.btn15).setOnClickListener { startTimed(15 * 60) }
        findViewById<Button>(R.id.btn30).setOnClickListener { startTimed(30 * 60) }
        findViewById<Button>(R.id.btnIndefinite).setOnClickListener { startIndefinite() }
        findViewById<Button>(R.id.btnStop).setOnClickListener { stop() }

        populateUserPresets()
    }

    private fun populateUserPresets() {
        val container = findViewById<LinearLayout>(R.id.presetsContainer)
        val presets = PresetPrefs.getPresets(this)
        presets.forEach { preset ->
            val button = Button(this).apply {
                text = preset.label
                gravity = Gravity.CENTER
                setOnClickListener { startTimed(preset.durationSeconds) }
            }
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { topMargin = dpToPx(8) }
            container.addView(button, params)
        }
    }

    private fun dpToPx(dp: Int): Int = (dp * resources.displayMetrics.density).toInt()

    private fun startTimed(seconds: Int) {
        val intent = Intent(this, ScreenAwakeForegroundService::class.java).apply {
            action = ScreenAwakeForegroundService.ACTION_START_TIMED
            putExtra(ScreenAwakeForegroundService.EXTRA_DURATION_MILLIS, TimeUnit.SECONDS.toMillis(seconds.toLong()))
        }
        startForegroundService(intent)
        finish()
    }

    private fun startIndefinite() {
        val intent = Intent(this, ScreenAwakeForegroundService::class.java).apply {
            action = ScreenAwakeForegroundService.ACTION_START_INDEFINITE
        }
        startForegroundService(intent)
        finish()
    }

    private fun stop() {
        val intent = Intent(this, ScreenAwakeForegroundService::class.java).apply {
            action = ScreenAwakeForegroundService.ACTION_STOP
        }
        startService(intent)
        finish()
    }
}
