# Hüpfheld – Schritt-für-Schritt-Anleitung

Ein Jump'n'Run nach dem Vorbild von Super Mario Bros. Level 1-1. Wie bei Flatterfisch baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Das Projekt ist größer als Flatterfisch (die Roadmap rechnet mit 2–3 Wochen). Dafür kannst du vieles wiederverwenden: Szenen, Signale, Gruppen, Process Mode, Export.

**Geplante Kapitel:**
1. Projekt, Grafiken und die erste Plattform ✔
2. Laufen und Springen, die sich gut anfühlen (eigene Steuerung, variable Sprunghöhe) ✔
3. Game Feel: Beschleunigung, Coyote Time, Jump Buffering ✔
4. Kamera und ein langer Level ✔
5. Animationen: stehen, laufen, springen ✔
6. Gegner: patrouillieren und plattgesprungen werden ✔
7. Blöcke und Items: Münzen und ein Power-up ✔
8. Ziel, Leben, Anzeige und Web-Export ✔
9. Bonuslevel: durch die Röhre in einen anderen Raum ← *du bist hier*

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

---

## Kapitel 6: Gegner

Jetzt bekommt der Level Bewohner: kleine Krabbler, die hin und her laufen. Springt man ihnen auf den Kopf, sind sie platt. Berührt man sie von der Seite, ist der Held erledigt. Das ist das Grundprinzip jedes Mario-Gegners.

Neu in diesem Kapitel sind **Kollisionsebenen**: Wer stößt mit wem zusammen und wer bemerkt wen?

### 6.1 Kollisionsebenen benennen

Bisher liegt alles auf derselben Ebene 1: Kacheln, Held, alles stößt mit allem zusammen. Mit Gegnern wird das zum Problem. Der Held würde Gegner vor sich herschieben wie Kisten, statt mit ihnen zusammenzustoßen. Deshalb verteilt man die Dinge auf Ebenen.

*Project Settings* → General → Layer Names → **2D Physics**:

| Ebene | Name |
|---|---|
| 1 | `Welt` |
| 2 | `Held` |
| 3 | `Gegner` |

Jedes Physik-Objekt hat zwei Einstellungen unter **Collision**:

- **Layer:** Auf welcher Ebene *bin ich*?
- **Mask:** Welche Ebenen *bemerke ich*? Gegen die stoße ich, oder die melde ich als Signal.

Die Kacheln liegen schon auf Ebene 1, das ist im TileSet so eingestellt.

Jetzt beim Held: `held.tscn` öffnen, `Held` auswählen → **Collision**:
- **Layer:** nur `2` (das Kästchen 1 ausschalten, 2 einschalten).
- **Mask:** nur `1`. Der Held steht auf der Welt, durch Gegner läuft er körperlich hindurch. Ob er sie berührt, merkt der Gegner selbst (6.4).

Wenn du über die Kästchen fährst, zeigt Godot die Namen, die du eben vergeben hast.

### 6.2 Die Gegner-Szene

Grafik: Im Kachelblatt `tilemap-characters_packed.png` von Kenney sind neben Spielfiguren auch kleine Gegner, jeweils mit zwei Bildern zum Laufen. Die Bilder sind **24 × 24** groß, das Blatt hat 9 Spalten und 3 Zeilen. Du kannst auch einen eigenen Gegner zeichnen, wie beim Held.

1. *Scene → New Scene* → **Other Node** → `CharacterBody2D` → umbenennen in `Gegner`.
2. **Collision → Layer:** nur `3`. **Mask:** nur `1`. Gegner laufen auf der Welt und laufen durch den Held hindurch.
3. Kinder hinzufügen:
   - `AnimatedSprite2D` → `Bild`. New SpriteFrames, Animation `laufen` (Loop an, etwa 5 FPS) mit den zwei Bildern deines Gegners aus dem Kachelblatt (Add frames from a Sprite Sheet, Horizontal `9`, Vertical `3`). **Autoplay on Load** = `laufen`. Lege auch eine Animation `platt` mit einem Bild an, das zweite Bild reicht für den Anfang.
   - `CollisionShape2D` → RectangleShape2D, so groß wie der *sichtbare* Körper des Gegners, nicht wie das ganze 24-er Bild. Schieb die Form so, dass ihre Unterkante genau an den Füßen liegt. Sonst schwebt der Gegner über dem Boden oder versinkt darin.
   - `Area2D` → `Treffer`, mit einer eigenen `CollisionShape2D`: dieselbe Form, nur 1 bis 2 Pixel größer. **Collision → Layer:** keine. **Mask:** nur `2`. Diese Fläche meldet also ausschließlich den Held.
4. Speichern als `gegner.tscn`.

Warum zwei Formen? Die `CollisionShape2D` direkt am Gegner ist für die Physik: Boden, Wände. Die `Treffer`-Fläche ist ein Sensor. Sie hält nichts auf, sie meldet nur. Das kennst du von der Punktzone der Korallen bei Flatterfisch.

### 6.3 Hin und her laufen

Skript an `Gegner` hängen (diesmal **ohne** Vorlage, *Template* auf **Empty**). Speichern als `gegner.gd`:

```gdscript
extends CharacterBody2D


const SPEED = 30.0

var direction := -1.0   # startet nach links, dem Held entgegen


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = direction * SPEED
	move_and_slide()

	# An einer Wand umdrehen
	if is_on_wall():
		direction = -direction
	$Bild.flip_h = direction > 0
```

- `is_on_wall()` ist wie `is_on_floor()`, nur für die Seiten: Ist der Gegner beim letzten `move_and_slide()` gegen etwas Seitliches gestoßen?
- `direction = -direction` dreht die Richtung um, aus -1 wird 1 und umgekehrt.
- Bei `flip_h` kommt es darauf an, wohin dein Bild schaut. Schaut der Gegner im Bild nach links, ist `direction > 0` richtig. Läuft er rückwärts, nimm `direction < 0`.

Zum Testen: Setz einen Gegner in `level.tscn` zwischen zwei Säulen und drück F5. Er sollte hin und her pendeln.

### 6.4 Draufspringen oder erwischt werden

Wenn der Held die `Treffer`-Fläche berührt, gibt es zwei Möglichkeiten:

- Der Held **fällt** gerade (`velocity.y > 0`) **und** ist **über** dem Gegner: Der Gegner ist platt, der Held prallt ab.
- Sonst: Der Held hat verloren.

**Signal verbinden:** `Treffer` auswählen → Tab **Node** → **Signals** → `body_entered` doppelklicken → mit `Gegner` verbinden. Godot legt in `gegner.gd` die Funktion `_on_treffer_body_entered` an. Fülle sie so:

```gdscript
func _on_treffer_body_entered(body: Node2D) -> void:
	# Von oben drauf: platt. Sonst hat der Held verloren.
	if body.velocity.y > 0 and body.global_position.y < global_position.y:
		plattmachen()
		body.abprallen()
	else:
		body.sterben()
```

`body` ist hier immer der Held, denn die Maske von `Treffer` meldet nur Ebene 2. Deshalb darf man einfach `body.velocity` fragen und `body.sterben()` aufrufen.

`global_position` statt `position`: Die `position` ist immer relativ zum Eltern-Node. Held und Gegner sind beide Kinder von `Level`, da wäre es gleich. `global_position` ist aber immer die Position in der Welt und damit die sichere Wahl, wenn man zwei Objekte vergleicht.

Und das Plattmachen:

