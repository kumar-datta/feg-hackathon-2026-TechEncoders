// Shared guardrail gate for every PSK Pulse widget. Self-exclusion always
// wins — no odds, scores or picks are ever composed for that state, only
// this neutral message — followed by the widget's own opt-in flag, which
// starts false until the user turns it on in PSK Pulse Widgets settings.
package com.example.psk

import android.content.SharedPreferences
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider

private val GuardMuted = Color(0xFFB0B0C0)
private val GuardRed = Color(0xFFC52D16)

@Composable
fun GuardrailGate(prefs: SharedPreferences, enabledKey: String, content: @Composable () -> Unit) {
    val selfExcluded = prefs.getBoolean("psk_self_excluded", false)
    val enabled = if (prefs.contains(enabledKey)) prefs.getBoolean(enabledKey, true) else true

    when {
        selfExcluded -> GuardrailMessage("PSK is closed for your account", GuardRed)
        !enabled -> GuardrailMessage("Widget off — enable in PSK Pulse settings", GuardMuted)
        else -> content()
    }
}

@Composable
private fun GuardrailMessage(message: String, color: Color) {
    Box(modifier = GlanceModifier.fillMaxSize().padding(12.dp), contentAlignment = Alignment.Center) {
        Text(
            message,
            style =
                TextStyle(
                    color = ColorProvider(color),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                ),
        )
    }
}
