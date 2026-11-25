# 07 · Hordenheld

Fünf Minuten überleben, gegen Hunderte Gegner auf einmal, im Stil von Vampire Survivors. Man steuert nur die Laufrichtung, die Waffen feuern von selbst. Besiegte Gegner lassen Edelsteine fallen, und mit jedem Level wählt man ein Upgrade: mehr Messer, schärfere Messer, einen Glutring, kreisende Äxte. Die Wellen werden dichter, schneller und zäher, Zyklopen walzen heran, und am Ende schließt sich ein Ring aus Gegnern um den Helden. Wer bis 0:00 durchhält, gewinnt.

Dieses Spiel habe ich selbst im Editor gebaut, in 10 Kapiteln. Wie es entstanden ist, steht in der [ANLEITUNG.md](ANLEITUNG.md), mit allen Übungsaufgaben.

**Starten:**
- **Im Browser über GitHub Pages:** https://barsieg.github.io/games/07-hordenheld/web/index.html
- **Im Browser:** über die Startseite oder direkt `web/index.html`. Das braucht einen Webserver (z. B. `python -m http.server 8000` im `games`-Ordner), ein Doppelklick auf die Datei reicht nicht.
- **Im Editor:** Ordner in 🆓 Godot 4 öffnen und **F5** drücken.

Im Browser setzt die Musik erst mit dem ersten Tastendruck ein, so wollen es die Browser. Vollbild gibt es dort mit **F11**. Der Controller brummt im Browser nur in Chrome und Edge, und erst nachdem man einmal einen Knopf auf ihm gedrückt hat.

**Steuerung:**
- **Xbox-Controller:** Stick oder D-Pad: Laufen und im Menü wählen · A: OK · Start: Pause
- **Tastatur:** Pfeiltasten oder WASD: Laufen und im Menü wählen · Leertaste oder Enter: OK · Esc: Pause
- Im Titelbild und in der Pause ändern links und rechts die Optionen: Musik, Beben, Brummen und (nicht im Browser) Vollbild.

**Nur im Editor**, zum Messen und Testen: F1 = 100 Gegner mehr · F2 = Testmodus (unverwundbar) · F3 = Grenze suchen: so lange Gegner dazu, bis ein Physik-Schritt zu lange dauert · F4 = Uhr 30 Sekunden vor

## Was ich gelernt habe
- **Der Profiler zeigt, was bremst:** Erst messen, dann verbessern. Die Vermutung lag oft daneben. Eigene Monitore zeigen im Debugger, wie viele Gegner, Messer und Edelsteine gerade unterwegs sind.
- **Hunderte Gegner ohne teure Physik:** Die Gegner laufen ohne `move_and_slide()`. Damit sie sich nicht stapeln, schieben sie sich selbst auseinander. Ein Raster aus Kästchen sorgt dafür, dass jeder nur seine Nachbarn prüft, und jedes Paar nur einmal. Dazu ein Schachbrett: Jeder Physik-Schritt erledigt nur die Hälfte der Kästchen.
- **Grenzen messen statt raten:** Das Werkzeug lässt so lange Gegner kommen, bis ein Physik-Schritt länger als 16,7 ms dauert. Im Editor sind das über 1500, im Browser gut 1300.
- **Upgrades und Wellen als Daten:** Ein Upgrade ist eine Resource: welcher Knoten, welche Eigenschaft, mal wie viel, plus wie viel. Die Wellen genauso: wer kommt, wie schnell, wie zäh, ob ein Elite-Gegner oder ein Kessel dabei ist. Neues baut man im Inspector, nicht im Code.
- **Game Feel:** Treffer blitzen weiß auf, Gegner schrumpfen beim Sterben, Schadenszahlen ploppen hoch, kritische Treffer in Gelb. Wenn Gegner beißen, bebt das Bild und der Controller brummt. Tausend Zahlen malt dabei ein einziger Knoten.
- **Ausbalancieren mit Zahlen:** Der Glutring war zu stark, die Äxte nutzlos, die Gegner zu langsam. Ein Bot, der im Kreis läuft, hat gezeigt, welche Änderung wie viel bringt.
- **Signale statt Abhängigkeiten:** Die Uhr ruft nur `abgelaufen`. Der Spawner lässt die Horde zerplatzen, der Held feiert, der Ende-Bildschirm zeigt "Gewonnen!". Keiner weiß vom anderen.
- **Timer und Tweens:** `create_timer()` für eine Welle, die vom Held nach außen läuft. Tweens, die für immer laufen oder auch in der Pause weiterlaufen.
- **Musik passt zur Welle:** Titel, Kampf und Endspurt, von meinem eigenen Skript `musik.py` erzeugt und über einen Autoload ein- und ausgeblendet.
- **Debug und fertiges Spiel:** `OS.is_debug_build()` lässt die Messwerkzeuge zu Hause, wenn das Spiel ins Netz geht.
- **JavaScript aus Godot:** Godot kann im Browser keinen Controller brummen lassen. `JavaScriptBridge.eval()` fragt den Browser selbst.

## Notizen
_(Was war schwer? Was würde ich anders machen? Was war in Godot leichter, was hat mir gefehlt?)_

## Grafiken, Schrift, Musik und Engine
- Figuren und Gegenstände: [Tiny Dungeon](https://kenney.nl/assets/tiny-dungeon) von Kenney, CC0
- Wiese: [Tiny Town](https://kenney.nl/assets/tiny-town) von Kenney, CC0
- Schrift: [Kenney Fonts](https://kenney.nl/assets/kenney-fonts) von Kenney, CC0
- Musik: von meinem eigenen Skript `musik.py` erzeugt
- Sounds: die Fanfare von `fanfare.py` aus dem Kerkerheld, das Plopp selbst gemacht mit 🆓 [sfxr.me](https://sfxr.me/)
- Erstellt mit der [Godot Engine](https://godotengine.org) (MIT-Lizenz). Der Web-Export in `web/` enthält die Engine. Lizenz und Hinweise: https://godotengine.org/license

Für meinen eigenen Code, meine Musik und meine Sounds gilt die [LICENSE](../LICENSE) im Hauptordner.
