# 00 · Ballwechsel

**Starten:** `index.html` im Browser öffnen.

**Steuerung:** gegen CPU: W/S, ↑/↓ oder Maus · zu zweit: W/S und ↑/↓ · Leertaste: Pause · M: Ton · Esc: Menü

## Was ich gelernt habe
- **Game Loop:** `requestAnimationFrame` ruft ~60× pro Sekunde `update(dt)` und `draw()` auf. `dt` (Zeit seit dem letzten Bild) sorgt dafür, dass das Spiel auf jedem Bildschirm gleich schnell läuft.
- **Spielzustände:** `menu`, `serve`, `play`, `paused`, `over` – je nach Zustand reagiert das Spiel anders auf Eingaben.
- **Kollision:** Rechteck-gegen-Rechteck-Test (AABB). Der Abprallwinkel hängt davon ab, wo der Ball den Schläger trifft.
- **Teilschritte (Substeps):** Ein schneller Ball wird pro Bild in mehreren kleinen Schritten bewegt, damit er nicht durch den Schläger „tunnelt“.
- **Einfache KI:** Die CPU sagt voraus, wo der Ball ankommt, und baut absichtlich Fehler ein. Ein Schwierigkeitsgrad ist nur ein Satz von Zahlen.
- **Sound ohne Dateien:** Pieptöne mit der Web Audio API erzeugen.

## Notizen
_(Was war schwer? Was würde ich anders machen?)_
