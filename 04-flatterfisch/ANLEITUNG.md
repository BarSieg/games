# Flatterfisch – Schritt-für-Schritt-Anleitung

Diesmal baust du selbst, im Godot-Editor. Die Anleitung kommt in Kapiteln. Nach jedem Kapitel meldest du dich, ich schaue mir deine Dateien an, und dann kommt das nächste.

Szenen (`.tscn`) und Skripte (`.gd`) sind bei Godot normale Textdateien. Darum kann ich sie genauso durchsehen wie bisher dein JavaScript.

**Geplante Kapitel:**
1. Godot einrichten, der Fisch fällt und flattert ✅
2. Korallen: Hindernisse, die von rechts kommen (dein erstes **Signal**) ✅
3. Zusammenstoß und Game Over (eigene **Signale**) ← *du bist hier*
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

---

## Kapitel 2: Korallen

Jetzt kommen Hindernisse: ein Korallenpaar oben und unten, mit einer Lücke dazwischen. Es schwimmt von rechts nach links durchs Bild. Alle paar Sekunden kommt ein neues.

Grafik gibt es noch keine. Die Korallen sind erstmal einfache farbige Rechtecke.

### 2.1 Die Korallen-Szene

So soll die Szene aussehen. Der Ursprung (0, 0) der Szene ist die **Mitte der Lücke**. Die Lücke ist 160 Pixel hoch, also von y = -80 bis y = 80.

```
Korallen (Area2D)
├── ObenBild (ColorRect)
├── ObenForm (CollisionShape2D)
├── UntenBild (ColorRect)
└── UntenForm (CollisionShape2D)
```

1. *Scene → New Scene* → **Other Node** → `Area2D` → in `Korallen` umbenennen.
   Eine `Area2D` ist eine Fläche, die merkt, wenn etwas sie berührt, die aber nichts aufhält. Der Fisch schwimmt also vorerst einfach hindurch. Das Merken nutzen wir in Kapitel 3.
2. Zwei Kinder vom Typ `ColorRect` hinzufügen, `ObenBild` und `UntenBild`. Im Inspector bei **Layout → Transform**:

   | Node | Position | Size |
   |---|---|---|
   | ObenBild | `-30, -680` | `60, 600` |
   | UntenBild | `-30, 80` | `60, 600` |

   Bei **Color** eine Farbe nach Wahl.
3. Zwei Kinder vom Typ `CollisionShape2D` hinzufügen, `ObenForm` und `UntenForm`. Bei beiden **Shape → New RectangleShape2D**, dann auf das neue Shape klicken und **Size** = `60, 600` eintragen.

   | Node | Position |
   |---|---|
   | ObenForm | `0, -380` |
   | UntenForm | `0, 380` |

   **Warum andere Zahlen als beim Bild?** Ein `ColorRect` wird von seiner **linken oberen Ecke** aus platziert, eine `CollisionShape2D` von ihrer **Mitte** aus. Rechne nach: Das obere Bild geht von y = -680 bis -80, seine Mitte liegt also bei -380.

   **Achtung:** Wenn du `ObenForm` mit Strg+D duplizierst statt neu anzulegen, teilen sich beide Kopien dasselbe Shape. Das ist hier egal, weil beide gleich groß sind. Aber merk es dir: Wer bei einer Kopie die Größe ändert, ändert beide. Abhilfe: Rechtsklick aufs Shape → **Make Unique**.
4. Speichern als `korallen.tscn`.

### 2.2 Korallen bewegen sich

Skript an `Korallen` hängen (`korallen.gd`):

```gdscript
extends Area2D

const SPEED = 150.0  # Pixel pro Sekunde nach links

func _process(delta):
	position.x -= SPEED * delta
	# ganz links raus? Dann weg damit
	if position.x < -50:
		queue_free()
```

- `_process` läuft einmal pro Bild, `_physics_process` (beim Fisch) in festen Physik-Schritten. Faustregel: Wer Kollisionen per Physik braucht (`move_and_slide`), nimmt `_physics_process`, alles andere `_process`.
- `queue_free()` löscht die Node am Ende dieses Bildes. Ohne das würden immer mehr unsichtbare Korallen links aus dem Bild weiterschwimmen. In Weltraumsteine war das dein `asteroids.filter(a => !a.dead)`.

