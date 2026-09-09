import { createContext, useContext, useState, useEffect, useCallback, useRef } from 'react';
import api, { getToken, setToken } from '../api/client';
import { useT } from '../i18n';

const AppContext = createContext(null);
export const useApp = () => useContext(AppContext);

const read = (key, fallback) => {
  try {
    const v = localStorage.getItem(`psk.${key}`);
    return v === null ? fallback : JSON.parse(v);
  } catch { return fallback; }
};
const write = (key, val) => {
  try { localStorage.setItem(`psk.${key}`, JSON.stringify(val)); } catch {}
};

export function AppProvider({ children }) {
  const { t } = useT();
  /* ---------------- theme ---------------- */
  const [theme, setThemeState] = useState(() => read('theme', 'dark'));
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    write('theme', theme);
  }, [theme]);
  const toggleTheme = () => setThemeState(t => (t === 'dark' ? 'light' : 'dark'));

  /* ---------------- toasts ---------------- */
  const [toasts, setToasts] = useState([]);
  const toastId = useRef(0);
  const toast = useCallback((message, kind = 'ok') => {
    const id = ++toastId.current;
    setToasts(list => [...list, { id, message, kind }]);
    setTimeout(() => setToasts(list => list.filter(t => t.id !== id)), 3200);
  }, []);

  /* ---------------- modal ---------------- */
  const [modal, setModal] = useState(null); // { title, content, wide }
  const closeModal = useCallback(() => setModal(null), []);

  /* ---------------- auth ---------------- */
  const [user, setUser] = useState(null);
  const [authReady, setAuthReady] = useState(false);

  useEffect(() => {
    if (!getToken()) { setAuthReady(true); return; }
    api.auth.me()
      .then(({ user }) => setUser(user))
      .catch(() => setToken(null))
      .finally(() => setAuthReady(true));
  }, []);

  const login = useCallback(async (username, password) => {
    const { token, user } = await api.auth.login({ username, password });
    setToken(token);
    setUser(user);
    toast(t('auth.loggedInAs', { name: user.username }));
    return user;
  }, [toast, t]);

  const register = useCallback(async (payload) => {
    const { token, user } = await api.auth.register(payload);
    setToken(token);
    setUser(user);
    toast(t('auth.registered'));
    return user;
  }, [toast, t]);

  const logout = useCallback(() => {
    setToken(null);
    setUser(null);
    toast(t('auth.loggedOut'), 'info');
  }, [toast, t]);

  /** Keep the balance in sync after any wallet-changing call. */
  const setBalance = useCallback((balance) => {
    setUser(u => (u ? { ...u, balance } : u));
  }, []);

  const refreshUser = useCallback(async () => {
    if (!getToken()) return;
    try {
      const { user } = await api.auth.me();
      setUser(user);
    } catch { /* leave state as-is */ }
  }, []);

  /* ---------------- bet slip ---------------- */
  const [slip, setSlip] = useState(() => read('slip', []));
  const [stake, setStakeState] = useState(() => read('stake', 5));

  useEffect(() => write('slip', slip), [slip]);
  useEffect(() => write('stake', stake), [stake]);

  const hasPick = useCallback(
    (eventId, marketKey) => slip.some(p => p.eventId === eventId && p.marketKey === marketKey),
    [slip]
  );

  const togglePick = useCallback((event, marketKey, odds) => {
    setSlip(list => {
      const same = list.findIndex(p => p.eventId === event.id && p.marketKey === marketKey);
      if (same > -1) return list.filter((_, i) => i !== same);
      // a slip holds at most one selection per event
      const rest = list.filter(p => p.eventId !== event.id);
      return [...rest, {
        eventId: event.id,
        marketKey,
        odds: odds ?? event.markets?.[marketKey],
        eventName: event.name,
        leagueName: event.leagueName,
        code: event.code
      }];
    });
  }, []);

  const removePick = useCallback((i) => setSlip(list => list.filter((_, j) => j !== i)), []);
  const clearSlip  = useCallback(() => setSlip([]), []);
  const setStake   = useCallback((v) => setStakeState(Math.max(0.5, Number(v) || 0.5)), []);

  const totalOdds = slip.reduce((a, p) => a * (p.odds || 1), 1);

  const placeTicket = useCallback(async () => {
    if (!user) throw new Error(t('slip.loginBody'));
    if (!slip.length) throw new Error(t('slip.empty'));
    const res = await api.tickets.place({
      stake,
      selections: slip.map(p => ({ eventId: p.eventId, marketKey: p.marketKey }))
    });
    setBalance(res.balance);
    clearSlip();
    return res.ticket;
  }, [user, slip, stake, setBalance, clearSlip, t]);

  /* ---------------- mobile drawer ---------------- */
  const [drawerOpen, setDrawerOpen] = useState(false);

  const value = {
    theme, toggleTheme,
    toasts, toast,
    modal, setModal, closeModal,
    user, authReady, login, register, logout, setBalance, refreshUser,
    slip, stake, setStake, hasPick, togglePick, removePick, clearSlip, totalOdds, placeTicket,
    drawerOpen, setDrawerOpen
  };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export default AppContext;
