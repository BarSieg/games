# Hüpfheld – Schritt-für-Schritt-Anleitung

Ein Jump'n'Run nach dem Vorbild von Super Mario Bros. Level 1-1. Wie bei Flatterfisch baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Das Projekt ist größer als Flatterfisch (die Roadmap rechnet mit 2–3 Wochen). Dafür kannst du vieles wiederverwenden: Szenen, Signale, Gruppen, Process Mode, Export.

**Geplante Kapitel:**
1. Projekt, Grafiken und die erste Plattform ✔
2. Laufen und Springen, die sich gut anfühlen (eigene Steuerung, variable Sprunghöhe) ✔
3. Game Feel: Beschleunigung, Coyote Time, Jump Buffering ✔
4. Kamera und ein langer Level ✔
5. Animationen: stehen, laufen, springen ← *du bist hier*
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

---

## Kapitel 3: Game Feel

„Game Feel“ nennt man alles, was ein Spiel sich gut anfühlen lässt, ohne dass man es bewusst bemerkt. Spieler sagen dann „die Steuerung ist präzise“ oder „fühlt sich schwammig an“. In diesem Kapitel kommen drei Tricks dazu, die fast jedes gute Jump'n'Run benutzt.

### 3.1 Beschleunigen und Abbremsen

Im Moment ist der Held sofort auf voller Geschwindigkeit und steht sofort still. Das ist präzise, wirkt aber, als hätte er kein Gewicht. Mario dagegen nimmt Anlauf und rutscht ein Stück nach.

Die Idee: `velocity.x` springt nicht auf den Zielwert, sondern bewegt sich jedes Bild ein Stück darauf zu. Dafür hast du `move_toward` schon. Bisher war die Schrittweite `SPEED`, also alles auf einmal. Jetzt wird sie klein.

Neue Konstanten. Die Einheit ist Pixel pro Sekunde², also „so viel schneller pro Sekunde“:

```gdscript
const ACCELERATION = 600.0        # am Boden loslaufen
const FRICTION = 800.0            # am Boden abbremsen
const AIR_ACCELERATION = 400.0    # in der Luft lenken
const AIR_FRICTION = 150.0        # in der Luft fast keine Bremse: der Schwung bleibt
```

Bei 600 ist der Held nach 1/6 Sekunde auf 100. Bewusst merkt man das kaum, aber es fühlt sich weicher an.

Den ganzen Lauf-Teil ersetzt du so:

```gdscript
	# Laufen: Die Geschwindigkeit nähert sich dem Ziel, statt zu springen
	var direction := Input.get_axis("links", "rechts")
	var max_speed := RUN_SPEED if Input.is_action_pressed("rennen") else SPEED
	var accel: float
	if direction:
		accel = ACCELERATION if is_on_floor() else AIR_ACCELERATION
		$Bild.flip_h = direction < 0
	else:
		accel = FRICTION if is_on_floor() else AIR_FRICTION
	velocity.x = move_toward(velocity.x, direction * max_speed, accel * delta)
```

Neu ist die Schreibweise **`A if Bedingung else B`**. Das ist dasselbe wie `Bedingung ? A : B` in JavaScript: ein `if` in einer Zeile, das einen Wert ergibt.

Der Trick steckt in der letzten Zeile. Das Ziel ist `direction * max_speed`: mit gedrückter Taste 100 (oder 160 beim Rennen), ohne Taste 0. Losrennen, Abbremsen und vom Rennen zurück zum Gehen sind damit alle dieselbe Zeile, nur `accel` ist jeweils anders.

Das `* delta` ist wichtig. Die Beschleunigung gilt pro Sekunde, ein Bild dauert aber nur 1/60 Sekunde. Das kennst du aus den JavaScript-Spielen (`dt`).

Ausprobieren: Spring mit Anlauf und lass in der Luft die Taste los. Der Held fliegt fast genauso weit weiter, statt in der Luft stehen zu bleiben. Das behebt auch etwas aus Übung 2 von Kapitel 2: Bisher fiel der Held in der Luft sofort auf Schrittgeschwindigkeit zurück, wenn man Shift losließ.

### 3.2 Coyote Time

Kennst du das aus Zeichentrickfilmen? Der Kojote rennt über die Klippe hinaus, schwebt kurz in der Luft und fällt erst, wenn er nach unten schaut.

