import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psk/models/demo_user.dart';
import 'package:psk/state/app_state.dart';
import 'package:psk/widgets/auth_dialog.dart';
import 'package:psk/widgets/psk_drawer.dart';

void main() {
  group('DemoUserProfile & AppState Auth Tests', () {
    test('Demo profiles list has 4 distinct rich profiles', () {
      final profiles = DemoUserProfile.demoProfiles;
      expect(profiles.length, 4);

      final vip = profiles.firstWhere((p) => p.username == 'Marko_VIP');
      expect(vip.startingBalance, 5000.00);
      expect(vip.badge, 'VIP Gold Tier');
      expect(vip.avatar, '👑');

      final sports = profiles.firstWhere((p) => p.username == 'Luka_HNL_Pro');
      expect(sports.startingBalance, 350.00);
      expect(sports.badge, 'Sportsbook Master');
      expect(sports.avatar, '⚽');

      final casino = profiles.firstWhere((p) => p.username == 'Ana_SpinQueen');
      expect(casino.startingBalance, 1500.00);
      expect(casino.badge, 'Casino VIP');
      expect(casino.avatar, '🎰');

      final casual = profiles.firstWhere((p) => p.username == 'Casual_Matej');
      expect(casual.startingBalance, 75.00);
      expect(casual.badge, 'Casual Player');
      expect(casual.avatar, '🎯');
    });

    test('AppState loginAsDemo updates user credentials and wallet', () {
      final state = AppState();

      expect(state.isLoggedIn, isFalse);
      expect(state.username, 'Guest');

      final vip = DemoUserProfile.demoProfiles.first;
      state.loginAsDemo(vip);

      expect(state.isLoggedIn, isTrue);
      expect(state.username, 'Marko_VIP');
      expect(state.userBadge, 'VIP Gold Tier');
      expect(state.userAvatar, '👑');
      expect(state.balance, 5000.00);

      // Logout resets
      state.logout();
      expect(state.isLoggedIn, isFalse);
      expect(state.username, 'Guest');
      expect(state.userBadge, 'Guest');
      expect(state.userAvatar, '👤');

      state.dispose();
    });

    test('AppState login with matching demo username resolves profile', () {
      final state = AppState();

      state.login('luka_hnl_pro', 'any_pass'); // case-insensitive match
      expect(state.isLoggedIn, isTrue);
      expect(state.username, 'Luka_HNL_Pro');
      expect(state.userBadge, 'Sportsbook Master');
      expect(state.balance, 350.00);

      state.dispose();
    });

    test('AppState login with custom username creates club member', () {
      final state = AppState();

      state.login('CustomBettor', 'secret');
      expect(state.isLoggedIn, isTrue);
      expect(state.username, 'CustomBettor');
      expect(state.userBadge, 'Club Member');
      expect(state.balance, 125.50);

      state.dispose();
    });
  });

  group('Bright & Dark Mode Tests', () {
    test('AppState setThemeMode and toggleTheme operate properly', () {
      final state = AppState();

      expect(state.isDarkMode, isTrue);

      // Switch to Bright Mode
      state.setThemeMode(false);
      expect(state.isDarkMode, isFalse);

      // Switch back to Dark Mode
      state.setThemeMode(true);
      expect(state.isDarkMode, isTrue);

      // Toggle
      state.toggleTheme();
      expect(state.isDarkMode, isFalse);

      state.toggleTheme();
      expect(state.isDarkMode, isTrue);

      state.dispose();
    });

    testWidgets('PskDrawer contains Bright and Dark Mode options and demo profiles', (tester) async {
      final state = AppState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: PskDrawer(state: state),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open Drawer'),
              ),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();

      // Bright Mode and Dark Mode buttons exist
      expect(find.text('Bright Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);

      // Tap Bright Mode
      await tester.tap(find.text('Bright Mode'));
      await tester.pumpAndSettle();
      expect(state.isDarkMode, isFalse);

      // Tap Dark Mode
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();
      expect(state.isDarkMode, isTrue);

      // Tap Marko_VIP
      await tester.ensureVisible(find.text('Marko_VIP'));
      await tester.tap(find.text('Marko_VIP'));
      await tester.pumpAndSettle();

      expect(state.isLoggedIn, isTrue);
      expect(state.username, 'Marko_VIP');
      expect(state.balance, 5000.00);

      state.dispose();
    });

    testWidgets('AuthDialog renders demo profiles and logs in on tap', (tester) async {
      final state = AppState();

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => AuthDialog.show(context, state),
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify Demo section header
      expect(find.text('OR 1-TAP DEMO LOGIN'), findsOneWidget);

      // Scroll to Marko_VIP and tap
      await tester.ensureVisible(find.text('Marko_VIP'));
      await tester.tap(find.text('Marko_VIP'));
      await tester.pumpAndSettle();

      // Verify state changed
      expect(state.isLoggedIn, isTrue);
      expect(state.username, 'Marko_VIP');
      expect(state.userBadge, 'VIP Gold Tier');
      expect(state.balance, 5000.00);

      state.dispose();
    });

    testWidgets('PskDrawer renders _loggedOutCluster when logged out and _loggedInCluster when logged in', (tester) async {
      final state = AppState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: PskDrawer(state: state),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open Menu'),
              ),
            ),
          ),
        ),
      );

      // Open drawer as logged-out guest
      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      // Verify Log in & Register buttons from _loggedOutCluster exist in menu
      expect(find.text('Guest User'), findsOneWidget);
      expect(find.text('Log in'), findsWidgets);
      expect(find.text('Register'), findsOneWidget);

      // Close drawer
      Navigator.pop(tester.element(find.byType(PskDrawer)));
      await tester.pumpAndSettle();

      // Log in as demo user
      final profile = DemoUserProfile.demoProfiles.first;
      state.loginAsDemo(profile);

      // Open drawer as logged-in user
      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      // Verify wallet & DEPOSIT button from _loggedInCluster exist in menu
      expect(find.text('DEPOSIT'), findsOneWidget);
      expect(find.text('${profile.startingBalance.toStringAsFixed(2)} €'), findsOneWidget);

      state.dispose();
    });
  });
}
