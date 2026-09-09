import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';
import '../models/demo_user.dart';

class AuthDialog extends StatefulWidget {
  final AppState state;
  final bool isRegister;

  const AuthDialog({
    super.key,
    required this.state,
    required this.isRegister,
  });

  static void show(BuildContext context, AppState state, {bool isRegister = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AuthDialog(state: state, isRegister: isRegister),
    );
  }

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late bool _isRegister;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isRegister = widget.isRegister;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Dialog(
      backgroundColor: isDark ? PskColors.surfaceDark : PskColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isRegister ? 'PSK Registration' : 'Log in to PSK',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _isRegister
                  ? 'Claim a 100% welcome bonus on your first deposit!'
                  : 'Log in and play like a champion with the best odds.',
                style: const TextStyle(color: PskColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              if (_isRegister) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    filled: true,
                    fillColor: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final name = _usernameController.text.trim();
                  widget.state.login(name.isNotEmpty ? name : 'Player_PSK', _passwordController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isRegister ? 'Welcome to PSK! 100€ bonus activated.' : 'Successfully logged in!'),
                      backgroundColor: PskColors.liveGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRegister ? PskColors.accentGold : PskColors.brandBlue,
                  foregroundColor: _isRegister ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _isRegister ? 'REGISTER' : 'LOG IN',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegister = !_isRegister;
                    });
                  },
                  child: Text(
                    _isRegister ? 'Already have an account? Log in' : 'Don\'t have an account? Register here',
                    style: const TextStyle(color: PskColors.brandBlueLight),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR 1-TAP DEMO LOGIN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: isDark ? PskColors.textMuted : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12)),
                ],
              ),
              const SizedBox(height: 10),
              ...DemoUserProfile.demoProfiles.map((profile) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? PskColors.surfaceDarkPanel : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? PskColors.borderDark : Colors.grey.shade300,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      widget.state.loginAsDemo(profile);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Logged in as ${profile.fullName} • ${profile.recentGames.length} games & ${profile.recentTickets.length} bets ready',
                          ),
                          backgroundColor: PskColors.liveGreen,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark ? PskColors.surfaceDarkAction : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: PskColors.accentGold.withValues(alpha: 0.5)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              profile.avatar,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      profile.username,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: PskColors.accentGold.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        profile.tag,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: PskColors.accentGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? PskColors.textMuted : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${profile.startingBalance.toStringAsFixed(0)} €',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: PskColors.moneyGreen,
                                ),
                              ),
                              Text(
                                '1-Tap Play',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? PskColors.brandBlueLight : PskColors.brandBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