```gdscript
func plattmachen() -> void:
	$Bild.play("platt")
	set_physics_process(false)                   # nicht mehr laufen
	$Treffer.set_deferred("monitoring", false)   # nicht noch einmal treffen
	await get_tree().create_timer(0.5).timeout
	queue_free()
```

- `set_physics_process(false)` schaltet `_physics_process` für diesen Node ab. Der Gegner bleibt stehen.
- **`set_deferred`** heißt: „Mach das, aber erst am Ende dieses Physik-Schritts.“ Während Godot gerade Kollisionen meldet, darf man an Kollisionsformen nichts ändern. Ohne `set_deferred` gäbe es eine Fehlermeldung.
- `await … create_timer(0.5)` kennst du aus Flatterfisch. Der platte Gegner bleibt eine halbe Sekunde liegen, dann verschwindet er.

### 6.5 Der Held: abprallen und sterben

In `held.gd` zwei neue Funktionen. Zuerst die Konstante oben:

```gdscript
const STOMP_BOUNCE = -220.0       # so hoch prallt der Held vom Gegner ab
```

Dann:

```gdscript
# Auf einen Gegner gesprungen: hochfedern
func abprallen() -> void:
	velocity.y = STOMP_BOUNCE


# Erwischt: Level von vorn
func sterben() -> void:
	get_tree().reload_current_scene()
```

`reload_current_scene()` kennst du vom Neustart bei Flatterfisch. Es setzt alles zurück: Held, Kamera und auch die plattgemachten Gegner sind wieder da. Bei Mario fängt man nach dem Tod auch von vorne an. Leben und Punkte, die einen Neustart überleben, kommen in Kapitel 8.

Damit kannst du auch das Runterfallen vereinfachen. Statt alles einzeln zurückzusetzen:

```gdscript
	# Runtergefallen
	if position.y > FALL_LIMIT:
		sterben()
```

Danach brauchst du `start_position`, das `limit_left = 0` und die beiden Kamera-Zeilen beim Runterfallen nicht mehr. Du kannst sie löschen, `reload_current_scene()` erledigt das alles.

### 6.6 Erst loslaufen, wenn man sie sieht

Setz jetzt 4 bis 6 Gegner in deinen Level: einen allein auf dem ersten flachen Stück, ein Paar zwischen den Säulen, einen auf einer Plattform. Drück F5 und lauf zum letzten Gegner.

Wahrscheinlich fehlen einige. Alle Gegner laufen ab dem Start los, auch die, die noch weit rechts außerhalb des Bildes sind. Bis der Held ankommt, sind manche schon in eine Lücke gefallen. Bei Mario werden Gegner erst lebendig, wenn sie ins Bild kommen.

Dafür hat Godot einen fertigen Node: In `gegner.tscn` ein Kind `VisibleOnScreenEnabler2D` an `Gegner` hängen. Er zeigt ein Rechteck. Mach es etwa so groß wie den Gegner. Solange dieses Rechteck außerhalb des Bildschirms ist, schaltet der Enabler seinen Eltern-Node ab, also den Gegner. Sobald es ins Bild kommt, läuft der Gegner los.

Probier es noch einmal: Jetzt warten alle Gegner, bis du kommst.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 6

1. **Plopp (leicht):** Ein Geräusch beim Plattmachen. Mach mit 🆓 jsfxr einen kurzen Ton und spiel ihn ab. Vorsicht: Hängt der `AudioStreamPlayer` am Gegner, verschwindet er nach 0,5 Sekunden mit dem Gegner. Ist dein Ton länger, wird er abgeschnitten. Wo könnte der Player stattdessen hängen?
2. **Hoher Abpraller (leicht):** Bei Mario prallt man höher ab, wenn man beim Draufspringen die Sprungtaste gedrückt hält. Bau das in `abprallen()` ein, zum Beispiel mit `JUMP_VELOCITY` statt `STOMP_BOUNCE`, solange `springen` gedrückt ist.
3. **Nicht von der Kante fallen (mittel):** Manche Gegner drehen an Kanten um, statt herunterzufallen. Häng einen `RayCast2D` namens `Kante` an den Gegner: etwas vor seinen Füßen, mit **Target Position** `0, 10` (ein kurzer Strahl nach unten). Wenn `$Kante.is_colliding()` `false` ist, ist vor ihm kein Boden mehr: umdrehen. Damit der Strahl immer *vorne* ist, setzt du `$Kante.position.x` abhängig von `direction`. Mach eine zweite Gegner-Szene oder eine Einstellung mit `@export`, damit es beide Sorten gibt.
4. **Gegner stoßen sich (mittel):** Im Moment laufen Gegner durcheinander hindurch. Welche Einstellung musst du ändern, damit sie aneinander umdrehen wie an einer Wand? Tipp: Es ist nur ein Kästchen, kein Code.
5. **Ein richtiger Abgang (knifflig):** Bei Mario hüpft der Held beim Sterben einmal hoch und fällt dann durch den Boden aus dem Bild. Erst danach beginnt der Level neu. Bau das nach:
   - Eine Variable `tot`. Ist sie `true`, ignoriert `_physics_process` alle Eingaben und lässt nur noch die Schwerkraft wirken.
   - Beim Sterben: `velocity.y` kräftig nach oben, `velocity.x = 0` und die **Mask** auf 0 (`collision_mask = 0`), damit er durch den Boden fällt.
   - Mit `await` etwa 1,5 Sekunden warten, dann `reload_current_scene()`.
   - Denk an die Lehre aus Flatterfisch: Was passiert, wenn `sterben()` zweimal aufgerufen wird, zum Beispiel von zwei Gegnern gleichzeitig oder vom Gegner und danach vom Runterfallen?

---

## Kapitel 7: Blöcke und Items

Was wäre Mario ohne Münzen und Fragezeichen-Blöcke? In diesem Kapitel kommen drei Dinge dazu: Münzen zum Einsammeln, Blöcke, gegen die man von unten springt, und ein Power-up, das einen Treffer aushält.

Neu sind dabei **Tweens** (kleine Animationen per Code) und Szenen, die andere Szenen während des Spiels erzeugen. Vieles kennst du aber schon: `Area2D` als Sensor, Kollisionsebenen, `preload` und `instantiate` von den Korallen.

### 7.1 Bilder aus dem Kachelblatt ohne SpriteFrames

Für Blöcke und Items brauchst du einzelne Bilder aus `tilemap_packed.png`. Dafür gibt es einen einfachen Weg: Eine `Sprite2D` kann ein Kachelblatt selbst in Stücke teilen.

- **Texture** = `tilemap_packed.png`
- **Animation → Hframes** = `20` (Spalten), **Vframes** = `9` (Zeilen). Das Blatt ist 360 × 162 groß, das ergibt 18 × 18 pro Bild.
- **Animation → Frame** = die Nummer des Bildes: Zeile × 20 + Spalte, gezählt ab 0. Am einfachsten drehst du im Inspector an der Zahl, bis das richtige Bild erscheint.

Im Code kann man `frame` ändern. So wird aus einem vollen Block ein leerer, ohne zweites Bild.

Such dir im Kachelblatt aus:
- eine **Münze**,
- einen **Block**, der nach „da ist was drin“ aussieht, und einen, der leer oder benutzt aussieht,
- ein **Power-up**, zum Beispiel einen Pilz, ein Herz oder einen Edelstein.

### 7.2 Die Münze