### 2.3 Ein Timer erzeugt neue Korallen

In Weltraumsteine hast du Zeit selbst heruntergezählt (`alienSpawn -= dt`). In Godot gibt es dafür eine fertige Node: den **Timer**.

1. In `main.tscn`: Rechtsklick auf `Main` → **Add Child Node** → `Timer` → umbenennen in `KorallenTimer`.
   Im Inspector: **Wait Time** = `1.6`, **Autostart** = an.
2. Skript an `Main` hängen (`main.gd`):

   ```gdscript
   extends Node2D

   const KORALLEN = preload("res://korallen.tscn")
   const GAP_MIN_Y = 150.0  # höchste Lage der Lücke
   const GAP_MAX_Y = 490.0  # tiefste Lage der Lücke
   ```

   `preload` lädt die Szene einmal beim Start, wie ein Bauplan.
3. Jetzt dein erstes **Signal**. Ein Timer sendet das Signal `timeout`, wenn die Zeit abgelaufen ist. Wer zuhört, wird benachrichtigt.
   - `KorallenTimer` auswählen.
   - Rechts neben dem Inspector auf den Tab **Node** → **Signals**.
   - Doppelklick auf `timeout()` → im Fenster `Main` auswählen → **Connect**.
   - Godot springt in `main.gd` und hat dort eine neue Funktion `_on_korallen_timer_timeout()` angelegt. Links neben der Zeile ist ein grünes Symbol: Das heißt, die Funktion ist mit einem Signal verbunden.
4. Fülle die Funktion:

   ```gdscript
   func _on_korallen_timer_timeout():
   	var korallen = KORALLEN.instantiate()
   	korallen.position = Vector2(400, randf_range(GAP_MIN_Y, GAP_MAX_Y))
   	add_child(korallen)
   ```

   | Weltraumsteine (JS) | Flatterfisch (GDScript) |
   |---|---|
   | `makeAsteroid(x, y, size)` baut ein Objekt | `KORALLEN.instantiate()` baut eine Kopie der Szene |
   | `asteroids.push(a)` | `add_child(korallen)` – erst dann ist sie im Spiel und wird gezeichnet |
   | `randomBetween(min, max)` | `randf_range(min, max)` |

   x = 400 liegt rechts außerhalb des Bildes (das ist 360 breit), damit die Korallen hereingeschwommen kommen statt plötzlich aufzutauchen.
5. **F5.** Korallen sollten von rechts kommen, in verschiedener Höhe, und der Fisch flattert hindurch.

### 2.4 Nachschauen, ob `queue_free` wirklich löscht

Während das Spiel läuft: Im Editor oben im Scene-Panel auf **Remote** klicken. Das ist der Baum des **laufenden** Spiels. Klapp `Main` auf: Korallen kommen hinzu und verschwinden wieder. Bleibt die Zahl ungefähr gleich, funktioniert das Aufräumen.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 2

1. **Farben (leicht):** Gib den Korallen eine Korallenfarbe und dem Meer einen blauen Hintergrund. Den Hintergrund findest du unter *Project Settings → Rendering → Environment → Default Clear Color*.
2. **Abstand rechnen (leicht):** Wie viele Pixel liegen zwischen zwei Korallenpaaren? Rechne es aus `SPEED` und **Wait Time** aus. Ändere eins von beiden, bis dir der Abstand gefällt.
3. **Weichere Höhen (mittel):** Manchmal liegt eine Lücke ganz oben und die nächste ganz unten. Das ist kaum zu schaffen. Sorge dafür, dass die nächste Lücke höchstens 150 Pixel von der vorigen entfernt ist. Tipp: Merke dir die letzte Höhe in einer Variable außerhalb der Funktion, und schau dir `clamp` an.
4. **Wer liegt oben? (mittel):** Die Korallen werden über den Fisch gezeichnet, weil sie später hinzugefügt werden. Finde heraus, wie man das ändert. Stichwort: `z_index` im Inspector unter **Ordering**.

---

## Kapitel 3: Zusammenstoß und Game Over

