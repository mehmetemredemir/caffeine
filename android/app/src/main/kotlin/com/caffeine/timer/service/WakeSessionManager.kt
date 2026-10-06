package com.caffeine.timer.service

import android.os.CountDownTimer

enum class WakeMode { TIMED, INDEFINITE, APP_BOUND }

data class WakeSessionState(
    val isActive: Boolean = false,
    val mode: WakeMode = WakeMode.INDEFINITE,
    val remainingMillis: Long = 0L,
    val totalMillis: Long = 0L,
    val boundPackage: String? = null
)

class WakeSessionManager(
    private val onTick: (WakeSessionState) -> Unit,
    private val onFinish: () -> Unit
) {
    private var timer: CountDownTimer? = null

    var state: WakeSessionState = WakeSessionState()
        private set

    fun startTimed(durationMillis: Long) {
        cancelTimer()
        state = WakeSessionState(
            isActive = true,
            mode = WakeMode.TIMED,
            remainingMillis = durationMillis,
            totalMillis = durationMillis
        )
        timer = object : CountDownTimer(durationMillis, 1000L) {
            override fun onTick(millisUntilFinished: Long) {
                state = state.copy(remainingMillis = millisUntilFinished)
                onTick(state)
            }

            override fun onFinish() {
                state = state.copy(isActive = false, remainingMillis = 0L)
                onFinish()
            }
        }.start()
        onTick(state)
    }

    fun startIndefinite() {
        cancelTimer()
        state = WakeSessionState(isActive = true, mode = WakeMode.INDEFINITE)
        onTick(state)
    }

    fun startAppBound(packageName: String, durationMillis: Long?) {
        cancelTimer()
        state = WakeSessionState(
            isActive = true,
            mode = WakeMode.APP_BOUND,
            remainingMillis = durationMillis ?: 0L,
            totalMillis = durationMillis ?: 0L,
            boundPackage = packageName
        )
        if (durationMillis != null) {
            startTimed(durationMillis)
        } else {
            onTick(state)
        }
    }

    fun stop() {
        cancelTimer()
        state = WakeSessionState(isActive = false)
        onFinish()
    }

    private fun cancelTimer() {
        timer?.cancel()
        timer = null
    }
}
