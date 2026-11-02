# Hüpfheld – Schritt-für-Schritt-Anleitung

Ein Jump'n'Run nach dem Vorbild von Super Mario Bros. Level 1-1. Wie bei Flatterfisch baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Das Projekt ist größer als Flatterfisch (die Roadmap rechnet mit 2–3 Wochen). Dafür kannst du vieles wiederverwenden: Szenen, Signale, Gruppen, Process Mode, Export.

**Geplante Kapitel:**
1. Projekt, Grafiken und die erste Plattform ← *du bist hier*
2. Laufen und Springen, die sich gut anfühlen (eigene Steuerung, variable Sprunghöhe)
3. Game Feel: Beschleunigung, Coyote Time, Jump Buffering
4. Kamera und ein langer Level
5. Animationen: stehen, laufen, springen
6. Gegner: patrouillieren und plattgesprungen werden
7. Blöcke und Items: Münzen und ein Power-up
8. Ziel, Leben, Anzeige und Web-Export

---

## Kapitel 1: Projekt, Grafiken und die erste Plattform

### 1.1 Das Projekt anlegen

Im Godot-Projekt-Manager → **Create**:

| Feld | Wert |
|---|---|
| Project Name | `Hüpfheld` |
| Project Path | `...\games\05-huepfheld` (der Ordner mit dieser Anleitung; Ordnernamen ohne Umlaut, das ist im Web sicherer) |
| Renderer | **Compatibility** (für den Web-Export) |
| Version Control Metadata | **Git** |

### 1.2 Pixel-Art-Einstellungen gleich am Anfang

Bei Flatterfisch kamen die verschwommenen Pixel und die Streifen am Sand erst spät. Diesmal stellen wir es gleich richtig ein. *Project → Project Settings*:

| Einstellung | Wert | Warum |
|---|---|---|
| Display → Window → **Viewport Width / Height** | `384` × `216` | Die „echte“ Auflösung des Spiels: 16:9 und genau 12 Kacheln hoch (216 ÷ 18). |
| Display → Window → **Window Width Override / Height Override** | `1152` × `648` | Das Fenster beim Testen ist dreimal so groß, sonst wäre es winzig. (Die Overrides sieht man erst mit **Advanced Settings** oben rechts.) |
| Display → Window → Stretch → **Mode** | `viewport` | Godot rechnet in 384 × 216 und vergrößert das fertige Bild. Pixel bleiben Pixel. |
| Display → Window → Stretch → **Scale Mode** | `integer` | Nur ganze Vergrößerungen (2×, 3× …): jedes Pixel gleich groß, keine Streifen. |
| Rendering → Textures → Canvas Textures → **Default Texture Filter** | `Nearest` | Keine Glättung. |

### 1.3 Die Grafiken von Kenney 🆓