1. Neue Szene → **Other Node** → `Area2D` → `Muenze`.
2. **Collision → Layer:** keine. **Mask:** nur `2` (Held).
3. Kinder: `Sprite2D` → `Bild` (wie in 7.1, mit dem Münzbild) und `CollisionShape2D` mit einem **CircleShape2D**, Radius etwa `6`.
4. Speichern als `muenze.tscn`, Skript `muenze.gd`. Das Signal `body_entered` der Münze mit sich selbst verbinden.

```gdscript
extends Area2D


func _on_body_entered(body: Node2D) -> void:
	body.muenze_einsammeln()
	queue_free()
```

Der Held zählt mit, vorerst in seinem Debug-Label. Eine richtige Anzeige kommt in Kapitel 8. In `held.gd`:

```gdscript
var muenzen := 0


# Eine Münze eingesammelt
func muenze_einsammeln() -> void:
	muenzen += 1
	$MuenzTon.play()
```

Und das Debug-Label zeigt jetzt die Münzen: `$Debug.text = "%d" % muenzen`.

Den `MuenzTon` (`AudioStreamPlayer` am Held, Ton mit 🆓 jsfxr, Vorlage *Pickup/Coin*) hängst du an den **Held**, nicht an die Münze. Du kennst das Problem aus Übung 1 von Kapitel 6: Die Münze verschwindet sofort, ihr Ton würde mit ihr verschwinden.

Verteil ein paar Münzen im Level. Eine Reihe über einer Lücke lockt den Spieler zum Springen. Eine Münze hoch über einer Säule belohnt den, der sich traut.

### 7.3 Der Block

Ein Block ist fest wie eine Kachel. Er merkt aber, wenn der Held von unten dagegen springt.

1. Neue Szene → **Other Node** → `StaticBody2D` → `Block`. Ein `StaticBody2D` bewegt sich nie, er ist einfach nur da, wie ein Stück Wand.
2. **Collision → Layer:** `1` (Welt). Der Held und die Gegner stehen darauf wie auf Kacheln.
3. Kinder:
   - `Sprite2D` → `Bild` mit dem vollen Block (7.1).
   - `CollisionShape2D` → RectangleShape2D `18, 18`.
   - `Area2D` → `Unterseite`, **Layer** keine, **Mask** `2`. Darin eine `CollisionShape2D` als Streifen direkt unter dem Block: Größe `14, 8`, Position `0, 13`. Er reicht also von der Unterkante des Blocks 8 Pixel nach unten.
     - Schmaler als der Block, damit ein Sprung knapp neben dem Block nicht zählt.
     - 8 Pixel hoch, weil der Held schnell ist: Beim Absprung steigt er gut 6 Pixel pro Bild. Wäre der Streifen dünner, könnte der Held im selben Bild hineinkommen und schon mit dem Kopf anstoßen. Dann steht `velocity.y` bereits auf 0, und die Bedingung „steigt gerade“ unten passt nicht mehr. Mit 8 Pixeln ist er sicher mindestens ein Bild lang im Streifen, während er noch steigt.
4. Speichern als `block.tscn`, Skript `block.gd`. Signal `body_entered` von `Unterseite` mit `Block` verbinden.

```gdscript
extends StaticBody2D


const FRAME_LEER = 0   # hier die Nummer deines leeren Blocks eintragen

var leer := false


func _on_unterseite_body_entered(body: Node2D) -> void:
	# Nur wenn der Held von unten kommt, also gerade steigt
	if body.velocity.y < 0 and not leer:
		leer = true
		$Bild.frame = FRAME_LEER
		body.muenze_einsammeln()
		anstossen()
```

`velocity.y < 0` heißt: Der Held steigt. Ohne diese Bedingung würde auch ein Held zählen, der seitlich durch den Streifen läuft.

Wenn der Held mit dem Kopf gegen den Block stößt, stoppt `move_and_slide()` den Sprung übrigens von selbst. Dafür musst du nichts tun.

### 7.4 Tweens: Der Block hüpft

Bei Mario hüpft ein Block kurz hoch, wenn man dagegen springt. Das könnte man mit einer Variablen und `_process` von Hand bauen. Für solche kleinen Bewegungen hat Godot aber **Tweens**. Ein Tween verändert eine Eigenschaft über eine bestimmte Zeit von ihrem jetzigen Wert zu einem Zielwert.

```gdscript
# Kurz hochhüpfen und zurück
func anstossen() -> void:
	var tween := create_tween()
	tween.tween_property($Bild, "position:y", -4.0, 0.08)
	tween.tween_property($Bild, "position:y", 0.0, 0.08)
```

- `create_tween()` erzeugt einen neuen Tween. Er startet sofort von selbst.
- `tween_property(Node, "Eigenschaft", Ziel, Sekunden)`: Schieb `$Bild.position.y` in 0,08 Sekunden auf -4.
- Mehrere `tween_property` laufen **nacheinander**: erst hoch, dann zurück. Fertig ist der Hüpfer.
- `"position:y"` mit Doppelpunkt heißt: nur der y-Teil der Position.

Bewegt wird nur das **Bild**, nicht der Block. Die Kollision bleibt an ihrem Platz, sonst würde der Held mit hochgeschoben.

Setz ein paar Blöcke in den Level, zum Beispiel an die Stelle aus Kapitel 4, an der eine Reihe Blöcke in 4 Kacheln Höhe schwebt.

### 7.5 Das Power-up

Bei Mario macht der Pilz den Helden groß, und er hält einen Treffer aus. Ein großer Held bräuchte neue, doppelt so hohe Bilder und eine andere Kollisionsform. Wir machen es einfacher: Das Power-up macht den Held **stark**. Er leuchtet golden, und ein Treffer macht ihn nur wieder normal, statt ihn zu besiegen.

**Die Power-up-Szene.** Ein Pilz läuft bei Mario wie ein Gegner über den Boden. Du kannst also fast alles von deinem Gegner übernehmen.

1. Neue Szene → `CharacterBody2D` → `PowerUp`. **Layer:** keine, **Mask:** `1`. Es läuft auf der Welt, und nichts stößt dagegen.
2. Kinder: `Sprite2D` `Bild` (7.1), `CollisionShape2D` (etwa `14, 14`), `Area2D` `Einsammeln` mit Mask `2` und einer etwas größeren Form.
3. Speichern als `power_up.tscn`, Skript `power_up.gd`:

```gdscript
extends CharacterBody2D


const SPEED = 40.0

var direction := 1.0   # läuft nach rechts aus dem Block


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = direction * SPEED
	move_and_slide()

	# An einer Wand umdrehen, wie der Gegner
	if is_on_wall() and get_wall_normal().x * direction < 0:
		direction = -direction


func _on_einsammeln_body_entered(body: Node2D) -> void:
	body.power_up()
	queue_free()
```

**Der Block erzeugt das Power-up.** In `block.gd` eine Einstellung, ob der Block eine Münze oder ein Power-up enthält:

```gdscript
const POWER_UP = preload("res://power_up.tscn")

@export var hat_power_up := false
```

Im Signal statt `body.muenze_einsammeln()`:

```gdscript
		if hat_power_up:
			var power_up := POWER_UP.instantiate()
			power_up.position = position + Vector2(0, -18)   # eine Kachel über dem Block
			get_parent().add_child.call_deferred(power_up)
		else:
			body.muenze_einsammeln()
```

