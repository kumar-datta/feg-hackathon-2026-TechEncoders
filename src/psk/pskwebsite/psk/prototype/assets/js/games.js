/* ============================================================
   games.js — playable demo game engines used by the casino,
   live-casino, virtuals and lotto pages.
   All maths runs client-side against the demo wallet only.
   ============================================================ */
(function () {
  'use strict';

  const P = window.PSK;
  const D = window.PSK_DATA;
  const $ = P.$, $$ = P.$$, esc = P.esc, eur = P.eur, num = P.num;

  let stopFn = null;
  function stop() { if (stopFn) { stopFn(); stopFn = null; } }

  /* shared bet control strip */
  function betBar(id, extra) {
    return `
      <div class="g-bar">
        <div class="g-stat"><span>Ulog</span>
          <b><input id="${id}Bet" class="stake-input" style="width:96px;height:30px;font-size:14px"
                    type="number" min="0.10" step="0.10" value="1.00"></b></div>
        <div class="g-stat"><span>Stanje</span><b id="${id}Bal">${eur(P.acct.balance)}</b></div>
        <div class="g-stat"><span>Zadnji dobitak</span><b class="win" id="${id}Win">${eur(0)}</b></div>
        <div class="grow"></div>
        ${extra || ''}
      </div>`;
  }
  function readBet(id) {
    const v = Math.max(0.10, +$('#' + id + 'Bet').value || 0.10);
    return Math.round(v * 100) / 100;
  }
  function syncBar(id, win) {
    const b = $('#' + id + 'Bal'); if (b) b.textContent = eur(P.acct.balance);
    if (win !== undefined) { const w = $('#' + id + 'Win'); if (w) w.textContent = eur(win); }
  }
  function requireLogin() {
    if (P.acct.logged) return true;
    P.modal('Prijava potrebna',
      `<p>Za igranje demo igara prijavi se na demo račun.</p>
       <p style="color:var(--txt-mute);font-size:13px">Demo račun koristi izmišljena sredstva.</p>`,
      `<a class="btn btn-ghost" href="registracija.html">Registracija</a>
       <a class="btn btn-primary" href="prijava.html">Prijavi se</a>`);
    return false;
  }

  /* ============================================================
     1) SLOT — 5x3 reels, 5 paylines
     ============================================================ */
  const PAYLINES = [
    [1, 1, 1, 1, 1], [0, 0, 0, 0, 0], [2, 2, 2, 2, 2],
    [0, 1, 2, 1, 0], [2, 1, 0, 1, 2]
  ];
  const PAY = { 3: 4, 4: 12, 5: 45 };

  function slotGame(game) {
    const strip = [game.sym, '🍒', '🔔', '💎', '7️⃣', '🍇', '🍋', '⭐', '👑', '🍀'];
    const body = `
      <div class="g-stage">
        <div class="reels" id="slReels">
          ${[0,1,2,3,4].map(c => `<div class="reel" data-c="${c}">
            ${[0,1,2].map(r => `<div class="cell" data-c="${c}" data-r="${r}">${strip[(c + r) % strip.length]}</div>`).join('')}
          </div>`).join('')}
        </div>
        <div style="margin-top:10px;font-size:12px;color:var(--txt-mute)" id="slMsg">
          5 linija · 3 u nizu = 4×, 4 = 12×, 5 = 45× ulog po liniji
        </div>
        ${betBar('sl', `<button class="btn btn-accent btn-lg" id="slSpin">ZAVRTI</button>`)}
      </div>
      <p style="font-size:12px;color:var(--txt-mute);margin-top:12px">
        RTP ${game.rtp}% · Volatilnost: ${esc(game.volatility || 'Srednja')} · ${esc(game.provider)}
      </p>`;

    P.modal(`${game.sym} ${esc(game.title)}`, body, null, true);

    let busy = false;
    $('#slSpin').onclick = () => {
      if (busy || !requireLogin()) return;
      const bet = readBet('sl');
      if (!P.acct.debit(bet)) { P.toast('Nedovoljno sredstava.', 'err'); return; }
      busy = true; syncBar('sl');
      $$('#slReels .reel').forEach(r => r.classList.add('spinning'));
      $$('#slReels .cell').forEach(c => c.classList.remove('hit'));
      $('#slMsg').textContent = 'Vrtim...';

      const grid = [];
      for (let c = 0; c < 5; c++) grid.push([0,1,2].map(() => strip[Math.floor(Math.random() * strip.length)]));

      const timers = [];
      for (let c = 0; c < 5; c++) {
        timers.push(setTimeout(() => {
          const reel = $(`#slReels .reel[data-c="${c}"]`);
          reel.classList.remove('spinning');
          [0,1,2].forEach(r => { $(`#slReels .cell[data-c="${c}"][data-r="${r}"]`).textContent = grid[c][r]; });
          if (c === 4) settle();
        }, 450 + c * 260));
      }

      function settle() {
        let win = 0;
        PAYLINES.forEach(line => {
          const first = grid[0][line[0]];
          let n = 1;
          while (n < 5 && grid[n][line[n]] === first) n++;
          if (n >= 3) {
            win += bet / 5 * PAY[n];
            for (let c = 0; c < n; c++) $(`#slReels .cell[data-c="${c}"][data-r="${line[c]}"]`).classList.add('hit');
          }
        });
        if (win > 0) { P.acct.credit(win); $('#slMsg').innerHTML = `<span style="color:var(--win);font-weight:700">Dobitak ${eur(win)}!</span>`; }
        else $('#slMsg').textContent = 'Nema dobitne kombinacije. Pokušaj ponovno.';
        syncBar('sl', win);
        busy = false;
      }
      stopFn = () => timers.forEach(clearTimeout);
    };
  }

  /* ============================================================
     2) ROULETTE — European single-zero
     ============================================================ */
  const WHEEL_ORDER = [0,32,15,19,4,21,2,25,17,34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14,31,9,22,18,29,7,28,12,35,3,26];
  const REDS = new Set([1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36]);
  const colorOf = n => n === 0 ? 'green' : (REDS.has(n) ? 'red' : 'black');

  function rouletteGame(game) {
    const seg = 360 / WHEEL_ORDER.length;
    const grad = WHEEL_ORDER.map((n, i) => {
      const c = colorOf(n) === 'green' ? '#12643a' : colorOf(n) === 'red' ? '#8b1717' : '#171b22';
      return `${c} ${i * seg}deg ${(i + 1) * seg}deg`;
    }).join(',');

    const outside = [
      ['red',  'CRVENO', 2, 'red'], ['black','CRNO', 2, 'blk'],
      ['odd',  'NEPAR', 2, ''],     ['even', 'PAR', 2, ''],
      ['low',  '1-18', 2, ''],      ['high', '19-36', 2, ''],
      ['d1',   '1. tucet', 3, ''],  ['d2', '2. tucet', 3, ''], ['d3', '3. tucet', 3, ''],
      ['zero', 'ZERO (0)', 36, '']
    ];

    const body = `
      <div class="g-stage">
        <div class="wheel-wrap">
          <div class="wheel-ptr"></div>
          <div class="wheel" id="rtWheel" style="background:conic-gradient(${grad})">
            <div class="wheel-center" id="rtCenter">—</div>
          </div>
        </div>
        <div style="margin-top:12px;font-size:12px;color:var(--txt-mute)" id="rtMsg">Odaberi jednu ili više oklada, zatim zavrti.</div>
        <div class="rt-board" id="rtBoard">
          ${outside.map(o => `<button class="rt-bet ${o[3]}" data-bet="${o[0]}" data-pay="${o[2]}">${o[1]}</button>`).join('')}
        </div>
        <div class="rt-board" style="grid-template-columns:repeat(12,1fr);margin-top:6px">
          ${Array.from({length: 36}, (_, i) => i + 1).map(n =>
            `<button class="rt-bet ${colorOf(n) === 'red' ? 'red' : 'blk'}" data-bet="n${n}" data-pay="36" style="font-size:10px">${n}</button>`
          ).join('')}
        </div>
        ${betBar('rt', `<button class="btn btn-accent btn-lg" id="rtSpin">ZAVRTI</button>`)}
      </div>
      <p style="font-size:12px;color:var(--txt-mute);margin-top:12px">Europski rulet, jedna nula · RTP 97,30% · ${esc(game.provider)}</p>`;

    P.modal(`${game.sym} ${esc(game.title)}`, body, null, true);

    const bets = new Set();
    let deg = 0, busy = false;
    $$('#rtBoard .rt-bet, .rt-board .rt-bet').forEach(b => {
      b.onclick = () => {
        if (busy) return;
        const k = b.dataset.bet;
        if (bets.has(k)) { bets.delete(k); b.classList.remove('on'); }
        else { bets.add(k); b.classList.add('on'); }
        $('#rtMsg').textContent = bets.size ? `Odabrano oklada: ${bets.size}` : 'Odaberi jednu ili više oklada.';
      };
    });

    $('#rtSpin').onclick = () => {
      if (busy || !requireLogin()) return;
      if (!bets.size) { P.toast('Prvo odaberi okladu.', 'err'); return; }
      const unit = readBet('rt');
      const total = unit * bets.size;
      if (!P.acct.debit(total)) { P.toast('Nedovoljno sredstava.', 'err'); return; }
      busy = true; syncBar('rt');

      const idx = Math.floor(Math.random() * WHEEL_ORDER.length);
      const n = WHEEL_ORDER[idx];
      deg += 360 * 5 + (360 - idx * seg - seg / 2);
      const w = $('#rtWheel');
      w.style.transform = `rotate(${deg}deg)`;
      $('#rtMsg').textContent = 'Kuglica se vrti...';

      const t = setTimeout(() => {
        const col = colorOf(n);
        $('#rtCenter').textContent = n;
        $('#rtCenter').style.color = col === 'red' ? '#ff6b6b' : col === 'green' ? '#3ddc84' : 'var(--txt)';

        let win = 0;
        bets.forEach(k => {
          let hit = false, pay = 0;
          if (k.startsWith('n')) { hit = (+k.slice(1) === n); pay = 36; }
          else if (k === 'red')  { hit = col === 'red';  pay = 2; }
          else if (k === 'black'){ hit = col === 'black';pay = 2; }
          else if (k === 'odd')  { hit = n !== 0 && n % 2 === 1; pay = 2; }
          else if (k === 'even') { hit = n !== 0 && n % 2 === 0; pay = 2; }
          else if (k === 'low')  { hit = n >= 1 && n <= 18; pay = 2; }
          else if (k === 'high') { hit = n >= 19; pay = 2; }
          else if (k === 'd1')   { hit = n >= 1 && n <= 12; pay = 3; }
          else if (k === 'd2')   { hit = n >= 13 && n <= 24; pay = 3; }
          else if (k === 'd3')   { hit = n >= 25; pay = 3; }
          else if (k === 'zero') { hit = n === 0; pay = 36; }
          if (hit) win += unit * pay;
        });
        if (win > 0) { P.acct.credit(win); $('#rtMsg').innerHTML = `Broj <strong>${n}</strong> (${col}) — <span style="color:var(--win);font-weight:700">dobitak ${eur(win)}</span>`; }
        else $('#rtMsg').innerHTML = `Broj <strong>${n}</strong> (${col}) — nema dobitka.`;
        syncBar('rt', win);
        busy = false;
      }, 4600);
      stopFn = () => clearTimeout(t);
    };
  }

  /* ============================================================
     3) BLACKJACK
     ============================================================ */
  const SUITS = [['♠', 0], ['♥', 1], ['♦', 1], ['♣', 0]];
  const RANKS = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];
  const drawCard = () => {
    const s = SUITS[Math.floor(Math.random() * 4)];
    return { r: RANKS[Math.floor(Math.random() * 13)], s: s[0], red: s[1] };
  };
  const handValue = h => {
    let t = 0, aces = 0;
    h.forEach(c => {
      if (c.r === 'A') { t += 11; aces++; }
      else if (['J','Q','K'].includes(c.r)) t += 10;
      else t += +c.r;
    });
    while (t > 21 && aces) { t -= 10; aces--; }
    return t;
  };
  const cardHTML = (c, hidden) => hidden
    ? `<div class="pcard back"></div>`
    : `<div class="pcard${c.red ? ' red' : ''}"><span>${c.r}${c.s}</span><span class="b">${c.r}${c.s}</span></div>`;

  function blackjackGame(game) {
    const body = `
      <div class="g-stage">
        <div style="font-size:12px;color:var(--txt-mute);margin-bottom:6px">Djelitelj <span id="bjDv"></span></div>
        <div class="cards-row" id="bjDealer"></div>
        <div style="font-size:12px;color:var(--txt-mute);margin:14px 0 6px">Igrač <span id="bjPv"></span></div>
        <div class="cards-row" id="bjPlayer"></div>
        <div style="margin-top:12px;font-weight:700;min-height:22px" id="bjMsg">Postavi ulog i podijeli karte.</div>
        ${betBar('bj', `
          <button class="btn btn-primary" id="bjDeal">Podijeli</button>
          <button class="btn btn-ghost" id="bjHit" disabled>Još kartu</button>
          <button class="btn btn-ghost" id="bjStand" disabled>Stani</button>`)}
      </div>
      <p style="font-size:12px;color:var(--txt-mute);margin-top:12px">Blackjack plaća 3:2 · djelitelj vuče do 17 · ${esc(game.provider)}</p>`;

    P.modal(`${game.sym} ${esc(game.title)}`, body, null, true);

    let ph = [], dh = [], bet = 0, live = false;
    const paint = (revealAll) => {
      $('#bjPlayer').innerHTML = ph.map(c => cardHTML(c)).join('');
      $('#bjDealer').innerHTML = dh.map((c, i) => cardHTML(c, !revealAll && i === 1)).join('');
      $('#bjPv').textContent = ph.length ? '(' + handValue(ph) + ')' : '';
      $('#bjDv').textContent = dh.length ? (revealAll ? '(' + handValue(dh) + ')' : '(?)') : '';
    };
    const setBtns = (on) => {
      $('#bjHit').disabled = !on; $('#bjStand').disabled = !on; $('#bjDeal').disabled = on;
    };
    const finish = (msg, win) => {
      live = false; setBtns(false); paint(true);
      if (win > 0) P.acct.credit(win);
      $('#bjMsg').innerHTML = win > 0
        ? `<span style="color:var(--win)">${msg} — ${eur(win)}</span>`
        : `<span style="color:var(--live)">${msg}</span>`;
      syncBar('bj', win);
    };

    $('#bjDeal').onclick = () => {
      if (!requireLogin()) return;
      bet = readBet('bj');
      if (!P.acct.debit(bet)) { P.toast('Nedovoljno sredstava.', 'err'); return; }
      syncBar('bj');
      ph = [drawCard(), drawCard()]; dh = [drawCard(), drawCard()];
      live = true; setBtns(true); paint(false);
      $('#bjMsg').textContent = 'Tvoj potez.';
      if (handValue(ph) === 21) finish('Blackjack!', bet * 2.5);
    };
    $('#bjHit').onclick = () => {
      if (!live) return;
      ph.push(drawCard()); paint(false);
      const v = handValue(ph);
      if (v > 21) finish('Prekoračenje (' + v + ').', 0);
      else if (v === 21) $('#bjStand').click();
    };
    $('#bjStand').onclick = () => {
      if (!live) return;
      while (handValue(dh) < 17) dh.push(drawCard());
      const p = handValue(ph), d = handValue(dh);
      if (d > 21) finish('Djelitelj je prekoračio (' + d + ').', bet * 2);
      else if (p > d) finish(`Pobjeda ${p}:${d}.`, bet * 2);
      else if (p === d) finish(`Neriješeno ${p}:${d} — ulog vraćen.`, bet);
      else finish(`Djelitelj pobjeđuje ${d}:${p}.`, 0);
    };
  }

  /* ============================================================
     4) CRASH / AVIATOR
     ============================================================ */
  function crashGame(game) {
    const body = `
      <div class="g-stage">
        <div class="crash-box">
          <canvas id="crCanvas" width="600" height="190" style="width:100%;height:100%"></canvas>
          <div class="crash-mult" id="crMult">1.00×</div>
        </div>
        <div style="margin-top:10px;font-size:12px;color:var(--txt-mute)" id="crMsg">
          Postavi ulog, pokreni rundu i naplati prije pada.
        </div>
        <div style="display:flex;gap:6px;flex-wrap:wrap;justify-content:center;margin-top:10px" id="crHist"></div>
        ${betBar('cr', `
          <button class="btn btn-accent btn-lg" id="crStart">Pokreni</button>
          <button class="btn btn-primary btn-lg" id="crCash" disabled>Naplati</button>`)}
      </div>
      <p style="font-size:12px;color:var(--txt-mute);margin-top:12px">RTP 97% · maksimalni množitelj 100× · ${esc(game.provider)}</p>`;

    P.modal(`${game.sym} ${esc(game.title)}`, body, null, true);

    const cv = $('#crCanvas'), ctx = cv.getContext('2d');
    const hist = [];
    let raf = null, running = false, mult = 1, bust = 2, t0 = 0, bet = 0;

    function draw(m) {
      ctx.clearRect(0, 0, cv.width, cv.height);
      ctx.strokeStyle = 'rgba(255,255,255,.06)';
      for (let i = 1; i < 5; i++) {
        ctx.beginPath(); ctx.moveTo(0, i * 38); ctx.lineTo(cv.width, i * 38); ctx.stroke();
      }
      const prog = Math.min(1, (m - 1) / 9);
      ctx.beginPath();
      ctx.moveTo(0, cv.height);
      for (let x = 0; x <= cv.width * prog; x += 6) {
        const p = x / cv.width;
        ctx.lineTo(x, cv.height - Math.pow(p, 1.6) * cv.height * 1.5);
      }
      ctx.strokeStyle = '#ffcc00'; ctx.lineWidth = 3; ctx.stroke();
      ctx.lineTo(cv.width * prog, cv.height); ctx.lineTo(0, cv.height); ctx.closePath();
      ctx.fillStyle = 'rgba(255,204,0,.13)'; ctx.fill();
    }

    function tick(ts) {
      if (!t0) t0 = ts;
      const el = (ts - t0) / 1000;
      mult = +(Math.pow(1.0718, el * 8)).toFixed(2);
      const el2 = $('#crMult');
      if (mult >= bust) {
        el2.textContent = bust.toFixed(2) + '× 💥';
        el2.className = 'crash-mult bust';
        $('#crMsg').innerHTML = `<span style="color:var(--live)">Pad na ${bust.toFixed(2)}× — ulog izgubljen.</span>`;
        endRound(bust);
        return;
      }
      el2.textContent = mult.toFixed(2) + '×';
      draw(mult);
      raf = requestAnimationFrame(tick);
    }

    function endRound(at) {
      running = false;
      cancelAnimationFrame(raf); raf = null; t0 = 0;
      $('#crStart').disabled = false; $('#crCash').disabled = true;
      hist.unshift(at);
      if (hist.length > 12) hist.pop();
      $('#crHist').innerHTML = hist.map(h =>
        `<span class="pay-chip" style="color:${h < 2 ? 'var(--live)' : 'var(--win)'}">${h.toFixed(2)}×</span>`
      ).join('');
    }

    $('#crStart').onclick = () => {
      if (running || !requireLogin()) return;
      bet = readBet('cr');
      if (!P.acct.debit(bet)) { P.toast('Nedovoljno sredstava.', 'err'); return; }
      syncBar('cr');
      // 97% RTP crash curve
      const r = Math.random();
      bust = Math.max(1.00, +((0.97 / (1 - r)).toFixed(2)));
      if (bust > 100) bust = 100;
      running = true; mult = 1;
      $('#crMult').className = 'crash-mult';
      $('#crMsg').textContent = 'Runda je u tijeku...';
      $('#crStart').disabled = true; $('#crCash').disabled = false;
      raf = requestAnimationFrame(tick);
    };

    $('#crCash').onclick = () => {
      if (!running) return;
      const win = +(bet * mult).toFixed(2);
      P.acct.credit(win);
      $('#crMult').className = 'crash-mult cashed';
      $('#crMsg').innerHTML = `<span style="color:var(--win)">Naplaćeno na ${mult.toFixed(2)}× — ${eur(win)}</span>`;
      syncBar('cr', win);
      endRound(mult);
    };

    draw(1);
    stopFn = () => { if (raf) cancelAnimationFrame(raf); };
  }

  /* ============================================================
     5) MINES
     ============================================================ */
  function minesGame(game) {
    const N = 25, BOMBS = 3;
    const body = `
      <div class="g-stage">
        <div style="display:grid;grid-template-columns:repeat(5,1fr);gap:6px;max-width:320px;margin:0 auto" id="mnGrid"></div>
        <div style="margin-top:12px;font-weight:700;min-height:22px" id="mnMsg">Pokreni rundu i otkrivaj polja.</div>
        ${betBar('mn', `
          <button class="btn btn-accent" id="mnStart">Nova runda</button>
          <button class="btn btn-primary" id="mnCash" disabled>Naplati</button>`)}
      </div>
      <p style="font-size:12px;color:var(--txt-mute);margin-top:12px">25 polja, 3 mine · množitelj raste sa svakim sigurnim poljem · ${esc(game.provider)}</p>`;

    P.modal(`${game.sym} ${esc(game.title)}`, body, null, true);

    let bombs = new Set(), opened = 0, live = false, bet = 0;
    const grid = $('#mnGrid');

    function multiplier(k) {
      let m = 1;
      for (let i = 0; i < k; i++) m *= (N - BOMBS - i) === 0 ? 1 : (N - i) / (N - BOMBS - i);
      return +(m * 0.97).toFixed(2);
    }
    function paintGrid(reveal) {
      grid.innerHTML = Array.from({ length: N }, (_, i) => {
        const isB = bombs.has(i);
        return `<button class="rt-bet" data-i="${i}" style="height:52px;font-size:18px">${
          reveal && isB ? '💣' : ''
        }</button>`;
      }).join('');
      $$('#mnGrid .rt-bet').forEach(b => b.onclick = () => open(+b.dataset.i, b));
    }
    function open(i, btn) {
      if (!live || btn.dataset.done) return;
      btn.dataset.done = '1';
      if (bombs.has(i)) {
        btn.textContent = '💣'; btn.style.background = 'var(--live)';
        live = false; $('#mnCash').disabled = true; $('#mnStart').disabled = false;
        $('#mnMsg').innerHTML = '<span style="color:var(--live)">Mina! Runda je gotova.</span>';
        $$('#mnGrid .rt-bet').forEach(b => { if (bombs.has(+b.dataset.i)) b.textContent = '💣'; });
        syncBar('mn', 0);
        return;
      }
      opened++;
      btn.textContent = '💎'; btn.style.background = 'rgba(33,192,122,.25)';
      $('#mnMsg').textContent = `Sigurnih polja: ${opened} · množitelj ${multiplier(opened)}×`;
    }

    $('#mnStart').onclick = () => {
      if (!requireLogin()) return;
      bet = readBet('mn');
      if (!P.acct.debit(bet)) { P.toast('Nedovoljno sredstava.', 'err'); return; }
      syncBar('mn');
      bombs = new Set();
      while (bombs.size < BOMBS) bombs.add(Math.floor(Math.random() * N));
      opened = 0; live = true;
      paintGrid(false);
      $('#mnCash').disabled = false; $('#mnStart').disabled = true;
      $('#mnMsg').textContent = 'Otkrivaj polja i naplati prije mine.';
    };
    $('#mnCash').onclick = () => {
      if (!live || opened === 0) { P.toast('Otkrij barem jedno polje.', 'err'); return; }
      const win = +(bet * multiplier(opened)).toFixed(2);
      P.acct.credit(win);
      live = false; $('#mnCash').disabled = true; $('#mnStart').disabled = false;
      $('#mnMsg').innerHTML = `<span style="color:var(--win)">Naplaćeno ${multiplier(opened)}× — ${eur(win)}</span>`;
      syncBar('mn', win);
    };
    paintGrid(false);
  }

  /* ============================================================
     6) DICE / SIC BO
     ============================================================ */
  function diceGame(game) {
    const body = `
      <div class="g-stage">
        <div style="font-size:56px;letter-spacing:10px" id="dcFace">🎲🎲</div>
        <div style="margin-top:8px;font-weight:700;min-height:22px" id="dcMsg">Odaberi okladu i baci kocke.</div>
        <div class="rt-board" style="grid-template-columns:repeat(3,1fr);max-width:420px;margin:14px auto 0">
          <button class="rt-bet on" data-bet="under" data-pay="2">Manje (2-6)</button>
          <button class="rt-bet" data-bet="seven" data-pay="5">Točno 7</button>
          <button class="rt-bet" data-bet="over"  data-pay="2">Više (8-12)</button>
        </div>
        ${betBar('dc', `<button class="btn btn-accent btn-lg" id="dcRoll">Baci</button>`)}
      </div>
      <p style="font-size:12px;color:var(--txt-mute);margin-top:12px">Dvije kocke · "Točno 7" plaća 5× · ${esc(game.provider)}</p>`;

    P.modal(`${game.sym} ${esc(game.title)}`, body, null, true);

    let sel = 'under', pay = 2;
    $$('.rt-bet[data-bet]').forEach(b => b.onclick = () => {
      $$('.rt-bet[data-bet]').forEach(x => x.classList.remove('on'));
      b.classList.add('on'); sel = b.dataset.bet; pay = +b.dataset.pay;
    });

    const FACES = ['⚀','⚁','⚂','⚃','⚄','⚅'];
    $('#dcRoll').onclick = () => {
      if (!requireLogin()) return;
      const bet = readBet('dc');
      if (!P.acct.debit(bet)) { P.toast('Nedovoljno sredstava.', 'err'); return; }
      syncBar('dc');
      let n = 0;
      const iv = setInterval(() => {
        $('#dcFace').textContent = FACES[Math.floor(Math.random()*6)] + FACES[Math.floor(Math.random()*6)];
        if (++n > 12) {
          clearInterval(iv);
          const a = 1 + Math.floor(Math.random()*6), b = 1 + Math.floor(Math.random()*6);
          $('#dcFace').textContent = FACES[a-1] + FACES[b-1];
          const s = a + b;
          const hit = sel === 'seven' ? s === 7 : sel === 'under' ? s < 7 : s > 7;
          const win = hit ? bet * pay : 0;
          if (win) P.acct.credit(win);
          $('#dcMsg').innerHTML = hit
            ? `<span style="color:var(--win)">Zbroj ${s} — dobitak ${eur(win)}</span>`
            : `<span style="color:var(--live)">Zbroj ${s} — nema dobitka.</span>`;
          syncBar('dc', win);
        }
      }, 70);
      stopFn = () => clearInterval(iv);
    };
  }

  /* ============================================================
     7) MONEY WHEEL (game show)
     ============================================================ */
  function wheelGame(game) {
    const SEGS = [1,2,5,1,10,1,2,20,1,5,2,40,1,2,5,1,10,2,1,5];
    const COLORS = { 1:'#1d4ed8', 2:'#0f766e', 5:'#a16207', 10:'#7c2d12', 20:'#701a75', 40:'#991b1b' };
    const seg = 360 / SEGS.length;
    const grad = SEGS.map((v, i) => `${COLORS[v]} ${i*seg}deg ${(i+1)*seg}deg`).join(',');

    const body = `
      <div class="g-stage">
        <div class="wheel-wrap">
          <div class="wheel-ptr"></div>
          <div class="wheel" id="whWheel" style="background:conic-gradient(${grad})">
            <div class="wheel-center" id="whCenter">—</div>
          </div>
        </div>
        <div style="margin-top:12px;font-weight:700;min-height:22px" id="whMsg">Odaberi polje i zavrti kolo.</div>
        <div class="rt-board" style="grid-template-columns:repeat(6,1fr);max-width:460px;margin:12px auto 0">
          ${[1,2,5,10,20,40].map((v,i) => `<button class="rt-bet${i===0?' on':''}" data-w="${v}">${v}×</button>`).join('')}
        </div>
        ${betBar('wh', `<button class="btn btn-accent btn-lg" id="whSpin">ZAVRTI</button>`)}
      </div>
      <p style="font-size:12px;color:var(--txt-mute);margin-top:12px">Kolo sreće, 20 polja · ${esc(game.provider)}</p>`;

    P.modal(`${game.sym} ${esc(game.title)}`, body, null, true);

    let sel = 1, deg = 0, busy = false;
    $$('.rt-bet[data-w]').forEach(b => b.onclick = () => {
      if (busy) return;
      $$('.rt-bet[data-w]').forEach(x => x.classList.remove('on'));
      b.classList.add('on'); sel = +b.dataset.w;
    });

    $('#whSpin').onclick = () => {
      if (busy || !requireLogin()) return;
      const bet = readBet('wh');
      if (!P.acct.debit(bet)) { P.toast('Nedovoljno sredstava.', 'err'); return; }
      busy = true; syncBar('wh');
      const idx = Math.floor(Math.random() * SEGS.length);
      const val = SEGS[idx];
      deg += 360*6 + (360 - idx*seg - seg/2);
      $('#whWheel').style.transform = `rotate(${deg}deg)`;
      $('#whMsg').textContent = 'Kolo se vrti...';
      const t = setTimeout(() => {
        $('#whCenter').textContent = val + '×';
        const win = val === sel ? bet * val : 0;
        if (win) P.acct.credit(win);
        $('#whMsg').innerHTML = win
          ? `<span style="color:var(--win)">Palo je ${val}× — dobitak ${eur(win)}</span>`
          : `<span style="color:var(--live)">Palo je ${val}×, tvoj odabir ${sel}×.</span>`;
        syncBar('wh', win);
        busy = false;
      }, 4600);
      stopFn = () => clearTimeout(t);
    };
  }

  /* ============================================================
     8) BACCARAT
     ============================================================ */
  function baccaratGame(game) {
    const val = c => c.r === 'A' ? 1 : ['10','J','Q','K'].includes(c.r) ? 0 : +c.r;
    const total = h => h.reduce((a, c) => a + val(c), 0) % 10;

    const body = `
      <div class="g-stage">
        <div style="display:flex;gap:26px;justify-content:center;flex-wrap:wrap">
          <div><div style="font-size:12px;color:var(--txt-mute);margin-bottom:6px">Igrač <span id="bcP"></span></div>
               <div class="cards-row" id="bcPlayer"></div></div>
          <div><div style="font-size:12px;color:var(--txt-mute);margin-bottom:6px">Banka <span id="bcB"></span></div>
               <div class="cards-row" id="bcBank"></div></div>
        </div>
        <div style="margin-top:12px;font-weight:700;min-height:22px" id="bcMsg">Odaberi stranu i podijeli.</div>
        <div class="rt-board" style="grid-template-columns:repeat(3,1fr);max-width:420px;margin:12px auto 0">
          <button class="rt-bet on" data-b="player" data-pay="2">Igrač (2×)</button>
          <button class="rt-bet" data-b="bank" data-pay="1.95">Banka (1,95×)</button>
          <button class="rt-bet" data-b="tie"  data-pay="9">Neriješeno (9×)</button>
        </div>
        ${betBar('bc', `<button class="btn btn-accent btn-lg" id="bcDeal">Podijeli</button>`)}
      </div>
      <p style="font-size:12px;color:var(--txt-mute);margin-top:12px">Punto Banco pravila (pojednostavljeno) · ${esc(game.provider)}</p>`;

    P.modal(`${game.sym} ${esc(game.title)}`, body, null, true);

    let sel = 'player', pay = 2;
    $$('.rt-bet[data-b]').forEach(b => b.onclick = () => {
      $$('.rt-bet[data-b]').forEach(x => x.classList.remove('on'));
      b.classList.add('on'); sel = b.dataset.b; pay = +b.dataset.pay;
    });

    $('#bcDeal').onclick = () => {
      if (!requireLogin()) return;
      const bet = readBet('bc');
      if (!P.acct.debit(bet)) { P.toast('Nedovoljno sredstava.', 'err'); return; }
      syncBar('bc');
      const ph = [drawCard(), drawCard()], bh = [drawCard(), drawCard()];
      if (total(ph) <= 5) ph.push(drawCard());
      if (total(bh) <= 5) bh.push(drawCard());
      $('#bcPlayer').innerHTML = ph.map(c => cardHTML(c)).join('');
      $('#bcBank').innerHTML   = bh.map(c => cardHTML(c)).join('');
      const p = total(ph), b = total(bh);
      $('#bcP').textContent = '(' + p + ')';
      $('#bcB').textContent = '(' + b + ')';
      const res = p > b ? 'player' : b > p ? 'bank' : 'tie';
      const win = res === sel ? +(bet * pay).toFixed(2) : 0;
      if (win) P.acct.credit(win);
      const label = { player: 'Igrač', bank: 'Banka', tie: 'Neriješeno' }[res];
      $('#bcMsg').innerHTML = win
        ? `<span style="color:var(--win)">${label} ${p}:${b} — dobitak ${eur(win)}</span>`
        : `<span style="color:var(--live)">${label} ${p}:${b} — nema dobitka.</span>`;
      syncBar('bc', win);
    };
  }

  /* ============================================================
     9) LOTTERY DRAW
     ============================================================ */
  function lottoGame(lot) {
    const body = `
      <div class="g-stage">
        <p style="font-size:13px;color:var(--txt-dim)">Odaberi ${lot.pick} brojeva od ${lot.max}. Izvlačenje: ${esc(lot.draw)}.</p>
        <div class="ball-grid" id="ltGrid" style="margin:14px 0">
          ${Array.from({length: lot.max}, (_, i) =>
            `<button class="ball" data-n="${i+1}">${i+1}</button>`).join('')}
        </div>
        <div style="font-weight:700;min-height:22px" id="ltMsg">Odabrano 0 / ${lot.pick}</div>
        ${betBar('lt', `
          <button class="btn btn-ghost" id="ltRandom">Slučajno</button>
          <button class="btn btn-accent btn-lg" id="ltDraw">Izvuci</button>`)}
      </div>
      <p style="font-size:12px;color:var(--txt-mute);margin-top:12px">
        Jackpot u prikazu: ${eur(lot.jackpot)} · cijena kombinacije ${eur(lot.price)}
      </p>`;

    P.modal('🎱 ' + esc(lot.name), body, null, true);

    const sel = new Set();
    const upd = () => { $('#ltMsg').textContent = `Odabrano ${sel.size} / ${lot.pick}`; };
    const bindBalls = () => $$('#ltGrid .ball').forEach(b => b.onclick = () => {
      const n = +b.dataset.n;
      if (sel.has(n)) { sel.delete(n); b.classList.remove('on'); }
      else if (sel.size < lot.pick) { sel.add(n); b.classList.add('on'); }
      upd();
    });
    bindBalls();

    $('#ltRandom').onclick = () => {
      sel.clear();
      $$('#ltGrid .ball').forEach(b => b.className = 'ball');
      while (sel.size < lot.pick) sel.add(1 + Math.floor(Math.random() * lot.max));
      sel.forEach(n => $(`#ltGrid .ball[data-n="${n}"]`).classList.add('on'));
      upd();
    };

    $('#ltDraw').onclick = () => {
      if (!requireLogin()) return;
      if (sel.size !== lot.pick) { P.toast(`Odaberi točno ${lot.pick} brojeva.`, 'err'); return; }
      const bet = readBet('lt');
      if (!P.acct.debit(bet)) { P.toast('Nedovoljno sredstava.', 'err'); return; }
      syncBar('lt');
      const drawn = new Set();
      while (drawn.size < lot.pick) drawn.add(1 + Math.floor(Math.random() * lot.max));
      const arr = [...drawn];
      $('#ltMsg').textContent = 'Izvlačenje...';
      arr.forEach((n, i) => setTimeout(() => {
        const b = $(`#ltGrid .ball[data-n="${n}"]`);
        if (b) b.classList.add('drawn');
        if (i === arr.length - 1) {
          const hits = arr.filter(x => sel.has(x)).length;
          const table = { 3: 2, 4: 8, 5: 40, 6: 400, 7: 5000, 10: 20000 };
          const win = hits >= 3 ? bet * (table[hits] || 2) : 0;
          if (win) P.acct.credit(win);
          $('#ltMsg').innerHTML = win
            ? `<span style="color:var(--win)">Pogodaka: ${hits} — dobitak ${eur(win)}</span>`
            : `<span style="color:var(--live)">Pogodaka: ${hits} — nema dobitka.</span>`;
          syncBar('lt', win);
        }
      }, 420 * (i + 1)));
    };
  }

  /* ============================================================
     DISPATCH
     ============================================================ */
  const ENGINES = {
    slot: slotGame, roulette: rouletteGame, blackjack: blackjackGame,
    crash: crashGame, mines: minesGame, dice: diceGame,
    wheel: wheelGame, baccarat: baccaratGame, poker: baccaratGame
  };

  function launch(game) {
    stop();
    (ENGINES[game.engine] || slotGame)(game);
  }

  window.PSK_GAME = { launch, lotto: lottoGame, stop };
})();
