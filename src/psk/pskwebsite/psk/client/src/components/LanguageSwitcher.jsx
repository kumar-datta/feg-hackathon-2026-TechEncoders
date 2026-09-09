import { useT, LANGUAGES } from '../i18n';

/**
 * Language selector. Rendered in the footer as a segmented control;
 * pass variant="select" for a compact dropdown.
 */
export default function LanguageSwitcher({ variant = 'buttons' }) {
  const { lang, setLang, t } = useT();

  if (variant === 'select') {
    return (
      <select
        className="lang-select"
        value={lang}
        onChange={(e) => setLang(e.target.value)}
        aria-label={t('footer.language')}
      >
        {LANGUAGES.map(l => (
          <option key={l.code} value={l.code}>{l.flag} {l.label}</option>
        ))}
      </select>
    );
  }

  return (
    <div className="lang-switch" role="group" aria-label={t('footer.language')}>
      {LANGUAGES.map(l => (
        <button
          key={l.code}
          className={'lang-opt' + (lang === l.code ? ' is-active' : '')}
          onClick={() => setLang(l.code)}
          aria-pressed={lang === l.code}
          lang={l.code}
        >
          <span className="lang-flag" aria-hidden="true">{l.flag}</span>
          <span>{l.label}</span>
        </button>
      ))}
    </div>
  );
}