- `get_parent()` ist der `Level`. Das Power-up gehört in den Level, nicht in den Block, sonst würde es mit dem Block-Bild hüpfen.
- **`add_child.call_deferred(...)`**: Das ist dasselbe Prinzip wie `set_deferred` in Kapitel 6. Wir sind gerade mitten in einer Kollisionsmeldung, da darf man keine neuen Physik-Objekte einfügen. `call_deferred` ruft die Funktion erst am Ende des Physik-Schritts auf.

Im Level wählst du bei einem Block **Hat Power Up** an. Das ist dein `@export` aus Kapitel 6.

**Der Held wird stark.** In `held.gd`:

```gdscript
const INVINCIBLE_TIME = 1.5       # so lange ist der Held nach einem Treffer unverwundbar

var stark := false
var unverwundbar := 0.0


# Power-up eingesammelt
func power_up() -> void:
	stark = true
	$Bild.modulate = Color(1, 0.8, 0.3)   # golden


# Von einem Gegner erwischt
func getroffen() -> void:
	if unverwundbar > 0:
		return
	if stark:
		stark = false
		$Bild.modulate = Color.WHITE
		unverwundbar = INVINCIBLE_TIME
	else:
		sterben()
```

- `modulate` färbt einen Node ein. Weiß heißt: Originalfarben.
- `return` beendet die Funktion sofort. Ist der Held gerade unverwundbar, passiert gar nichts.

In `gegner.gd` ersetzt du `body.sterben()` durch `body.getroffen()`. Das Runterfallen ruft weiter direkt `sterben()` auf, denn gegen ein Loch hilft auch das Power-up nicht.

**Blinken, solange er unverwundbar ist.** In `_physics_process`, zum Beispiel nach dem Herunterzählen von `brake_timer`:

```gdscript
	# Nach einem Treffer kurz unverwundbar, und blinken
	if unverwundbar > 0:
		unverwundbar -= delta
		$Bild.visible = int(unverwundbar * 10) % 2 == 0
	else:
		$Bild.visible = true
```

`int(unverwundbar * 10) % 2` wechselt alle 0,1 Sekunden zwischen 0 und 1. Das ist derselbe Trick wie beim blinkenden „PAUSE“ bei Flatterfisch, nur mit dem eigenen Zähler statt der Uhrzeit.

### 7.6 Ausprobieren

Spring gegen einen Münzblock: Er hüpft, wird leer, und eine Münze wird gezählt. Spring gegen den Power-up-Block: Das Power-up läuft heraus. Sammel es ein und lauf in einen Gegner. Der Held blinkt, ist wieder normal und läuft weiter. Beim zweiten Gegner ist er erledigt.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 7

1. **Klingeling (leicht):** Wenn man schnell viele Münzen einsammelt, klingt der immer gleiche Ton künstlich. Gib dem `MuenzTon` vor jedem Abspielen eine leicht andere Tonhöhe: `$MuenzTon.pitch_scale = randf_range(0.9, 1.1)`. Hörst du den Unterschied?
2. **Mehrfach-Block (leicht):** Manche Blöcke bei Mario geben mehrere Münzen, eine pro Anstoßen. Ersetz `leer` durch `@export var muenzen := 1`. Jedes Anstoßen zählt eins herunter, bei 0 ist der Block leer. Stell im Level einen Block auf 5.
3. **Aus dem Block steigen (mittel):** Das Power-up erscheint einfach über dem Block. Bei Mario steigt es langsam heraus. Lass es an der Stelle des Blocks entstehen (`position` statt `position + Vector2(0, -18)`), hinter dem Block (`z_index = -1`) und mit einem Tween in 0,5 Sekunden nach oben steigen. Während es steigt, darf es noch nicht laufen. Tipp: `set_physics_process(false)` und der Tween kann am Ende eine Funktion aufrufen: `tween.tween_callback(set_physics_process.bind(true))`.
4. **Von unten erwischt (mittel):** Bei Mario besiegt man Gegner, die auf einem Block stehen, indem man von unten gegen den Block springt. Gib dem Block eine zweite `Area2D` namens `Oberseite` als flachen Streifen auf dem Block, mit **Mask** `3` (Gegner). Beim Anstoßen gehst du alle Körper durch, die gerade darauf stehen: `for gegner in $Oberseite.get_overlapping_bodies():` und machst sie platt.
5. **Ziegel zerschlagen (knifflig):** Ein starker Held kann bei Mario Ziegel zerschlagen. Mach eine Einstellung `@export var zerbrechlich := false`. Ein zerbrechlicher Block verschwindet beim Anstoßen, aber nur, wenn `body.stark` ist. Sonst hüpft er nur. Bonus: ein paar Bruchstücke mit `CPUParticles2D`. Vorsicht: Die Partikel hängen am Block, und der verschwindet. Was kannst du tun, damit die Bruchstücke trotzdem zu sehen sind? (Denk an den Ton aus Kapitel 6.)

---

## Kapitel 8: Ziel, Leben, Anzeige und Web-Export

Im letzten Kapitel wird aus dem Level ein richtiges Spiel. Es gibt 3 Leben, eine Anzeige oben im Bild, ein Ziel am Ende und einen Bildschirm für „Game Over“ und „Geschafft“. Danach exportierst du Hüpfheld fürs Web und stellst es auf die Startseite.

Neu sind zwei Dinge:
- **Autoload:** ein Node, der einen Szenenwechsel überlebt.
- **`change_scene_to_file`:** von einer Szene zu einer anderen wechseln.

Beides brauchst du in Zelda und DOOM wieder.

### 8.1 Ein Spielstand, der den Neustart überlebt

Bisher setzt `reload_current_scene()` beim Sterben *alles* zurück, auch die Münzen des Helden. Leben, die nach jedem Tod wieder bei 3 anfangen, wären sinnlos. Wir brauchen also etwas, das *außerhalb* des Levels liegt.

Das ist ein **Autoload**. Godot erzeugt ihn beim Spielstart einmal und hängt ihn ganz oben in den Baum, neben die Szene. Wird die Szene neu geladen, bleibt er unberührt.

1. Im FileSystem: Rechtsklick → **New Script** → `spielstand.gd`, **Inherits** `Node`, **Template** Empty:

```gdscript
extends Node


const START_LEBEN = 3

var leben := START_LEBEN
var muenzen := 0
var meldung := ""   # was der Ende-Bildschirm zeigt


# Alles auf Anfang, für ein neues Spiel
func neues_spiel() -> void:
	leben = START_LEBEN
	muenzen = 0
```

2. *Project Settings* → Tab **Globals** → **Autoload**:
   - Bei **Path** wählst du `spielstand.gd`.
   - Bei **Node Name** trägst du `Spielstand` ein.
   - Dann **Add**.

Ab jetzt kennt jedes Skript den Namen `Spielstand`, so wie `Input` oder `Vector2`. In `held.gd` zählt die Münze jetzt dort:

```gdscript
# Eine Münze eingesammelt
func muenze_einsammeln() -> void:
	Spielstand.muenzen += 1
	$MuenzeTon.pitch_scale = randf_range(0.9, 1.1)
	$MuenzeTon.play()
```

`var muenzen` im Held kannst du löschen. Das `Debug`-Label übernimmt gleich die Anzeige, also kann es mitsamt seinen Zeilen ebenfalls weg.

Bei Mario ist es genauso: Nach einem Tod sind die Münzen und Blöcke im Level wieder da, aber dein Münzzähler bleibt.

### 8.2 Die Anzeige: ein CanvasLayer

Die Kamera bewegt sich, also würde ein normales `Label` im Level wegscrollen. Ein **`CanvasLayer`** ist eine eigene Zeichenebene, die die Kamera nicht mitbewegt. Alles darin klebt am Bildschirm.

