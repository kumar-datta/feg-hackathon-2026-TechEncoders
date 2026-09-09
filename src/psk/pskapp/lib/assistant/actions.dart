import 'assistant_models.dart';
import 'resolver.dart';

/// Turns an entity_id into a typed, executable action.
///
/// SAFETY INVARIANT: this is the ONLY place a route is produced, and it does so
/// exclusively by looking up the entity registry. Nothing here accepts a route
/// string from a model or from user input.
class ActionBuilder {
  static const Map<String, String> _actionForType = {
    'GAME': 'OPEN_GAME',
    'CATEGORY': 'OPEN_CATEGORY',
    'SPORT': 'OPEN_SPORT',
    'PAGE': 'OPEN_PAGE',
  };

  static const Map<String, String> _actionForIntent = {
    'DEPOSIT': 'OPEN_DEPOSIT',
    'WITHDRAW': 'OPEN_WITHDRAW',
    'BET_HISTORY': 'OPEN_BET_HISTORY',
    'KYC': 'OPEN_KYC',
    'PROMOTION': 'OPEN_PROMOTIONS',
    'SUPPORT': 'OPEN_SUPPORT',
    'RESPONSIBLE_GAMING': 'OPEN_RESPONSIBLE_GAMING',
  };

  static const Map<String, String> _labelVerb = {
    'OPEN_GAME': 'Play',
    'OPEN_CATEGORY': 'Browse',
    'OPEN_SPORT': 'Open',
    'OPEN_DEPOSIT': 'Go to',
    'OPEN_WITHDRAW': 'Go to',
    'OPEN_BET_HISTORY': 'View',
    'OPEN_KYC': 'Open',
    'OPEN_PROMOTIONS': 'View',
    'OPEN_SUPPORT': 'Contact',
    'OPEN_RESPONSIBLE_GAMING': 'Open',
    'OPEN_PAGE': 'Open',
  };

  /// Financial destinations always confirm, whatever the confidence.
  static const Set<String> confirmActions = {'OPEN_DEPOSIT', 'OPEN_WITHDRAW'};

  final EntityResolver resolver;
  ActionBuilder(this.resolver);

  AssistantAction? build(String entityId, {String? intent, String? label}) {
    final e = resolver.getEntity(entityId);
    if (e == null) return null;
    final action = (intent != null ? _actionForIntent[intent] : null) ?? _actionForType[e.type] ?? 'OPEN_PAGE';
    final verb = _labelVerb[action] ?? 'Open';
    return AssistantAction(
      action: action,
      label: label ?? '$verb ${e.name}',
      entityId: e.id,
      entityType: e.type,
      route: e.route,
      requiresAuth: e.requiresAuth,
      requiresConfirmation: confirmActions.contains(action),
      active: e.active,
    );
  }

  List<AssistantAction> buildAll(Iterable<String> ids, {String? intent}) =>
      ids.map((id) => build(id, intent: intent)).whereType<AssistantAction>().toList();

  /// Contextual follow-up actions worth surfacing under an answer.
  List<AssistantAction> supporting(String intent, String? primaryId) {
    final ids = <String>[];
    switch (intent) {
      case 'RESPONSIBLE_GAMING':
        ids.addAll(['page_responsible_gaming', 'page_contact']);
      case 'WITHDRAW':
        ids.addAll(['page_account', 'page_contact']);
      case 'DEPOSIT':
      case 'GAME_INFO':
        ids.add('page_responsible_gaming');
      case 'ACCOUNT_DATA':
        ids.addAll(['page_account', 'page_tickets']);
      case 'FAQ':
      case 'SUPPORT':
        ids.addAll(['page_help', 'page_contact']);
    }
    return buildAll(ids.where((id) => id != primaryId));
  }
}

class GateResult {
  final bool allowed;
  final String? gate; // login | unavailable
  const GateResult(this.allowed, [this.gate]);
}

GateResult checkGates(AssistantAction? action, {required bool authenticated}) {
  if (action == null) return const GateResult(false, 'unknown');
  if (!action.active) return const GateResult(false, 'unavailable');
  if (action.requiresAuth && !authenticated) return const GateResult(false, 'login');
  return const GateResult(true);
}
