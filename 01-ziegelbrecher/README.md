# 01 · Ziegelbrecher

**Starten:** `index.html` im Browser öffnen.

**Steuerung:** Maus oder ← / → (A / D) · Leertaste / Klick: Ball abschießen · P: Pause · M: Ton · N: Level überspringen (Entwickler-Taste)

## Was ich gelernt habe
- **Level als Daten:** Die Level stehen als Textzeilen in `LEVELS` (`R` = roter Stein, `S` = Silber, `X` = unzerstörbar, `.` = Lücke). Ein neues Level ist nur ein neuer Eintrag, kein neuer Code. Genau so arbeiten auch große Spiele: Inhalte stecken in Daten, die Regeln im Code.
- **Steintypen als Tabelle:** `BRICK_TYPES` legt Farbe, nötige Treffer und Punkte fest. Ein neuer Steintyp ist eine neue Zeile.
- **Kollision mit vielen Objekten:** Der Ball bewegt sich erst in x-Richtung, dann in y-Richtung. Je nachdem, bei welchem Schritt er einen Stein berührt, prallt er seitlich oder oben/unten ab.
- **Viele Objekte gleichzeitig:** Bälle, Power-up-Kapseln und Splitter liegen in Listen (`balls`, `drops`, `particles`). Jedes Bild wird jede Liste aktualisiert, und was „tot“ ist, fliegt mit `filter` raus.
- **Power-ups:** Ein Timer (`wideTimer`) zählt herunter und macht den Effekt danach rückgängig. Multiball kopiert jeden Ball und dreht seine Richtung ein Stück (Rotation eines Vektors).
- **Game Feel:** Splitter, Töne in unterschiedlicher Höhe, ein blinkender Schläger kurz vor Ablauf des Power-ups – Kleinigkeiten, die das Spiel lebendig machen.
- **Entwickler-Abkürzungen:** Mit `N` kann man ein Level überspringen. Solche Debug-Tasten haben fast alle Spiele während der Entwicklung.

## Übungsaufgaben
Klein anfangen, nach jeder Aufgabe testen und mit Git committen:
1. **Eigenes Level:** Füge in `LEVELS` ein viertes Level hinzu (z. B. deine Initialen aus Steinen).
2. **Neuer Steintyp:** Ein goldener Stein `D`, der 3 Treffer braucht und 150 Punkte bringt.
3. **Neues Power-up „L“:** ein Extraleben. Tipp: In `POWERUPS` eintragen und in `applyPowerup` behandeln.
4. **Highscore:** Speichere die beste Punktzahl mit `localStorage` und zeige sie im Titelbildschirm.
5. **Schwieriger:** Ein Power-up, das den Ball für 10 Sekunden verlangsamt.

## Notizen
_(Was war schwer? Was würde ich anders machen?)_
