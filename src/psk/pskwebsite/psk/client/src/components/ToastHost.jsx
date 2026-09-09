import { useApp } from '../context/AppContext';

export default function ToastHost() {
  const { toasts } = useApp();
  if (!toasts.length) return null;

  return (
    <div className="toast-wrap">
      {toasts.map(t => (
        <div key={t.id} className={`toast${t.kind === 'ok' ? '' : ' ' + t.kind}`} role="status">
          {t.message}
        </div>
      ))}
    </div>
  );
}