Bisher schwimmt der Fisch durch alles hindurch. Jetzt soll er sterben, wenn er eine Koralle berührt oder unten aus dem Bild fällt. Dann bleibt alles stehen, „GAME OVER“ erscheint, und mit Leertaste geht es von vorn los.

Dabei lernst du das Herzstück von Godot richtig kennen: **Signale**. In Kapitel 2 hast du ein fertiges Signal benutzt (`timeout` vom Timer). Jetzt baust du ein eigenes.

### 3.1 Die Idee: Wer muss was wissen?

In Weltraumsteine stand die ganze Logik in einer großen `update`-Funktion. Die wusste alles über alle. In Godot verteilt man die Aufgaben:

```
Koralle merkt:   „Mich hat etwas berührt“  → sagt dem Ding: „Stirb!“
Fisch merkt:     „Ich bin tot“             → sendet Signal  gestorben
Main hört zu:    „Fisch ist tot“           → Timer aus, Korallen anhalten, GAME OVER zeigen
```

Der Fisch weiß nicht, wer ihm zuhört. Die Koralle weiß nicht, dass es ein Fisch ist. So kann man jedes Teil ändern, ohne die anderen anzufassen.

### 3.2 Der Fisch kann sterben

Ergänze `fisch.gd`. Oben unter `extends`:

```gdscript
signal gestorben  # Nachricht an alle, die zuhören

var tot = false
```

Eine neue Funktion, z. B. ganz unten:

```gdscript
func sterben():
	if tot:
		return  # wer schon tot ist, stirbt nicht noch mal
	tot = true
	gestorben.emit()
```

Kommt dir `if tot: return` bekannt vor? Das ist die Lehre aus der Mehrfach-Explosion in Weltraumsteine.

Und ganz am **Anfang** von `_physics_process` ein Block für den toten Fisch. Er fällt nur noch, dreht sich mit dem Bauch nach oben und reagiert auf keine Taste mehr:

```gdscript
	if tot:
		velocity.y += gravity * delta
		rotation = move_toward(rotation, PI / 2, 5 * delta)
		move_and_slide()
		return
```

Zuletzt, ebenfalls in `_physics_process` (nach dem `tot`-Block): Wer unten rausfällt, stirbt auch.

```gdscript
	if position.y > 660:
		sterben()
```

### 3.3 Die Koralle meldet eine Berührung

1. `korallen.tscn` öffnen, `Korallen` auswählen → Tab **Node** → **Signals**.
2. Doppelklick auf `body_entered(body: Node2D)` → als Ziel **Korallen selbst** auswählen → **Connect**.
   Eine `Area2D` sendet `body_entered`, wenn ein Physik-Körper (wie dein `CharacterBody2D`) sie berührt. `body` ist der Körper, der sie berührt hat.
3. Fülle die neue Funktion in `korallen.gd`:

```gdscript
func _on_body_entered(body):
	if body.has_method("sterben"):
		body.sterben()
```

`has_method` fragt: „Kannst du sterben?“ Die Koralle muss nicht wissen, dass es ein Fisch ist. Kommt später etwas anderes dazu, das sterben kann (ein zweiter Fisch, ein Gegner …), funktioniert es sofort mit.

### 3.4 Korallen in eine Gruppe stecken

Main muss später *alle* Korallen auf einmal anhalten. Dafür gibt es **Gruppen**: ein Etikett, das man beliebig vielen Nodes geben kann.

`korallen.tscn` → `Korallen` auswählen → Tab **Node** → **Groups** → `korallen` eintippen → **Add**. Speichern.

Weil die Gruppe in der Szene steht, hat jede neu erzeugte Koralle sie automatisch.

### 3.5 Die GAME-OVER-Anzeige

1. In `main.tscn`: Rechtsklick auf `Main` → **Add Child Node** → `CanvasLayer`.
   Ein `CanvasLayer` ist eine Ebene für Anzeigen, die immer über dem Spiel liegt. Das wird in Kapitel 4 für die Punkte wichtig.
2. Rechtsklick auf `CanvasLayer` → **Add Child Node** → `Label` → umbenennen in `GameOverLabel`.
3. Im Inspector:
   - **Text:** `GAME OVER`, dann Enter, leere Zeile, `Leertaste: nochmal`
   - **Horizontal Alignment** und **Vertical Alignment:** `Center`
   - **Theme Overrides → Font Sizes → Font Size:** `32` (Häkchen davor setzen)
