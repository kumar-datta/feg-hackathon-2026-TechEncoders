/* ============================================================
   casino.js — game grid rendering, category filtering, search,
   provider pages and jackpot tickers.
   Used by casino.html, live-casino.html and pretraga.html.
   ============================================================ */
(function () {
  'use strict';

  const P = window.PSK, D = window.PSK_DATA;
  if (!P) return;
  const $ = P.$, $$ = P.$$, esc = P.esc, eur = P.eur;

  /* ---------- one game tile ---------- */
  function tile(g, opts) {
    opts = opts || {};
    const bg = `linear-gradient(150deg, hsl(${g.h1} 72% 46%), hsl(${g.h2} 68% 22%))`;
    const badge =
      g.cats && g.cats.includes('new')       ? '<span class="game-badge">NOVO</span>' :
      g.cats && g.cats.includes('exclusive') ? '<span class="game-badge">EKSKLUZIVNO</span>' :
      g.cats && g.cats.includes('jackpot')   ? '<span class="game-badge jp">JACKPOT</span>' :
      opts.live ? '<span class="game-badge live">UŽIVO</span>' : '';
    const jp = g.jackpot ? `<span class="game-jp-amt">${eur(g.jackpot)}</span>` : '';
    const players = opts.live && g.players ? `<span class="game-jp-amt">👥 ${g.players}</span>` : '';

    return `
      <div class="game-card" data-game="${g.id}">
        <div class="game-thumb" style="background:${bg}">
          ${badge}${jp}${players}
          <span class="sym">${g.sym}</span>
          <div class="game-ovl">
            <button class="btn btn-accent" data-play="${g.id}">Igraj</button>
            <button class="btn btn-ghost" data-info="${g.id}" style="color:#fff;border-color:rgba(255,255,255,.4)">Detalji</button>
          </div>
          <div class="game-name">${esc(g.title)}<div class="game-prov">${esc(g.provider)}</div></div>
        </div>
      </div>`;
  }

  function findGame(id) {
    return D.ALL_GAMES.find(g => g.id === id) || D.LIVE_TABLES.find(g => g.id === id);
  }

  function bindTiles(root) {
    $$('[data-play]', root).forEach(b => b.onclick = e => {
      e.stopPropagation();
      const g = findGame(b.dataset.play);
      if (g) window.PSK_GAME.launch(g);
    });
    $$('[data-info]', root).forEach(b => b.onclick = e => {
      e.stopPropagation();
      const g = findGame(b.dataset.info);
      if (!g) return;
      P.modal(`${g.sym} ${esc(g.title)}`, `
        <table class="tbl">
          <tbody>
            <tr><td>Provider</td><td class="num">${esc(g.provider)}</td></tr>
            <tr><td>RTP</td><td class="num">${g.rtp ? g.rtp + '%' : '—'}</td></tr>
            <tr><td>Volatilnost</td><td class="num">${esc(g.volatility || '—')}</td></tr>
            <tr><td>Linije</td><td class="num">${g.lines || '—'}</td></tr>
            <tr><td>Raspon uloga</td><td class="num">${g.minBet ? eur(g.minBet) + ' – ' + eur(g.maxBet) : '—'}</td></tr>
            <tr><td>Jackpot</td><td class="num">${g.jackpot ? eur(g.jackpot) : 'nema'}</td></tr>
          </tbody>
        </table>
        <p style="font-size:12px;color:var(--txt-mute);margin-top:14px">
          Igra je demonstracijska simulacija napisana u JavaScriptu. Ne koristi stvarni novac.
        </p>`,
        `<button class="btn btn-ghost" data-close>Zatvori</button>
         <button class="btn btn-accent" id="infoPlay">Igraj</button>`);
      const ip = $('#infoPlay');
      if (ip) ip.onclick = () => { P.closeModal(); window.PSK_GAME.launch(g); };
    });
    $$('.game-card', root).forEach(c => c.ondblclick = () => {
      const g = findGame(c.dataset.game);
      if (g) window.PSK_GAME.launch(g);
    });
  }

  /* ---------- rail (horizontal section) ---------- */
  function rail(title, icon, games, href) {
    if (!games.length) return '';
    return `
      <section class="sec">
        <div class="sec-hd">
          <h2>${icon} ${esc(title)}</h2>
          <a class="more" href="${href || '#'}">Vidi sve (${games.length}) →</a>
        </div>
        <div class="game-grid">${games.slice(0, 12).map(g => tile(g)).join('')}</div>
      </section>`;
  }

  /* ============================================================
     CASINO LOBBY
     ============================================================ */
  function initLobby() {
    const host = $('#casinoHost');
    if (!host) return;

    let cat = P.qs('kategorija') || 'lobby';
    let prov = P.qs('provider') || '';
    let q = '';

    const catBar = () => `
      <div class="cat-bar" style="margin-bottom:18px">
        ${D.CASINO_CATEGORIES.map(c =>
          `<button class="chip${cat === c.id ? ' is-active' : ''}" data-cat="${c.id}">${c.icon} ${esc(c.name)}</button>`
        ).join('')}
      </div>`;

    const searchBar = () => `
      <div class="hdr-search" style="max-width:100%;flex:1;height:40px;margin-bottom:16px">
        <span>🔍</span>
        <input id="gameSearch" type="search" placeholder="Pronađi svoju igru..." value="${esc(q)}">
      </div>`;

    function filtered() {
      let list = D.ALL_GAMES;
      if (prov) list = list.filter(g => g.provider === prov);
      if (cat !== 'lobby' && cat !== 'all') list = list.filter(g => g.cats.includes(cat));
      if (q) {
        const s = q.toLowerCase();
        list = list.filter(g => g.title.toLowerCase().includes(s) || g.provider.toLowerCase().includes(s));
      }
      return list;
    }

    function jackpotStrip() {
      const jps = D.ALL_GAMES.filter(g => g.jackpot).sort((a, b) => b.jackpot - a.jackpot).slice(0, 4);
      return `
        <div class="jp-strip" style="margin-bottom:24px">
          ${jps.map((g, i) => `
            <div class="jp-card">
              <div class="lbl">${['Mega','Major','Minor','Mini'][i] || 'Jackpot'}</div>
              <div class="amt" data-jp="${g.jackpot}">${eur(g.jackpot)}</div>
              <div class="sub">${esc(g.title)}</div>
            </div>`).join('')}
        </div>`;
    }

    function draw() {
      const list = filtered();
      const isLobby = cat === 'lobby' && !prov && !q;

      host.innerHTML = searchBar() + catBar() + jackpotStrip() + (isLobby ? `
          ${rail('PSK favoriti', '⭐', D.ALL_GAMES.filter(g => g.cats.includes('favourites')), 'casino.html?kategorija=favourites')}
          ${rail('Nove igre', '✨', D.ALL_GAMES.filter(g => g.cats.includes('new')), 'casino.html?kategorija=new')}
          ${rail('Popularno', '🔥', D.ALL_GAMES.filter(g => g.cats.includes('popular')), 'casino.html?kategorija=popular')}
          ${rail('Igre na stolovima', '🃏', D.TABLE_GAMES, 'casino.html?kategorija=table')}
          ${rail('Jackpot igre', '💰', D.ALL_GAMES.filter(g => g.cats.includes('jackpot')), 'casino.html?kategorija=jackpot')}
          ${rail('Buy Bonus', '🎁', D.ALL_GAMES.filter(g => g.cats.includes('buy-bonus')), 'casino.html?kategorija=buy-bonus')}
          ${rail('Mali ulozi', '🪙', D.ALL_GAMES.filter(g => g.cats.includes('small-bets')), 'casino.html?kategorija=small-bets')}
          ${rail('Megaways', '🌀', D.ALL_GAMES.filter(g => g.cats.includes('megaways')), 'casino.html?kategorija=megaways')}
          <section class="sec">
            <div class="sec-hd"><h2>🏢 Provideri</h2><a class="more" href="provideri.html">Svi provideri (${D.PROVIDERS.length}) →</a></div>
            <div class="provider-grid">
              ${D.PROVIDERS.slice(0, 18).map(p => `
                <a class="provider-card" href="casino.html?provider=${encodeURIComponent(p)}">
                  ${esc(p)}<span class="n">${D.ALL_GAMES.filter(g => g.provider === p).length} igara</span>
                </a>`).join('')}
            </div>
          </section>
        ` : `
          <div class="sec-hd">
            <h2>${prov ? '🏢 ' + esc(prov) : (D.CASINO_CATEGORIES.find(c => c.id === cat) || {}).name || 'Igre'}</h2>
            <span class="more">${list.length} igara</span>
          </div>
          <div class="game-grid dense">${list.slice(0, 120).map(g => tile(g)).join('')}</div>
          ${list.length > 120 ? `<p style="text-align:center;color:var(--txt-mute);margin-top:20px">Prikazano prvih 120 od ${list.length} igara.</p>` : ''}
          ${list.length === 0 ? `<div class="slip-empty" style="padding:60px">Nema igara za odabrane filtere.</div>` : ''}
        `);

      $$('[data-cat]').forEach(b => b.onclick = () => { cat = b.dataset.cat; prov = ''; draw(); });
      const gs = $('#gameSearch');
      if (gs) {
        gs.oninput = () => { q = gs.value.trim(); clearTimeout(gs._t); gs._t = setTimeout(draw, 220); };
        if (q) { gs.focus(); gs.setSelectionRange(q.length, q.length); }
      }
      bindTiles(host);
    }

    draw();

    /* jackpot ticker */
    setInterval(() => {
      $$('[data-jp]').forEach(el => {
        const v = +el.dataset.jp + Math.random() * 12;
        el.dataset.jp = v;
        el.textContent = eur(v);
      });
    }, 2500);
  }

  /* ============================================================
     LIVE CASINO
     ============================================================ */
  function initLive() {
    const host = $('#liveHost');
    if (!host) return;

    const cats = [
      ['all', 'Svi stolovi', '🎬'],
      ['roulette', 'Rulet', '🎡'],
      ['table', 'Kartaške igre', '🃏'],
      ['game-shows', 'Game Shows', '🎪']
    ];
    let cat = 'all';

    function draw() {
      const list = cat === 'all' ? D.LIVE_TABLES : D.LIVE_TABLES.filter(t => t.cats.includes(cat));
      host.innerHTML = `
        <div class="cat-bar" style="margin-bottom:18px">
          ${cats.map(c => `<button class="chip${cat === c[0] ? ' is-active' : ''}" data-lc="${c[0]}">${c[2]} ${c[1]}</button>`).join('')}
        </div>
        <div class="game-grid">${list.map(g => tile(g, { live: true })).join('')}</div>`;
      $$('[data-lc]').forEach(b => b.onclick = () => { cat = b.dataset.lc; draw(); });
      bindTiles(host);
    }
    draw();

    setInterval(() => {
      D.LIVE_TABLES.forEach(t => {
        t.players = Math.max(5, t.players + Math.round((Math.random() - 0.5) * 18));
      });
      draw();
    }, 8000);
  }

  /* ============================================================
     PROVIDERS PAGE
     ============================================================ */
  function initProviders() {
    const host = $('#providersHost');
    if (!host) return;
    host.innerHTML = `
      <div class="provider-grid">
        ${D.PROVIDERS.map(p => `
          <a class="provider-card" href="casino.html?provider=${encodeURIComponent(p)}">
            ${esc(p)}<span class="n">${D.ALL_GAMES.filter(g => g.provider === p).length} igara</span>
          </a>`).join('')}
      </div>`;
  }

  /* ============================================================
     GLOBAL SEARCH PAGE
     ============================================================ */
  function initSearch() {
    const host = $('#searchHost');
    if (!host) return;
    const q = (P.qs('q') || '').toLowerCase();

    const games = D.ALL_GAMES.filter(g =>
      g.title.toLowerCase().includes(q) || g.provider.toLowerCase().includes(q));
    const events = D.OFFER.filter(e =>
      e.name.toLowerCase().includes(q) || e.leagueName.toLowerCase().includes(q)).slice(0, 40);

    host.innerHTML = `
      <h1 class="page-title">Rezultati pretrage</h1>
      <p class="page-lede">Upit: <strong>${esc(P.qs('q') || '')}</strong> — ${events.length} događaja, ${games.length} igara.</p>

      <section class="sec">
        <div class="sec-hd"><h2>🏆 Sportski događaji</h2></div>
        ${events.length ? `<div class="panel">${events.map(e => `
          <a class="evt" style="--cols:0;grid-template-columns:1fr auto" href="oklade.html?sport=${e.sportId}&league=${e.leagueId}">
            <div class="evt-main"><div class="evt-teams">
              <div class="evt-team">${esc(e.name)}</div>
              <div class="evt-meta"><span>${e.flag} ${esc(e.leagueName)}</span><span>#${e.code}</span></div>
            </div></div>
            <span style="color:var(--accent);font-weight:700">Otvori →</span>
          </a>`).join('')}</div>` : '<p style="color:var(--txt-mute)">Nema pronađenih događaja.</p>'}
      </section>

      <section class="sec">
        <div class="sec-hd"><h2>🎰 Casino igre</h2></div>
        ${games.length ? `<div class="game-grid dense">${games.slice(0, 60).map(g => tile(g)).join('')}</div>`
                       : '<p style="color:var(--txt-mute)">Nema pronađenih igara.</p>'}
      </section>`;
    bindTiles(host);
  }

  /* ============================================================
     VIRTUALS
     ============================================================ */
  function initVirtuals() {
    const host = $('#virtualHost');
    if (!host) return;
    host.innerHTML = `
      <div class="game-grid">${D.VIRTUALS.map(v => `
        <div class="game-card">
          <div class="game-thumb" style="background:linear-gradient(150deg,hsl(${v.h1} 70% 46%),hsl(${v.h2} 66% 22%))">
            <span class="game-badge">${esc(v.every)}</span>
            <span class="sym">${v.sym}</span>
            <div class="game-ovl">
              <button class="btn btn-accent" data-vr="${v.id}">Pokreni</button>
            </div>
            <div class="game-name">${esc(v.name)}<div class="game-prov">novo kolo svakih ${esc(v.every)}</div></div>
          </div>
        </div>`).join('')}
      </div>`;

    $$('[data-vr]').forEach(b => b.onclick = () => {
      const v = D.VIRTUALS.find(x => x.id === b.dataset.vr);
      runVirtual(v);
    });
  }

  function runVirtual(v) {
    const r = D.makeRng(Date.now() % 100000);
    const field = ['Crveni','Plavi','Zeleni','Žuti','Bijeli','Crni','Sivi','Ljubičasti'];
    const runners = field.slice(0, 6).map((n, i) => ({
      n: n + ' #' + (i + 1),
      odd: +(1.8 + r() * 9).toFixed(2)
    }));

    const box = P.modal(`${v.icon} ${esc(v.name)}`, `
      <p style="color:var(--txt-dim);font-size:13.5px">${esc(v.desc)}</p>
      <p style="font-size:12px;color:var(--txt-mute)">Odaberi pobjednika i pokreni simulaciju kola.</p>
      <div class="rt-board" style="grid-template-columns:repeat(2,1fr);margin:14px 0">
        ${runners.map((x, i) => `<button class="rt-bet${i === 0 ? ' on' : ''}" data-r="${i}"
            style="height:40px;justify-content:space-between;padding:0 12px;display:flex;align-items:center">
            <span>${esc(x.n)}</span><span style="color:var(--accent)">${x.odd.toFixed(2)}</span></button>`).join('')}
      </div>
      <div class="g-stage" style="padding:12px">
        <div id="vrTrack" style="font-size:13px;text-align:left;font-family:monospace;line-height:1.9"></div>
      </div>
      <div style="margin-top:12px;font-weight:700;min-height:22px" id="vrMsg">Spremno.</div>
      <div class="g-bar">
        <div class="g-stat"><span>Ulog</span>
          <b><input id="vrBet" class="stake-input" style="width:90px;height:30px;font-size:14px" type="number" min="0.5" step="0.5" value="2"></b></div>
        <div class="g-stat"><span>Stanje</span><b id="vrBal">${eur(P.acct.balance)}</b></div>
        <div class="grow"></div>
        <button class="btn btn-accent btn-lg" id="vrGo">Pokreni kolo</button>
      </div>`, null, true);

    let sel = 0;
    $$('[data-r]', box).forEach(b => b.onclick = () => {
      $$('[data-r]', box).forEach(x => x.classList.remove('on'));
      b.classList.add('on'); sel = +b.dataset.r;
    });

    $('#vrGo', box).onclick = () => {
      if (!P.acct.logged) { P.toast('Prijavi se na demo račun.', 'err'); return; }
      const bet = Math.max(0.5, +$('#vrBet', box).value || 0.5);
      if (!P.acct.debit(bet)) { P.toast('Nedovoljno sredstava.', 'err'); return; }
      $('#vrBal', box).textContent = eur(P.acct.balance);

      const pos = runners.map(() => 0);
      let ticks = 0;
      const iv = setInterval(() => {
        ticks++;
        runners.forEach((_, i) => { pos[i] += Math.random() * 3; });
        $('#vrTrack', box).innerHTML = runners.map((x, i) =>
          `${esc(x.n.padEnd(14))} ${'▬'.repeat(Math.floor(pos[i]))}`
        ).join('<br>');
        if (ticks >= 18) {
          clearInterval(iv);
          const winner = pos.indexOf(Math.max(...pos));
          const win = winner === sel ? +(bet * runners[sel].odd).toFixed(2) : 0;
          if (win) P.acct.credit(win);
          $('#vrBal', box).textContent = eur(P.acct.balance);
          $('#vrMsg', box).innerHTML = win
            ? `<span style="color:var(--win)">Pobjednik: ${esc(runners[winner].n)} — dobitak ${eur(win)}</span>`
            : `<span style="color:var(--live)">Pobjednik: ${esc(runners[winner].n)} — nema dobitka.</span>`;
        }
      }, 220);
      window.PSK_GAME.stop();
    };
  }

  /* ============================================================
     LOTTO
     ============================================================ */
  function initLotto() {
    const host = $('#lottoHost');
    if (!host) return;
    host.innerHTML = `
      <div class="tile-grid">
        ${D.LOTTERIES.map(l => `
          <div class="panel">
            <div class="panel-hd"><span>${esc(l.name)}</span><span style="color:var(--accent)">${eur(l.jackpot)}</span></div>
            <div class="panel-bd">
              <p style="font-size:13px;color:var(--txt-dim);margin-bottom:6px">Odabir ${l.pick} od ${l.max}</p>
              <p style="font-size:12px;color:var(--txt-mute);margin-bottom:14px">Izvlačenje: ${esc(l.draw)}</p>
              <button class="btn btn-accent btn-block" data-lot="${l.id}">Uplati listić</button>
            </div>
          </div>`).join('')}
      </div>`;
    $$('[data-lot]').forEach(b => b.onclick = () => {
      const l = D.LOTTERIES.find(x => x.id === b.dataset.lot);
      window.PSK_GAME.lotto(l);
    });
  }

  /* ---------- boot whichever host exists ---------- */
  initLobby(); initLive(); initProviders(); initSearch(); initVirtuals(); initLotto();

  window.PSK_CASINO = { tile, bindTiles, rail };
})();
