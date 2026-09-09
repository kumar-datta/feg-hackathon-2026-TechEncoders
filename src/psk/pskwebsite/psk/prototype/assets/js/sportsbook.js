/* ============================================================
   sportsbook.js — renders the offer grid on oklade.html,
   plus results / statistics helpers.
   ============================================================ */
(function () {
  'use strict';

  const P = window.PSK, D = window.PSK_DATA;
  if (!P || !document.getElementById('offerHost')) return;

  const $ = P.$, $$ = P.$$, esc = P.esc, num = P.num;

  const state = {
    sport:  P.qs('sport')  || 'nogomet',
    league: P.qs('league') || null,
    filter: P.qs('filter') || 'all',      // all | live | today | soon
    search: (P.qs('q') || '').toLowerCase()
  };

  const sportOf = id => D.SPORTS.find(s => s.id === id) || D.SPORTS[0];

  function timeCell(ev) {
    if (ev.live) return `<div class="evt-time"><span class="evt-live-min">${ev.minute}'</span><span class="d">UŽIVO</span></div>`;
    const d = new Date(ev.start);
    const hh = String(d.getHours()).padStart(2, '0') + ':' + String(d.getMinutes()).padStart(2, '0');
    const dd = d.toLocaleDateString('hr-HR', { day: '2-digit', month: '2-digit' });
    return `<div class="evt-time">${hh}<span class="d">${dd}</span></div>`;
  }

  function oddCell(ev, mkt) {
    const o = ev.markets[mkt];
    if (o == null) return `<button class="odd is-empty" disabled>–</button>`;
    const on = P.slip.has(ev.id, mkt) ? ' is-picked' : '';
    return `<button class="odd${on}" data-ev="${ev.id}" data-mkt="${mkt}">${num(o)}</button>`;
  }

  function eventRow(ev, cols) {
    return `
      <div class="evt" style="--cols:${cols.length}">
        <div class="evt-main">
          ${timeCell(ev)}
          <div class="evt-teams">
            <div class="evt-team">${esc(ev.name)}</div>
            <div class="evt-meta">
              <span>${ev.flag} ${esc(ev.leagueName)}</span>
              <span>#${ev.code}</span>
              ${ev.live ? `<span style="color:var(--live);font-weight:700">${ev.score}</span>` : ''}
            </div>
          </div>
        </div>
        ${cols.map(c => oddCell(ev, c)).join('')}
        <button class="evt-more" data-more="${ev.id}" title="Sva tržišta">+${ev.marketCount}</button>
      </div>`;
  }

  function applyFilter(list) {
    const now = Date.now();
    return list.filter(ev => {
      if (state.filter === 'live'  && !ev.live) return false;
      if (state.filter === 'today') {
        const d = new Date(ev.start);
        if (d.toDateString() !== new Date().toDateString()) return false;
      }
      if (state.filter === 'soon' && (new Date(ev.start) - now > 3 * 3600e3 || ev.live)) return false;
      if (state.league && ev.leagueId !== state.league) return false;
      if (state.search && !ev.name.toLowerCase().includes(state.search)) return false;
      return true;
    });
  }

  function render() {
    const sport = sportOf(state.sport);
    const cols  = D.MARKET_SETS[sport.cols];

    let list = D.OFFER.filter(e => state.filter === 'live' ? true : e.sportId === state.sport);
    if (state.filter === 'live') list = D.OFFER.filter(e => e.live);
    list = applyFilter(list);

    // group by league
    const groups = {};
    list.forEach(e => { (groups[e.leagueId] = groups[e.leagueId] || []).push(e); });

    const filters = [
      ['all',   'Sve'],
      ['live',  'Uživo ' + D.LIVE_COUNT],
      ['today', 'Danas'],
      ['soon',  'Uskoro (3h)']
    ];

    const header = `
      <div class="offer-toolbar">
        <strong style="font-size:15px;margin-right:6px">${sport.icon} ${esc(sport.name)}</strong>
        ${filters.map(f => `
          <button class="chip${state.filter === f[0] ? ' is-active' : ''}${f[0] === 'live' ? ' is-live' : ''}"
                  data-filter="${f[0]}">${f[1]}</button>`).join('')}
        <span style="flex:1"></span>
        <span style="font-size:12px;color:var(--txt-mute)">${list.length} događaja</span>
      </div>`;

    const blocks = Object.keys(groups).length === 0
      ? `<div class="slip-empty" style="padding:60px 20px">Nema događaja za odabrane filtere.</div>`
      : Object.entries(groups).map(([lid, evs]) => {
          const l = evs[0];
          return `
            <div class="league-block">
              <button class="league-hd" data-toggle="${lid}">
                <span class="flag">${l.flag}</span>
                <span>${esc(l.leagueName)}</span>
                <span class="cnt">${evs.length}</span>
              </button>
              <div data-body="${lid}">
                <div class="mk-head">
                  <span>Događaj</span>
                  ${cols.map(c => `<span>${c}</span>`).join('')}
                  <span></span>
                </div>
                ${evs.map(e => eventRow(e, cols)).join('')}
              </div>
            </div>`;
        }).join('');

    $('#offerHost').innerHTML = `<div class="panel">${header}${blocks}</div>`;
    bind();
    P.render();
  }

  function bind() {
    $$('[data-filter]').forEach(b => b.onclick = () => {
      state.filter = b.dataset.filter;
      if (state.filter === 'live') state.league = null;
      render();
    });
    $$('[data-toggle]').forEach(b => b.onclick = () => {
      const body = $(`[data-body="${b.dataset.toggle}"]`);
      if (body) body.style.display = body.style.display === 'none' ? '' : 'none';
    });
    $$('.odd[data-ev]').forEach(b => b.onclick = () => {
      const ev = D.OFFER.find(e => e.id === b.dataset.ev);
      if (!ev) return;
      P.slip.toggle(ev, b.dataset.mkt);
    });
    $$('[data-more]').forEach(b => b.onclick = () => showMarkets(b.dataset.more));
  }

  /* ---------- all-markets modal (BetBuilder style) ---------- */
  function showMarkets(evId) {
    const ev = D.OFFER.find(e => e.id === evId);
    if (!ev) return;
    const sport = sportOf(ev.sportId);
    const r = D.makeRng(ev.code);

    const groups = [
      { n: 'Konačni ishod', keys: D.MARKET_SETS[sport.cols] },
      { n: 'Ukupno golova / poena', keys: ['0-1','0-2','2+','3+','4+','5+'] },
      { n: 'Poluvrijeme', keys: ['1P 1','1P X','1P 2'] },
      { n: 'Hendikep', keys: ['H -1','H 0','H +1'] },
      { n: 'Kombinacije', keys: ['1 i GG','2 i GG','1 i 2+','2 i 2+'] }
    ];

    const html = groups.map(g => `
      <div style="margin-bottom:18px">
        <div style="font-size:12px;font-weight:700;color:var(--txt-mute);margin-bottom:8px;text-transform:uppercase">${esc(g.n)}</div>
        <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(96px,1fr));gap:6px">
          ${g.keys.map(k => {
            const o = ev.markets[k] != null ? ev.markets[k] : +(1.2 + r() * 6).toFixed(2);
            return `<button class="odd" data-mev="${ev.id}" data-mmkt="${esc(k)}" data-modd="${o}"
                      style="height:42px;flex-direction:column">
                      <span style="font-size:10px;color:var(--txt-mute)">${esc(k)}</span>
                      <span>${num(o)}</span>
                    </button>`;
          }).join('')}
        </div>
      </div>`).join('');

    const box = P.modal(
      `${sport.icon} ${esc(ev.name)}`,
      `<div style="font-size:12px;color:var(--txt-mute);margin-bottom:14px">
         ${ev.flag} ${esc(ev.leagueName)} · šifra ${ev.code}
         ${ev.live ? ` · <span style="color:var(--live)">UŽIVO ${ev.minute}' ${ev.score}</span>` : ''}
       </div>${html}`,
      `<button class="btn btn-ghost" data-close>Zatvori</button>`, true);

    $$('[data-mev]', box).forEach(b => b.onclick = () => {
      const mkt = b.dataset.mmkt;
      const tmp = Object.assign({}, ev, { markets: Object.assign({}, ev.markets, { [mkt]: +b.dataset.modd }) });
      D.MARKET_LABELS[mkt] = D.MARKET_LABELS[mkt] || mkt;
      P.slip.toggle(tmp, mkt);
      b.classList.toggle('is-picked');
      P.toast('Dodano na listić: ' + mkt);
    });
  }

  /* ---------- live odds drift ---------- */
  setInterval(() => {
    const live = D.OFFER.filter(e => e.live);
    if (!live.length) return;
    for (let i = 0; i < 3; i++) {
      const ev = live[Math.floor(Math.random() * live.length)];
      const keys = Object.keys(ev.markets).filter(k => ev.markets[k] != null);
      if (!keys.length) continue;
      const k = keys[Math.floor(Math.random() * keys.length)];
      const dir = Math.random() < 0.5 ? -1 : 1;
      const next = Math.max(1.02, +(ev.markets[k] + dir * 0.05).toFixed(2));
      ev.markets[k] = next;
      const btn = document.querySelector(`.odd[data-ev="${ev.id}"][data-mkt="${k}"]`);
      if (btn) {
        btn.textContent = num(next);
        btn.classList.remove('up', 'down');
        void btn.offsetWidth;
        btn.classList.add(dir > 0 ? 'up' : 'down');
      }
    }
  }, 4000);

  /* ---------- live clock ---------- */
  setInterval(() => {
    D.OFFER.forEach(e => { if (e.live && e.minute < 90) e.minute++; });
    $$('.evt-live-min').forEach((el, i) => {});
  }, 60000);

  render();
  window.PSK_SPORTSBOOK = { render, state };
})();