4. Oben in der Werkzeugleiste über dem Bild erscheint bei ausgewähltem Label ein Symbol für **Anchor Presets** (ein kleines grünes Kreuz/Rechteck). Wähle **Full Rect**. Dann füllt das Label den ganzen Bildschirm, und der Text steht genau in der Mitte.
5. Im Szenenbaum auf das **Auge** neben `GameOverLabel` klicken, damit es unsichtbar ist. Es soll erst beim Tod erscheinen.

### 3.6 Main reagiert auf den Tod

1. In `main.tscn` den `Fisch` auswählen → **Node** → **Signals**. Dort steht jetzt dein eigenes Signal `gestorben()`! (Falls nicht: `fisch.gd` speichern.)
2. Doppelklick auf `gestorben()` → Ziel `Main` → **Connect**.
3. Ergänze `main.gd`:

```gdscript
var kann_neustarten = false

func _on_fisch_gestorben():
	$KorallenTimer.stop()
	get_tree().call_group("korallen", "set_process", false)
	$CanvasLayer/GameOverLabel.show()
	# kurz warten, damit ein hektischer Tastendruck nicht sofort neu startet
	await get_tree().create_timer(0.8).timeout
	kann_neustarten = true

func _process(_delta):
	if kann_neustarten and Input.is_action_just_pressed("flap"):
		get_tree().reload_current_scene()
```

Was ist neu?

| Code | Bedeutung |
|---|---|
| `$KorallenTimer` | Kurzform für „die Kind-Node mit diesem Namen“. Mit `/` geht es tiefer: `$CanvasLayer/GameOverLabel`. |
| `call_group("korallen", "set_process", false)` | Ruft bei **jeder** Node der Gruppe `set_process(false)` auf. Dann läuft ihr `_process` nicht mehr, und sie bleiben stehen. |
| `await ... .timeout` | Die Funktion **pausiert** hier und macht nach 0,8 Sekunden weiter. Das Spiel läuft währenddessen normal weiter. In JavaScript hättest du dafür einen eigenen Timer herunterzählen müssen. |
| `_delta` | Der Unterstrich sagt Godot: „Diesen Parameter brauche ich absichtlich nicht.“ Ohne ihn zeigt Godot eine Warnung. |
| `reload_current_scene()` | Lädt `main.tscn` komplett neu: Alles ist wieder wie beim Start. Ein `newGame()`, in dem man jede Variable einzeln zurücksetzt (und eine vergisst), braucht man so nicht. |

4. **F5.** Gegen eine Koralle schwimmen → der Fisch kippt und fällt, die Korallen stehen, GAME OVER erscheint. Leertaste → neues Spiel.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 3

1. **Aussehen (leicht):** Gib dem GAME-OVER-Text eine andere Farbe und einen Umriss, damit er sich vom Wasser abhebt. Schau unter **Theme Overrides → Colors** und **Constants**.
2. **Signal per Code (mittel):** Verbinde `gestorben` nicht im Editor, sondern im Code. Lösche die Verbindung im Signals-Panel (Rechtsklick → Disconnect) und schreib in `main.gd` eine Funktion `_ready()`, die Godot beim Start einmal aufruft. Darin: `$Fisch.gestorben.connect(_on_fisch_gestorben)`. Beide Wege sind gleichwertig. Welcher gefällt dir besser?
3. **Bereit? (mittel):** Im Original geht es erst los, wenn man das erste Mal tippt. Bis dahin schwebt der Vogel und es kommen keine Hindernisse. Baue das nach. Tipps: Beim Timer **Autostart** ausschalten und ihn per Code mit `$KorallenTimer.start()` starten. Der Fisch braucht ein eigenes Signal, z. B. `gestartet`.
4. **Pause (schwer):** Mit P soll das Spiel anhalten. Godot hat dafür `get_tree().paused = true`. Probier es aus, und finde heraus, warum danach auch die Taste zum Weiterspielen nicht mehr reagiert. Stichwort: **Process → Mode** im Inspector.
