# Games – Spieleentwicklung lernen

Mein Lernprojekt: Ich baue klassische Spielideen nach, um Spieleentwicklung von Grund auf zu lernen. Es fängt mit einem einfachen Ballspiel an, und am Ende soll ein Ego-Shooter im Stil der 2010er stehen. Der ganze Lernpfad steht in [ROADMAP.md](ROADMAP.md).

Alle Spiele laufen direkt im Browser, ohne Installation und ohne Bibliotheken. Sie sind in reinem JavaScript mit dem HTML-Canvas geschrieben.

## Spiele

| Nr. | Spiel | Worum es geht | Was ich dabei gelernt habe |
|---|---|---|---|
| 00 | [Ballwechsel](00-ballwechsel/) | Zwei Schläger, ein Ball, gegen die CPU oder zu zweit | Game Loop, Kollision, Spielzustände, einfache KI |
| 01 | [Ziegelbrecher](01-ziegelbrecher/) | Steine zerschießen in 5 Leveln, mit Power-ups | Level als Daten, viele Objekte, Power-ups, Highscore |
| 02 | [Insekteninvasion](02-insekteninvasion/) | Eine Insekten-Formation abwehren, hinter zerbröselnder Deckung | Sprites, Sprite-Animation, Pixel-Kollision, eigene Grafik und Sounds |
| 03 | [Weltraumsteine](03-weltraumsteine/) | Mit Schub und Trägheit durchs Asteroidenfeld | Vektoren, Rotation mit sin/cos, Trägheit, Kreis-Kollision |

Jeder Ordner hat eine eigene `README.md` mit Steuerung, Lernnotizen und Übungsaufgaben.

## Spielen

Am einfachsten: `index.html` im Hauptordner im Browser öffnen und ein Spiel auswählen.

Mit einem lokalen Webserver (zum Beispiel mit Python) funktioniert alles am zuverlässigsten:

```bash
python -m http.server 8000
```

Danach im Browser `http://localhost:8000/` öffnen.

## Nutzung und Urheberrecht

© 2026 Siegfried (BarSieg). Alle Rechte vorbehalten.

Spielen und Ansehen ist ausdrücklich erwünscht, auch über GitHub Pages. Der Code, die Grafiken und die Sounds dürfen aber ohne meine schriftliche Erlaubnis nicht kopiert, verändert, weiterverbreitet oder in anderen Projekten verwendet werden. Details stehen in [LICENSE](LICENSE).

## Hinweis

Dies ist ein privates Lernprojekt ohne kommerzielle Absicht. Die Spiele sind von bekannten Arcade-Klassikern inspiriert, verwenden aber eigene Namen, eigene Grafiken und eigene Sounds. Das Projekt steht in keiner Verbindung zu Atari, Taito oder anderen Rechteinhabern der Originalspiele. Alle genannten Marken gehören ihren jeweiligen Inhabern.
