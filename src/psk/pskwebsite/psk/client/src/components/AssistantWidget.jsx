import { useState, useRef, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useT } from '../i18n';
import { useApp } from '../context/AppContext';

const SESSION_KEY = 'psk.assistant.session';
const HISTORY_KEY = 'psk.assistant.history';

function sessionId() {
  try {
    let id = localStorage.getItem(SESSION_KEY);
    if (!id) {
      id = 'web_' + Math.random().toString(36).slice(2) + Date.now().toString(36);
      localStorage.setItem(SESSION_KEY, id);
    }
    return id;
  } catch {
    return 'web_anon';
  }
}

const loadHistory = () => {
  try { return JSON.parse(sessionStorage.getItem(HISTORY_KEY)) || []; } catch { return []; }
};
const saveHistory = (h) => {
  try { sessionStorage.setItem(HISTORY_KEY, JSON.stringify(h.slice(-20))); } catch {}
};

/**
 * Floating assistant. Present on every page via App.jsx.
 *
 * Navigation is driven by the `route` the server attaches to each action — the
 * widget never builds a URL itself, so a wrong answer can't produce a dead link.
 */
export default function AssistantWidget() {
  const { t } = useT();
  const { toast } = useApp();
  const navigate = useNavigate();

  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [input, setInput] = useState('');
  const [messages, setMessages] = useState(loadHistory);
  const [unread, setUnread] = useState(false);

  const bodyRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => { saveHistory(messages); }, [messages]);

  useEffect(() => {
    if (bodyRef.current) bodyRef.current.scrollTop = bodyRef.current.scrollHeight;
  }, [messages, busy, open]);

  useEffect(() => {
    if (open) {
      setUnread(false);
      setTimeout(() => inputRef.current?.focus(), 120);
    }
  }, [open]);

  useEffect(() => {
    const onKey = (e) => {
      if (e.key === 'Escape' && open) setOpen(false);
    };
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [open]);

  const send = useCallback(async (text) => {
    const message = String(text ?? input).trim();
    if (!message || busy) return;

    setInput('');
    setMessages((m) => [...m, { role: 'user', content: message }]);
    setBusy(true);

    try {
      const res = await fetch('/api/assistant/query', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message, session_id: sessionId() }),
      });

      if (!res.ok) throw new Error(String(res.status));
      const data = await res.json();

      setMessages((m) => [...m, {
        role: 'assistant',
        content: data.answer,
        actions: data.actions || [],
        clarification: data.clarification || null,
        sources: data.sources || [],
        intent: data.intent,
        refusal: data.refusal_reason || null,
      }]);

      // The server decides when a jump is safe. It omits `navigate` whenever the
      // match is uncertain or the destination needs confirmation.
      if (data.navigate) {
        setTimeout(() => {
          navigate(data.navigate);
          setOpen(false);
        }, 550);
      }
      if (!open) setUnread(true);
    } catch {
      setMessages((m) => [...m, {
        role: 'assistant',
        content: t('assistant.error'),
        actions: [],
        error: true,
      }]);
    } finally {
      setBusy(false);
    }
  }, [input, busy, navigate, open, t]);

  const runAction = (action) => {
    if (!action?.route) return;
    if (action.requires_confirmation) {
      // a financial destination: let the server's confirm loop handle it
      send(t('assistant.yes'));
      return;
    }
    navigate(action.route);
    setOpen(false);
  };

  const suggestions = [
    t('assistant.s1'), t('assistant.s2'), t('assistant.s3'), t('assistant.s4'),
  ];

  return (
    <>
      {/* launcher */}
      <button
        className={'as-fab' + (open ? ' is-open' : '')}
        onClick={() => setOpen((o) => !o)}
        aria-label={t('assistant.title')}
        aria-expanded={open}
      >
        {open ? '✕' : (
          <>
            <svg viewBox="0 0 24 24" width="24" height="24" aria-hidden="true">
              <path fill="currentColor" d="M12 2a9 9 0 0 0-9 9c0 1.7.5 3.3 1.3 4.6L3 22l6.6-1.7A9 9 0 1 0 12 2Z" opacity=".18" />
              <path fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"
                    d="M12 3.2a8.8 8.8 0 0 0-7.7 13.1L3.4 21l4.8-1.2A8.8 8.8 0 1 0 12 3.2Z" />
              <circle cx="8.6" cy="12" r="1.15" fill="currentColor" />
              <circle cx="12" cy="12" r="1.15" fill="currentColor" />
              <circle cx="15.4" cy="12" r="1.15" fill="currentColor" />
            </svg>
            {unread && <span className="as-dot" />}
          </>
        )}
      </button>

      {/* panel */}
      {open && (
        <div className="as-panel" role="dialog" aria-label={t('assistant.title')}>
          <header className="as-head">
            <span className="as-avatar" aria-hidden="true">✦</span>
            <div>
              <div className="as-title">{t('assistant.title')}</div>
              <div className="as-sub">{t('assistant.subtitle')}</div>
            </div>
            <button className="as-x" onClick={() => setOpen(false)} aria-label={t('common.close')}>×</button>
          </header>

          <div className="as-body" ref={bodyRef}>
            {messages.length === 0 && (
              <div className="as-welcome">
                <div className="as-welcome-icon">✦</div>
                <p>{t('assistant.welcome')}</p>
                <div className="as-chips">
                  {suggestions.map((s) => (
                    <button key={s} className="as-chip" onClick={() => send(s)}>{s}</button>
                  ))}
                </div>
              </div>
            )}

            {messages.map((m, i) => (
              <div key={i} className={'as-msg as-' + m.role + (m.error ? ' as-err' : '')}>
                <div className="as-bubble">{m.content}</div>

                {m.clarification?.options?.length > 0 && (
                  <div className="as-options">
                    {m.clarification.options.map((o) => (
                      <button key={o.entity_id} className="as-option" onClick={() => send(o.label)}>
                        {o.label}
                      </button>
                    ))}
                  </div>
                )}

                {m.actions?.length > 0 && (
                  <div className="as-actions">
                    {m.actions.map((a) => (
                      <button
                        key={a.entity_id + a.action}
                        className={'as-action' + (a.requires_confirmation ? ' is-confirm' : '')}
                        onClick={() => runAction(a)}
                        title={a.route}
                      >
                        {a.label}
                        {a.requires_auth && <span className="as-lock" aria-hidden="true">🔒</span>}
                      </button>
                    ))}
                  </div>
                )}

                {m.sources?.length > 0 && (
                  <details className="as-sources">
                    <summary>{t('assistant.sources', { n: m.sources.length })}</summary>
                    <ul>
                      {m.sources.map((s) => (
                        <li key={s.chunk_id}>
                          {s.title || s.chunk_id}
                          {s.requires_verified_source && (
                            <span className="as-flag"> · {t('assistant.policyFlag')}</span>
                          )}
                        </li>
                      ))}
                    </ul>
                  </details>
                )}
              </div>
            ))}

            {busy && (
              <div className="as-msg as-assistant">
                <div className="as-bubble as-typing"><span /><span /><span /></div>
              </div>
            )}
          </div>

          <form
            className="as-input"
            onSubmit={(e) => { e.preventDefault(); send(); }}
          >
            <input
              ref={inputRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder={t('assistant.placeholder')}
              maxLength={500}
              aria-label={t('assistant.placeholder')}
            />
            <button type="submit" disabled={busy || !input.trim()} aria-label={t('assistant.send')}>
              ➤
            </button>
          </form>

          <div className="as-foot">{t('assistant.disclaimer')}</div>
        </div>
      )}
    </>
  );
}