1. In `level.tscn`: Rechtsklick auf `Level` → **Add Child Node** → `CanvasLayer` → umbenennen in `HUD` („Head-Up Display“).
2. Darunter zwei `Label`: `Muenzen` und `Leben`.
3. `Muenzen` auswählen → oben im 2D-Editor **Anchor Preset** (das grüne Kreuz-Symbol) → **Top Left**. `Leben` → **Top Right**. Schieb beide ein paar Pixel vom Rand weg.

**Eine Pixel-Schrift:** Godots Standardschrift ist bei 384 × 216 verschwommen und zu groß. Kenney hat auch freie Schriften:
1. Lade 🆓 **Kenney Fonts** (kenney.nl → Assets → Kenney Fonts, CC0).
2. Kopier eine Pixel-Schrift, zum Beispiel `Kenney Pixel.ttf`, in deinen `Kenney`-Ordner.
3. Wähl sie im FileSystem aus → Tab **Import**:
   - **Antialiasing** auf `None`, **Hinting** auf `None`.
   - Dann **Reimport**.

Damit du Schrift, Größe und Rand nicht bei jedem Label einzeln einstellen musst, gibt es **LabelSettings**:

1. Wähl `Muenzen` → **Label Settings** → **New LabelSettings** → darauf klicken.
2. **Font**: deine Schrift. **Size**: probier `8` oder `16`. Pixel-Schriften sind nur bei bestimmten Größen scharf.
3. **Outline**: Size `2`, Farbe dunkel. So bleibt die Schrift vor Himmel *und* Wolken lesbar.
4. Rechtsklick auf die LabelSettings → **Save As…** → `schrift.tres`.
5. Bei `Leben` und allen weiteren Labels ziehst du `schrift.tres` in **Label Settings**.

Das ist dieselbe Idee wie die `SpriteFrames`: eine Resource, die mehrere Nodes gemeinsam benutzen. Änderst du die Größe in `schrift.tres`, ändern sich alle Labels.

**Achtung, Umlaute:** Nicht jede Pixel-Schrift hat ein `Ü`. Wenn statt eines Buchstabens ein Kästchen erscheint, schreib `MUENZEN`. Schöner ist ein Münzbild: Häng eine `TextureRect` mit einer AtlasTexture der Münze vor das Label und schreib nur `x 05`.

Skript an `HUD` (`hud.gd`):

```gdscript
extends CanvasLayer


func _process(_delta: float) -> void:
	$Muenzen.text = "MUENZEN %02d" % Spielstand.muenzen
	$Leben.text = "LEBEN %d" % Spielstand.leben
```

- **`%02d`** ist wie `%d`, nur immer zweistellig mit führender Null: aus `5` wird `05`. Bei Mario steht da auch nie eine einzelne Ziffer.
- **`_delta`** mit Unterstrich: Die Funktion bekommt `delta` mit, braucht es aber nicht. Der Unterstrich sagt Godot, dass das Absicht ist, und die gelbe Warnung verschwindet.
- Jedes Bild den Text neu zu setzen ist für zwei Labels völlig in Ordnung. Bei hunderten Anzeigen würde man ein Signal schicken, sobald sich etwas ändert.

### 8.3 Leben verlieren und Game Over

Der Ende-Bildschirm ist eine **eigene Szene**. Er zeigt `Spielstand.meldung` an, damit dieselbe Szene „GAME OVER“ und „GESCHAFFT!“ sagen kann.

1. *Scene → New Scene* → **User Interface** (`Control`) → umbenennen in `Ende`. Anchor Preset **Full Rect**.
2. Kinder:
   - `ColorRect`, ebenfalls **Full Rect**, Farbe schwarz. Sonst sieht man den Himmel.
   - `VBoxContainer` mit Anchor Preset **Center**. Darin drei `Label`: `Meldung`, `Muenzen` und `Hinweis` (Text: `SPRUNGTASTE: NEUES SPIEL`). Bei allen dreien **Horizontal Alignment** `Center` und `schrift.tres`.
3. Speichern als `ende.tscn`. Skript `ende.gd`:

```gdscript
extends Control


var bereit := false   # erst nach einer Sekunde, sonst springt man versehentlich weiter


func _ready() -> void:
	$VBoxContainer/Meldung.text = Spielstand.meldung
	$VBoxContainer/Muenzen.text = "MUENZEN %02d" % Spielstand.muenzen
	$VBoxContainer/Hinweis.modulate.a = 0.0   # unsichtbar, nimmt aber schon Platz ein
	await get_tree().create_timer(1.0).timeout
	bereit = true
	$VBoxContainer/Hinweis.modulate.a = 1.0


func _unhandled_input(event: InputEvent) -> void:
	if bereit and event.is_action_pressed("springen"):
		Spielstand.neues_spiel()
		get_tree().change_scene_to_file("res://level.tscn")
```

- **`_unhandled_input`** kennst du aus Flatterfisch. Godot ruft es bei jedem Tastendruck auf, statt dass man jedes Bild fragt.
- **`change_scene_to_file`** wirft die aktuelle Szene weg und lädt eine andere. Der Autoload `Spielstand` bleibt dabei bestehen. Deshalb kennt der Ende-Bildschirm die Münzen noch.
- **`bereit`:** Wer beim Sterben gerade die Sprungtaste drückt, soll nicht sofort im neuen Spiel landen.
- **`modulate.a` statt `visible`:** Ein Container ordnet nur sichtbare Kinder an. Mit `visible = false` wäre `Hinweis` gar nicht da, und wenn er erscheint, rutschen die anderen Labels nach oben. Mit `modulate.a = 0.0` ist er nur durchsichtig, sein Platz ist aber schon reserviert.

Jetzt der Held. In `sterben()` ersetzt du die letzte Zeile, also `reload_current_scene()` nach dem `await`:

```gdscript
		await get_tree().create_timer(1.5).timeout
		Spielstand.leben -= 1
		if Spielstand.leben > 0:
			get_tree().reload_current_scene()
		else:
			Spielstand.meldung = "GAME OVER"
			get_tree().change_scene_to_file("res://ende.tscn")
```

Test: Spring dreimal in ein Loch. Die Anzeige zählt herunter, dann kommt GAME OVER, und mit der Sprungtaste beginnt alles von vorn.

### 8.4 Das Ziel

Am Ende des Levels steht bei Mario eine Fahnenstange. Für uns reicht eine unsichtbare Fläche, und die Optik malst du dazu.

1. **Aussehen:** Mal in `Deco` eine Fahnenstange auf das flache Stück hinter der großen Treppe (4.4, Abschnitt 8). Im Kachelblatt von Kenney gibt es Fahnen. Die Stange kannst du aus anderen Kacheln bauen oder in Piskel selbst zeichnen.
2. **Fläche:** In `level.tscn` eine `Area2D` namens `Ziel` an `Level` hängen, mit **Mask** nur `2` (Held). Dazu eine `CollisionShape2D` als schmales, sehr **hohes** Rechteck an der Stange, zum Beispiel 6 × 216 von ganz oben bis zum Boden. So kann niemand über das Ziel hinwegspringen.
3. Häng ein Skript an `Ziel` (`ziel.gd`) und verbinde dessen Signal `body_entered` mit `Ziel` selbst, wie bei der Münze:

```gdscript
extends Area2D


func _on_body_entered(body: Node2D) -> void:
	body.ziel_erreicht()
```

