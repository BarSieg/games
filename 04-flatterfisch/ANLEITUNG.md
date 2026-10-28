# Flatterfisch – Schritt-für-Schritt-Anleitung

Diesmal baust du selbst, im Godot-Editor. Die Anleitung kommt in Kapiteln. Nach jedem Kapitel meldest du dich, ich schaue mir deine Dateien an, und dann kommt das nächste.

Szenen (`.tscn`) und Skripte (`.gd`) sind bei Godot normale Textdateien. Darum kann ich sie genauso durchsehen wie bisher dein JavaScript.

**Geplante Kapitel:**
1. Godot einrichten, der Fisch fällt und flattert ← *du bist hier*
2. Korallen: Hindernisse, die von rechts kommen
3. Zusammenstoß und Game Over (hier lernst du **Signale**)
4. Punkte, Anzeige und Highscore
5. Eigene Grafik und Sound
6. Export als Web-Spiel und Eintrag auf der Startseite

---

## Kapitel 1: Der Fisch fällt und flattert

### 1.1 Godot installieren 🆓

1. Auf **godotengine.org** → *Download* → **Windows**.
2. Nimm die **Standard-Version**, nicht die *.NET*-Version. Die .NET-Version ist für C#; wir schreiben GDScript.
3. Es ist eine ZIP-Datei ohne Installer. Entpacke sie z. B. nach `C:\Tools\Godot\` und starte die `.exe`. Mehr Installation gibt es nicht.

**Tipp:** Stell den Editor auf **Englisch** um. Fast alle Tutorials, die Dokumentation und Fehlermeldungen in Foren sind englisch, und diese Anleitung verwendet die englischen Menünamen.
Im Projekt-Manager oder später im Editor: *Editor → Editor Settings → Interface → Editor → Editor Language* → `en`.

### 1.2 Das Projekt anlegen

Im Projekt-Manager auf **Create** (bzw. *New Project*):

| Feld | Wert | Warum |
|---|---|---|
| Project Name | `Flatterfisch` | |
| Project Path | `...\games\04-flatterfisch` | Der Ordner mit dieser Anleitung. Godot warnt, dass der Ordner nicht leer ist – das ist hier in Ordnung. |
| Renderer | **Compatibility** | Nur damit läuft das Spiel später im Browser. |
| Version Control Metadata | **Git** | Godot legt eine `.gitignore` an. Die sorgt dafür, dass der Cache-Ordner `.godot/` nicht im Repo landet. |

### 1.3 Das Spielfenster

*Project → Project Settings → General → Display → Window*:
- **Viewport Width:** `360`, **Viewport Height:** `640` (hochkant wie ein Handy)
- weiter unten bei **Stretch:** **Mode** = `canvas_items`, **Aspect** = `keep`

Damit wird das Spiel beim Vergrößern des Fensters mitskaliert, statt nur mehr leere Fläche zu zeigen.

### 1.4 Die Taste zum Flattern (Input Map)

Statt im Code nach „Leertaste“ zu fragen, gibt man in Godot einer **Aktion** einen Namen und legt fest, welche Tasten sie auslösen. Später kannst du Tasten ändern, ohne den Code anzufassen.

*Project → Project Settings → Tab **Input Map***:
1. Bei *Add New Action* `flap` eintippen → **Add**.
2. Beim neuen Eintrag `flap` auf das **+** klicken → Leertaste drücken → **OK**.
3. Nochmal **+** → *Mouse Buttons* → **Left Mouse Button** → **OK**.

### 1.5 Die Fisch-Szene

In Godot ist alles aus **Nodes** (Knoten) gebaut. Jede Node kann eine Sache gut: ein Bild zeigen, eine Form für Kollisionen haben, einen Ton abspielen … Mehrere Nodes zusammen als Baum ergeben eine **Szene**, z. B. „Fisch“. Eine Szene kann man dann beliebig oft in andere Szenen einsetzen. Das ist Godots Baukasten-Prinzip.

1. *Scene → New Scene* → im Scene-Panel links **Other Node** → `CharacterBody2D` suchen → **Create**.
   Das ist ein Körper, den *du* per Code bewegst (wie dein Schiff in Weltraumsteine), der aber Kollisionen kennt.
2. Doppelklick auf den Namen → in `Fisch` umbenennen.
3. Rechtsklick auf `Fisch` → **Add Child Node** → `Sprite2D`.
   Im **Inspector** rechts: Die Datei `icon.svg` aus dem FileSystem-Panel (unten links) auf das Feld **Texture** ziehen. Das Godot-Logo ist erstmal unser Platzhalter-Fisch.
   Mach es kleiner: **Transform → Scale** = `0.5, 0.5`.
4. Rechtsklick auf `Fisch` → **Add Child Node** → `CollisionShape2D`.
   Im Inspector bei **Shape** → **New CircleShape2D**. Im Bild erscheint ein Kreis; zieh am Punkt, bis er ungefähr das Logo abdeckt.
5. *Scene → Save Scene* (Strg+S) → `fisch.tscn`.

Der Baum sieht jetzt so aus:
```
Fisch (CharacterBody2D)
├── Sprite2D
└── CollisionShape2D
```

### 1.6 Das Skript

Rechtsklick auf `Fisch` → **Attach Script** → Name `fisch.gd` → **Create**. Ersetze den Inhalt durch:

```gdscript
extends CharacterBody2D

