import 'package:flutter/material.dart';

import '../../assistant/assistant_controller.dart';
import '../../theme/psk_colors.dart';

/// The floating launcher for the PSK Assistant — a 56 px gradient circle with
/// a pulsing glow ring and an unread badge, sitting bottom-right above the
/// bottom navigation.
class AssistantFab extends StatefulWidget {
  final AssistantController controller;
  final VoidCallback onPressed;

  const AssistantFab({super.key, required this.controller, required this.onPressed});

  @override
  State<AssistantFab> createState() => _AssistantFabState();
}

class _AssistantFabState extends State<AssistantFab> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final unread = widget.controller.unread;
        return SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  final t = _pulse.value;
                  return Container(
                    width: 56 + 20 * t,
                    height: 56 + 20 * t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PskColors.brandBlueLight.withValues(alpha: 0.35 * (1 - t) + 0.05),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: widget.onPressed,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [PskColors.brandBlueHover, PskColors.brandBlue],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PskColors.brandBlue.withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
              if (unread > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: PskColors.alertRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$unread',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
