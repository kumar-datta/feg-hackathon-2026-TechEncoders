// PSK Pulse — Bet Slip widget (2x2 square, resizable). Renders the BetSlipModel snapshot the
// Flutter app writes via WidgetBridgeService.pushBetSlip.
package com.example.psk

import android.content.Context
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
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.actionStartActivity

private val TileBg = Color(0xFF18181E)
private val TextWhite = Color(0xFFFFFFFF)
private val TextMuted = Color(0xFFB0B0C0)
private val Hairline = Color(0xFF2A2A35)
private val Profit = Color(0xFF35E94D)
private val Gold = Color(0xFFFFDB01)
private val PillBg = Color(0xFF2A2A38)

class BetSlipWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent { Content(context, currentState()) }
    }

    @Composable
    private fun Content(context: Context, currentState: HomeWidgetGlanceState) {
        val prefs = currentState.preferences
        val hasKey = prefs.contains("slip_count")
        val count = if (hasKey) prefs.getInt("slip_count", 0) else 2

        Box(
            modifier =
                GlanceModifier.fillMaxSize()
                    .background(TileBg)
                    .padding(10.dp)
                    .clickable(actionStartActivity<MainActivity>(context, Uri.parse("psk://betslip")))
        ) {
            GuardrailGate(prefs, "slip_widget_enabled") {
                if (hasKey && count == 0) {
                    EmptySlipContent()
                } else {
                    SlipContent(prefs, count)
                }
            }
        }
    }

    @Composable
    private fun EmptySlipContent() {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Box(
                modifier = GlanceModifier.background(PillBg).padding(horizontal = 8.dp, vertical = 3.dp),
            ) {
                Text(
                    "BET SLIP",
                    style = TextStyle(color = ColorProvider(Gold), fontSize = 10.sp, fontWeight = FontWeight.Bold),
                )
            }
            Spacer(modifier = GlanceModifier.height(6.dp))
            Text(
                "No active picks",
                style = TextStyle(color = ColorProvider(TextWhite), fontSize = 12.sp, fontWeight = FontWeight.Bold),
            )
            Spacer(modifier = GlanceModifier.height(4.dp))
            Text(
                "Tap to build your slip",
                style = TextStyle(color = ColorProvider(TextMuted), fontSize = 10.sp, textAlign = TextAlign.Center),
            )
        }
    }

    @Composable
    private fun SlipContent(prefs: android.content.SharedPreferences, count: Int) {
        val stake = prefs.getString("slip_stake", "€10.00")?.let { if (it.isEmpty()) "€10.00" else it } ?: "€10.00"
        val totalOdds = prefs.getString("slip_total_odds", "3.65")?.let { if (it.isEmpty()) "3.65" else it } ?: "3.65"
        val potentialWin = prefs.getString("slip_potential_win", "€36.50")?.let { if (it.isEmpty()) "€36.50" else it } ?: "€36.50"
        val moreCount = prefs.getInt("slip_more_count", 0)

        Column(modifier = GlanceModifier.fillMaxSize()) {
            Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "Bet Slip",
                    style = TextStyle(color = ColorProvider(TextWhite), fontSize = 12.sp, fontWeight = FontWeight.Bold),
                    modifier = GlanceModifier.defaultWeight(),
                )
                Box(modifier = GlanceModifier.background(PillBg).padding(horizontal = 6.dp, vertical = 2.dp)) {
                    Text(
                        if (count == 1) "1 pick" else "$count picks",
                        style = TextStyle(color = ColorProvider(Gold), fontSize = 10.sp, fontWeight = FontWeight.Bold),
                    )
                }
            }

            Spacer(modifier = GlanceModifier.height(6.dp))

            val row0Label = prefs.getString("slip_row_0_label", "Dinamo Zagreb — 1")?.let { if (it.isEmpty()) "Dinamo Zagreb — 1" else it } ?: "Dinamo Zagreb — 1"
            val row0Odd = prefs.getString("slip_row_0_odd", "1.35")?.let { if (it.isEmpty()) "1.35" else it } ?: "1.35"
            Row(modifier = GlanceModifier.fillMaxWidth().padding(vertical = 1.dp), verticalAlignment = Alignment.CenterVertically) {
                Text(
                    row0Label,
                    maxLines = 1,
                    style = TextStyle(color = ColorProvider(TextMuted), fontSize = 11.sp),
                    modifier = GlanceModifier.defaultWeight(),
                )
                Text(row0Odd, style = TextStyle(color = ColorProvider(TextWhite), fontSize = 11.sp, fontWeight = FontWeight.Bold))
            }

            if (count > 1) {
                val row1Label = prefs.getString("slip_row_1_label", "Real Madrid — 1")?.let { if (it.isEmpty()) "Real Madrid — 1" else it } ?: "Real Madrid — 1"
                val row1Odd = prefs.getString("slip_row_1_odd", "2.70")?.let { if (it.isEmpty()) "2.70" else it } ?: "2.70"
                Row(modifier = GlanceModifier.fillMaxWidth().padding(vertical = 1.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        row1Label,
                        maxLines = 1,
                        style = TextStyle(color = ColorProvider(TextMuted), fontSize = 11.sp),
                        modifier = GlanceModifier.defaultWeight(),
                    )
                    Text(row1Odd, style = TextStyle(color = ColorProvider(TextWhite), fontSize = 11.sp, fontWeight = FontWeight.Bold))
                }
            }

            if (moreCount > 0) {
                Text(
                    "+$moreCount more",
                    style = TextStyle(color = ColorProvider(TextMuted), fontSize = 9.sp),
                )
            }

            Spacer(modifier = GlanceModifier.defaultWeight())
            Box(modifier = GlanceModifier.fillMaxWidth().height(1.dp).background(Hairline)) {}
            Spacer(modifier = GlanceModifier.height(4.dp))

            Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Column(modifier = GlanceModifier.defaultWeight()) {
                    Text(
                        "stake $stake · $totalOdds",
                        style = TextStyle(color = ColorProvider(TextMuted), fontSize = 9.sp),
                    )
                }
                Text(
                    potentialWin,
                    style = TextStyle(color = ColorProvider(Profit), fontSize = 15.sp, fontWeight = FontWeight.Bold),
                )
            }
        }
    }
}

