/**
 * Server-side message catalogue.
 *
 * The client sends `Accept-Language: hr|en`; attachLocale() reads it and
 * puts a `req.t(key, vars)` helper on the request so route handlers can
 * return messages in the caller's language.
 */

const MESSAGES = {
  hr: {
    /* auth */
    'auth.missingFields':   'Korisničko ime, e-mail i lozinka su obavezni.',
    'auth.usernameShort':   'Korisničko ime mora imati barem 3 znaka.',
    'auth.passwordShort':   'Lozinka mora imati barem 8 znakova.',
    'auth.taken':           'Korisničko ime ili e-mail već postoji.',
    'auth.missingCreds':    'Unesi korisničko ime i lozinku.',
    'auth.badCreds':        'Neispravni podaci za prijavu.',
    'auth.noToken':         'Nedostaje token. Prijavi se.',
    'auth.noUser':          'Korisnik ne postoji.',
    'auth.badToken':        'Token nije valjan ili je istekao.',
    'auth.selfExcluded':    'Račun je privremeno samoisključen.',
    'auth.badAmount':       'Iznos mora biti između 0 i 1000 demo kredita.',

    /* offer */
    'offer.eventNotFound':  'Događaj nije pronađen.',

    /* casino */
    'casino.badStake':      'Ulog nije valjan.',
    'casino.gameNotFound':  'Igra nije pronađena.',
    'casino.stakeRange':    'Ulog mora biti između {min} i {max}.',
    'casino.insufficient':  'Nedovoljno sredstava na demo računu.',
    'casino.winTooLarge':   'Dobitak izvan dopuštenog raspona.',

    /* tickets */
    'ticket.empty':         'Listić je prazan.',
    'ticket.tooMany':       'Najviše 30 parova po listiću.',
    'ticket.minStake':      'Minimalna uplata je 0,50.',
    'ticket.insufficient':  'Nedovoljno sredstava na demo računu.',
    'ticket.duplicateEvent':'Dva para na istom događaju nisu dopuštena.',
    'ticket.eventGone':     'Događaj više nije u ponudi.',
    'ticket.eventClosed':   'Događaj {name} je zatvoren.',
    'ticket.marketGone':    'Tržište {market} nije dostupno.',
    'ticket.notFound':      'Listić nije pronađen.',
    'ticket.alreadySettled':'Listić je već obračunat.',

    /* generic */
    'error.validation':     'Podaci nisu valjani.',
    'error.badId':          'Neispravan identifikator.',
    'error.duplicate':      'Zapis s tom vrijednošću već postoji.',
    'error.internal':       'Interna greška poslužitelja.',
    'error.notFound':       'Ruta {method} {url} ne postoji.',
    'error.rateLimit':      'Previše zahtjeva. Pokušaj ponovno za koji trenutak.',
    'health.note':          'Demonstracijski projekt. Nema stvarnog novca ni klađenja.'
  },

  en: {
    /* auth */
    'auth.missingFields':   'Username, email and password are all required.',
    'auth.usernameShort':   'The username must be at least 3 characters.',
    'auth.passwordShort':   'The password must be at least 8 characters.',
    'auth.taken':           'That username or email is already taken.',
    'auth.missingCreds':    'Enter your username and password.',
    'auth.badCreds':        'Incorrect login details.',
    'auth.noToken':         'No token supplied. Please log in.',
    'auth.noUser':          'That user does not exist.',
    'auth.badToken':        'The token is invalid or has expired.',
    'auth.selfExcluded':    'This account is temporarily self-excluded.',
    'auth.badAmount':       'The amount must be between 0 and 1000 demo credits.',

    /* offer */
    'offer.eventNotFound':  'Event not found.',

    /* casino */
    'casino.badStake':      'That stake is not valid.',
    'casino.gameNotFound':  'Game not found.',
    'casino.stakeRange':    'The stake must be between {min} and {max}.',
    'casino.insufficient':  'Not enough funds in your demo account.',
    'casino.winTooLarge':   'That win is outside the permitted range.',

    /* tickets */
    'ticket.empty':         'Your slip is empty.',
    'ticket.tooMany':       'A slip may hold at most 30 selections.',
    'ticket.minStake':      'The minimum stake is 0.50.',
    'ticket.insufficient':  'Not enough funds in your demo account.',
    'ticket.duplicateEvent':'Two selections on the same event are not allowed.',
    'ticket.eventGone':     'That event is no longer in the offer.',
    'ticket.eventClosed':   'Event {name} is closed.',
    'ticket.marketGone':    'Market {market} is not available.',
    'ticket.notFound':      'Ticket not found.',
    'ticket.alreadySettled':'This ticket has already been settled.',

    /* generic */
    'error.validation':     'The submitted data is not valid.',
    'error.badId':          'Invalid identifier.',
    'error.duplicate':      'A record with that value already exists.',
    'error.internal':       'Internal server error.',
    'error.notFound':       'Route {method} {url} does not exist.',
    'error.rateLimit':      'Too many requests. Try again in a moment.',
    'health.note':          'Demonstration project. No real money and no real betting.'
  }
};

const DEFAULT_LANG = 'hr';

/** Pick a supported language from an Accept-Language header. */
export function pickLang(header) {
  if (!header) return DEFAULT_LANG;
  const first = String(header).split(',')[0].trim().slice(0, 2).toLowerCase();
  return MESSAGES[first] ? first : DEFAULT_LANG;
}

/** Translate a key, interpolating {placeholders}. */
export function translate(lang, key, vars) {
  const dict = MESSAGES[lang] || MESSAGES[DEFAULT_LANG];
  let str = dict[key] ?? MESSAGES[DEFAULT_LANG][key] ?? key;
  if (vars) {
    str = str.replace(/\{(\w+)\}/g, (m, k) => (vars[k] !== undefined ? String(vars[k]) : m));
  }
  return str;
}

/** Express middleware: attaches req.lang and req.t. */
export function attachLocale(req, _res, next) {
  req.lang = pickLang(req.headers['accept-language']);
  req.t = (key, vars) => translate(req.lang, key, vars);
  next();
}

export default MESSAGES;