Das Problem im Spiel: Spieler drücken Springen oft ein paar Hundertstelsekunden zu spät, wenn der Held schon über die Kante gelaufen ist. `is_on_floor()` ist dann `false`, der Sprung kommt nicht, und es fühlt sich an, als hätte das Spiel die Taste verschluckt. Die Lösung: Man darf noch kurz nach dem Verlassen des Bodens springen. Etwa 0,1 Sekunden reichen, sehen tut das niemand.

Du brauchst dafür einen Zähler, der herunterläuft. Bei Flatterfisch hast du `Timer`-Nodes benutzt. Für so kurze Zeiten, die jedes Bild neu gesetzt werden, ist eine einfache Zahl aber übersichtlicher, wie dein `alienSpawn -= dt` bei Weltraumsteine.

```gdscript
const COYOTE_TIME = 0.1           # so lange nach der Kante darf man noch springen

var coyote_timer := 0.0
```

Ganz oben in `_physics_process`, noch vor der Schwerkraft:

```gdscript
	# Coyote Time: Am Boden wird der Zähler voll, in der Luft läuft er ab
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
```

Der Sprung fragt jetzt den Zähler statt `is_on_floor()`:

```gdscript
	if Input.is_action_just_pressed("springen") and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0
		$SprungTon.play()
```

`coyote_timer = 0` beim Absprung ist wichtig. Sonst könnte man in den ersten 0,1 Sekunden des Sprungs ein zweites Mal springen.

### 3.3 Jump Buffering

Das ist das Gegenstück zur Coyote Time: Der Spieler drückt Springen ein paar Hundertstel **zu früh**, kurz bevor der Held landet. Auch dieser Druck ginge verloren. Also merkt sich das Spiel den Tastendruck einen Moment lang und springt, sobald der Held den Boden berührt.

```gdscript
const JUMP_BUFFER = 0.1           # so lange wird ein zu früher Sprung gemerkt

var jump_buffer_timer := 0.0
```

Der Sprung-Teil wird zu:

```gdscript
	# Jump Buffering: Ein Tastendruck gilt noch kurze Zeit
	if Input.is_action_just_pressed("springen"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer -= delta

	# Springen, wenn beides passt: Taste gerade gedrückt, Boden gerade unter den Füßen
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
		$SprungTon.play()
	if Input.is_action_just_released("springen") and velocity.y < 0:
		velocity.y *= JUMP_CUT
```

Beide Zähler werden beim Absprung auf 0 gesetzt. So wird aus einem Tastendruck genau ein Sprung.

Ausprobieren: Spring mehrmals hintereinander die Treppe hoch und drück die Taste jedes Mal kurz vor der Landung. Vorher kam dabei manchmal kein Sprung, jetzt klappt es jedes Mal.

### 3.4 Das ganze Skript

```gdscript
extends CharacterBody2D


const SPEED = 100.0
const RUN_SPEED = 160.0
const ACCELERATION = 600.0        # am Boden loslaufen
const FRICTION = 800.0            # am Boden abbremsen
const AIR_ACCELERATION = 400.0    # in der Luft lenken
const AIR_FRICTION = 150.0        # in der Luft fast keine Bremse: der Schwung bleibt
const JUMP_VELOCITY = -376.0
const JUMP_CUT = 0.4              # Taste früh losgelassen: restlichen Schwung kürzen
const FALL_GRAVITY_FACTOR = 1.7   # beim Fallen stärker nach unten ziehen
const MAX_FALL_SPEED = 300.0
const FALL_LIMIT = 224            # tiefer als das: runtergefallen
const COYOTE_TIME = 0.1           # so lange nach der Kante darf man noch springen
const JUMP_BUFFER = 0.1           # so lange wird ein zu früher Sprung gemerkt

var start_position: Vector2
var coyote_timer := 0.0
var jump_buffer_timer := 0.0


func _ready() -> void:
	start_position = position


func _physics_process(delta: float) -> void:
	# Coyote Time: Am Boden wird der Zähler voll, in der Luft läuft er ab
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

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

	# Jump Buffering: Ein Tastendruck gilt noch kurze Zeit
	if Input.is_action_just_pressed("springen"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer -= delta

	# Springen, wenn beides passt: Taste gerade gedrückt, Boden gerade unter den Füßen
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
		$SprungTon.play()
	if Input.is_action_just_released("springen") and velocity.y < 0:
		velocity.y *= JUMP_CUT

	# Laufen: Die Geschwindigkeit nähert sich dem Ziel, statt zu springen
	var direction := Input.get_axis("links", "rechts")
	var max_speed := RUN_SPEED if Input.is_action_pressed("rennen") else SPEED
	var accel: float
	if direction:
		accel = ACCELERATION if is_on_floor() else AIR_ACCELERATION
		$Bild.flip_h = direction < 0
	else:
		accel = FRICTION if is_on_floor() else AIR_FRICTION
	velocity.x = move_toward(velocity.x, direction * max_speed, accel * delta)

	move_and_slide()
```

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 3

