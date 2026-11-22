// Touch-Knöpfe für Handy und Tablet. Sie liegen im schwarzen Rand neben dem Spiel
// und schicken dem Spiel ganz normale Tastendrücke. Godot merkt keinen Unterschied.

//fallback für vibration
if (typeof navigator !== 'undefined' && typeof navigator.vibrate !== 'function') {
    navigator.vibrate = function() {
        // tue nichts
        return false;
    };
}

// Mit Maus (PC) gibt es keine Knöpfe. "coarse" heißt: ein grober Zeiger, also ein Finger.
if (matchMedia('(pointer: coarse)').matches) {
  document.addEventListener('DOMContentLoaded', touchKnoepfe);
}

// Was Godot mit jeder Taste bekommt: code ist die Taste, key das Zeichen darauf
const ZEICHEN = { ArrowUp: 'ArrowUp', ArrowDown: 'ArrowDown', ArrowLeft: 'ArrowLeft',
                  ArrowRight: 'ArrowRight', Space: ' ', Escape: 'Escape' };

function taste(code, gedrueckt) {
  const art = gedrueckt ? 'keydown' : 'keyup';
  document.getElementById('canvas').dispatchEvent(
    new KeyboardEvent(art, { code: code, key: ZEICHEN[code], bubbles: true, cancelable: true }));
}

function touchKnoepfe() {
  const ebene = document.createElement('div');
  ebene.id = 'touch';
  ebene.innerHTML = `
    <div class="kreuz">
      <span data-code="ArrowUp">▲</span><span data-code="ArrowLeft">◀</span>
      <span data-code="ArrowRight">▶</span><span data-code="ArrowDown">▼</span>
    </div>
    <div class="knoepfe">
      <button class="start" data-code="Escape">START</button>
      <button class="a" data-code="Space">A</button>
    </div>`;
  document.body.appendChild(ebene);
  ebene.addEventListener('contextmenu', (e) => e.preventDefault());   // kein Menü bei langem Drücken

  // A und Start: drücken und loslassen, mehr nicht
  for (const knopf of ebene.querySelectorAll('button')) {
    knopf.addEventListener('pointerdown', (e) => {
      e.preventDefault();
      knopf.classList.add('an');
      taste(knopf.dataset.code, true);
      if (knopf.dataset.code == "Space") navigator.vibrate(15);
    });
    for (const ende of ['pointerup', 'pointercancel', 'pointerleave']) {
      knopf.addEventListener(ende, () => {
        if (!knopf.classList.contains('an')) return;
        knopf.classList.remove('an');
        taste(knopf.dataset.code, false);
      });
    }
  }

  // Das Steuerkreuz ist eine Fläche: Wohin der Finger von der Mitte aus zeigt, so wird gelaufen.
  // Schräg drückt zwei Tasten auf einmal, wie auf der Tastatur. Der Finger darf rutschen.
  const kreuz = ebene.querySelector('.kreuz');
  let gedrueckt = new Set();

  function richtungen(e) {
    const r = kreuz.getBoundingClientRect();
    const x = (e.clientX - r.left) / r.width - 0.5;   // -0.5 links bis 0.5 rechts
    const y = (e.clientY - r.top) / r.height - 0.5;   // -0.5 oben bis 0.5 unten
    const neu = new Set();
    if (Math.hypot(x, y) < 0.1) return neu;           // genau in der Mitte: stehen bleiben
    const winkel = Math.atan2(y, x) * 180 / Math.PI;  // 0 = rechts, 90 = unten, -90 = oben
    // Acht Stücke zu je 45 Grad. Liegt der Winkel zwischen zwei Richtungen, gelten beide.
    if (winkel > -67.5 && winkel < 67.5) neu.add('ArrowRight');
    if (winkel > 22.5 && winkel < 157.5) neu.add('ArrowDown');
    if (winkel > 112.5 || winkel < -112.5) neu.add('ArrowLeft');
    if (winkel > -157.5 && winkel < -22.5) neu.add('ArrowUp');
    return neu;
  }

  // Nur melden, was sich geändert hat: Losgelassenes los, Neues drücken
  function setzen(neu) {
    for (const code of gedrueckt) if (!neu.has(code)) taste(code, false);
    for (const code of neu) if (!gedrueckt.has(code)) taste(code, true);
    gedrueckt = neu;
    for (const pfeil of kreuz.children) pfeil.classList.toggle('an', neu.has(pfeil.dataset.code));
  }

  kreuz.addEventListener('pointerdown', (e) => {
    e.preventDefault();
    kreuz.setPointerCapture(e.pointerId);   // auch melden, wenn der Finger aus dem Kreuz rutscht
    setzen(richtungen(e));
  });
  kreuz.addEventListener('pointermove', (e) => {
    if (kreuz.hasPointerCapture(e.pointerId)) setzen(richtungen(e));
  });
  for (const ende of ['pointerup', 'pointercancel']) {
    kreuz.addEventListener(ende, () => setzen(new Set()));
  }
}