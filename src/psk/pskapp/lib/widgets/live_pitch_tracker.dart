import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../models/sport_event.dart';

class LivePitchTracker extends StatefulWidget {
  final SportEvent event;

  const LivePitchTracker({super.key, required this.event});

  static void show(BuildContext context, SportEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LivePitchTracker(event: event),
    );
  }

  @override
  State<LivePitchTracker> createState() => _LivePitchTrackerState();
}

class _LivePitchTrackerState extends State<LivePitchTracker> {
  String _currentAction = 'Dangerous Attack - Dinamo';
  double _ballX = 0.72; // Normalized position on pitch (0.0 to 1.0)
  Timer? _actionTimer;

  final List<String> _actions = [
    'Attack - Dinamo',
    'Dangerous Attack - Dinamo',
    'Corner Kick',
    'Foul in Midfield',
    'Attack - Hajduk',
    'Goalkeeper Save!',
    'Goal Kick for Dinamo',
  ];

  @override
  void initState() {
    super.initState();
    _actionTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        final nextIdx = (timer.tick) % _actions.length;
        _currentAction = _actions[nextIdx];
        _ballX = 0.2 + (timer.tick % 6) * 0.12;
      });
    });
  }

  @override
  void dispose() {
    _actionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;

    return Container(
      height: 480,
      decoration: const BoxDecoration(
        color: PskColors.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: PskColors.bgDarkSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.stadium, color: PskColors.accentGold, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Live Pitch Tracker • ${e.liveMinute ?? "LIVE"}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Live Score Board
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            color: PskColors.surfaceDarkPanel,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    e.homeTeam,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: PskColors.bgDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: PskColors.accentGold, width: 1.5),
                  ),
                  child: Text(
                    '${e.homeScore ?? 0} : ${e.awayScore ?? 0}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PskColors.accentGold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    e.awayTeam,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),

          // 2D Football Pitch Visualizer
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E6B38), // Grass green
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white70, width: 2),
                ),
                child: Stack(
                  children: [
                    // Halfway line
                    Center(
                      child: Container(width: 2, color: Colors.white54),
                    ),
                    // Center circle
                    Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 2),
                        ),
                      ),
                    ),
                    // Penalty box Left
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 40,
                        height: 90,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white54, width: 2),
                            right: BorderSide(color: Colors.white54, width: 2),
                            bottom: BorderSide(color: Colors.white54, width: 2),
                          ),
                        ),
                      ),
                    ),
                    // Penalty box Right
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 40,
                        height: 90,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white54, width: 2),
                            left: BorderSide(color: Colors.white54, width: 2),
                            bottom: BorderSide(color: Colors.white54, width: 2),
                          ),
                        ),
                      ),
                    ),
                    // Live Action Banner Overlay
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _currentAction,
                          style: const TextStyle(
                            color: PskColors.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    // Moving Ball Indicator
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 600),
                      alignment: FractionalOffset(_ballX, 0.5),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black45, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.sports_soccer, size: 14, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Live Stats bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _buildStatColumn('Shots', '6', '3'),
                _buildStatColumn('Possession', '58%', '42%'),
                _buildStatColumn('Corners', '5', '2'),
                _buildStatColumn('Cards', '1', '2'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String home, String away) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: PskColors.textMuted, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(home, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Text(' - ', style: TextStyle(color: PskColors.textMuted, fontSize: 11)),
                Text(away, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