1. **Werte sichtbar machen (leicht):** Häng ein `Label` namens `Debug` an den Held, mit kleiner Schrift und über seinen Kopf geschoben. Am Ende von `_physics_process` schreibst du die Geschwindigkeit hinein: `$Debug.text = "%d %d" % [velocity.x, velocity.y]`. Bei mehreren Werten steht hinter dem `%` eine Liste in eckigen Klammern. Wie schnell ist der Held am höchsten Punkt eines Sprungs? Und wie schnell kurz vor der Landung nach einem langen Sturz?
2. **Kojote übertreiben (leicht):** Setz `COYOTE_TIME` auf `0.5` und lauf über eine Kante. Was kannst du jetzt, was eigentlich nicht gehen sollte? Danach auf `0`: Merkst du beim Springen an Kanten einen Unterschied zu `0.1`?
3. **Bremsspur (mittel):** Bei Mario rutscht der Held beim Umdrehen kurz weiter, bremst dabei aber stärker als beim normalen Ausrollen. Bau eine Konstante `TURN_ACCELERATION = 1200.0` ein. Sie gilt, wenn der Held am Boden ist, eine Richtung gedrückt ist **und** er sich gerade in die andere Richtung bewegt. Tipp: Zwei Zahlen haben verschiedene Vorzeichen, wenn ihr Produkt kleiner als 0 ist: `direction * velocity.x < 0`.
4. **Der verschluckte Kurzsprung (knifflig):** Tipp die Sprungtaste ganz kurz an, kurz bevor der Held landet. Er macht dann einen vollen, hohen Sprung, obwohl du nur getippt hast. Warum? Denk daran, wann `is_action_just_released` kommt und wann der gemerkte Sprung ausgelöst wird. Repariere es beim Absprung mit zwei Zeilen. Tipp: `Input.is_action_pressed("springen")` sagt dir, ob die Taste in diesem Moment noch gedrückt ist.

---

## Kapitel 4: Kamera und ein langer Level

Bisher passt der ganze Level auf einen Bildschirm. Level 1-1 von Mario ist aber gut 13 Bildschirme lang. In diesem Kapitel folgt eine Kamera dem Held, der Level wird lang, und dahinter zieht ein Hintergrund langsamer vorbei.

### 4.1 Pixel sauber halten

Sobald sich eine Kamera bewegt, steht sie oft zwischen zwei Pixeln, zum Beispiel bei x = 103,4. Bei Pixel-Art führt das zu Zittern: Mal wird ein Pixel nach links gerundet, mal nach rechts, und Held und Kacheln wackeln gegeneinander. Dagegen hilft eine Einstellung.

*Project → Project Settings* (mit **Advanced Settings**) → Rendering → 2D → Snap:

| Einstellung | Wert |
|---|---|
| **Snap 2D Transforms to Pixel** | an |

Godot rundet dann alle Positionen beim Zeichnen auf ganze Pixel. Gerechnet wird weiterhin genau, nur das Bild ist sauber.

### 4.2 Die Kamera

1. `held.tscn` öffnen. Rechtsklick auf `Held` → **Add Child Node** → `Camera2D`.
2. Im Inspector:

| Einstellung | Wert | Warum |
|---|---|---|
| **Limit → Left** | `0` | Links vom Levelanfang gibt es nichts zu sehen. |
| **Limit → Top** | `0` | Zusammen mit Bottom: Der Level ist genau 216 hoch, die Kamera bewegt sich also nie nach oben oder unten. So ist es bei Mario auch. |
| **Limit → Bottom** | `216` | 12 Kacheln × 18 Pixel. |
| **Limit → Right** | erst mal so lassen | Das setzen wir, wenn der Level fertig ist (4.4). |
| **Position Smoothing → Enabled** | an | Die Kamera gleitet hinterher, statt am Held zu kleben. |
| **Position Smoothing → Speed** | `8` | Größer heißt: schneller hinterher. |

Eine Kamera, die ein Kind des Helden ist, bewegt sich automatisch mit ihm. Code brauchst du dafür nicht.

3. **F5**: Lauf nach rechts aus dem Bild. Die Kamera folgt.

