# 02 · Insekteninvasion

**Starten:** `index.html` im Browser öffnen.

**Steuerung:** ← / → (A / D): bewegen · Leertaste: schießen (gedrückt halten geht auch) · P: Pause · M: Ton · K: alle Invader besiegen (Entwickler-Taste)

## Was ich gelernt habe
- **Sprites:** Ein Sprite ist ein kleines Bild, das immer wieder gezeichnet wird. Hier stehen die Sprites als Textzeilen in `SPRITES`. `makeSprite` macht daraus einmal beim Start ein Bild, danach wird es nur noch kopiert (`drawImage`). Profis zeichnen Sprites in einem Pixel-Editor und laden sie als PNG. Das ist eine der Übungsaufgaben.
- **Sprite-Animation:** Jeder Invader hat zwei Bilder (`frames`). Bei jedem Schritt der Formation wird zwischen Bild 0 und 1 gewechselt, und schon „laufen“ sie.
- **Kleine Auflösung, groß gezeichnet:** Das Spiel rechnet in 224 × 256 Pixeln wie der Automat von 1978. `ctx.scale(3, 3)` vergrößert alles, und `imageSmoothingEnabled = false` bzw. CSS `image-rendering: pixelated` halten die Pixel scharf.
- **Formation:** Die Invader bewegen sich nicht einzeln, sondern als Block. Stößt einer am Rand an, geht der ganze Block eine Reihe tiefer und dreht um (`stepFormation`).
- **Schwierigkeit, die von selbst steigt:** `stepInterval` wird kürzer, je weniger Invader leben. Im Original war das übrigens ein Zufall: Der Automat wurde schneller, weil er weniger zu zeichnen hatte. Daraus wurde ein berühmtes Spielprinzip.
- **Zerstörbare Deckung:** Jede Deckung ist ein Raster aus `true`/`false`. Ein Treffer setzt ein paar Pixel auf `false` (`damageShield`). Kollision Pixel für Pixel statt Rechteck gegen Rechteck.
- **Einfache Gegner-KI:** Nur der unterste Invader einer Spalte darf schießen, und manchmal „zielt“ er auf den Spieler (`AIM_CHANCE`).
- **Sound an einer Stelle:** Alle Geräusche stecken in `sfx`. So kann man sie später leicht austauschen.

## Übungsaufgaben
Klein anfangen, nach jeder Aufgabe testen und mit Git committen:
1. **Farbige Invader:** Gib jeder Invader-Sorte eine eigene Farbe. Tipp: `color` in `SPRITES`.
2. **Sechste Reihe:** Füge der `FORMATION` eine Reihe hinzu. Muss dafür irgendwo anders Code geändert werden?
3. **Bonusleben:** Bei 1500 Punkten gibt es ein Extraleben, aber nur einmal pro Spiel. Tipp: eine Variable wie `bonusGiven` und eine Prüfung dort, wo `score` erhöht wird.
4. **Eigenes Sprite mit 🆓 Piskel:** Öffne [piskelapp.com](https://www.piskelapp.com), stelle die Größe auf 13 × 8 ein, zeichne ein eigenes Raumschiff und exportiere es als `player.png` in diesen Ordner. Lade es mit `new Image()` und ersetze damit `IMG.player[0]`. Tipp: googeln nach „javascript new Image src“.
5. **Eigener Sound mit 🆓 jsfxr:** Klicke auf [sfxr.me](https://sfxr.me) auf „Laser/Shoot“, bis dir ein Ton gefällt, und speichere ihn als `shoot.wav`. Ändere dann `sfx.shoot`, sodass die Datei abgespielt wird. Tipp: googeln nach „javascript new Audio play“.
6. **Schwieriger:** Im Original hing die Punktzahl des Ufos (hier: der Kakerlake) nicht vom Zufall ab, sondern von der Anzahl deiner Schüsse. Wer mitzählte, traf immer die 300. Zähle die Schüsse und vergib die Punkte nach einer festen Liste: `COCKROACH_POINTS[shotsFired % COCKROACH_POINTS.length]`.

## Notizen
_(Was war schwer? Was würde ich anders machen?)_
