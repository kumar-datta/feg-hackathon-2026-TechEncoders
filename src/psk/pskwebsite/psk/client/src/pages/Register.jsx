import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';

export default function Register() {
  const { register, user } = useApp();
  const { t } = useT();
  const navigate = useNavigate();

  const [form, setForm] = useState({ username: '', email: '', password: '', confirm: '', age: false, terms: false });
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);

  if (user) {
    return (
      <div className="page narrow">
        <h1 className="page-title">{t('auth.accountExists')}</h1>
        <p className="page-lede">{t('auth.alreadyInBody', { name: user.username })}</p>
        <Link className="btn btn-accent" to="/racun" style={{ marginTop: 16 }}>{t('account.title')}</Link>
      </div>
    );
  }

  const submit = async (e) => {
    e.preventDefault();
    setError(null);

    if (form.password.length < 8) return setError(t('auth.errShort'));
    if (form.password !== form.confirm) return setError(t('auth.errMatch'));
    if (!form.age) return setError(t('auth.errAge'));
    if (!form.terms) return setError(t('auth.errTerms'));

    setBusy(true);
    try {
      await register({
        username: form.username.trim(),
        email: form.email.trim(),
        password: form.password
      });
      navigate('/racun');
    } catch (err) {
      setError(err.message);
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="page narrow" style={{ maxWidth: 520 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('header.register')}</div>
      <h1 className="page-title">{t('auth.registerTitle')}</h1>
      <p className="page-lede">{t('auth.registerLede')}</p>

      <div className="note warn">{t('auth.registerWarn')}</div>

      <form className="form-grid" onSubmit={submit} style={{ marginTop: 20 }}>
        <div className="field">
          <label htmlFor="u">{t('auth.username')}</label>
          <input
            id="u" type="text" required minLength={3} maxLength={24} autoComplete="username"
            value={form.username}
            onChange={(e) => setForm(f => ({ ...f, username: e.target.value }))}
          />
          <div className="hint">{t('auth.usernameHint')}</div>
        </div>

        <div className="field">
          <label htmlFor="e">{t('auth.email')}</label>
          <input
            id="e" type="email" required autoComplete="email"
            value={form.email}
            onChange={(e) => setForm(f => ({ ...f, email: e.target.value }))}
          />
          <div className="hint">{t('auth.emailHint')}</div>
        </div>

        <div className="field">
          <label htmlFor="p">{t('auth.password')}</label>
          <input
            id="p" type="password" required minLength={8} autoComplete="new-password"
            value={form.password}
            onChange={(e) => setForm(f => ({ ...f, password: e.target.value }))}
          />
          <div className="hint">{t('auth.passwordHint')}</div>
        </div>

        <div className="field">
          <label htmlFor="p2">{t('auth.confirmPassword')}</label>
          <input
            id="p2" type="password" required autoComplete="new-password"
            value={form.confirm}
            onChange={(e) => setForm(f => ({ ...f, confirm: e.target.value }))}
          />
        </div>

        <label style={{ display: 'flex', gap: 10, alignItems: 'flex-start', fontSize: 13, color: 'var(--txt-dim)' }}>
          <input
            type="checkbox"
            style={{ width: 'auto', height: 'auto', marginTop: 3 }}
            checked={form.age}
            onChange={(e) => setForm(f => ({ ...f, age: e.target.checked }))}
          />
          <span>{t('auth.ageConfirm')}</span>
        </label>

        <label style={{ display: 'flex', gap: 10, alignItems: 'flex-start', fontSize: 13, color: 'var(--txt-dim)' }}>
          <input
            type="checkbox"
            style={{ width: 'auto', height: 'auto', marginTop: 3 }}
            checked={form.terms}
            onChange={(e) => setForm(f => ({ ...f, terms: e.target.checked }))}
          />
          <span>
            {t('auth.termsPre')} <Link to="/pravila-igre" style={{ color: 'var(--accent)' }}>{t('auth.termsLink')}</Link>{' '}
            {t('auth.termsPost')}
          </span>
        </label>

        {error && <div className="note warn">{error}</div>}

        <button className="btn btn-accent btn-lg btn-block" disabled={busy}>
          {busy ? t('auth.creating') : t('auth.createAccount')}
        </button>
      </form>

      <p style={{ marginTop: 18, fontSize: 13, color: 'var(--txt-mute)' }}>
        {t('auth.haveAccount')} <Link to="/prijava" style={{ color: 'var(--accent)' }}>{t('auth.signIn')}</Link>.
      </p>
    </div>
  );
}
