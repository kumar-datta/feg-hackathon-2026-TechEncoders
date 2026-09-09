import { useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';

export default function ModalHost() {
  const { modal, closeModal } = useApp();
  const { t } = useT();

  useEffect(() => {
    if (!modal) return;
    const onKey = (e) => { if (e.key === 'Escape') closeModal(); };
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [modal, closeModal]);

  if (!modal) return null;

  return (
    <div
      className="modal-back is-open"
      role="dialog"
      aria-modal="true"
      aria-label={typeof modal.title === 'string' ? modal.title : t('common.details')}
      onMouseDown={(e) => { if (e.target === e.currentTarget) closeModal(); }}
    >
      <div className={'modal' + (modal.wide ? ' wide' : '')}>
        <div className="modal-hd">
          <span>{modal.title}</span>
          <button className="x" onClick={closeModal} aria-label={t('common.close')}>×</button>
        </div>
        <div className="modal-bd">{modal.content}</div>
        {modal.footer && <div className="modal-ft">{modal.footer}</div>}
      </div>
    </div>
  );
}