Dein Level ist bisher nur einen Bildschirm breit, also läuft der Held gleich ins Leere. Das ändern wir in 4.4.

### 4.3 Nach dem Sturz nicht durch den Level gleiten

Probier es: Fall in ein Loch weit rechts. Der Held erscheint am Start, aber die Kamera gleitet gemütlich durch den ganzen Level zurück. Das liegt am Smoothing. Nach einem Sprung an eine neue Stelle soll die Kamera sofort dort sein.

In `held.gd` beim Runtergefallen eine Zeile dazu:

```gdscript
	# Runtergefallen
	if position.y > FALL_LIMIT:
		position = start_position
		velocity = Vector2.ZERO
		$Camera2D.reset_smoothing()
```

`reset_smoothing()` heißt: Vergiss das Gleiten und spring direkt ans Ziel.

### 4.4 Ein langer Level

Jetzt kommt der kreative Teil. Mal den Level in `level.tscn` breiter, als Richtwert etwa **120 Kacheln** (gut 2000 Pixel, knapp 6 Bildschirme). Level 1-1 ist so aufgebaut, dass jeder Abschnitt eine Sache beibringt. Nimm dir das als Vorbild, ohne es abzumalen:

1. **Start:** flacher Boden, nichts passiert. Der Spieler probiert die Steuerung aus.
2. **Erste schwebende Blöcke:** eine Reihe in 4 Kacheln Höhe. Hier kommen in Kapitel 7 Münzblöcke hin.
3. **Säulen** in steigender Höhe: 2, 3 und 4 Kacheln. Die letzte schafft man nur mit vollem Sprung. Bei Mario sind das die grünen Röhren.
4. **Erste Lücke:** 2 Kacheln breit, einfach.
5. **Plattformen über einer längeren Lücke**, zum Beispiel deine One-Way-Plattformen.
6. **Eine breitere Lücke**, die man nur mit Anlauf (Rennen) schafft.
7. **Treppen:** eine Pyramide hoch und wieder runter, dann eine Treppe mit Lücke dazwischen.
8. **Ende:** eine große Treppe, danach ein flaches Stück. Hier kommt in Kapitel 8 das Ziel hin.

Lass zwischen den Abschnitten flache Stücke zum Durchatmen. Und bedenke: Der Held springt etwa 4 Kacheln hoch. Was höher als 4 Kacheln ist, ist eine Wand.

Wenn der Level fertig ist, brauchst du die rechte Kante der letzten Kachel. Oben und links im 2D-Editor sind Lineale mit Pixel-Koordinaten. Lies oben ab, wo die letzte Kachel rechts aufhört. Das ist immer ein Vielfaches von 18, bei 120 Kacheln zum Beispiel 120 × 18 = 2160. Diesen Wert trägst du in der Kamera bei **Limit → Right** ein.

### 4.5 Himmel und Hintergrund

Der graue Hintergrund ist Godots Standardfarbe. Für einen Himmel brauchst du keine Kacheln:

*Project Settings* → Rendering → Environment → **Default Clear Color** → ein helles Blau.

Dazu kommt ein Hintergrund, der langsamer vorbeizieht als der Level. Das ist der Parallax-Effekt, den du von Flatterfisch kennst.

1. In `level.tscn`: Rechtsklick auf `Level` → **Add Child Node** → `Parallax2D` → umbenennen in `Hintergrund`. Im Szenenbaum ganz nach oben ziehen, damit es hinter allem gezeichnet wird.
2. Darunter eine `TileMapLayer` namens `Huegel` anlegen, mit einem neuen TileSet aus `tilemap-backgrounds_packed.png`. Diese Kacheln sind **24 × 24** groß, nicht 18. Also **Tile Size** `24, 24`, bevor du das Bild hineinziehst.
3. Schau dir das Kachelblatt an: Es enthält Himmel-, Wolken- und Hügel-Stücke. Mal damit einen Streifen, der genau **16 Kacheln breit** ist (16 × 24 = 384, eine Bildschirmbreite), unten auf Höhe des Bodens.
4. `Hintergrund` im Inspector:

| Einstellung | Wert | Warum |
|---|---|---|
| **Scroll Scale** | `0.5, 1` | Halb so schnell wie die Kamera, das wirkt weit weg. |
| **Repeat → Repeat Size** | `384, 0` | Der Streifen wiederholt sich alle 384 Pixel, nach rechts endlos. |

Den Hintergrund-Streifen brauchst du also nur einmal zu malen.

