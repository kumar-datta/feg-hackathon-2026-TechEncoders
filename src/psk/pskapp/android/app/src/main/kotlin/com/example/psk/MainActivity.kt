package com.example.psk

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val OVERLAY_CHANNEL = "com.example.psk/overlay"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canDrawOverlays" -> {
                        val canDraw = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            Settings.canDrawOverlays(this)
                        } else {
                            true
                        }
                        result.success(canDraw)
                    }
                    "requestOverlayPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            )
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(true)
                        }
                    }
                    "openNotificationSettings" -> {
                        val intent = Intent().apply {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
                                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                            } else {
                                action = "android.settings.APP_NOTIFICATION_SETTINGS"
                                putExtra("app_package", packageName)
                                putExtra("app_uid", applicationInfo.uid)
                            }
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    }
                    "startFloatingOverlay" -> {
                        val canDraw = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            Settings.canDrawOverlays(this)
                        } else {
                            true
                        }
                        if (!canDraw) {
                            result.error("PERMISSION_DENIED", "SYSTEM_ALERT_WINDOW permission not granted", null)
                            return@setMethodCallHandler
                        }

                        val intent = Intent(this, LiveMatchOverlayService::class.java).apply {
                            action = LiveMatchOverlayService.ACTION_START
                            putExtra(LiveMatchOverlayService.EXTRA_HOME_TEAM, call.argument<String>("homeTeam") ?: "Dinamo Zagreb")
                            putExtra(LiveMatchOverlayService.EXTRA_AWAY_TEAM, call.argument<String>("awayTeam") ?: "Hajduk Split")
                            putExtra(LiveMatchOverlayService.EXTRA_HOME_SCORE, call.argument<Int>("homeScore") ?: 2)
                            putExtra(LiveMatchOverlayService.EXTRA_AWAY_SCORE, call.argument<Int>("awayScore") ?: 1)
                            putExtra(LiveMatchOverlayService.EXTRA_MINUTE, call.argument<String>("minute") ?: "67'")
                            putExtra(LiveMatchOverlayService.EXTRA_LEAGUE, call.argument<String>("league") ?: "SuperSport HNL")
                            putExtra(LiveMatchOverlayService.EXTRA_ODDS_1, call.argument<String>("odds1") ?: "1.35")
                            putExtra(LiveMatchOverlayService.EXTRA_ODDS_X, call.argument<String>("oddsX") ?: "4.80")
                            putExtra(LiveMatchOverlayService.EXTRA_ODDS_2, call.argument<String>("odds2") ?: "9.50")
                        }

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    }
                    "updateFloatingOverlay" -> {
                        val homeTeam = call.argument<String>("homeTeam") ?: "Dinamo Zagreb"
                        val awayTeam = call.argument<String>("awayTeam") ?: "Hajduk Split"
                        val homeScore = call.argument<Int>("homeScore") ?: 2
                        val awayScore = call.argument<Int>("awayScore") ?: 1
                        val minute = call.argument<String>("minute") ?: "67'"
                        val league = call.argument<String>("league") ?: "SuperSport HNL"
                        val odds1 = call.argument<String>("odds1") ?: "1.35"
                        val oddsX = call.argument<String>("oddsX") ?: "4.80"
                        val odds2 = call.argument<String>("odds2") ?: "9.50"

                        LiveMatchOverlayService.updateOverlayData(
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
                        result.success(true)
                    }
                    "stopFloatingOverlay" -> {
                        val intent = Intent(this, LiveMatchOverlayService::class.java).apply {
                            action = LiveMatchOverlayService.ACTION_STOP
                        }
                        stopService(intent)
                        result.success(true)
                    }
                    "isFloatingOverlayRunning" -> {
                        result.success(LiveMatchOverlayService.isRunning)
                    }
                    "pinWidget" -> {
                        val tag = "PSKPulse"
                        try {
                            android.util.Log.d(tag, "pinWidget: SDK_INT=${Build.VERSION.SDK_INT}, applicationContext.packageName=${applicationContext.packageName}")
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                val widgetType = call.argument<String>("type") ?: "live"
                                val className = when (widgetType) {
                                    "slip" -> "com.example.psk.BetSlipWidgetReceiver"
                                    "boost" -> "com.example.psk.BoostWidgetReceiver"
                                    else -> "com.example.psk.LiveMatchWidgetReceiver"
                                }
                                android.util.Log.d(tag, "pinWidget: type=$widgetType, resolvedClassName=$className")
                                val provider = ComponentName(applicationContext, className)
                                val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
                                val supported = appWidgetManager.isRequestPinAppWidgetSupported
                                android.util.Log.d(tag, "pinWidget: isRequestPinAppWidgetSupported=$supported")
                                if (supported) {
                                    val accepted = appWidgetManager.requestPinAppWidget(provider, null, null)
                                    android.util.Log.d(tag, "pinWidget: requestPinAppWidget() returned=$accepted (this is the launcher's own accept/reject of the request)")
                                    result.success(true)
                                } else {
                                    android.util.Log.w(tag, "pinWidget: current launcher does NOT support requestPinAppWidget — this is a launcher limitation, not an app bug")
                                    result.success(false)
                                }
                            } else {
                                android.util.Log.w(tag, "pinWidget: requires API 26+, device is API ${Build.VERSION.SDK_INT}")
                                result.success(false)
                            }
                        } catch (e: Exception) {
                            android.util.Log.e(tag, "pinWidget: THREW", e)
                            result.error("PIN_WIDGET_ERROR", e.message, e.stackTraceToString())
                        }
                    }
                    "openHomeSettings" -> {
                        // There is no public API to check or change a launcher's
                        // "Lock Home screen layout" setting — that flag lives in
                        // each launcher's own private storage. This opens the
                        // closest thing Android exposes (Settings > Home); from
                        // there, or by long-pressing the home screen, the user
                        // reaches their launcher's own settings, where that
                        // toggle actually lives.
                        try {
                            val intent = Intent(Settings.ACTION_HOME_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            android.util.Log.e("PSKPulse", "openHomeSettings: THREW", e)
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