Im Held: eine Variable neben `tot`, eine neue Funktion und ein `ZielTon` (ein `AudioStreamPlayer` mit einer kleinen Fanfare aus 🆓 jsfxr):

```gdscript
var im_ziel := false
```

```gdscript
# Die Fahne erreicht: kurz feiern, dann der Ende-Bildschirm
func ziel_erreicht() -> void:
	if im_ziel or tot:
		return
	im_ziel = true
	velocity.x = 0
	$Bild.play("stehen")
	$ZielTon.play()
	await get_tree().create_timer(3.0).timeout
	Spielstand.meldung = "GESCHAFFT!"
	get_tree().change_scene_to_file("res://ende.tscn")
```

Im Ziel soll der Held, wie im Tod, nicht mehr auf Tasten hören. Am Anfang von `_physics_process` wird deshalb aus `if tot:` das hier:

```gdscript
	if tot or im_ziel:
```

Im Ziel bleibt die Maske, anders als beim Sterben. Der Held fällt also nicht durch den Boden, sondern landet und bleibt stehen.

Und ein Gegner darf den Held im Ziel nicht mehr erwischen. In `getroffen()`:

```gdscript
	if unverwundbar > 0 or im_ziel:
		return
```

### 8.5 Export fürs Web

Das kennst du aus Flatterfisch, Kapitel 6. Kurz:

1. **Export Templates:** Hast du Godot seit Flatterfisch aktualisiert, brauchst du sie für die neue Version noch einmal (*Editor → Manage Export Templates*). Sonst sind sie schon da.
2. Ordner **`web`** in `05-huepfheld` mit einer leeren **`.gdignore`** darin.
3. *Project → Export → Add… → Web*:
   - **Export Path** `web/index.html`
   - **Thread Support** aus
4. **Export Project**, ohne **Export With Debug**.
5. Testen über den Webserver, im `games`-Ordner:

```bash
python -m http.server 8000
```

Dann `http://localhost:8000/05-huepfheld/web/` öffnen.

Teste im Browser:
- Tasten **und** Gamepad
- Ton nach dem ersten Tastendruck
- ob das Bild scharf bleibt, wenn du das Fenster größer und kleiner ziehst

Dank **Integer**-Skalierung aus 1.2 bleibt jedes Pixel ein Quadrat.

Vorher aufräumen: In `05-huepfheld` liegt noch eine `sprite_2d.tscn`, die nichts benutzt. Lösch sie, sonst wandert sie mit in den Export.

### 8.6 Startseite, README und Lizenzen

**Startseite:** In der `index.html` im `games`-Ordner ist Hüpfheld noch grau. Mach den Eintrag spielbar wie bei Flatterfisch: `folder`, `color` und `desc`. Trag das Spiel auch in die Tabelle der `README.md` im `games`-Ordner ein.

**README für Hüpfheld:** Schreib sie wieder selbst, Gliederung wie bei Flatterfisch:
- **Steuerung**: alle vier Aktionen, auch mit Gamepad
- **Was ich gelernt habe**
- **Was schwer war**
- **Grafiken und Engine**

Den letzten Abschnitt brauchst du diesmal für **drei** Lizenzen:

```markdown
## Grafiken, Schrift und Engine
- Kacheln, Hintergründe und Gegner: [Pixel Platformer](https://kenney.nl/assets/pixel-platformer) von Kenney, CC0
- Schrift: [Kenney Fonts](https://kenney.nl/assets/kenney-fonts) von Kenney, CC0
- Erstellt mit der [Godot Engine](https://godotengine.org) (MIT-Lizenz). Der Web-Export in `web/` enthält die Engine. Lizenz und Hinweise: https://godotengine.org/license

Für meinen eigenen Code, meine Spielfigur und meine Sounds gilt die [LICENSE](../LICENSE) im Hauptordner.
```

**CC0** heißt: Kenney verzichtet auf alle Rechte, du darfst die Grafiken für alles benutzen, ohne Pflicht zur Nennung. Genannt wird er trotzdem: Das ist fair, und jeder Leser sieht sofort, welche Grafiken *nicht* von dir sind. Denn deine „Alle Rechte vorbehalten“-Lizenz kann für Kenneys Grafiken nicht gelten. Die gehören niemandem.

Fertig? Committen und Bescheid geben. Ein Kapitel kommt noch: der Bonuslevel.

### Übungsaufgaben zu Kapitel 8

1. **Extraleben (leicht):** Bei Mario gibt es für 100 Münzen ein Leben dazu, und der Zähler fängt wieder bei 0 an. Bau das ein. Wo gehört der Code hin: in den Held, in die Münze oder in `Spielstand`? Bonus: ein eigener Ton dafür.
2. **Rekord (leicht):** Speichere die meisten Münzen, die man je ins Ziel gebracht hat, wie den Highscore in Flatterfisch mit `ConfigFile` in `user://`. Zeig den Rekord auf dem Ende-Bildschirm.
3. **Die Uhr läuft (mittel):** Mario hat 400 Sekunden für einen Level. Zeig im HUD eine Zeit an, die herunterzählt. Bei 0 stirbt der Held. Das HUD kennt den Held aber nicht. Erinnerst du dich an die **Gruppen** aus Flatterfisch? Steck den Held in eine Gruppe `held` und ruf `get_tree().call_group("held", "sterben")` auf. Was muss beim Neustart mit der Zeit passieren, und wohin gehört sie deshalb?
4. **Zwischenbild (mittel):** Bei Mario kommt vor jedem Versuch kurz ein schwarzes Bild mit „WELT 1-1“ und der Zahl der Leben. Bau eine Szene `zwischenbild.tscn`, die das 2 Sekunden zeigt und dann mit `change_scene_to_file` den Level lädt. Sie wird zur Hauptszene (*Project Settings → Application → Run → Main Scene*). Und `sterben()` lädt jetzt nicht mehr den Level neu, sondern …?
5. **Die Fahnenstange (knifflig):** Bei Mario rutscht der Held an der Stange herunter, landet, läuft von allein nach rechts in ein Häuschen und verschwindet. Tipps:
   - Eine Variable für den Zustand im Ziel reicht nicht mehr. Du brauchst mehrere: rutschen, laufen, fertig. Das ist der Anfang einer **State Machine**, die in Zelda ein großes Thema wird.
   - Rutschen: `velocity.x = 0`, `velocity.y` fest auf zum Beispiel `80`, bis `is_on_floor()`.
   - Laufen: `velocity.x = SPEED`, die Animation `laufen`. Hinter dem Häuschen versteckst du ihn mit `visible = false`.
   - Bonus: Je höher er die Stange trifft, desto mehr Punkte. Den Treffpunkt kennst du: `position.y` beim Berühren.

---

## Kapitel 9: Bonuslevel

Bei Mario kann man in manche Röhren hinabsteigen. Unten wartet ein dunkler Raum voller Münzen, und durch eine zweite Röhre kommt man weiter hinten im Level wieder heraus. Genau das baust du in diesem Kapitel.

Technisch ist das ein **Raumwechsel**: von einer Szene in eine andere und wieder zurück, ohne dass etwas verloren geht. In Zelda wird daraus ein ganzer Dungeon aus Räumen, und dafür ist dieses Kapitel die Vorübung.

### 9.1 Was überlebt welchen Wechsel?

Bisher gab es zwei Wechsel: Tod (Start-Bildschirm, dann der Level von vorn) und neues Spiel. Jetzt kommt die Röhre dazu, und die soll *anders* sein. Wer aus dem Bonusraum zurückkommt, darf weder die Zeit noch das Power-up verlieren.