Erinnerst du dich an die Streifen am Sand bei Flatterfisch? Hier passieren sie nicht: Die Kacheln werden mit Nearest-Filter gezeichnet und nicht als Tile-Textur gestreckt.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 4

1. **Kamera ausprobieren (leicht):** Stell **Position Smoothing → Speed** auf `2` und auf `20`. Was ist der Unterschied? Was passiert ganz ohne Smoothing? Such dir den Wert aus, der dir gefällt.
2. **Vorausschauen (leicht):** Die Kamera zeigt gleich viel vor und hinter dem Held. Nach vorne zu sehen ist aber wichtiger. Schieb die Kamera ein Stück nach vorne: Ihre **Offset**-Eigenschaft, zum Beispiel `40, 0`. Was passiert jetzt, wenn der Held nach links läuft? (Eine Lösung, bei der die Kamera mit der Laufrichtung umschwenkt, findest du vielleicht selbst: `flip_h` kennst du schon.)
3. **Zweite Parallax-Ebene (mittel):** Leg eine zweite `Parallax2D` mit Wolken an, die noch langsamer zieht (`Scroll Scale` 0.25). Die Wolken dürfen aus dem normalen Kachelblatt oder aus dem Hintergrund-Blatt kommen. Bonus: Lass sie mit **Autoscroll** ganz langsam von allein ziehen, wie bei Flatterfisch.
4. **Kein Weg zurück (knifflig):** Bei Mario kann man nie zurück nach links laufen: Die Kamera fährt nur nach rechts, und der linke Bildrand ist eine Wand. Bau das nach. Tipps:
   - Die linke Bildkante liegt bei `$Camera2D.get_screen_center_position().x - 192` (die halbe Bildschirmbreite).
   - Wenn du `$Camera2D.limit_left` jedes Bild auf diese Kante setzt (aber nur, wenn sie dadurch größer wird), kann die Kamera nicht mehr zurück.
   - Den Held hältst du mit `position.x = max(position.x, …)` im Bild. Denk an die halbe Breite des Helden.
   - Was passiert jetzt beim Runterfallen und Neustart am Anfang? Was musst du dort zurücksetzen?

---

## Kapitel 5: Animationen

Der Held gleitet im Moment als starres Bild durch den Level. In diesem Kapitel bekommt er Beine: ein Bild zum Stehen, eine Laufanimation und ein Sprungbild. Die Technik kennst du vom Flossenschlag bei Flatterfisch (`AnimatedSprite2D`). Neu ist, dass das Skript abhängig vom Zustand selbst entscheidet, welche Animation läuft.

### 5.1 Die Bilder zeichnen

In 🆓 Piskel oder 🆓 Pixelorama, jedes Bild 16 × 16 wie bisher:

| Animation | Bilder | Idee |
|---|---|---|
| `stehen` | 1 | dein jetziges `held.png` |
| `laufen` | 3 oder 4 | Beine abwechselnd vorne und hinten. Bei 3 Bildern zum Beispiel: Schritt links, Beine zusammen, Schritt rechts |
| `springen` | 1 | Beine angezogen, Arme hoch |

Tipp: Fang mit dem Stehbild an, kopiere es (in Piskel: das Bild links in der Liste duplizieren) und ändere nur die Beine. So bleibt der Körper in allen Bildern an derselben Stelle und wackelt nicht.

Exportiere alle Bilder als **ein Sprite-Sheet**: in Piskel unter *Export → PNG* mit allen Bildern nebeneinander in einer Zeile. Speichern als `held_sheet.png` und ins FileSystem ziehen.

### 5.2 Aus `Bild` wird eine `AnimatedSprite2D`

Du musst den Node nicht löschen und neu anlegen. In `held.tscn`:

1. Rechtsklick auf `Bild` → **Change Type** → `AnimatedSprite2D`.

Name und Position bleiben dabei, und `$Bild.flip_h` im Skript funktioniert weiter, denn `AnimatedSprite2D` kann das auch. Nur die **Texture** fällt weg, an ihre Stelle kommen **Sprite Frames**.

