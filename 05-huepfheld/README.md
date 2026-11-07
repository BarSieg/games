# 05 · Hüpfheld

Vertiefung in die Godot-Engine. Ein Held läuft, springt, sammelt Münzen und macht Gegner platt. Gegner bewegen sich, wenden an Hindernissen oder optional auch vor dem Abgrund.

Dieses Spiel habe ich auch selbst im Editor gebaut, Kapitel für Kapitel. Wie es entstanden ist, steht in der [ANLEITUNG.md](ANLEITUNG.md), mit allen Übungsaufgaben.

**Starten:**
- **Im Browser über GitHub Pages:** https://barsieg.github.io/games/05-huepfheld/web/index.html
- **Im Browser:** über die Startseite oder direkt `web/index.html`. Das braucht einen Webserver (z. B. `python -m http.server 8000` im `games`-Ordner), ein Doppelklick auf die Datei reicht nicht.
- **Im Editor:** Ordner in 🆓 Godot 4 öffnen und **F5** drücken.

**Steuerung:**
- **Tastatur:** Links/A und Rechts/D: Laufen · Leertaste/W: Springen · Shift: Schneller laufen · Nach Game Over: Leertaste für ein neues Spiel
- **Xbox-Controller:** Links und Rechts (Stick oder D-Pad): Laufen · A: Springen · LT: Schneller laufen · Nach Game Over: A für ein neues Spiel

## Was ich gelernt habe
- **Tilemap:** Eine PNG-Datei enthält mehrere Grafiken, die als Kacheln zusammengesetzt werden können. So kann der Level als Raster aufgebaut werden.
- **Animated Sprite:** Ähnlich wie bei der Tilemap kann eine PNG-Datei für Sprites verwendet werden. Sogar mehrere Sprites sind aus einer PNG möglich.
- **Kollisionsebenen (Layer und Mask):** Wer auf welcher Ebene liegt und wen bemerkt. Die Ebenen haben Namen (z. B. „Welt“ oder „Held“), die Funktionsweise ist aber trotzdem nicht immer das, was man erwartet.
- **Kollisionsfunktionen:** Kollisionen können nicht nur Signale erzeugen, sondern auch unterschiedliche Zustände auf Abruf liefern: `is_on_wall()`, `is_on_floor()` u. a.
- **Kollisionszustand:** `body_entered` meldet sich nur einmal. Läuft man nach dem ersten Treffer neben dem Gegner weiter, werden keine neuen Signale erzeugt. Deswegen dürfen sich die Gegner nicht auf Signale verlassen und müssen in jedem Frame prüfen, ob der Held mit ihnen gerade kollidiert.
- **Deko-Tilemap:** Eine Tilemap ohne Kollisionen kann dieselben Grafiken enthalten, aus denen der Level gebaut ist.
- **Variable Gravitation:** Spaß ist wichtiger als eine physikalisch treue Darstellung. Der Held bekommt eine größere Gravitation beim Runterfallen, die Ziegelsteine eine kleinere.
- **Großzügige Steuerung:** Der Sprungknopf darf etwas später oder früher gedrückt werden.
- **Beschleunigung und Abbremsen:** Der Held braucht Zeit, um zu beschleunigen oder zum Stillstand zu kommen. Bei einer schnellen Umdrehung kommt sogar ein „Bremsen“-Frame zum Einsatz.
- **Sprunghöhe:** Die Sprünge sind nicht alle gleich. Lässt man den Knopf los, wird der Sprung kürzer. Und vom Gegner springt der Held noch höher ab!
- **Kamera:** Bewegt sich hinter dem Held, verhindert aber, dass der Held zurückgehen kann. Eine unsichtbare Wand, deren Platzierung von der Kamera abgeleitet wird, schiebt den Helden zurück.
- **Hintergründe:** Die Z-Order bestimmt, welche Schicht über welcher gemalt wird. Am besten gleich einen Schichtabstand größer als 1 nehmen, falls man später etwas dazwischen braucht.
- **Gegner:** Die Gegner bewegen sich, stoßen an Wände und aneinander und können sogar Lücken im Boden erkennen: Manche fallen hinein und manche drehen sich um. Die Lückenerkennung ist optional und wird über eine Export-Variable eingestellt. Es gibt also nur eine Gegner-Szene für beide Verhalten.
- **VisibleOnScreenNotifier:** Die Gegner warten, bis die Kamera sie erreicht. Einmal aufgewacht, können sie den Bildschirm verlassen, ohne wieder zu erstarren, und so sogar von links zurückkommen. Aber nur, wenn sie nicht zu weit gehen.
- **Tweens:** Kleine Animationen durch die langsame Änderung von Eigenschaften.
- **enum für Blöcke:** Eine Block-Szene erlaubt die Typauswahl über ein Auswahlmenü: Der Block kann mehrere Münzen (die Anzahl ist variabel), ein Power-up oder auch nichts enthalten. Die leeren Blöcke (Ziegel) sind zerstörbar, die mit Inhalt bleiben auch stehen, nachdem der Inhalt genommen wurde.
- **_deferred:** `set_deferred()` und `call_deferred()`: Während Godot Kollisionen meldet, darf man nichts an der Physik ändern.
- **Töne:** Die Töne für das Sammeln von Münzen und auch viele andere hängen am Helden, weil er bleibt. Die Münzen verschwinden letztendlich (`queue_free()`), und das würde den Ton abschneiden, wäre er an die Münzen gebunden.
- **Autoload:** Beim Neuladen der Szene bleiben einige wichtige Werte erhalten, z. B. die Anzahl der Leben.
- **CanvasLayer:** Eine Anzeige, die sich nicht mit der Kamera bewegt. Die Statusanzeige zeigt im Prinzip die Daten, die der Autoload verwaltet.
- **Bildgröße:** Variable Bildgröße im Browser darf keine Auswirkung auf die Kamera haben.
- **Mehrere Szenen:** Koordination von Level, Bonuslevel und Ende-Bildschirm.

## Notizen
_(Was war schwer? Was würde ich anders machen? Was war in Godot leichter, was hat mir gefehlt?)_
Die Pixel-Grafiken zu malen ist irgendwie nicht zufriedenstellend...
Die Pixel-Schrift ist schwer zu lesen.

## Grafiken, Schrift und Engine
- Kacheln, Hintergründe und Gegner: [Pixel Platformer](https://kenney.nl/assets/pixel-platformer) von Kenney, CC0
- Schrift: [Kenney Fonts](https://kenney.nl/assets/kenney-fonts) von Kenney, CC0
- Erstellt mit der [Godot Engine](https://godotengine.org) (MIT-Lizenz). Der Web-Export in `web/` enthält die Engine. Lizenz und Hinweise: https://godotengine.org/license

Für meinen eigenen Code, meine Spielfigur und meine Sounds gilt die [LICENSE](../LICENSE) im Hauptordner.
