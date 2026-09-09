import { useT } from '../i18n';

export function Loader({ label }) {
  const { t } = useT();
  return (
    <div className="slip-empty" style={{ padding: '60px 20px' }}>
      <span className="big">⏳</span>
      {label || t('common.loading')}
    </div>
  );
}

export function ErrorBox({ error, onRetry }) {
  const { t } = useT();
  return (
    <div className="note warn">
      <strong>{t('common.error')}:</strong> {error?.message || String(error)}
      {onRetry && (
        <div style={{ marginTop: 10 }}>
          <button className="btn btn-ghost" onClick={onRetry}>{t('common.retry')}</button>
        </div>
      )}
    </div>
  );
}

export function Empty({ children }) {
  const { t } = useT();
  return <div className="slip-empty" style={{ padding: '60px 20px' }}>{children || t('common.noData')}</div>;
}

export default Loader;
