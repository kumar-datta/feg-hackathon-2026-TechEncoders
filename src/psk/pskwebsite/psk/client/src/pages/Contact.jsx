import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';

export default function Contact() {
  const { toast } = useApp();
  const { t } = useT();

  const topics = t('contact.topics');
  const [form, setForm] = useState({ name: '', email: '', topic: 0, message: '' });
  const [sent, setSent] = useState(false);

  const submit = (e) => {
    e.preventDefault();
    // no backend endpoint: this form intentionally transmits nothing
    setSent(true);
    toast(t('contact.toast'), 'info');
  };

  const tiles = [
    ['❓', 'faq', '/pomoc'],
    ['📍', 'shops', '/poslovnice'],
    ['ℹ️', 'about', '/o-nama']
  ];

  return (
    <div className="page narrow" style={{ maxWidth: 620 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('contact.title')}</div>
      <h1 className="page-title">✉️ {t('contact.title')}</h1>
      <p className="page-lede">{t('contact.lede')}</p>

      <div className="note warn">{t('contact.warn')}</div>

      {sent ? (
        <div className="panel panel-bd" style={{ marginTop: 20 }}>
          <h3 style={{ fontSize: 16 }}>{t('contact.sentTitle')}</h3>
          <p style={{ color: 'var(--txt-dim)', fontSize: 13.5 }}>{t('contact.sentBody')}</p>
          <button className="btn btn-ghost" onClick={() => setSent(false)}>{t('contact.newMessage')}</button>
        </div>
      ) : (
        <form className="form-grid" onSubmit={submit} style={{ marginTop: 20 }}>
          <div className="field">
            <label htmlFor="n">{t('contact.name')}</label>
            <input id="n" type="text" required value={form.name}
              onChange={(e) => setForm(f => ({ ...f, name: e.target.value }))} />
          </div>

          <div className="field">
            <label htmlFor="e">{t('contact.email')}</label>
            <input id="e" type="email" required value={form.email}
              onChange={(e) => setForm(f => ({ ...f, email: e.target.value }))} />
            <div className="hint">{t('contact.emailHint')}</div>
          </div>

          <div className="field">
            <label htmlFor="tp">{t('contact.topic')}</label>
            <select id="tp" value={form.topic}
              onChange={(e) => setForm(f => ({ ...f, topic: Number(e.target.value) }))}>
              {topics.map((label, i) => <option key={i} value={i}>{label}</option>)}
            </select>
          </div>

          <div className="field">
            <label htmlFor="m">{t('contact.message')}</label>
            <textarea id="m" rows={6} required value={form.message}
              onChange={(e) => setForm(f => ({ ...f, message: e.target.value }))} />
          </div>

          <button className="btn btn-accent btn-lg btn-block">{t('contact.submit')}</button>
        </form>
      )}

      <section className="sec">
        <div className="sec-hd"><h2>{t('contact.otherTitle')}</h2></div>
        <div className="quick-grid">
          {tiles.map(([icon, key, to]) => (
            <Link className="quick-card" to={to} key={key}>
              <div className="ico">{icon}</div>
              <div className="t">{t('contact.tiles.' + key)}</div>
              <div className="s">{t('contact.tiles.' + key + 'Sub')}</div>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
