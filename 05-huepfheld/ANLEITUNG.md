# Hüpfheld – Schritt-für-Schritt-Anleitung

Ein Jump'n'Run nach dem Vorbild von Super Mario Bros. Level 1-1. Wie bei Flatterfisch baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Das Projekt ist größer als Flatterfisch (die Roadmap rechnet mit 2–3 Wochen). Dafür kannst du vieles wiederverwenden: Szenen, Signale, Gruppen, Process Mode, Export.

**Geplante Kapitel:**
1. Projekt, Grafiken und die erste Plattform ✔
2. Laufen und Springen, die sich gut anfühlen (eigene Steuerung, variable Sprunghöhe) ← *du bist hier*
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

---

## Kapitel 2: Laufen und Springen, die sich gut anfühlen

Die Vorlage aus Kapitel 1 funktioniert, fühlt sich aber steif an: Jeder Sprung ist gleich hoch, der Held fällt so langsam, wie er steigt, und er schaut immer nach rechts. In diesem Kapitel baust du das Skript Stück für Stück um. Am Ende steht das ganze Skript zum Vergleichen.

### 2.1 Eigene Aktionen statt `ui_…`

Die Aktionen `ui_left`, `ui_right` und `ui_accept` gehören eigentlich den Menüs. `ui_accept` reagiert zum Beispiel auch auf Enter, und wenn du später ein Menü baust, kommen sich Spiel und Menü in die Quere. Deshalb legt man für das Spiel eigene Aktionen an.

*Project → Project Settings* → Tab **Input Map**:

1. Oben bei *Add New Action* `links` eintippen → **Add**. Genauso `rechts` und `springen`.
2. Neben jeder Aktion auf das **+** klicken und die Taste drücken, die dazugehören soll:

| Aktion | Tasten |
|---|---|
| `links` | Pfeil links, A |
| `rechts` | Pfeil rechts, D |
| `springen` | Leertaste, Pfeil hoch, W |

Eine Aktion darf mehrere Tasten haben. Im Code fragst du nur noch die Aktion ab und musst die Tasten nicht kennen. Das ist dasselbe Prinzip wie dein `pressKey` bei den Touch-Knöpfen: Viele Eingaben führen zu einer Handlung.

Dann im Skript die drei Namen austauschen:

```gdscript
	if Input.is_action_just_pressed("springen") and is_on_floor():
	...
	var direction := Input.get_axis("links", "rechts")
```

Den Kommentar „As good practice, you should replace UI actions …“ kannst du jetzt löschen, das ist erledigt.

### 2.2 Variable Sprunghöhe

Bei Mario gilt: kurz tippen ergibt einen kleinen Hüpfer, gedrückt halten einen hohen Sprung. Der Trick dahinter ist einfach. Lässt der Spieler die Taste los, während der Held noch steigt, nimmt man ihm einen Teil des Schwungs weg.

Oben zu den Konstanten:

```gdscript
const JUMP_CUT = 0.5   # Taste früh losgelassen: restlichen Schwung halbieren
```

Direkt unter den Sprung:

```gdscript
	if Input.is_action_just_released("springen") and velocity.y < 0:
		velocity.y *= JUMP_CUT
```

`velocity.y < 0` heißt: Der Held steigt noch. Ohne diese Bedingung würde das Loslassen auch beim Fallen bremsen, und der Held würde kurz in der Luft schweben.

Die volle Sprunghöhe aus Übung 1 von Kapitel 1 bleibt gleich, denn wer die Taste hält, merkt vom Abschneiden nichts.

### 2.3 Schneller fallen

In echt fällt man genauso schnell, wie man steigt. In Spielen fühlt sich das schwammig an, wie auf dem Mond. Fast alle Jump'n'Runs ziehen den Helden beim Fallen deshalb stärker nach unten als beim Steigen. Zusätzlich gibt es eine Höchstgeschwindigkeit, damit lange Stürze nicht immer schneller werden.

```gdscript
const FALL_GRAVITY_FACTOR = 1.6   # beim Fallen stärker nach unten ziehen
const MAX_FALL_SPEED = 300.0
```

Den Schwerkraft-Teil ersetzt du so:

```gdscript
	# Schwerkraft, beim Fallen stärker
	if not is_on_floor():
		var gravity := get_gravity()
		if velocity.y > 0:
			gravity *= FALL_GRAVITY_FACTOR
		velocity += gravity * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
```

`min` nimmt den kleineren der beiden Werte, so wird `velocity.y` nie größer als 300. Bei 60 Bildern pro Sekunde sind das 5 Pixel pro Bild. Das ist weniger als eine Kachel (18), so kann der Held auch nicht durch eine dünne Plattform „durchrutschen“.

