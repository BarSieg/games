# 06 · Kerkerheld

Ein Dungeon von oben, nach dem Vorbild des ersten Dungeons aus The Legend of Zelda. Mit Schwert, Gegnern, Schlüsseln, verschlossenen Türen, Rätseln, Fallen, einem Händler und einem Boss am Ende. Der Kerker merkt sich alles und wird gespeichert. Wer es härter mag, spielt Iron Man: Tot ist tot.

Dieses Spiel habe ich selbst im Editor gebaut, in 14 Kapiteln. Wie es entstanden ist, steht in der [ANLEITUNG.md](ANLEITUNG.md), mit allen Übungsaufgaben.

**Starten:**
- **Im Browser über GitHub Pages:** https://barsieg.github.io/games/06-kerkerheld/web/index.html
- **Im Browser:** über die Startseite oder direkt `web/index.html`. Das braucht einen Webserver (z. B. `python -m http.server 8000` im `games`-Ordner), ein Doppelklick auf die Datei reicht nicht.
- **Im Editor:** Ordner in 🆓 Godot 4 öffnen und **F5** drücken.

Im Browser setzt die Musik erst mit dem ersten Tastendruck ein, so wollen es die Browser. Der Spielstand wird im Browser gespeichert. Vollbild gibt es dort mit **F11**.

**Steuerung:**
- **Tastatur:** Pfeiltasten oder WASD: Laufen · Leertaste/J: Angriff, Sprechen, Öffnen · Esc: Pause
- **Xbox-Controller:** Stick oder D-Pad: Laufen · A: Angriff, Sprechen, Öffnen · Start: Pause
- **Handy und Tablet (im Browser):** Steuerkreuz: Laufen · A: Angriff, Sprechen, Öffnen · Start: Pause

**Sprachen:** Deutsch, Englisch und Französisch, umschaltbar in den Optionen.

## Was ich gelernt habe
- **State Machine:** Der Held und die Gegner sind immer in genau einem Zustand, zum Beispiel Laufen, Angreifen, Getroffen. Jeder Zustand weiß selbst, wann es in den nächsten geht. Das hält auch komplizierte Gegner übersichtlich.
- **Räume wie im Original:** Die Kamera springt nicht mit, sondern schiebt sich Raum für Raum weiter. Solange steht das Spiel still. Nur die Gegner im aktuellen Raum sind wach.
- **Kollisionsebenen mit Namen:** Welt, Held, Gegner, Schwert und Gegnersperre. Eine Area2D bemerkt nur, wer sie berührt, aufhalten kann sie niemanden. Dafür braucht es einen Körper.
- **Vererbung:** Alle Gegner erben von einer gemeinsamen `Monster`-Klasse. Was alle können (Schaden nehmen, sterben, schlafen), steht nur einmal da.
- **Pixel mit Code malen:** Die Herzen, Münzen und Schlüssel malt `_draw()` Pixel für Pixel aus kleinen Text-Bildern.
- **Dialoge:** Text, der Buchstabe für Buchstabe erscheint, mit Plapper-Geräusch, Ja/Nein-Fragen und Auswahllisten. `await` macht daraus Code, der sich liest wie ein Gespräch.
- **Die Welt merkt sich alles:** Offene Truhen, besiegte Gegner, gefundene Geheimnisse. Alles landet in einem Spielstand mit `ConfigFile`, dazu eine Prüfsumme gegen Schummeln.
- **Zwei Arten zu sterben:** Normal steht man am Eingang wieder auf. Bei Iron Man gibt es kein Speichern, dafür eine Bestenliste.
- **Ein Boss:** eine Krabbe mit eigener State Machine. Sie läuft seitwärts, zielt, nimmt Anlauf und stürmt los. Ein Kampfgitter sperrt den Raum, bis sie besiegt ist.
- **Rätsel und Fallen:** Schalter, falsche Wände, Felsbrocken zum Schieben, Klingenfallen, Dornen und dunkle Räume mit Licht (`CanvasModulate` und `PointLight2D`).
- **Übersetzen:** Alle Texte stehen in `texte.csv`, Godot übersetzt sie mit `tr()`. Ein eigenes Python-Skript findet vergessene Texte und tauscht die Spalten mit DeepL aus.
- **Optionen:** Sprache, Lautstärke, Musik, Vollbild und wie der Held läuft, gespeichert in einer eigenen Datei. Erreichbar vom Titelbild und aus dem Pausenmenü.
- **Musik aus einem Skript:** `musik.py` schreibt die Stücke Note für Note als WAV-Datei, im Klang einer alten Konsole. Die Schleife steht in der Datei selbst, Godot liest sie beim Import.
- **Audio-Busse:** Die Musik hat ihren eigenen Bus, mit eigener Lautstärke und Effekten. In der Pause klingt sie gedämpft.
- **Autoloads:** Spielstand, Optionen, Dialog und Musik leben über jeden Szenenwechsel hinweg.

## Notizen
_(Was war schwer? Was würde ich anders machen? Was war in Godot leichter, was hat mir gefehlt?)_

## Grafiken, Schrift, Musik und Engine
- Kacheln, Figuren und Gegenstände: [Tiny Dungeon](https://kenney.nl/assets/tiny-dungeon) von Kenney, CC0
- Schrift: [Kenney Fonts](https://kenney.nl/assets/kenney-fonts) von Kenney, CC0
- Musik: von meinem eigenen Skript `musik.py` erzeugt
- Erstellt mit der [Godot Engine](https://godotengine.org) (MIT-Lizenz). Der Web-Export in `web/` enthält die Engine. Lizenz und Hinweise: https://godotengine.org/license

Für meinen eigenen Code, meine Musik und meine Sounds gilt die [LICENSE](../LICENSE) im Hauptordner.
