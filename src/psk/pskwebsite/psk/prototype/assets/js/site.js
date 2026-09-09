/* ============================================================
   site.js — shared shell: header, navigation, footer, bet slip,
   demo wallet, modal + toast helpers.
   Every page includes this and declares  window.PAGE = { id, ... }.
   ============================================================ */
(function () {
  'use strict';

  const D = window.PSK_DATA;
  const PAGE = window.PAGE || {};
  const $  = (s, c) => (c || document).querySelector(s);
  const $$ = (s, c) => Array.from((c || document).querySelectorAll(s));

  /* ---------- utils ---------- */
  const eur = n => new Intl.NumberFormat('hr-HR', { style: 'currency', currency: 'EUR' }).format(n);
  const num = n => new Intl.NumberFormat('hr-HR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(n);
  const esc = s => String(s).replace(/[&<>"']/g, m => ({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[m]));

  function store(key, fallback) {
    try {
      const v = localStorage.getItem('psk.' + key);
      return v === null ? fallback : JSON.parse(v);
    } catch (e) { return fallback; }
  }
  function save(key, val) {
    try { localStorage.setItem('psk.' + key, JSON.stringify(val)); } catch (e) {}
  }

  /* ============================================================
     THEME
     ============================================================ */
  const theme = {
    get() { return store('theme', 'dark'); },
    set(v) { save('theme', v); document.documentElement.setAttribute('data-theme', v); },
    toggle() { this.set(this.get() === 'dark' ? 'light' : 'dark'); }
  };
  document.documentElement.setAttribute('data-theme', theme.get());

  /* ============================================================
     DEMO WALLET / SESSION
     ============================================================ */
  const acct = {
    get logged() { return store('logged', false); },
    get balance() { return store('balance', 500); },
    get user() { return store('user', 'igrac01'); },
    set balance(v) { save('balance', Math.round(v * 100) / 100); renderBalance(); },
    login(name) {
      save('logged', true);
      save('user', name || 'igrac01');
      if (store('balance', null) === null) save('balance', 500);
      renderBalance();
    },
    logout() { save('logged', false); renderBalance(); },
    debit(v) {
      if (v > this.balance) return false;
      this.balance = this.balance - v;
      return true;
    },
    credit(v) { this.balance = this.balance + v; }
  };

  /* ============================================================
     NAVIGATION MODEL — mirrors the routes of the source site
     ============================================================ */
  const NAV_MAIN = [
    { id: 'sport',    label: 'Sport',          href: 'oklade.html' },
    { id: 'live',     label: 'Uživo',          href: 'oklade.html?filter=live', live: true },
    { id: 'casino',   label: 'Casino',         href: 'casino.html', badge: 'NEW' },
    { id: 'live-casino', label: 'Live Casino', href: 'live-casino.html' },
    { id: 'loto',     label: 'Loto',           href: 'loto.html' },
    { id: 'virtuals', label: 'Virtualne igre', href: 'virtualne-igre.html' },
    { id: 'forum',    label: 'Forum',          href: 'forum.html' },
    { id: 'arena',    label: 'PSK arena',      href: 'psk-arena.html' },
    { id: 'promo',    label: 'Promo',          href: 'promocije.html' },
    { id: 'swipe',    label: 'Swipe & Bet',    href: 'swipe-and-bet.html' }
  ];

  const NAV_SUB = [
    { id: 'home',     label: 'Naslovna',           href: 'index.html' },
    { id: 'app',      label: 'Mobilna aplikacija', href: 'mobilna-aplikacija.html' },
    { id: 'rezultati',label: 'Rezultati',          href: 'rezultati.html' },
    { id: 'statistika',label: 'Statistika',        href: 'statistika.html' },
    { id: 'novosti',  label: 'Novosti',            href: 'novosti.html' },
    { id: 'klub',     label: 'Klub prvaka',        href: 'klub-prvaka.html' },
    { id: 'pomoc',    label: 'Pomoć',              href: 'pomoc.html' },
    { id: 'shops',    label: 'Poslovnice',         href: 'poslovnice.html' }
  ];

  const FOOTER_COLS = [
    { h: 'Ponuda', links: [
      ['Sportska kladionica', 'oklade.html'], ['Klađenje uživo', 'oklade.html?filter=live'],
      ['Casino', 'casino.html'], ['Live Casino', 'live-casino.html'],
      ['Loto', 'loto.html'], ['Virtualne igre', 'virtualne-igre.html'],
      ['Swipe & Bet', 'swipe-and-bet.html'], ['Promocije', 'promocije.html']
    ]},
    { h: 'O nama', links: [
      ['O nama', 'o-nama.html'], ['Poslovnice', 'poslovnice.html'],
      ['Klub prvaka', 'klub-prvaka.html'], ['PSK arena', 'psk-arena.html'],
      ['Novosti', 'novosti.html'], ['Karijera', 'o-nama.html#karijera'],
      ['Kontakt', 'kontakt.html']
    ]},
    { h: 'Pravila', links: [
      ['Pravila igre', 'pravila-igre.html'], ['Opća pravila bonusa', 'pravila-igre.html#bonusi'],
      ['Pravila o privatnosti', 'pravila-privatnosti.html'], ['Politika kolačića', 'pravila-privatnosti.html#kolacici'],
      ['Zaštita osobnih podataka', 'pravila-privatnosti.html#gdpr'], ['Izjava o sukladnosti', 'pravila-igre.html#sukladnost']
    ]},
    { h: 'Podrška', links: [
      ['Pomoć i česta pitanja', 'pomoc.html'], ['Kontakt forma', 'kontakt.html'],
      ['Odgovorno igranje', 'odgovorno-igranje.html'], ['Obrazac za samoisključenje', 'odgovorno-igranje.html#samoiskljucenje'],
      ['Limiti igre', 'odgovorno-igranje.html#limiti'], ['Sigurnosni vodič', 'novosti.html']
    ]}
  ];

  /* ============================================================
     HEADER
     ============================================================ */
  function headerHTML() {
    const main = NAV_MAIN.map(n => `
      <a class="nav-link${PAGE.nav === n.id ? ' is-active' : ''}" href="${n.href}">
        ${n.live ? '<span class="dot-live"></span>' : ''}${esc(n.label)}
        ${n.badge ? `<span class="tag-new">${n.badge}</span>` : ''}
      </a>`).join('');

    const sub = NAV_SUB.map(n =>
      `<a class="sub-link${PAGE.sub === n.id ? ' is-active' : ''}" href="${n.href}">${esc(n.label)}</a>`
    ).join('');

    return `
    <div class="demo-bar">DEMO / UČENJE — nezavisna vježba izrade sučelja. Nije povezano s pravim operaterom; nema stvarnog novca ni klađenja.</div>
    <header class="site-header">
      <div class="hdr-top">
        <button class="burger" id="burger" aria-label="Izbornik">☰</button>
        <a class="logo" href="index.html">
          <span class="logo-mark">PSK</span>
          <span class="logo-txt">PSK<em>.demo</em></span>
        </a>
        <div class="hdr-spacer"></div>
        <label class="hdr-search">
          <span aria-hidden="true">🔍</span>
          <input type="search" id="globalSearch" placeholder="Pretraži događaje i igre..." aria-label="Pretraga">
        </label>
        <button class="icon-btn" id="themeBtn" title="Svijetla / tamna tema" aria-label="Promijeni temu">◐</button>
        <a class="icon-btn" href="pomoc.html" title="Pomoć" aria-label="Pomoć">?</a>
        <div id="acctZone"></div>
      </div>
      <nav class="hdr-nav" aria-label="Glavna navigacija">
        <div class="hdr-nav-inner">${main}</div>
      </nav>
      <nav class="hdr-sub" aria-label="Dodatna navigacija">
        <div class="hdr-sub-inner">${sub}</div>
      </nav>
    </header>
    <div class="drawer-back" id="drawerBack"></div>`;
  }

  function renderBalance() {
    const zone = $('#acctZone');
    if (!zone) return;
    zone.innerHTML = acct.logged ? `
      <div style="display:flex;gap:8px;align-items:center">
        <div class="balance-pill">
          <span class="bal-amt">${eur(acct.balance)}</span>
          <a class="bal-add" href="racun.html" title="Uplata">+</a>
        </div>
        <a class="icon-btn" href="racun.html" title="Moj račun" aria-label="Moj račun">👤</a>
      </div>` : `
      <div style="display:flex;gap:8px">
        <a class="btn btn-ghost" href="prijava.html">Prijava</a>
        <a class="btn btn-accent" href="registracija.html">Registracija</a>
      </div>`;
  }

  /* ============================================================
     FOOTER
     ============================================================ */
  function footerHTML() {
    const cols = FOOTER_COLS.map(c => `
      <div class="foot-col">
        <h4>${esc(c.h)}</h4>
        ${c.links.map(l => `<a href="${l[1]}">${esc(l[0])}</a>`).join('')}
      </div>`).join('');

    const pay = D.PAYMENTS.map(p => `<span class="pay-chip">${esc(p)}</span>`).join('');

    return `
    <footer class="site-footer">
      <div class="foot-inner">
        <div class="foot-cols">
          ${cols}
          <div class="foot-col">
            <h4>Aplikacija i mreže</h4>
            <a href="mobilna-aplikacija.html">Android aplikacija</a>
            <a href="mobilna-aplikacija.html">iOS aplikacija</a>
            <a href="mobilna-aplikacija.html">Casino aplikacija</a>
            <div class="foot-social">
              <a href="#" title="Facebook" aria-label="Facebook">f</a>
              <a href="#" title="Instagram" aria-label="Instagram">ig</a>
              <a href="#" title="X" aria-label="X">x</a>
              <a href="#" title="YouTube" aria-label="YouTube">▶</a>
              <a href="#" title="TikTok" aria-label="TikTok">♪</a>
            </div>
          </div>
        </div>

        <div style="margin-top:26px">
          <h4 style="font-size:12px;letter-spacing:.6px;text-transform:uppercase;color:var(--txt-mute)">Načini plaćanja (prikaz)</h4>
          <div class="foot-pay">${pay}</div>
        </div>

        <div class="foot-legal">
          <p style="margin-bottom:10px">
            <span class="age-badge">18+</span>
            Igre na sreću mogu izazvati ovisnost. Igraj odgovorno i postavi limite.
            Više na stranici <a href="odgovorno-igranje.html" style="color:var(--accent)">Odgovorno igranje</a>.
          </p>
          <p style="margin:0">
            <strong>Ovo je demonstracijski projekt.</strong> Radi se o samostalno izrađenoj vježbi sučelja
            (HTML/CSS/JavaScript) napravljenoj radi učenja. Stranica nije povezana ni s jednim stvarnim
            priređivačem igara na sreću, ne prihvaća uplate, ne omogućuje stvarno klađenje i ne predstavlja
            nijednu tvrtku. Svi prikazani događaji, tečajevi, igre i iznosi su nasumično generirani podaci.
          </p>
          <p style="margin:8px 0 0">© ${new Date().getFullYear()} PSK.demo — obrazovni klon sučelja.</p>
        </div>
      </div>
    </footer>

    <nav class="mob-bar" aria-label="Mobilna navigacija">
      <a href="index.html" class="${PAGE.nav === 'home' ? 'is-active' : ''}"><span class="i">🏠</span>Naslovna</a>
      <a href="oklade.html" class="${PAGE.nav === 'sport' ? 'is-active' : ''}"><span class="i">🏆</span>Sport</a>
      <a href="oklade.html?filter=live" class="${PAGE.nav === 'live' ? 'is-active' : ''}"><span class="i">🔴</span>Uživo</a>
      <a href="casino.html" class="${PAGE.nav === 'casino' ? 'is-active' : ''}"><span class="i">🎰</span>Casino</a>
      <a href="listici.html" class="${PAGE.nav === 'listici' ? 'is-active' : ''}"><span class="i">🎫</span>Listići</a>
    </nav>

    <div class="toast-wrap" id="toastWrap"></div>
    <div class="modal-back" id="modalBack" role="dialog" aria-modal="true"><div class="modal" id="modalBox"></div></div>`;
  }

  /* ============================================================
     TOAST + MODAL
     ============================================================ */
  function toast(msg, kind) {
    const wrap = $('#toastWrap');
    if (!wrap) return;
    const el = document.createElement('div');
    el.className = 'toast' + (kind ? ' ' + kind : '');
    el.textContent = msg;
    wrap.appendChild(el);
    setTimeout(() => { el.style.opacity = '0'; el.style.transition = 'opacity .3s'; }, 2800);
    setTimeout(() => el.remove(), 3200);
  }

  function modal(title, bodyHTML, footHTML, wide) {
    const back = $('#modalBack'), box = $('#modalBox');
    if (!back) return;
    box.className = 'modal' + (wide ? ' wide' : '');
    box.innerHTML = `
      <div class="modal-hd"><span>${title}</span><button class="x" data-close aria-label="Zatvori">×</button></div>
      <div class="modal-bd">${bodyHTML}</div>
      ${footHTML ? `<div class="modal-ft">${footHTML}</div>` : ''}`;
    back.classList.add('is-open');
    box.querySelectorAll('[data-close]').forEach(b => b.onclick = closeModal);
    return box;
  }
  function closeModal() {
    const back = $('#modalBack');
    if (!back) return;
    back.classList.remove('is-open');
    if (window.PSK_GAME && window.PSK_GAME.stop) window.PSK_GAME.stop();
  }

  /* ============================================================
     BET SLIP
     ============================================================ */
  const slip = {
    picks: store('slip', []),
    tickets: store('tickets', []),
    persist() { save('slip', this.picks); render(); },
    has(evId, mkt) { return this.picks.some(p => p.evId === evId && p.mkt === mkt); },
    toggle(ev, mkt) {
      const i = this.picks.findIndex(p => p.evId === ev.id && p.mkt === mkt);
      if (i > -1) { this.picks.splice(i, 1); this.persist(); return false; }
      // one selection per event, like a real slip
      const j = this.picks.findIndex(p => p.evId === ev.id);
      if (j > -1) this.picks.splice(j, 1);
      this.picks.push({
        evId: ev.id, mkt,
        odd: ev.markets[mkt],
        name: ev.name,
        league: ev.leagueName,
        label: D.MARKET_LABELS[mkt] || mkt,
        code: ev.code
      });
      this.persist();
      return true;
    },
    remove(i) { this.picks.splice(i, 1); this.persist(); },
    clear() { this.picks = []; this.persist(); },
    get totalOdds() { return this.picks.reduce((a, p) => a * p.odd, 1); },
    get stake() { return store('stake', 5); },
    set stake(v) { save('stake', v); render(); }
  };

  function slipHTML() {
    const n = slip.picks.length;
    const stake = slip.stake;
    const odds = slip.totalOdds;
    const gross = stake * odds;
    const tax = gross > stake ? (gross - stake) * 0.10 : 0;   // illustrative payout deduction
    const net = gross - tax;

    const picks = n === 0
      ? `<div class="slip-empty"><span class="big">🎫</span>Listić je prazan.<br>Odaberi tečaj iz ponude.</div>`
      : slip.picks.map((p, i) => `
        <div class="pick">
          <button class="pick-rm" data-rm="${i}" title="Ukloni">✕</button>
          <div class="pick-top">
            <span class="pick-mkt">${esc(p.label)}</span>
            <span class="pick-odd">${num(p.odd)}</span>
          </div>
          <div class="pick-evt">${esc(p.name)}</div>
          <div class="pick-lg">${esc(p.league)} · šifra ${p.code}</div>
        </div>`).join('');

    return `
      <div class="panel slip">
        <div class="slip-tabs">
          <button class="slip-tab is-active">Listić ${n ? `<span class="cnt">${n}</span>` : ''}</button>
          <a class="slip-tab" href="listici.html" style="text-align:center">Moji listići</a>
        </div>
        <div class="slip-body" id="slipBody">${picks}</div>
        <div class="slip-foot">
          <div class="quick-stakes">
            ${[2, 5, 10, 20, 50].map(v => `<button data-stake="${v}">${v}€</button>`).join('')}
          </div>
          <div class="stake-row">
            <label for="stakeInput">Uplata</label>
            <input class="stake-input" id="stakeInput" type="number" min="0.5" step="0.5" value="${stake}">
          </div>
          <div class="sum-row"><span>Parova</span><strong>${n}</strong></div>
          <div class="sum-row"><span>Ukupni tečaj</span><strong>${num(odds)}</strong></div>
          <div class="sum-row"><span>Bruto dobitak</span><strong>${eur(gross)}</strong></div>
          <div class="sum-row"><span>Odbitak (10%)</span><strong>-${eur(tax)}</strong></div>
          <div class="sum-row total"><span>Mogući dobitak</span><strong>${eur(net)}</strong></div>
          <button class="btn btn-accent btn-block btn-lg" id="placeBet" style="margin-top:12px" ${n ? '' : 'disabled'}>
            Uplati listić
          </button>
          ${n ? `<button class="btn btn-ghost btn-block" id="clearSlip" style="margin-top:8px">Obriši listić</button>` : ''}
        </div>
      </div>`;
  }

  function render() {
    const host = $('#slipHost');
    if (host) {
      host.innerHTML = slipHTML();
      bindSlip(host);
    }
    // FAB counter on narrow screens
    const fab = $('#slipFab');
    if (fab) fab.innerHTML = `🎫 Listić <span>${slip.picks.length}</span>`;
    // repaint odd buttons
    $$('.odd[data-ev]').forEach(b => {
      b.classList.toggle('is-picked', slip.has(b.dataset.ev, b.dataset.mkt));
    });
  }

  function bindSlip(root) {
    $$('[data-rm]', root).forEach(b => b.onclick = () => slip.remove(+b.dataset.rm));
    $$('[data-stake]', root).forEach(b => b.onclick = () => slip.stake = +b.dataset.stake);
    const si = $('#stakeInput', root);
    if (si) si.onchange = () => slip.stake = Math.max(0.5, +si.value || 0.5);
    const clr = $('#clearSlip', root);
    if (clr) clr.onclick = () => slip.clear();
    const pb = $('#placeBet', root);
    if (pb) pb.onclick = placeBet;
  }

  function placeBet() {
    if (!slip.picks.length) return;
    if (!acct.logged) {
      modal('Prijava potrebna',
        `<p>Za uplatu listića potrebna je prijava na demo račun.</p>
         <p style="color:var(--txt-mute);font-size:13px">Demo račun ne koristi stvarni novac.</p>`,
        `<a class="btn btn-ghost" href="registracija.html">Registracija</a>
         <a class="btn btn-primary" href="prijava.html">Prijavi se</a>`);
      return;
    }
    const stake = slip.stake;
    if (!acct.debit(stake)) { toast('Nedovoljno sredstava na demo računu.', 'err'); return; }

    const ticket = {
      id: 'T' + Date.now().toString().slice(-8),
      at: new Date().toISOString(),
      stake,
      odds: +slip.totalOdds.toFixed(2),
      picks: slip.picks.slice(),
      status: 'open'
    };
    const list = store('tickets', []);
    list.unshift(ticket);
    save('tickets', list);
    slip.clear();
    modal('Listić uplaćen',
      `<p>Demo listić <strong>${ticket.id}</strong> je zaprimljen.</p>
       <div class="sum-row"><span>Uplata</span><strong>${eur(ticket.stake)}</strong></div>
       <div class="sum-row"><span>Ukupni tečaj</span><strong>${num(ticket.odds)}</strong></div>
       <div class="sum-row"><span>Parova</span><strong>${ticket.picks.length}</strong></div>`,
      `<a class="btn btn-ghost" href="listici.html">Moji listići</a>
       <button class="btn btn-primary" data-close>U redu</button>`);
    toast('Listić ' + ticket.id + ' uplaćen (demo).');
  }

  /* ============================================================
     SIDEBAR (sports tree)
     ============================================================ */
  function sidebarHTML(activeSport) {
    const rows = D.SPORTS.map(s => {
      const lgs = (D.LEAGUES[s.id] || []);
      const open = s.id === activeSport;
      return `
        <button class="sport-row${open ? ' is-open' : ''}" data-sport="${s.id}">
          <span class="sport-ico">${s.icon}</span>
          <span class="sport-name">${esc(s.name)}</span>
          <span class="sport-count">${D.SPORT_COUNTS[s.id] || 0}</span>
          <span class="sport-caret">▶</span>
        </button>
        <div class="league-list${open ? ' is-open' : ''}" data-lglist="${s.id}">
          ${lgs.map(l => `
            <a class="league-row" href="oklade.html?sport=${s.id}&league=${l.id}">
              <span>${l.flag} ${esc(l.name)}</span>
            </a>`).join('')}
        </div>`;
    }).join('');

    return `
      <div class="panel sidebar">
        <div class="panel-hd">
          <span>Sportovi</span>
          <a href="oklade.html?filter=live" style="color:var(--live);font-size:11px">UŽIVO ${D.LIVE_COUNT}</a>
        </div>
        <div class="side-search"><input type="search" id="sportFilter" placeholder="Filtriraj sport..."></div>
        <div class="side-list scroll-y" id="sideList">${rows}</div>
      </div>`;
  }

  function bindSidebar() {
    $$('.sport-row').forEach(b => {
      b.onclick = () => {
        const list = $(`[data-lglist="${b.dataset.sport}"]`);
        const open = b.classList.toggle('is-open');
        if (list) list.classList.toggle('is-open', open);
      };
    });
    const f = $('#sportFilter');
    if (f) f.oninput = () => {
      const q = f.value.trim().toLowerCase();
      $$('.sport-row').forEach(row => {
        const hit = row.querySelector('.sport-name').textContent.toLowerCase().includes(q);
        row.style.display = hit ? '' : 'none';
        const l = $(`[data-lglist="${row.dataset.sport}"]`);
        if (l && !hit) l.style.display = 'none';
        else if (l) l.style.display = '';
      });
    };
  }

  /* ============================================================
     GLOBAL SEARCH
     ============================================================ */
  function bindSearch() {
    const inp = $('#globalSearch');
    if (!inp) return;
    inp.onkeydown = e => {
      if (e.key !== 'Enter') return;
      const q = inp.value.trim();
      if (q) location.href = 'pretraga.html?q=' + encodeURIComponent(q);
    };
  }

  /* ============================================================
     BOOT
     ============================================================ */
  function boot() {
    const h = document.createElement('div');
    h.innerHTML = headerHTML();
    document.body.insertBefore(h, document.body.firstChild);

    const f = document.createElement('div');
    f.innerHTML = footerHTML();
    document.body.appendChild(f);

    renderBalance();

    $('#themeBtn').onclick = () => theme.toggle();
    $('#modalBack').onclick = e => { if (e.target.id === 'modalBack') closeModal(); };
    document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });

    const burger = $('#burger'), back = $('#drawerBack');
    if (burger) burger.onclick = () => {
      const col = $('.sidebar-col');
      if (col) { col.classList.toggle('is-open'); back.classList.toggle('is-open'); }
    };
    if (back) back.onclick = () => {
      const col = $('.sidebar-col');
      if (col) col.classList.remove('is-open');
      back.classList.remove('is-open');
    };

    bindSearch();
    bindSidebar();
    render();
  }

  /* expose shared API for page scripts */
  window.PSK = {
    $, $$, esc, eur, num, store, save, toast, modal, closeModal,
    acct, slip, theme, render, sidebarHTML, bindSidebar,
    qs: (k) => new URLSearchParams(location.search).get(k)
  };

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot);
  else boot();
})();