| Wert | Neues Spiel | Tod | Röhre |
|---|---|---|---|
| Leben | 3 | eins weniger | bleibt |
| Münzen | 0 | bleibt | bleibt |
| Zeit | 400 | 400 | **bleibt** |
| Stark | nein | nein | **bleibt** |
| Startpunkt | Levelanfang | Levelanfang | **Ausgangsröhre** |

Alles, was einen Szenenwechsel überleben soll, muss in den Autoload. Die Zeit steht im Moment im HUD, `stark` steht im Held, und beide werden beim Wechsel gelöscht. Sie ziehen also um in `spielstand.gd`:

```gdscript
const START_ZEIT = 400.0

var zeit := START_ZEIT
var stark := false
var rueckkehr := Vector2.ZERO   # wo der Held nach einer Röhre auftaucht, ZERO heißt: am Levelanfang
```

```gdscript
# Alles auf Anfang, für ein neues Spiel
func neues_spiel() -> void:
	leben = START_LEBEN
	muenzen = 0
	neuer_versuch()


# Nach einem Tod: Zeit und Kraft zurück, Start am Levelanfang
func neuer_versuch() -> void:
	zeit = START_ZEIT
	stark = false
	rueckkehr = Vector2.ZERO
```

`neues_spiel()` ruft `neuer_versuch()` auf, denn ein neues Spiel setzt alles zurück, was ein Tod auch zurücksetzt, und noch mehr.

In `held.gd` in `sterben()` gleich nach `Spielstand.leben -= 1`:

```gdscript
		Spielstand.neuer_versuch()
```

Im `hud.gd` zählt die Uhr jetzt im Spielstand. `time_left` und `START_TIMER` fallen weg:

```gdscript
	if Spielstand.zeit > 0:
		Spielstand.zeit -= delta
	else:
		get_tree().call_group("held", "sterben")
	$Timer.text = "%03d" % Spielstand.zeit
```

`stark` bleibt im Held, denn dort wird es ständig gebraucht. Nur beim Wechsel wird es übergeben: Der Held schreibt es vor dem Abstieg in den Spielstand (9.3) und liest es in `_ready()` wieder heraus (9.4).

### 9.2 Eine Taste für „runter“

*Project Settings* → **Input Map** → neue Aktion `runter`:
- Pfeil runter und `S`
- Gamepad: D-Pad runter (*Joypad Button* 12) und der linke Stick nach unten (*Joypad Axis* 1, positiv)

### 9.3 Die Röhre zum Hineingehen

Die Röhren sind Kacheln im `Boden`, und Kacheln haben kein Skript. Also kommt wieder eine unsichtbare Fläche obendrauf, wie beim Ziel.

1. *Scene → New Scene* → `Area2D` → umbenennen in `Roehre`. **Layer:** keine, **Mask:** nur `2`.
2. Eine `CollisionShape2D` als flaches Rechteck, etwa **10 × 4**, bei Position `0, -2`. Damit liegt die Unterkante der Form genau am Ursprung der Szene. Später setzt du die `Roehre` mit ihrem Ursprung auf die Oberkante einer Röhren-Kachel. Die Form ist schmaler als die Röhre, so muss der Held ungefähr mittig stehen.
3. Speichern als `roehre.tscn`. Skript `roehre.gd`:

```gdscript
extends Area2D


@export_file("*.tscn") var ziel_szene: String
@export var ausgang := Vector2.ZERO   # wo der Held in der Ziel-Szene herauskommt, ZERO: wo er dort steht


func _physics_process(_delta: float) -> void:
	if not Input.is_action_pressed("runter"):
		return
	for body in get_overlapping_bodies():
		if body.is_on_floor():
			Spielstand.rueckkehr = ausgang
			body.roehre_betreten(ziel_szene)
```

- **`@export_file("*.tscn")`** ist ein `@export` für einen Dateipfad. Im Inspector erscheint ein Ordner-Symbol, über das du die Szene auswählst, statt den Pfad abzutippen.
- **Jedes Bild prüfen statt `body_entered`:** Diese Lehre kennst du von den Gegnern. Der Held steht oft schon auf der Röhre, *bevor* er runter drückt. Das Signal wäre dann längst vorbei.
- **`is_on_floor()`:** Im Sprung über die Röhre hinweg zählt es nicht.

Jetzt der Held. Oben bei den Konstanten:

```gdscript
const ROEHRE_TIEFE = 24.0         # so tief verschwindet der Held in der Röhre
const ROEHRE_ZEIT = 0.8           # so lange dauert das Hinab- und Heraussteigen
```

Bei den Variablen:

```gdscript
var in_roehre := false
```

Und die Funktion:

```gdscript
# In eine Röhre hinabsteigen, dann in eine andere Szene
func roehre_betreten(szene: String) -> void:
	if in_roehre or tot or im_ziel:
		return
	in_roehre = true
	set_physics_process(false)
	z_index = -1
	$Bild.play("stehen")
	$Schaden.play()
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y + ROEHRE_TIEFE, ROEHRE_ZEIT)
	await tween.finished
	Spielstand.stark = stark
	get_tree().change_scene_to_file(szene)
```

- **`set_physics_process(false)`:** Ohne `_physics_process` gibt es keine Schwerkraft, keine Steuerung und kein `move_and_slide()`. Der Held bewegt sich nur noch durch den Tween und sinkt dabei auch durch die Röhren-Kachel. Das klappt, weil nur `move_and_slide()` auf Kollisionen achtet. Ein Tween setzt die Position einfach.
- **`z_index = -1`** schiebt den Held hinter die Kacheln, er verschwindet *in* der Röhre. Das ist derselbe Trick wie beim Power-up.
- **`await tween.finished`:** Ein Tween hat ein Signal, wenn er fertig ist. Bisher hast du mit `tween_callback` etwas ans Ende gehängt, `await` geht genauso.
- **`$Schaden.play()`:** Bei Mario klingt die Röhre tatsächlich genauso wie ein Treffer. Wenn du willst, kannst du dir mit 🆓 jsfxr einen eigenen Ton machen.

Damit ein Gegner den Held in der Röhre nicht noch erwischt, kommt `in_roehre` in die erste Zeile von `getroffen()`:

```gdscript
	if unverwundbar > 0 or im_ziel or in_roehre:
		return
```

### 9.4 Aus der Röhre wieder herauskommen

Kommt der Held im Level aus dem Bonusraum zurück, wird `level.tscn` neu geladen. Ohne weitere Hilfe stünde er dann am Levelanfang. Deshalb steht in `Spielstand.rueckkehr` der Punkt, an dem er auftauchen soll. Der Held schaut in `_ready()` nach:

```gdscript
func _ready() -> void:
	stark = Spielstand.stark
	if stark:
		$Bild.modulate = Color(1, 0.8, 0.3)   # golden
	if Spielstand.rueckkehr != Vector2.ZERO:
		roehre_verlassen(Spielstand.rueckkehr)
		Spielstand.rueckkehr = Vector2.ZERO   # nur einmal, beim nächsten Tod geht es wieder vom Anfang los
	$Camera2D.reset_smoothing()
```

