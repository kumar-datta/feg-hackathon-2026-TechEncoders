// PSK Pulse — Favorit Plus Boost widget (2x2). Renders the SportEvent
// snapshot the Flutter app writes via WidgetBridgeService.pushBoostMatch.
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
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.actionStartActivity

private val TileBg = Color(0xFF18181E)
private val TextWhite = Color(0xFFFFFFFF)
private val TextMuted = Color(0xFFB0B0C0)
private val Gold = Color(0xFFFFDB01)

class BoostWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent { Content(context, currentState()) }
    }

    @Composable
    private fun Content(context: Context, currentState: HomeWidgetGlanceState) {
        val prefs = currentState.preferences
        val eventId = prefs.getString("boost_event_id", "") ?: ""
        val uri = Uri.parse(if (eventId.isEmpty()) "psk://boost" else "psk://boost/$eventId")

        Box(
            modifier =
                GlanceModifier.fillMaxSize()
                    .background(TileBg)
                    .padding(14.dp)
                    .clickable(actionStartActivity<MainActivity>(context, uri))
        ) {
            GuardrailGate(prefs, "boost_widget_enabled") {
                val hasMatch = if (prefs.contains("boost_has_match")) prefs.getBoolean("boost_has_match", true) else true
                if (!hasMatch) {
                    Box(modifier = GlanceModifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text(
                            "No boosted price right now",
                            style = TextStyle(color = ColorProvider(TextMuted), fontSize = 12.sp),
                        )
                    }
                } else {
                    BoostContent(prefs)
                }
            }
        }
    }

    @Composable
    private fun BoostContent(prefs: SharedPreferences) {
        val league = prefs.getString("boost_league", "Supercopa")?.let { if (it.isEmpty()) "Supercopa" else it } ?: "Supercopa"
        val homeTeam = prefs.getString("boost_home_team", "Real Madrid")?.let { if (it.isEmpty()) "Real Madrid" else it } ?: "Real Madrid"
        val awayTeam = prefs.getString("boost_away_team", "Barcelona")?.let { if (it.isEmpty()) "Barcelona" else it } ?: "Barcelona"
        val startTime = prefs.getString("boost_start_time", "Tonight 20:45")?.let { if (it.isEmpty()) "Tonight 20:45" else it } ?: "Tonight 20:45"
        val original = prefs.getString("boost_original_odds", "2.10")?.let { if (it.isEmpty()) "2.10" else it } ?: "2.10"
        val boosted = prefs.getString("boost_boosted_odds", "2.40")?.let { if (it.isEmpty()) "2.40" else it } ?: "2.40"

        Column(modifier = GlanceModifier.fillMaxSize()) {
            Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Box(modifier = GlanceModifier.background(Gold).padding(horizontal = 7.dp, vertical = 2.dp)) {
                    Text(
                        "FAVORIT PLUS",
                        style = TextStyle(color = ColorProvider(Color(0xFF3A2F00)), fontSize = 9.sp, fontWeight = FontWeight.Bold),
                    )
                }
                Spacer(modifier = GlanceModifier.defaultWeight())
                Text(startTime, maxLines = 1, style = TextStyle(color = ColorProvider(TextMuted), fontSize = 10.sp))
            }

            Spacer(modifier = GlanceModifier.height(10.dp))

            Text(
                "$homeTeam vs $awayTeam",
                maxLines = 2,
                style = TextStyle(color = ColorProvider(TextWhite), fontSize = 13.sp, fontWeight = FontWeight.Bold),
            )

            Spacer(modifier = GlanceModifier.height(8.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    original,
                    style = TextStyle(color = ColorProvider(TextMuted), fontSize = 14.sp),
                )
                Text(
                    " → ",
                    style = TextStyle(color = ColorProvider(TextMuted), fontSize = 14.sp),
                )
                Text(
                    boosted,
                    style = TextStyle(color = ColorProvider(Gold), fontSize = 22.sp, fontWeight = FontWeight.Bold),
                )
            }

            Spacer(modifier = GlanceModifier.defaultWeight())
            Text(league, maxLines = 1, style = TextStyle(color = ColorProvider(TextMuted), fontSize = 10.sp))
        }
    }
}
