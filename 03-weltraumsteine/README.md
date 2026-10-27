# 03 · Weltraumsteine

**Starten:** `index.html` im Browser öffnen.

**Steuerung:** ← / → (A / D): drehen · ↑ (W): Schub · Leertaste: schießen · P: Pause · M: Ton · K: alle Asteroiden zerstören (Entwickler-Taste)

## Was ich gelernt habe
- **Vektoren:** Position, Geschwindigkeit und Schub sind Pfeile mit einem x- und einem y-Anteil. Die meiste Spiele-Mathematik besteht daraus, solche Pfeile zu addieren und zu verlängern oder zu kürzen.
- **Winkel → Richtung:** `fromAngle` macht aus einem Winkel einen Vektor. `cos` liefert den x-Anteil, `sin` den y-Anteil. Auf dem Bildschirm zeigt y nach unten, darum ist „oben“ -90°.
- **Rotation:** `rotate` dreht einen Punkt um die Mitte. Das Schiff und die Asteroiden sind nur Punktlisten, die jedes Bild gedreht und verschoben werden. In 3D funktioniert das genauso, nur mit einer Achse mehr.
- **Trägheit:** Der Schub ändert die *Geschwindigkeit*, nicht die Position. Ohne Schub fliegt das Schiff einfach weiter. Die Reibung (`DRAG`) bremst es langsam ab.
- **Vektoren addieren:** Eine Kugel bekommt die Geschwindigkeit des Schiffs dazu. Darum fliegt sie schneller, wenn man nach vorn fliegt.
- **Kreis-Kollision:** Zwei Kreise berühren sich, wenn der Abstand ihrer Mittelpunkte kleiner ist als beide Radien zusammen. Das ist einfacher als Rechtecke und passt besser zu runden Dingen.
- **Bildschirm-Wrap:** Wer links rausfliegt, kommt rechts wieder rein (`wrap`). Damit nichts plötzlich auftaucht, wird ein Objekt am Rand zusätzlich auf der anderen Seite gezeichnet (`drawWrapped`).
- **Zufallsformen (prozedural):** Kein Asteroid ist von Hand gezeichnet. `makeAsteroid` setzt Punkte im Kreis und lässt jeden Abstand etwas wackeln. So sieht jeder anders aus.
- **Zerfallen:** Ein getroffener Asteroid macht zwei kleinere. Die Größen stehen als Tabelle in `ASTEROID_SIZES`.

## Übungsaufgaben
Klein anfangen, nach jeder Aufgabe testen und mit Git committen:
1. **Fluggefühl einstellen:** Spiel mit `THRUST`, `DRAG`, `TURN_SPEED` und `MAX_SPEED`. Was passiert bei `DRAG = 0` (wie im echten Weltall)? Notiere dir unter „Notizen“, welche Werte sich am besten anfühlen. Genau so verbringen Spieleentwickler viele Stunden („Game Feel“).
2. **Farbige Asteroiden:** Jede Größe bekommt eine eigene Farbe. Tipp: `color` in `ASTEROID_SIZES` eintragen und vor `drawShape` als `ctx.strokeStyle` setzen.
3. **Dauerfeuer:** Wer die Leertaste gedrückt hält, schießt alle 0,25 Sekunden. Tipp: ein Timer wie `bombTimer` in Insekteninvasion, und `keys.Space` abfragen.
4. **Hyperraum:** Mit der Taste H springt das Schiff an eine zufällige Stelle. Aber mit 1 zu 6 Wahrscheinlichkeit explodiert es dabei. Tipp: `explodeShip()` gibt es schon.
5. **Rotation sehen mit 🆓 Desmos:** Öffne [desmos.com/calculator](https://www.desmos.com/calculator) und gib `(16cos(a), 16sin(a))` ein. Desmos bietet dir einen Schieberegler für `a` an. Zieh daran: Der Punkt ist die Nase deines Schiffs (`SHIP_SHAPE[0]`), wenn es sich dreht. Probier danach die Formel aus `rotate` für den Punkt (-10, -10) aus.
6. **Schwieriger:** Eine fliegende Untertasse wie im Original. Sie fliegt quer übers Bild und schießt alle 1,5 Sekunden in eine zufällige Richtung. Tipp: Ihre Kugeln sind wie `bullets`, treffen aber das Schiff. Für die Kollision reicht `distance`.

## Notizen
_(Was war schwer? Was würde ich anders machen?)_
1. TURN_SPEED = 3.3, THRUST = 200, DRAG = 0.3, MAX_SPEED = 450
5. (c,d) -> (x,y)
\left(c\cdot\cos\left(a\right)-d\cdot\sin\left(a\right),c\cdot\sin\left(a\right)+d\cdot\cos\left(a\right)\right)