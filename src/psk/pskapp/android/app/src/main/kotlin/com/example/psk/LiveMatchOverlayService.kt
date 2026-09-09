package com.example.psk

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Native Android Floating Live Match Overlay Service.
 *
 * Renders a draggable, real-time live score card over any screen, launcher, or
 * lock screen using Android's WindowManager and TYPE_APPLICATION_OVERLAY.
 * Requires android.permission.SYSTEM_ALERT_WINDOW ("Display over other apps").
 */
class LiveMatchOverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null

    // UI elements to update dynamically
    private var tvLeague: TextView? = null
    private var tvMinute: TextView? = null
    private var tvTeams: TextView? = null
    private var tvScore: TextView? = null
    private var oddsContainer: LinearLayout? = null

    companion object {
        const val CHANNEL_ID = "psk_pulse_overlay_channel"
        const val NOTIFICATION_ID = 8001

        const val ACTION_START = "com.example.psk.START_OVERLAY"
        const val ACTION_STOP = "com.example.psk.STOP_OVERLAY"
        const val ACTION_UPDATE = "com.example.psk.UPDATE_OVERLAY"

        const val EXTRA_HOME_TEAM = "home_team"
        const val EXTRA_AWAY_TEAM = "away_team"
        const val EXTRA_HOME_SCORE = "home_score"
        const val EXTRA_AWAY_SCORE = "away_score"
        const val EXTRA_MINUTE = "minute"
        const val EXTRA_LEAGUE = "league"
        const val EXTRA_ODDS_1 = "odds_1"
        const val EXTRA_ODDS_X = "odds_x"
        const val EXTRA_ODDS_2 = "odds_2"
        const val EXTRA_EVENT_ID = "event_id"

        var isRunning = false
            private set

        private var activeService: LiveMatchOverlayService? = null

        fun updateOverlayData(
            homeTeam: String,
            awayTeam: String,
            homeScore: Int,
            awayScore: Int,
            minute: String,
            league: String,
            odds1: String,
            oddsX: String,
            odds2: String,
        ) {
            activeService?.updateViews(
                homeTeam = homeTeam,
                awayTeam = awayTeam,
                homeScore = homeScore,
                awayScore = awayScore,
                minute = minute,
                league = league,
                odds1 = odds1,
                oddsX = oddsX,
                odds2 = odds2,
            )
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        activeService = this
        isRunning = true
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildForegroundNotification())
        initOverlay()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) return START_STICKY

        when (intent.action) {
            ACTION_STOP -> {
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_UPDATE, ACTION_START -> {
                val homeTeam = intent.getStringExtra(EXTRA_HOME_TEAM) ?: "Dinamo Zagreb"
                val awayTeam = intent.getStringExtra(EXTRA_AWAY_TEAM) ?: "Hajduk Split"
                val homeScore = intent.getIntExtra(EXTRA_HOME_SCORE, 2)
                val awayScore = intent.getIntExtra(EXTRA_AWAY_SCORE, 1)
                val minute = intent.getStringExtra(EXTRA_MINUTE) ?: "67'"
                val league = intent.getStringExtra(EXTRA_LEAGUE) ?: "SuperSport HNL"
                val odds1 = intent.getStringExtra(EXTRA_ODDS_1) ?: "1.35"
                val oddsX = intent.getStringExtra(EXTRA_ODDS_X) ?: "4.80"
                val odds2 = intent.getStringExtra(EXTRA_ODDS_2) ?: "9.50"

                updateViews(
                    homeTeam = homeTeam,
                    awayTeam = awayTeam,
                    homeScore = homeScore,
                    awayScore = awayScore,
                    minute = minute,
                    league = league,
                    odds1 = odds1,
                    oddsX = oddsX,
                    odds2 = odds2,
                )
            }
        }
        return START_STICKY
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initOverlay() {
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val overlayType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        layoutParams = WindowManager.LayoutParams(
            dpToPx(270),
            WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = dpToPx(20)
            y = dpToPx(120)
        }

        // Root container with dark styling and gold accent border
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dpToPx(10), dpToPx(8), dpToPx(10), dpToPx(10))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#18181E"))
                cornerRadius = dpToPx(14).toFloat()
                setStroke(dpToPx(2), Color.parseColor("#FFDB01"))
            }
            elevation = dpToPx(10).toFloat()
        }

        // Top Header Row: [LIVE] [67'] [League] ... [X]
        val headerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        val liveBadge = TextView(this).apply {
            text = "LIVE"
            textSize = 9f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.WHITE)
            setPadding(dpToPx(6), dpToPx(2), dpToPx(6), dpToPx(2))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#0E7C1C"))
                cornerRadius = dpToPx(6).toFloat()
            }
        }

        tvMinute = TextView(this).apply {
            text = "67'"
            textSize = 10f
            setTextColor(Color.parseColor("#B0B0C0"))
            setPadding(dpToPx(6), 0, dpToPx(4), 0)
        }

        tvLeague = TextView(this).apply {
            text = "SuperSport HNL"
            textSize = 9f
            setTextColor(Color.parseColor("#8E8E9E"))
            maxLines = 1
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        }

        val closeBtn = TextView(this).apply {
            text = "✕"
            textSize = 13f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.parseColor("#B0B0C0"))
            setPadding(dpToPx(6), dpToPx(2), dpToPx(4), dpToPx(2))
            setOnClickListener {
                stopSelf()
            }
        }

        headerRow.addView(liveBadge)
        headerRow.addView(tvMinute)
        headerRow.addView(tvLeague)
        headerRow.addView(closeBtn)
        root.addView(headerRow)

        // Teams & Score Row
        val scoreRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, dpToPx(6), 0, dpToPx(6))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        tvTeams = TextView(this).apply {
            text = "Dinamo Zagreb vs Hajduk Split"
            textSize = 11.5f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.WHITE)
            maxLines = 1
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        }

        tvScore = TextView(this).apply {
            text = "2–1"
            textSize = 16f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.parseColor("#FFDB01"))
            setPadding(dpToPx(6), 0, 0, 0)
        }

        scoreRow.addView(tvTeams)
        scoreRow.addView(tvScore)
        root.addView(scoreRow)

        // Odds Row: [1: 1.35] [X: 4.80] [2: 9.50]
        oddsContainer = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        root.addView(oddsContainer)

        updateOddsPills("1.35", "4.80", "9.50")

        // Touch & Drag Handling
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f

        root.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = layoutParams?.x ?: 0
                    initialY = layoutParams?.y ?: 0
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    layoutParams?.x = initialX + (event.rawX - initialTouchX).toInt()
                    layoutParams?.y = initialY + (event.rawY - initialTouchY).toInt()
                    try {
                        windowManager?.updateViewLayout(root, layoutParams)
                    } catch (_: Exception) {}
                    true
                }
                MotionEvent.ACTION_UP -> {
                    val diffX = Math.abs(event.rawX - initialTouchX)
                    val diffY = Math.abs(event.rawY - initialTouchY)
                    // If tap with minimal movement, open the app
                    if (diffX < 10 && diffY < 10) {
                        val launchIntent = Intent(Intent.ACTION_VIEW, Uri.parse("psk://live")).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                        }
                        startActivity(launchIntent)
                    }
                    true
                }
                else -> false
            }
        }

        overlayView = root

        try {
            windowManager?.addView(overlayView, layoutParams)
        } catch (e: Exception) {
            e.printStackTrace()
            stopSelf()
        }
    }

    private fun updateOddsPills(o1: String, oX: String, o2: String) {
        val container = oddsContainer ?: return
        container.removeAllViews()

        val odds = listOf(
            Triple("1", o1, "#35E94D"),
            Triple("X", oX, "#C52D16"),
            Triple("2", o2, "#C52D16"),
        )

        for ((label, value, colorHex) in odds) {
            val pill = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER
                setPadding(dpToPx(4), dpToPx(3), dpToPx(4), dpToPx(3))
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                    setMargins(dpToPx(2), 0, dpToPx(2), 0)
                }
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#363644"))
                    cornerRadius = dpToPx(4).toFloat()
                }
            }

            val tvL = TextView(this).apply {
                text = label
                textSize = 9.5f
                setTextColor(Color.parseColor("#B0B0C0"))
                setPadding(0, 0, dpToPx(4), 0)
            }
            val tvV = TextView(this).apply {
                text = value
                textSize = 10.5f
                setTypeface(null, Typeface.BOLD)
                setTextColor(Color.parseColor(colorHex))
            }

            pill.addView(tvL)
            pill.addView(tvV)
            container.addView(pill)
        }
    }

    fun updateViews(
        homeTeam: String,
        awayTeam: String,
        homeScore: Int,
        awayScore: Int,
        minute: String,
        league: String,
        odds1: String,
        oddsX: String,
        odds2: String,
    ) {
        tvMinute?.text = minute
        tvLeague?.text = league
        tvTeams?.text = "$homeTeam vs $awayTeam"
        tvScore?.text = "$homeScore–$awayScore"
        updateOddsPills(odds1, oddsX, odds2)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "PSK Live Floating Overlay",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows floating score widget status over apps and home screen"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun buildForegroundNotification(): Notification {
        val launchIntent = Intent(Intent.ACTION_VIEW, Uri.parse("psk://live"))
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setContentTitle("PSK Live Match Overlay Active")
            .setContentText("Draggable live score card running on screen")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        activeService = null
        if (overlayView != null && windowManager != null) {
            try {
                windowManager?.removeView(overlayView)
            } catch (_: Exception) {}
            overlayView = null
        }
    }
}
