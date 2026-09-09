import 'package:flutter/widgets.dart';

import 'assistant_controller.dart';

/// Makes the single [AssistantController] reachable from any route. Installed
/// above the Navigator via `MaterialApp.builder`, so pushed screens see it too.
class AssistantScope extends InheritedNotifier<AssistantController> {
  const AssistantScope({super.key, required AssistantController controller, required super.child})
      : super(notifier: controller);

  static AssistantController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AssistantScope>();
    assert(scope != null, 'AssistantScope is missing above this widget');
    return scope!.notifier!;
  }

  static AssistantController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AssistantScope>()?.notifier;
}