Weil nur das Fallen stärker wird, bleibt die Sprunghöhe dieselbe. Der Sprung wird nur kürzer und knackiger.

### 2.4 Den Startpunkt merken

In deiner Übung 2 aus Kapitel 1 stehen die Zahlen `44` und `135` zweimal: im Level (wo der Held steht) und im Skript (wohin er zurückkommt). Verschiebst du den Held im Level, stimmt das Skript nicht mehr. Besser: Der Held merkt sich beim Start selbst, wo er steht.

```gdscript
const FALL_LIMIT = 224   # tiefer als das: runtergefallen

var start_position: Vector2


func _ready() -> void:
	start_position = position
```

`_ready` läuft einmal, sobald der Held in der Szene ist. Dein Rücksetzen wird dann zu:

```gdscript
	# Runtergefallen
	if position.y > FALL_LIMIT:
		position = start_position
		velocity = Vector2.ZERO
```

`Vector2.ZERO` ist dasselbe wie `Vector2(0, 0)`, nur besser lesbar. Und `position` kann man als Ganzes zuweisen, `x` und `y` einzeln sind nicht nötig.

### 2.5 In Laufrichtung schauen

Der Held schaut immer nach rechts, auch wenn er nach links läuft. Ein `Sprite2D` kann sein Bild spiegeln: **Flip H** (horizontal). Im Skript dort, wo `direction` nicht 0 ist:

```gdscript
	if direction:
		velocity.x = direction * SPEED
		$Bild.flip_h = direction < 0
```

`direction < 0` ist `true` beim Laufen nach links und `false` nach rechts. Steht der Held still, bleibt das Bild, wie es war. So schaut er weiter in die Richtung, in die er zuletzt gelaufen ist.

### 2.6 Das ganze Skript

So sollte `held.gd` jetzt ungefähr aussehen:

```gdscript
extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -376.0
const JUMP_CUT = 0.5              # Taste früh losgelassen: restlichen Schwung halbieren
const FALL_GRAVITY_FACTOR = 1.6   # beim Fallen stärker nach unten ziehen
const MAX_FALL_SPEED = 300.0
const FALL_LIMIT = 224            # tiefer als das: runtergefallen

var start_position: Vector2


func _ready() -> void:
	start_position = position


func _physics_process(delta: float) -> void:
	# Schwerkraft, beim Fallen stärker
	if not is_on_floor():
		var gravity := get_gravity()
		if velocity.y > 0:
			gravity *= FALL_GRAVITY_FACTOR
		velocity += gravity * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)

	# Runtergefallen
	if position.y > FALL_LIMIT:
		position = start_position
		velocity = Vector2.ZERO

	# Springen, und kürzer springen beim frühen Loslassen
	if Input.is_action_just_pressed("springen") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("springen") and velocity.y < 0:
		velocity.y *= JUMP_CUT

	# Laufen
	var direction := Input.get_axis("links", "rechts")
	if direction:
		velocity.x = direction * SPEED
		$Bild.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
```

Ausprobieren: kurz tippen und lang halten an deiner Treppe. Fühlt sich der Sprung besser an als vorher?

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 2

1. **Am Gefühl drehen (leicht):** Probier `JUMP_CUT` mit `0.2`, `0.5` und `1.0` aus und `FALL_GRAVITY_FACTOR` mit `1.0`, `1.6` und `3.0`. Was passiert bei `JUMP_CUT = 1.0`? Such dir die Werte aus, die sich für dich am besten anfühlen. Game Feel ist Geschmackssache, es gibt kein Richtig.
2. **Rennen (leicht):** Leg eine Aktion `rennen` an (Shift). Solange sie gedrückt ist, läuft der Held mit `RUN_SPEED = 160.0` statt `SPEED`. Kommt er mit Anlauf über eine breitere Lücke? Bau eine in deinen Level, die man nur rennend schafft.
3. **Gamepad (mittel):** Falls du einen Controller hast: Gib den Aktionen in der Input Map auch Gamepad-Eingaben (für `links`/`rechts` den linken Stick, *Joypad Axis*, und das Steuerkreuz, für `springen` den unteren Knopf, *Joypad Button 0*). Musst du am Skript etwas ändern? Warum nicht?
4. **Sprung-Sound (mittel):** Wie bei Flatterfisch: einen kurzen Sprung-Ton mit 🆓 jsfxr machen, als `AudioStreamPlayer` namens `SprungTon` an den Held hängen und beim Abspringen abspielen. Denk an die Lehre aus Flatterfisch: Ohne zugewiesenen **Stream** bleibt es still, ohne Fehlermeldung.
