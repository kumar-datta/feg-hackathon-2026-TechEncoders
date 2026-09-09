/**
 * actions.js — turns an entity_id into a typed, executable action.
 *
 * SAFETY INVARIANT: this module is the ONLY place a route is produced, and it
 * produces routes exclusively by looking up the entity registry. There is no
 * function here that accepts a URL string from a model or from user input.
 * That is what makes an invented link structurally impossible rather than
 * merely discouraged by a prompt.
 */
import { getEntity } from './resolver.js';
import config from './config.js';

/** intent + entity type -> action name */
const ACTION_FOR_TYPE = {
  GAME: 'OPEN_GAME',
  CATEGORY: 'OPEN_CATEGORY',
  SPORT: 'OPEN_SPORT',
  PAGE: 'OPEN_PAGE',
  ACCOUNT: 'OPEN_PAGE',
  POLICY: 'OPEN_PAGE',
  SUPPORT: 'OPEN_PAGE',
};

const ACTION_FOR_INTENT = {
  DEPOSIT: 'OPEN_DEPOSIT',
  WITHDRAW: 'OPEN_WITHDRAW',
  BET_HISTORY: 'OPEN_BET_HISTORY',
  KYC: 'OPEN_KYC',
  PROMOTION: 'OPEN_PROMOTIONS',
  SUPPORT: 'OPEN_SUPPORT',
  RESPONSIBLE_GAMING: 'OPEN_RESPONSIBLE_GAMING',
};

const LABEL_VERB = {
  OPEN_GAME: 'Play',
  OPEN_CATEGORY: 'Browse',
  OPEN_SPORT: 'Open',
  OPEN_DEPOSIT: 'Go to',
  OPEN_WITHDRAW: 'Go to',
  OPEN_BET_HISTORY: 'View',
  OPEN_KYC: 'Open',
  OPEN_PROMOTIONS: 'View',
  OPEN_SUPPORT: 'Contact',
  OPEN_RESPONSIBLE_GAMING: 'Open',
  OPEN_PAGE: 'Open',
};

/**
 * Build an action from an entity_id. Returns null if the id is unknown —
 * an unknown id must never produce a guessed route.
 */
export function buildAction(entityId, { intent = null, label = null } = {}) {
  const e = getEntity(entityId);
  if (!e) return null;

  const action = ACTION_FOR_INTENT[intent] || ACTION_FOR_TYPE[e.type] || 'OPEN_PAGE';
  const verb = LABEL_VERB[action] || 'Open';

  return {
    action,
    label: label || `${verb} ${e.name}`,
    entity_id: e.id,
    entity_type: e.type,
    route: e.route,                       // from the registry, never generated
    requires_auth: Boolean(e.requires_auth),
    requires_kyc: Boolean(e.requires_kyc),
    requires_confirmation: config.confirmActions.has(action),
    status: e.status,
  };
}

/** Several actions at once, skipping any unknown ids. */
export function buildActions(entityIds, opts = {}) {
  return entityIds.map((id) => buildAction(id, opts)).filter(Boolean);
}

/**
 * Decide whether an action may execute now.
 * Returns { allowed, reason, gate } — the caller turns a gate into a prompt.
 */
export function checkGates(action, user = {}) {
  if (!action) return { allowed: false, reason: 'unknown_entity' };

  if (action.status && action.status !== 'active') {
    return { allowed: false, reason: 'entity_inactive', gate: 'unavailable' };
  }
  if (action.requires_auth && !user.authenticated) {
    return { allowed: false, reason: 'requires_login', gate: 'login' };
  }
  if (action.requires_kyc && user.kyc_status !== 'verified') {
    return { allowed: false, reason: 'requires_kyc', gate: 'kyc' };
  }
  return { allowed: true };
}

/** Contextual follow-up actions worth surfacing under an answer. */
export function supportingActions(intent, primaryId) {
  const ids = [];
  if (intent === 'RESPONSIBLE_GAMING') {
    ids.push('page_responsible_gaming', 'page_contact');
  } else if (intent === 'WITHDRAW') {
    // this build has no withdrawal or KYC flow, so point at account + support
    ids.push('page_account', 'page_contact');
  } else if (intent === 'DEPOSIT') {
    ids.push('page_responsible_gaming');
  } else if (intent === 'GAME_INFO') {
    ids.push('page_responsible_gaming');
  } else if (intent === 'ACCOUNT_DATA') {
    ids.push('page_account', 'page_tickets');
  } else if (intent === 'FAQ' || intent === 'SUPPORT') {
    ids.push('page_help', 'page_contact');
  }
  return buildActions(ids.filter((id) => id !== primaryId));
}

export default { buildAction, buildActions, checkGates, supportingActions };
