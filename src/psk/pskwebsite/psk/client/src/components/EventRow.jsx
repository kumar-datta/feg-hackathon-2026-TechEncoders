import { useApp } from '../context/AppContext';
import { useT } from '../i18n';
import { num, time, day } from '../utils/format';

/**
 * One row of the offer grid: kickoff/clock, teams, odds buttons and
 * a "+N" button that opens the full market board.
 */
export default function EventRow({ event, columns, onOpenMarkets }) {
  const { hasPick, togglePick } = useApp();
  const { t } = useT();

  return (
    <div className="evt" style={{ '--cols': columns.length }}>
      <div className="evt-main">
        <div className="evt-time">
          {event.live ? (
            <>
              <span className="evt-live-min">{event.minute}'</span>
              <span className="d">{t('sportsbook.liveShort')}</span>
            </>
          ) : (
            <>
              {time(event.startsAt)}
              <span className="d">{day(event.startsAt)}</span>
            </>
          )}
        </div>

        <div className="evt-teams">
          <div className="evt-team">{event.name}</div>
          <div className="evt-meta">
            <span>{event.flag} {event.leagueName}</span>
            <span>#{event.code}</span>
            {event.live && event.score && (
              <span style={{ color: 'var(--live)', fontWeight: 700 }}>{event.score}</span>
            )}
          </div>
        </div>
      </div>

      {columns.map(key => {
        const odds = event.markets?.[key];
        if (odds == null) {
          return <button key={key} className="odd is-empty" disabled>–</button>;
        }
        return (
          <button
            key={key}
            className={'odd' + (hasPick(event.id, key) ? ' is-picked' : '')}
            onClick={() => togglePick(event, key, odds)}
            title={`${event.name} — ${key}`}
          >
            {num(odds)}
          </button>
        );
      })}

      <button className="evt-more" onClick={() => onOpenMarkets(event)} title={t('sportsbook.allMarkets')}>
        +{event.marketCount}
      </button>
    </div>
  );
}