const GRAVITY = 1200.0     # Pixel pro Sekunde², zieht nach unten
const FLAP_SPEED = -400.0  # Tempo direkt nach einem Flossenschlag (negativ = nach oben)

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("flap"):
		velocity.y = FLAP_SPEED
	move_and_slide()
```

**Tipp:** Tipp es ab statt es zu kopieren. GDScript rückt mit **Tabs** ein, und beim Kopieren aus dem Browser werden daraus manchmal Leerzeichen. Dann meckert Godot über gemischte Einrückung.

**Vergleich mit deinem JavaScript:**

| Weltraumsteine (JS) | Flatterfisch (GDScript) |
|---|---|
| `function update(dt)`, von deinem `loop` aufgerufen | `func _physics_process(delta)` – Godot ruft es von selbst auf, 60-mal pro Sekunde |
| `ship.vx`, `ship.vy` | `velocity` – ein eingebauter Vektor mit `.x` und `.y` |
| `ship.y += ship.vy * dt` | `move_and_slide()` macht das, und prüft dabei auch Kollisionen |
| `keys.Space` | `Input.is_action_just_pressed("flap")` – „just“ heißt: nur im Moment des Drückens, nicht solange gehalten |

Fällt dir etwas auf? `velocity.y = FLAP_SPEED` **setzt** die Geschwindigkeit, es addiert nicht. Egal wie schnell der Fisch gerade fällt, ein Flossenschlag bremst ihn sofort und schickt ihn nach oben. Genau das macht das Original so gut steuerbar.

### 1.7 Die Hauptszene

1. *Scene → New Scene* → **2D Scene** (eine `Node2D`) → umbenennen in `Main`.
2. Den Fisch einsetzen: `fisch.tscn` aus dem FileSystem-Panel ins Bild ziehen. Oder: `Main` auswählen → Ketten-Symbol oben im Scene-Panel (**Instantiate Child Scene**) → `fisch.tscn`.
3. Fisch auswählen → Inspector → **Transform → Position** = `100, 320`.
4. Speichern als `main.tscn`.
5. **F5** (Projekt starten) → Godot fragt nach der Hauptszene → **Select Current**.

Der Fisch sollte jetzt nach unten fallen und bei Leertaste oder Mausklick nach oben springen. Er fällt unten aus dem Bild raus – das ist richtig so, darum kümmern wir uns in Kapitel 3.

### 1.8 Fertig? Dann committen

Im Terminal im `games`-Ordner:
```bash
git status
```
Du solltest u. a. `project.godot`, `fisch.tscn`, `fisch.gd`, `main.tscn`, `icon.svg` und `.gitignore` sehen, aber **nicht** den Ordner `.godot/`. Dann committen, und gib mir Bescheid.

### Übungsaufgaben zu Kapitel 1

1. **Spielgefühl (leicht):** Ändere `GRAVITY` und `FLAP_SPEED`. Wie fühlt sich 2000 / -500 an? Und 800 / -300? Such dir deine Lieblingswerte.
2. **Inspector-Zauber (leicht):** Mach aus `const GRAVITY = 1200.0` die Zeile `@export var gravity = 1200.0` und passe die Stelle an, wo `GRAVITY` benutzt wird. (In GDScript schreibt man Variablen klein, nur Konstanten groß.) Wähle dann den Fisch in `main.tscn` aus und schau in den Inspector. Was ist passiert, und warum ist das praktisch?
3. **Neigung (mittel):** Der Fisch soll sich nach oben neigen, wenn er steigt, und nach unten, wenn er fällt. Tipp: Jede Node2D hat `rotation` (in Bogenmaß, wie in Weltraumsteine). Such nach `clamp` in der Godot-Doku, damit er sich nicht überschlägt.
4. **Decke (mittel):** Der Fisch soll oben nicht aus dem Bild fliegen können. Tipp: `position.y`.
