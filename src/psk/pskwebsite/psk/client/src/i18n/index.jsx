/* ============================================================
   i18n — lightweight translation layer.

   Usage:
     const { t, lang, setLang } = useT();
     t('common.play')                     -> "Igraj" / "Play"
     t('slip.pairs', { n: 3 })            -> interpolation
     t('rules.sections')                  -> arrays/objects come back as-is
   ============================================================ */
import { createContext, useContext, useState, useEffect, useCallback, useMemo } from 'react';
import { setLocale } from '../utils/format';
import hr from './hr';
import en from './en';

const DICTS = { hr, en };

export const LANGUAGES = [
  { code: 'hr', label: 'Hrvatski', flag: '🇭🇷' },
  { code: 'en', label: 'English',  flag: '🇬🇧' }
];

const STORAGE_KEY = 'psk.lang';
const DEFAULT_LANG = 'hr';

function readStored() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return DEFAULT_LANG;
    const val = JSON.parse(raw);
    return DICTS[val] ? val : DEFAULT_LANG;
  } catch {
    return DEFAULT_LANG;
  }
}

/** Walk a dotted path through a nested object. */
function resolve(dict, path) {
  return path.split('.').reduce((acc, part) => (acc == null ? undefined : acc[part]), dict);
}

/** Replace {name} placeholders. */
function interpolate(str, vars) {
  if (!vars) return str;
  return str.replace(/\{(\w+)\}/g, (m, key) => (vars[key] !== undefined ? String(vars[key]) : m));
}

const I18nContext = createContext(null);

export function I18nProvider({ children }) {
  const [lang, setLangState] = useState(readStored);

  useEffect(() => {
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify(lang)); } catch {}
    document.documentElement.setAttribute('lang', lang);
    setLocale(lang === 'en' ? 'en-GB' : 'hr-HR');
  }, [lang]);

  const setLang = useCallback((code) => {
    if (DICTS[code]) setLangState(code);
  }, []);

  const t = useCallback((path, vars) => {
    const dict = DICTS[lang] || DICTS[DEFAULT_LANG];
    let value = resolve(dict, path);

    // fall back to the default language, then to the key itself
    if (value === undefined && lang !== DEFAULT_LANG) value = resolve(DICTS[DEFAULT_LANG], path);
    if (value === undefined) {
      if (import.meta.env.DEV) console.warn('[i18n] missing key:', path);
      return path;
    }

    return typeof value === 'string' ? interpolate(value, vars) : value;
  }, [lang]);

  /** Locale tag for Intl formatting. */
  const locale = lang === 'en' ? 'en-GB' : 'hr-HR';

  const value = useMemo(() => ({ lang, setLang, t, locale }), [lang, setLang, t, locale]);

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useT() {
  const ctx = useContext(I18nContext);
  if (!ctx) throw new Error('useT must be used inside <I18nProvider>');
  return ctx;
}

export default I18nContext;
