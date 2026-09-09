/**
 * Thin fetch wrapper around the Express API.
 * Attaches the JWT, unwraps JSON and turns non-2xx into thrown errors
 * so callers can rely on try/catch.
 */

const BASE = import.meta.env.VITE_API_URL || '/api';
const TOKEN_KEY = 'psk.token';
const LANG_KEY = 'psk.lang';

/** Read the chosen language without importing React state. */
function currentLang() {
  try {
    const raw = localStorage.getItem(LANG_KEY);
    const val = raw ? JSON.parse(raw) : 'hr';
    return val === 'en' ? 'en' : 'hr';
  } catch { return 'hr'; }
}

/* Transport-level messages, kept here because this module runs outside React. */
const NET_ERROR = {
  hr: 'Poslužitelj nije dostupan. Provjeri je li API pokrenut.',
  en: 'The server is unreachable. Check that the API is running.'
};
const HTTP_ERROR = {
  hr: (s) => `Greška ${s}`,
  en: (s) => `Error ${s}`
};

export const getToken = () => {
  try { return localStorage.getItem(TOKEN_KEY); } catch { return null; }
};
export const setToken = (t) => {
  try { t ? localStorage.setItem(TOKEN_KEY, t) : localStorage.removeItem(TOKEN_KEY); } catch {}
};

async function request(path, { method = 'GET', body, auth = true } = {}) {
  const lang = currentLang();
  const headers = { 'Accept-Language': lang };
  if (body !== undefined) headers['Content-Type'] = 'application/json';

  const token = auth ? getToken() : null;
  if (token) headers.Authorization = `Bearer ${token}`;

  let res;
  try {
    res = await fetch(`${BASE}${path}`, {
      method,
      headers,
      body: body === undefined ? undefined : JSON.stringify(body)
    });
  } catch {
    throw new Error(NET_ERROR[lang]);
  }

  let data = null;
  const text = await res.text();
  if (text) {
    try { data = JSON.parse(text); } catch { data = { raw: text }; }
  }

  if (!res.ok) {
    const err = new Error(data?.error || HTTP_ERROR[lang](res.status));
    err.status = res.status;
    err.details = data?.details;
    throw err;
  }
  return data;
}

const qs = (params = {}) => {
  const s = new URLSearchParams(
    Object.entries(params).filter(([, v]) => v !== undefined && v !== null && v !== '')
  ).toString();
  return s ? `?${s}` : '';
};

export const api = {
  health: () => request('/health', { auth: false }),

  auth: {
    register: (payload) => request('/auth/register', { method: 'POST', body: payload, auth: false }),
    login:    (payload) => request('/auth/login',    { method: 'POST', body: payload, auth: false }),
    me:       () => request('/auth/me'),
    deposit:  (amount) => request('/auth/deposit', { method: 'POST', body: { amount } }),
    limits:   (payload) => request('/auth/limits', { method: 'PUT', body: payload }),
    toggleFavourite: (gameId) => request(`/auth/favourites/${gameId}`, { method: 'POST' })
  },

  offer: {
    meta:   () => request('/offer/meta', { auth: false }),
    sports: () => request('/offer/sports', { auth: false }),
    events: (params) => request(`/offer/events${qs(params)}`, { auth: false }),
    event:  (id) => request(`/offer/events/${id}`, { auth: false })
  },

  casino: {
    categories: () => request('/casino/categories', { auth: false }),
    providers:  () => request('/casino/providers', { auth: false }),
    lobby:      () => request('/casino/lobby', { auth: false }),
    games:      (params) => request(`/casino/games${qs(params)}`, { auth: false }),
    game:       (slug) => request(`/casino/games/${slug}`, { auth: false }),
    round:      (payload) => request('/casino/round', { method: 'POST', body: payload }),
    rounds:     () => request('/casino/rounds')
  },

  tickets: {
    place:  (payload) => request('/tickets', { method: 'POST', body: payload }),
    mine:   (params) => request(`/tickets${qs(params)}`),
    shared: () => request('/tickets/shared', { auth: false }),
    one:    (ref) => request(`/tickets/${ref}`),
    share:  (ref) => request(`/tickets/${ref}/share`, { method: 'POST' }),
    settle: (ref) => request(`/tickets/${ref}/settle`, { method: 'POST' })
  },

  content: {
    promos:    (params) => request(`/content/promos${qs(params)}`, { auth: false }),
    promo:     (slug) => request(`/content/promos/${slug}`, { auth: false }),
    news:      (params) => request(`/content/news${qs(params)}`, { auth: false }),
    article:   (slug) => request(`/content/news/${slug}`, { auth: false }),
    shops:     (params) => request(`/content/shops${qs(params)}`, { auth: false }),
    lotteries: () => request('/content/lotteries', { auth: false }),
    virtuals:  () => request('/content/virtuals', { auth: false }),
    threads:   (params) => request(`/content/threads${qs(params)}`, { auth: false }),
    thread:    (slug) => request(`/content/threads/${slug}`, { auth: false }),
    results:   () => request('/content/results', { auth: false }),
    stats:     () => request('/content/stats', { auth: false }),
    payments:  () => request('/content/payments', { auth: false }),
    search:    (q) => request(`/content/search${qs({ q })}`, { auth: false })
  }
};

export default api;