```gdscript
# Aus einer Röhre nach oben herauskommen
func roehre_verlassen(ausgang: Vector2) -> void:
	in_roehre = true
	set_physics_process(false)
	z_index = -1
	position = ausgang + Vector2(0, ROEHRE_TIEFE)
	$Schaden.play()
	var tween := create_tween()
	tween.tween_property(self, "position:y", ausgang.y, ROEHRE_ZEIT)
	await tween.finished
	z_index = 0
	set_physics_process(true)
	in_roehre = false
```

Es ist dieselbe Bewegung wie beim Hinabsteigen, nur rückwärts: unten in der Röhre anfangen und nach oben steigen.

Jetzt wird auch das `reset_smoothing()` aus Kapitel 4 wieder wichtig. Es steht **nach** dem Versetzen, damit die Kamera sofort an der Ausgangsröhre ist, statt vom Levelanfang durch den halben Level zu gleiten. „Kein Zurück“ funktioniert danach von allein: `limit_left` wird im ersten Bild an die neue Bildkante gesetzt.

### 9.5 Der Bonusraum

Zuerst zwei Vorbereitungen in `level.tscn`, damit du Teile wiederverwenden kannst:

1. **Das TileSet als Datei:** Im Moment steckt es *in* `level.tscn`, und eine andere Szene kommt nicht heran. Wähl `Boden` → im Inspector beim **Tile Set** auf den Pfeil → **Save As…** → `kacheln.tres`. Dasselbe Prinzip wie bei `schrift.tres`.
2. **Das HUD als eigene Szene:** Rechtsklick auf `HUD` → **Save Branch as Scene** → `hud.tscn`. Im Level ändert sich nichts, aber jetzt kannst du das HUD auch woanders einsetzen.
3. **Die Gruppe `held`** steht im Moment an der Held-*Instanz* in `level.tscn`. Im Bonusraum gäbe es sie nicht, und die Uhr könnte den Held dort nicht erreichen. Nimm sie in `level.tscn` heraus (Node → Groups) und füge sie in `held.tscn` am `Held` selbst hinzu. Dann hat jeder Held die Gruppe, egal wo er steht.

Jetzt der Raum:

1. *Scene → New Scene* → **2D Scene** → umbenennen in `Bonus`. Speichern als `bonus.tscn`.
2. Ein `ColorRect` namens `Dunkel` als erstes Kind, Position `0, 0`, Größe `384 × 216`, Farbe ein dunkles Blau oder Schwarz. Als erstes Kind wird es zuerst gezeichnet, also hinter allem.
3. Eine `TileMapLayer` namens `Boden` mit **Tile Set** `kacheln.tres`. Mal einen Raum von einem Bildschirm: Boden unten, Wände links und rechts. Rechts kommt eine Röhre hin, das ist der Ausgang. Wenn es im Kachelblatt dunklere Steine gibt, passen sie gut zum Keller-Gefühl.
4. Münzen: Zieh `muenze.tscn` hinein und vervielfältige sie mit **Ctrl+D**, zum Beispiel als Block von 3 Reihen mal 7.
5. Der Held: Zieh `held.tscn` links oben hinein. Er fällt beim Start herunter, wie bei Mario. Seine Kamera hat noch die Grenzen vom langen Level. Rechtsklick auf die Instanz → **Editable Children** → `Camera2D` → **Limit → Right** `384`. Jetzt steht die Kamera still.
6. Das HUD: `hud.tscn` hineinziehen.
7. Der Ausgang: `roehre.tscn` auf die Oberkante der Röhre rechts setzen.

### 9.6 Die Röhren verbinden

Zwei Röhren brauchen Einstellungen:

**Im Level, der Eingang:** Such dir eine Röhre aus und setz eine `roehre.tscn` darauf. **Ziel Szene:** `bonus.tscn`. **Ausgang** bleibt `0, 0`: Im Bonusraum taucht der Held dort auf, wo er in `bonus.tscn` steht.

**Im Bonusraum, der Ausgang:** **Ziel Szene:** `level.tscn`. **Ausgang:** die Stelle auf der Ausgangsröhre im Level, an der der Held stehen soll. Diese Koordinate musst du ablesen. Am einfachsten geht das so:
1. In `level.tscn` den `Held` auf die Ausgangsröhre ziehen.
2. Im Inspector die **Position** ablesen.
3. Mit **Ctrl+Z** zurück.

So stimmt auch die Höhe, denn der Ursprung des Helden liegt in der Mitte seines Körpers, nicht an den Füßen.

**Wohin mit der Ausgangsröhre?** Weiter hinten im Level, und zwar **mehr als einen Bildschirm** hinter dem Eingang. Dann ist der Eingang beim Herauskommen schon links aus dem Bild, und „Kein Zurück“ verhindert, dass man noch einmal hinunter kann und sich die Münzen ein zweites Mal holt.

### 9.7 Ausprobieren

**F5**:
- Auf die Eingangsröhre stellen, runter drücken. Der Held sinkt ein, im Bonusraum fällt er von oben herein.
- Münzen sammeln, der Zähler zählt weiter.
- Die Uhr läuft weiter und fängt nicht bei 400 an.
- Auf die Ausgangsröhre, runter. Der Held steigt im Level aus der Ausgangsröhre, und die Kamera ist sofort da.
- Mit Power-up hineingehen: Kommt er golden zurück?
- Nach dem Bonusraum sterben: Der nächste Versuch beginnt am Levelanfang.

Eins wird dir auffallen: Nach dem Bonusraum sind im Level alle Gegner und Blöcke wieder da, auch die schon erledigten. Der Level wird ja neu geladen. Bei Mario passiert das nicht. Wie man das löst, ist die knifflige Übung.

Zum Schluss: Exportiere das Spiel neu (*Project → Export → Export Project*) und teste den Bonusraum auch im Browser.

Fertig? Committen, und Projekt 05 ist abgeschlossen. 🎉

### Übungsaufgaben zu Kapitel 9

1. **Die Uhr im Ziel (leicht):** Bei Mario bleibt die Uhr stehen, sobald man die Fahne berührt. Bei uns läuft sie weiter. Läuft sie während der Fahnen-Animation ab, ruft das HUD `sterben()` auf, obwohl der Held im Ziel ist. Halte die Uhr an. Tipp: `get_tree().get_first_node_in_group("held")` liefert den Held, dann kannst du `im_ziel` fragen. Bonus: Bei Mario wird die Restzeit am Ende in Punkte umgerechnet.
2. **Nur einmal hinein (leicht):** Falls man doch noch zurück zum Eingang kommt, soll die Röhre beim zweiten Mal nicht mehr funktionieren. Merk dir in `Spielstand`, dass der Bonusraum besucht wurde. Wann muss dieser Wert zurückgesetzt werden: bei einem Tod, bei einem neuen Spiel oder bei beidem?
3. **Seitliche Röhre (mittel):** Bei Mario verlässt man den Bonusraum durch eine Röhre, die zur Seite zeigt: hinlaufen und **rechts** drücken. Gib der `Roehre` ein `enum Richtung { UNTEN, RECHTS }` als `@export`. Bei `RECHTS` prüft sie die Aktion `rechts`, und der Held gleitet waagerecht hinein, mit `position:x` statt `position:y`. Wie sagst du `roehre_betreten()`, in welche Richtung es gehen soll?
4. **Musik im Keller (mittel):** Mach mit 🆓 BeepBox eine kurze, dunkle Schleife für den Bonusraum. Häng einen `AudioStreamPlayer` mit **Autoplay** an `Bonus`. Damit die Musik in Schleife läuft: im FileSystem die WAV-Datei auswählen → Tab **Import** → **Loop Mode** auf `Forward` → **Reimport**.
