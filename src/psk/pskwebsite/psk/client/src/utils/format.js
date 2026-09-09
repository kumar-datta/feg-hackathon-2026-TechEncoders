/**
 * Shared display formatting helpers.
 *
 * The active locale is module-level state set by the i18n provider, so call
 * sites can keep importing plain functions. Components re-render on a
 * language change (they consume the i18n context), which repaints these.
 */

let locale = 'hr-HR';

let eurFmt = new Intl.NumberFormat(locale, { style: 'currency', currency: 'EUR' });
let numFmt = new Intl.NumberFormat(locale, { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/** Called by <I18nProvider> whenever the language changes. */
export function setLocale(next) {
  locale = next || 'hr-HR';
  eurFmt = new Intl.NumberFormat(locale, { style: 'currency', currency: 'EUR' });
  numFmt = new Intl.NumberFormat(locale, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export const getLocale = () => locale;

export const eur = (n) => eurFmt.format(Number(n) || 0);
export const num = (n) => numFmt.format(Number(n) || 0);

export const time = (iso) => {
  const d = new Date(iso);
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
};

export const day = (iso) =>
  new Date(iso).toLocaleDateString(locale, { day: '2-digit', month: '2-digit' });

export const dateTime = (iso) =>
  new Date(iso).toLocaleString(locale, {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  });

export const dateOnly = (iso) => new Date(iso).toLocaleDateString(locale);

/** CSS gradient used for the generated game thumbnails. */
export const thumbGradient = (hueA, hueB) =>
  `linear-gradient(150deg, hsl(${hueA} 72% 46%), hsl(${hueB} 68% 22%))`;