[Kenney](https://kenney.nl) ist ein Spieleentwickler, der tausende Grafiken unter der Lizenz **CC0** verschenkt. CC0 heißt: Du darfst sie für alles verwenden, auch kommerziell, ohne Namensnennung (eine Erwähnung in der README ist trotzdem eine nette Geste).

1. Auf kenney.nl unter *Assets* das Paket **Pixel Platformer** suchen und herunterladen. Der Download ist kostenlos; Kenney fragt nach einer freiwilligen Spende, die du überspringen kannst.
2. ZIP entpacken. Im Ordner `Tilemap` liegen große Bilder mit allen Kacheln auf einem Blatt. Nimm die Datei, deren Name auf **`_packed`** endet (dort liegen die Kacheln ohne Abstand dazwischen) und ins Projekt-FileSystem ziehen. Die Kacheln sind **18 × 18** Pixel groß.
3. Kopier auch die Lizenzdatei aus dem ZIP (`License.txt`) in einen Unterordner, z. B. `kenney/`. So weiß jeder, woher die Grafiken stammen.

Nur das Kachelblatt kommt ins Projekt, nicht das ganze ZIP.

### 1.4 Deine Spielfigur

In 🆓 Piskel oder 🆓 Pixelorama: eine kleine Heldenfigur, **16 × 16 Pixel**, Blick nach rechts. Ein einziges Bild reicht für jetzt, Lauf- und Sprung-Bilder kommen in Kapitel 5. Speichern als `held.png` und ins FileSystem ziehen.

Etwas kleiner als eine Kachel (16 statt 18) ist Absicht: So passt der Held gut durch Lücken, die genau eine Kachel hoch sind.

### 1.5 Die Welt aus Kacheln: TileMapLayer

Statt jeden Boden als eigene Szene zu bauen (wie die Korallen), malt man Level aus **Kacheln** (Tiles) auf ein Raster. Das ist schneller, braucht weniger Speicher, und Godot kann die Kollision der Kacheln gleich mitliefern.

1. *Scene → New Scene* → **2D Scene** → Root umbenennen in `Level`.
2. Rechtsklick auf `Level` → **Add Child Node** → `TileMapLayer` → umbenennen in `Boden`.
3. Im Inspector bei **Tile Set** → **New TileSet**. Dann auf das neue TileSet klicken, damit es aufklappt:
   - **Tile Size:** `18, 18`
   - **Physics Layers** → **Add Element**. Damit können Kacheln eine Kollisionsform bekommen.
4. Unten im Editor erscheinen die Tabs **TileSet** und **TileMap**. Öffne **TileSet** und zieh dein Kenney-Kachelblatt in die linke Liste. Godot fragt, ob es automatisch Kacheln anlegen soll → **Yes**.
5. **Kollision malen:** Im TileSet-Tab oben auf **Paint** → bei *Paint Properties* **Physics → Physics Layer 0** wählen. Dann auf jede Kachel klicken, auf der man später stehen soll (Gras, Erde, Steinblöcke). Jede angeklickte Kachel bekommt ein volles Kollisions-Quadrat.
   Deko wie Gras-Büschel oder Wolken bekommt keine Kollision.
6. **Level malen:** Tab **TileMap** öffnen, eine Kachel auswählen und im Bild malen (Linksklick = malen, Rechtsklick = löschen). Mal einen Boden über die ganze Breite, eine kleine Treppe und eine schwebende Plattform.
7. Speichern als `level.tscn`.

Tipp: Mit Strg und dem Mausrad zoomst du im Editor. Ein Kasten in Lila zeigt die Größe des Spielfensters (384 × 216).

### 1.6 Der Held

1. *Scene → New Scene* → **Other Node** → `CharacterBody2D` → umbenennen in `Held`.
2. Kinder hinzufügen:
   - `Sprite2D` → umbenennen in `Bild`, **Texture** = `held.png`
   - `CollisionShape2D` → **Shape** = **New RectangleShape2D**, **Size** = `12, 15`

   Warum nicht 16 × 16? Etwas schmaler als das Bild fühlt sich fairer an: Der Held bleibt nicht an Kanten hängen, an denen er optisch vorbeipasst. Und 15 statt 16 hoch, damit die Füße genau auf dem Boden stehen, wenn du die Form 0,5 nach unten schiebst (**Position** `0, 0.5`).
3. Rechtsklick auf `Held` → **Attach Script**. Diesmal nicht leer: Bei **Template** steht **CharacterBody2D: Basic Movement**. Das lassen wir so → **Create**.
4. Godot hat ein fertiges Skript für Laufen und Springen geschrieben. Ändere nur zwei Zahlen, denn die Vorlage ist für viel größere Bildschirme gedacht:

```gdscript
const SPEED = 100.0
const JUMP_VELOCITY = -360.0
```

5. Speichern als `held.tscn`.

### 1.7 Ausprobieren

1. In `level.tscn` den Held einsetzen (aus dem FileSystem ins Bild ziehen) und über den Boden stellen.
2. **F5** → Hauptszene: `level.tscn` → **Select Current**.
3. Pfeiltasten: laufen. Leertaste oder Enter: springen.

Der Held sollte auf deinen Kacheln stehen, laufen und auf die Treppe und die Plattform springen können.

### 1.8 Lies das Skript

Bevor du committest: Lies die Vorlage Zeile für Zeile. Du kennst inzwischen fast alles darin.

- `get_gravity()`: Die Schwerkraft kommt aus den Projekteinstellungen (*Physics → 2D → Default Gravity*, 980). Bei Flatterfisch hattest du sie selbst als Konstante.
- `is_on_floor()`: Steht der Held gerade auf etwas? Das weiß `move_and_slide()` vom letzten Bild. Das war bei Flatterfisch nicht nötig, weil der Fisch nie steht.
- `Input.get_axis("ui_left", "ui_right")`: ergibt -1, 0 oder 1. Dasselbe wie dein `dir -= 1` / `dir += 1` aus Insekteninvasion in einer Zeile.
- `move_toward(velocity.x, 0, SPEED)`: bremst ab. Mit `SPEED` als Schrittweite steht der Held sofort. Das ändern wir in Kapitel 3.
- Der Kommentar „replace UI actions with custom gameplay actions“: Das machen wir in Kapitel 2.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 1

1. **Sprunghöhe rechnen (leicht):** Wie hoch springt der Held in Pixeln? Die Formel lautet Höhe = v² ÷ (2 · g), mit v = 360 und g = 980. Wie viele Kacheln sind das? Prüf es im Spiel an deiner Treppe. Welches `JUMP_VELOCITY` brauchst du für genau 4 Kacheln?
2. **Kein Fallen ins Nichts (leicht):** Was passiert, wenn der Held vom Rand fällt? Lass ihn wieder am Start erscheinen, sobald er unter den Bildschirm fällt. (Bei Flatterfisch hattest du `position.y > 660`.)
3. **Zweite Ebene (mittel):** Leg in `level.tscn` eine zweite `TileMapLayer` namens `Deko` an, die dasselbe TileSet benutzt (im Inspector beim TileSet: Pfeil → **Copy**, dann bei der neuen Ebene **Paste**). Mal darauf Büsche, Wolken und Zäune. Warum ist es praktisch, Deko auf einer eigenen Ebene ohne Kollision zu haben?
4. **Einseitige Plattform (mittel):** Manche Plattformen soll man von unten durchspringen können. Im TileSet-Tab bei der Kollision einer Kachel gibt es **One Way**. Probier es an deiner schwebenden Plattform aus.