2. Im Inspector **Sprite Frames** → **New SpriteFrames** → darauf klicken. Unten öffnet sich der SpriteFrames-Editor.
3. Die Animation `default` umbenennen in `stehen` (Doppelklick).
4. Auf das Raster-Symbol klicken (**Add frames from a Sprite Sheet**), `held_sheet.png` wählen und bei *Horizontal* die Zahl deiner Bilder eintragen, bei *Vertical* `1`. Godot zeigt die Bilder nummeriert an. Für `stehen` nur das Stehbild anklicken → **Add Frames**.
5. Mit **Add Animation** (das Blatt-Symbol links oben) `laufen` und `springen` anlegen und genauso füllen.
6. Bei `laufen`: **Loop** an (das Pfeil-Symbol) und das Tempo auf etwa **10 FPS**. Bei `stehen` und `springen` ist das Tempo egal, es gibt nur ein Bild.
7. Bei **Autoplay on Load** (das Symbol mit dem A und dem Pfeil) die Animation `stehen` wählen.

Wenn du jetzt F5 drückst, steht der Held wie vorher. Gewechselt wird noch nicht.

### 5.3 Die richtige Animation wählen

Welche Animation läuft, hängt davon ab, was der Held gerade tut. Das gehört in eine eigene Funktion, damit `_physics_process` übersichtlich bleibt:

```gdscript
# Welche Animation passt gerade?
func update_animation() -> void:
	if not is_on_floor():
		$Bild.play("springen")
	elif abs(velocity.x) > 5:
		$Bild.play("laufen")
	else:
		$Bild.play("stehen")
```

Aufgerufen wird sie ganz am Ende von `_physics_process`, nach `move_and_slide()`. Dann stimmt `is_on_floor()` schon für dieses Bild.

```gdscript
	move_and_slide()
	update_animation()
```

Drei Dinge dazu:

- **`elif`** ist „else if“. Es wird nur geprüft, wenn das `if` davor nicht gepasst hat. In JavaScript schreibst du `else if`.
- **`abs`** macht eine Zahl positiv: `abs(-80)` ist 80. So zählt Laufen nach links und nach rechts gleich.
- **`> 5` statt `!= 0`:** Durch das Abbremsen aus Kapitel 3 ist `velocity.x` am Ende ein paar Bilder lang winzig klein, aber nicht 0. Der Held würde dann auf der Stelle trippeln.

Und warum ist es kein Problem, dass `play` jedes Bild aufgerufen wird? Läuft die Animation schon, macht `play` mit demselben Namen einfach nichts. Sie fängt nicht jedes Bild von vorne an.

### 5.4 Ausprobieren

**F5**: stehen, loslaufen, springen, landen. Achte auf zwei Dinge:

- Beim Runterlaufen von einer Kante zeigt der Held sofort das Sprungbild, obwohl er gar nicht gesprungen ist. Das ist bei Mario genauso und fällt nicht auf. (Wenn es dich stört: Übung 1.)
- Wirken die Beine beim Laufen zu schnell oder zu langsam? Dreh am Tempo der Animation im SpriteFrames-Editor.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 5

1. **Fallen ist nicht Springen (leicht):** Zeichne ein Bild `fallen`, zum Beispiel mit Armen nach oben und gestreckten Beinen. Zeige `springen`, solange der Held steigt, und `fallen`, sobald er sinkt. Welche Zahl verrät dir, ob er steigt oder sinkt?
2. **Schritte im Takt (leicht):** Beim Rennen sollen die Beine schneller gehen. Eine `AnimatedSprite2D` hat dafür `speed_scale`: `1.0` ist normal, `2.0` doppelt so schnell. Setz es beim Laufen auf `abs(velocity.x) / SPEED`. Was passiert beim Anlaufen aus dem Stand?
3. **Bremsen (mittel):** Zu deiner Bremsspur aus Kapitel 3 gehört ein Bild: Bei Mario dreht sich der Held beim Umdrehen schon in die neue Richtung und stemmt die Füße in den Boden. Zeichne ein Bild `bremsen` und zeig es, solange `direction * velocity.x < 0` ist und der Held am Boden steht. Tipp: `direction` kennt `update_animation()` nicht, weil es eine lokale Variable in `_physics_process` ist. Gib sie als Parameter mit: `update_animation(direction)`.
4. **Staubwolke (mittel):** Beim Landen soll kurz etwas Staub aufwirbeln. Häng eine `CPUParticles2D` namens `Staub` an die Füße des Helden: **One Shot** an, **Emitting** aus, wenige Partikel (etwa 6), kurze **Lifetime** (0,3), eine helle Farbe. Abspielen mit `$Staub.restart()`. Das Knifflige ist der Moment: Du musst wissen, dass der Held im letzten Bild noch in der Luft war und jetzt am Boden steht. Merk dir dazu am Ende jedes Bilds in einer Variablen, ob er in der Luft war.
