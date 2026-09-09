import 'package:flutter_test/flutter_test.dart';
import 'package:psk/assistant/assistant_controller.dart';
import 'package:psk/main.dart';
import 'package:psk/state/app_state.dart';

void main() {
  testWidgets('PSK App smoke test - shows splash screen and navigates to main view', (WidgetTester tester) async {
    final state = AppState();
    final assistant = AssistantController(state);
    await tester.pumpWidget(PskApp(state: state, assistant: assistant));

    // Verify Splash Screen elements initially appear
    expect(find.text('SPORTS & CASINO'), findsOneWidget);
    expect(find.text('Prva Sportska Kladionica'), findsOneWidget);

    // Fast-forward animation & timer (2400ms + 600ms transition)
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(milliseconds: 700));

    // Verify main screen navigation after splash completes: the home tab is
    // the landing screen and the tab strip is on screen.
    expect(find.text('Home'), findsAtLeastNWidgets(1));
    expect(find.text('Sports'), findsAtLeastNWidgets(1));
    expect(find.text('Quick Access'), findsOneWidget);

    state.dispose();
  });
}
