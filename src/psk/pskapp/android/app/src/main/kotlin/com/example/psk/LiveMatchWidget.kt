// PSK Pulse — Live Match widget (2x2). Renders the SportEvent snapshot the
// Flutter app writes via WidgetBridgeService.pushLiveMatch, in whichever of
// the four designs the user picked in PSK Pulse Widgets settings
// ("live_widget_style" — see lib/models/widget_style.dart for the source of
// truth on the style keys).
package com.example.psk

import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.actionStartActivity

private val TileBg = Color(0xFF18181E)
private val PillBg = Color(0xFF363644)
private val TextWhite = Color(0xFFFFFFFF)
private val TextMuted = Color(0xFFB0B0C0)
private val Gold = Color(0xFFFFDB01)
private val GoldInk = Color(0xFF3A2F00)
private val LiveGreen = Color(0xFF0E7C1C)
private val OddsUp = Color(0xFFC52D16)
private val OddsDown = Color(0xFF35E94D)

private data class OddPill(val label: String, val value: String, val trend: String)

private data class LiveMatchData(
    val league: String,
    val homeTeam: String,
    val awayTeam: String,
    val homeScore: Int,
    val awayScore: Int,
    val minute: String,
    val odds: List<OddPill>,
)

private fun readMatchData(prefs: SharedPreferences): LiveMatchData {
    val homeTeam = prefs.getString("live_home_team", "") ?: ""
    if (homeTeam.isEmpty()) {
        return LiveMatchData(
            league = "SuperSport HNL",
            homeTeam = "Dinamo Zagreb",
            awayTeam = "Hajduk Split",
            homeScore = 2,
            awayScore = 1,
            minute = "67'",
            odds = listOf(
                OddPill("1", "1.35", "down"),
                OddPill("X", "4.80", "up"),
                OddPill("2", "9.50", "up"),
            ),
        )
    }
    val odds = (0..2).mapNotNull { i ->
        val label = prefs.getString("live_odds_${i}_label", "") ?: ""
        if (label.isEmpty()) return@mapNotNull null
        OddPill(
            label = label,
            value = prefs.getString("live_odds_${i}_value", "") ?: "",
            trend = prefs.getString("live_odds_${i}_trend", "flat") ?: "flat",
        )
    }
    return LiveMatchData(
        league = prefs.getString("live_league", "SuperSport HNL") ?: "SuperSport HNL",
        homeTeam = homeTeam,
        awayTeam = prefs.getString("live_away_team", "") ?: "",
        homeScore = prefs.getInt("live_home_score", 0),
        awayScore = prefs.getInt("live_away_score", 0),
        minute = prefs.getString("live_minute", "LIVE") ?: "LIVE",
        odds = if (odds.isNotEmpty()) odds else listOf(
            OddPill("1", "1.35", "down"),
            OddPill("X", "4.80", "up"),
            OddPill("2", "9.50", "up"),
        ),
    )
}

private fun trendColor(trend: String): Color = if (trend == "up") OddsUp else if (trend == "down") OddsDown else TextMuted
private fun trendArrow(trend: String): String = if (trend == "up") " ▲" else if (trend == "down") " ▼" else ""

class LiveMatchWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent { Content(context, currentState()) }
    }

    @Composable
    private fun Content(context: Context, currentState: HomeWidgetGlanceState) {
        val prefs = currentState.preferences
        val eventId = prefs.getString("live_event_id", "") ?: ""
        val uri = Uri.parse(if (eventId.isEmpty()) "psk://live" else "psk://live/$eventId")
        // Flipped every ~30s by AppState's rotation timer — 0 = live score,
        // 1 = wallet (balance / potential win). See _startPulseRotation in
        // lib/state/app_state.dart for the honest caveat on what "every 30
        // seconds" can mean for a home-screen widget.
        val faceIndex = prefs.getInt("live_face_index", 0)

        Box(
            modifier =
                GlanceModifier.fillMaxSize()
                    .background(TileBg)
                    .padding(14.dp)
                    .clickable(actionStartActivity<MainActivity>(context, uri))
        ) {
            GuardrailGate(prefs, "live_widget_enabled") {
                val hasMatch = if (prefs.contains("live_has_match")) prefs.getBoolean("live_has_match", true) else true
                if (!hasMatch) {
                    Box(modifier = GlanceModifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text(
                            "No live match tracked",
                            style = TextStyle(color = ColorProvider(TextMuted), fontSize = 12.sp),
                        )
                    }
                } else {
                    Box(modifier = GlanceModifier.fillMaxSize()) {
                        if (faceIndex == 1) {
                            WalletFaceContent(prefs)
                        } else {
                            val data = readMatchData(prefs)
                            when (prefs.getString("live_widget_style", "classic") ?: "classic") {
                                "minimal" -> MinimalMatchContent(data)
                                "odds_focus" -> OddsFocusMatchContent(data)
                                "scoreboard" -> ScoreboardMatchContent(data)
                                else -> ClassicMatchContent(data)
                            }
                        }
                        RotationDots(activeIndex = faceIndex)
                    }
                }
            }
        }
    }

    @Composable
    private fun RotationDots(activeIndex: Int) {
        Box(modifier = GlanceModifier.fillMaxSize(), contentAlignment = Alignment.BottomCenter) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(modifier = GlanceModifier.size(5.dp).background(if (activeIndex == 0) Gold else PillBg)) {}
                Spacer(modifier = GlanceModifier.width(4.dp))
                Box(modifier = GlanceModifier.size(5.dp).background(if (activeIndex == 1) Gold else PillBg)) {}
            }
        }
    }

    @Composable
    private fun WalletFaceContent(prefs: SharedPreferences) {
        val balance = prefs.getString("live_wallet_balance", "€0.00") ?: "€0.00"
        val slipCount = prefs.getInt("live_wallet_slip_count", 0)
        val slipOdds = prefs.getString("live_wallet_slip_odds", "") ?: ""
        val slipWin = prefs.getString("live_wallet_slip_win", "") ?: ""

        Column(
            modifier = GlanceModifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(modifier = GlanceModifier.background(PillBg).padding(horizontal = 7.dp, vertical = 2.dp)) {
                Text(
                    "YOUR WALLET",
                    style = TextStyle(color = ColorProvider(Gold), fontSize = 9.sp, fontWeight = FontWeight.Bold),
                )
            }

            Spacer(modifier = GlanceModifier.height(8.dp))
            Text(balance, style = TextStyle(color = ColorProvider(Gold), fontSize = 26.sp, fontWeight = FontWeight.Bold))
            Text("Balance", style = TextStyle(color = ColorProvider(TextMuted), fontSize = 9.sp))

            Spacer(modifier = GlanceModifier.height(10.dp))

            if (slipCount > 0) {
                Text(
                    if (slipCount == 1) "1 pick • odds $slipOdds" else "$slipCount picks • odds $slipOdds",
                    style = TextStyle(color = ColorProvider(TextMuted), fontSize = 10.sp),
                )
                Text(
                    "Potential win $slipWin",
                    style = TextStyle(color = ColorProvider(OddsDown), fontSize = 13.sp, fontWeight = FontWeight.Bold),
                )
            } else {
                Text("No active picks", style = TextStyle(color = ColorProvider(TextMuted), fontSize = 10.sp))
            }
        }
    }

    @Composable
    private fun ClassicMatchContent(data: LiveMatchData) {
        Column(modifier = GlanceModifier.fillMaxSize()) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(modifier = GlanceModifier.background(LiveGreen).padding(horizontal = 7.dp, vertical = 2.dp)) {
                    Text(
                        "LIVE",
                        style = TextStyle(color = ColorProvider(TextWhite), fontSize = 10.sp, fontWeight = FontWeight.Bold),
                    )
                }
                Spacer(modifier = GlanceModifier.width(8.dp))
                Text(data.minute, style = TextStyle(color = ColorProvider(TextMuted), fontSize = 11.sp))
            }

            Spacer(modifier = GlanceModifier.height(10.dp))

            Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Text(
                    data.homeTeam,
                    maxLines = 1,
                    style = TextStyle(color = ColorProvider(TextWhite), fontSize = 12.sp, fontWeight = FontWeight.Bold),
                    modifier = GlanceModifier.defaultWeight(),
                )
                Text(
                    "${data.homeScore}–${data.awayScore}",
                    style = TextStyle(color = ColorProvider(Gold), fontSize = 20.sp, fontWeight = FontWeight.Bold),
                    modifier = GlanceModifier.padding(horizontal = 8.dp),
                )
                Text(
                    data.awayTeam,
                    maxLines = 1,
                    style = TextStyle(color = ColorProvider(TextWhite), fontSize = 12.sp, fontWeight = FontWeight.Bold),
                    modifier = GlanceModifier.defaultWeight(),
                )
            }

            Spacer(modifier = GlanceModifier.height(10.dp))

            Row(modifier = GlanceModifier.fillMaxWidth()) {
                for (odd in data.odds) {
                    Box(
                        modifier =
                            GlanceModifier.defaultWeight()
                                .padding(horizontal = 2.dp)
                                .background(PillBg)
                                .padding(vertical = 6.dp),
                        contentAlignment = Alignment.Center,
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(odd.label, style = TextStyle(color = ColorProvider(TextMuted), fontSize = 9.sp))
                            Text(
                                "${odd.value}${trendArrow(odd.trend)}",
                                style =
                                    TextStyle(
                                        color = ColorProvider(trendColor(odd.trend)),
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Bold,
                                    ),
                            )
                        }
                    }
                }
            }

            Spacer(modifier = GlanceModifier.height(8.dp))
            Text(data.league, maxLines = 1, style = TextStyle(color = ColorProvider(TextMuted), fontSize = 10.sp))
        }
    }

    @Composable
    private fun MinimalMatchContent(data: LiveMatchData) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(modifier = GlanceModifier.background(LiveGreen).padding(horizontal = 6.dp, vertical = 2.dp)) {
                    Text(
                        "LIVE",
                        style = TextStyle(color = ColorProvider(TextWhite), fontSize = 9.sp, fontWeight = FontWeight.Bold),
                    )
                }
                Spacer(modifier = GlanceModifier.width(6.dp))
                Text(data.minute, style = TextStyle(color = ColorProvider(TextMuted), fontSize = 10.sp))
            }

            Spacer(modifier = GlanceModifier.height(10.dp))

            Text(
                "${data.homeScore}–${data.awayScore}",
                style = TextStyle(color = ColorProvider(Gold), fontSize = 32.sp, fontWeight = FontWeight.Bold),
            )

            Spacer(modifier = GlanceModifier.height(6.dp))

            Text(
                "${data.homeTeam} vs ${data.awayTeam}",
                maxLines = 2,
                style =
                    TextStyle(
                        color = ColorProvider(TextWhite),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center,
                    ),
            )
        }
    }

    @Composable
    private fun OddsFocusMatchContent(data: LiveMatchData) {
        Column(modifier = GlanceModifier.fillMaxSize()) {
            Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "${data.homeTeam} ${data.homeScore}–${data.awayScore} ${data.awayTeam}",
                    maxLines = 1,
                    style = TextStyle(color = ColorProvider(TextWhite), fontSize = 10.sp, fontWeight = FontWeight.Bold),
                    modifier = GlanceModifier.defaultWeight(),
                )
                Text(data.minute, style = TextStyle(color = ColorProvider(TextMuted), fontSize = 9.sp))
            }

            Spacer(modifier = GlanceModifier.height(10.dp))

            Row(modifier = GlanceModifier.fillMaxWidth().defaultWeight()) {
                for (odd in data.odds) {
                    Box(
                        modifier = GlanceModifier.defaultWeight().padding(horizontal = 3.dp).background(PillBg),
                        contentAlignment = Alignment.Center,
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(odd.label, style = TextStyle(color = ColorProvider(TextMuted), fontSize = 10.sp))
                            Text(
                                "${odd.value}${trendArrow(odd.trend)}",
                                style =
                                    TextStyle(
                                        color = ColorProvider(trendColor(odd.trend)),
                                        fontSize = 16.sp,
                                        fontWeight = FontWeight.Bold,
                                    ),
                            )
                        }
                    }
                }
            }

            Spacer(modifier = GlanceModifier.height(6.dp))
            Text(data.league, maxLines = 1, style = TextStyle(color = ColorProvider(TextMuted), fontSize = 9.sp))
        }
    }

    @Composable
    private fun ScoreboardMatchContent(data: LiveMatchData) {
        Column(
            modifier = GlanceModifier.fillMaxSize().background(Color(0xFF000000)),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Text(
                    data.league,
                    maxLines = 1,
                    style = TextStyle(color = ColorProvider(TextMuted), fontSize = 8.sp),
                    modifier = GlanceModifier.defaultWeight(),
                )
                Box(modifier = GlanceModifier.background(Gold).padding(horizontal = 6.dp, vertical = 2.dp)) {
                    Text(
                        data.minute,
                        style = TextStyle(color = ColorProvider(GoldInk), fontSize = 9.sp, fontWeight = FontWeight.Bold),
                    )
                }
            }

            Spacer(modifier = GlanceModifier.height(6.dp))
            Text(
                data.homeTeam,
                maxLines = 1,
                style = TextStyle(color = ColorProvider(TextWhite), fontSize = 11.sp, fontWeight = FontWeight.Bold),
            )
            Text(
                "${data.homeScore} : ${data.awayScore}",
                style = TextStyle(color = ColorProvider(Gold), fontSize = 30.sp, fontWeight = FontWeight.Bold),
            )
            Text(
                data.awayTeam,
                maxLines = 1,
                style = TextStyle(color = ColorProvider(TextWhite), fontSize = 11.sp, fontWeight = FontWeight.Bold),
            )
        }
    }
}
