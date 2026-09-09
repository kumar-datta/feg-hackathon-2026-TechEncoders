import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';

export default function Login() {
  const { login, user } = useApp();
  const { t } = useT();
  const navigate = useNavigate();

  const [form, setForm] = useState({ username: '', password: '' });
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);

  if (user) {
    return (
      <div className="page narrow">
        <h1 className="page-title">{t('auth.alreadyIn')}</h1>
        <p className="page-lede">{t('auth.alreadyInBody', { name: user.username })}</p>
        <div style={{ display: 'flex', gap: 10, marginTop: 20 }}>
          <Link className="btn btn-accent" to="/racun">{t('account.title')}</Link>
          <Link className="btn btn-ghost" to="/oklade">{t('sportsbook.offer')}</Link>
        </div>
      </div>
    );
  }

  const submit = async (e) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await login(form.username.trim(), form.password);
      navigate('/');
    } catch (err) {
      setError(err.message);
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="page narrow" style={{ maxWidth: 460 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('auth.loginTitle')}</div>
      <h1 className="page-title">{t('auth.loginTitle')}</h1>
      <p className="page-lede">{t('auth.loginLede')}</p>

      <div className="note">{t('auth.demoNote', { u: 'demo', p: 'demo1234' })}</div>

      <form className="form-grid" onSubmit={submit} style={{ marginTop: 20 }}>
        <div className="field">
          <label htmlFor="u">{t('auth.usernameOrEmail')}</label>
          <input
            id="u" type="text" autoComplete="username" required
            value={form.username}
            onChange={(e) => setForm(f => ({ ...f, username: e.target.value }))}
          />
        </div>

        <div className="field">
          <label htmlFor="p">{t('auth.password')}</label>
          <input
            id="p" type="password" autoComplete="current-password" required
            value={form.password}
            onChange={(e) => setForm(f => ({ ...f, password: e.target.value }))}
          />
        </div>

        {error && <div className="note warn">{error}</div>}

        <button className="btn btn-accent btn-lg btn-block" disabled={busy}>
          {busy ? t('auth.signingIn') : t('auth.signIn')}
        </button>
      </form>

      <p style={{ marginTop: 18, fontSize: 13, color: 'var(--txt-mute)' }}>
        {t('auth.noAccount')} <Link to="/registracija" style={{ color: 'var(--accent)' }}>{t('auth.openDemo')}</Link>.
      </p>

      <div className="note" style={{ marginTop: 24 }}>{t('auth.securityNote')}</div>
    </div>
  );
}
