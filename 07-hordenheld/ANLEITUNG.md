# Hordenheld – Schritt-für-Schritt-Anleitung

Überleben gegen Hunderte Gegner auf einmal, im Stil von Vampire Survivors. Du steuerst nur die Laufrichtung. Die Waffen feuern von selbst, besiegte Gegner lassen Edelsteine fallen, und mit jedem Level wählst du ein Upgrade. Wer eine bestimmte Zeit überlebt, hat gewonnen.

Wie immer baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Vieles kennst du aus dem Kerkerheld: CharacterBody2D, Kollisionsebenen, Autoloads, Signale, Tweens, Optionen, Musik, Web-Export. Darum geht es schnell voran. Neu ist vor allem eine Frage: **Was passiert, wenn sehr viel gleichzeitig los ist?** Dafür lernst du den **Profiler**, **Object Pooling** und ein paar Tricks, die DOOM später genauso braucht. Dazu ein **Upgrade-System** und viel **Game Feel**: Treffer müssen sich gut anfühlen.

Gespielt wird mit dem Controller. Die Tastatur geht natürlich auch.

**Geplante Kapitel:**
1. Projekt, Held und eine Wiese ohne Ende ✔
2. Gegner kommen von überall ✔
3. Die Waffe schießt von selbst ← *du bist hier*
4. Edelsteine, Erfahrung und Level-Up
5. Upgrades als Daten: mehrere Waffen mit Stufen
6. Hunderte Gegner: Der Profiler zeigt, was bremst
7. Object Pooling: wiederverwenden statt wegwerfen
8. Game Feel: Wackeln, Blitzen, Zahlen
9. Die Uhr: Wellen, Elite-Gegner, Sieg und Game Over
10. Titelbild, Musik und Web-Export

---

## Kapitel 1: Projekt, Held und eine Wiese ohne Ende

### 1.1 Das Projekt anlegen

Im Godot-Projekt-Manager → **Create**:

| Feld | Wert |
|---|---|
| Project Name | `Hordenheld` |
| Project Path | `...\games\07-hordenheld` (der Ordner mit dieser Anleitung) |
| Renderer | **Compatibility** (für den Web-Export) |
| Version Control Metadata | **Git** |

Godot warnt, dass der Ordner nicht leer ist. Das ist diese Anleitung, du kannst trotzdem anlegen.

### 1.2 Pixel-Art-Einstellungen

Diesmal soll man viel sehen: Gegner kommen von allen Seiten, und man muss sie früh erkennen. Das Bild ist deshalb **breit**, im Format 16:9 wie ein Fernseher. 384 × 216 Pixel sind genau ein Fünftel von Full HD. *Project → Project Settings* (mit **Advanced Settings**):

| Einstellung | Wert | Warum |
|---|---|---|
| Display → Window → **Viewport Width / Height** | `384` × `216` | 24 × 13,5 Kacheln, viel Platz für Gegner. |
| Display → Window → **Window Width Override / Height Override** | `1152` × `648` | Dreimal so groß zum Testen. |
| Display → Window → Stretch → **Mode** | `viewport` | Pixel bleiben Pixel. |
| Display → Window → Stretch → **Aspect** | `keep` | Alle sehen gleich viel. Siehe unten. |
| Display → Window → Stretch → **Scale Mode** | `integer` | Jedes Pixel gleich groß. |
| Rendering → Textures → Canvas Textures → **Default Texture Filter** | `Nearest` | Keine Glättung. |

**Warum `keep` und nicht `expand` wie beim Hüpfheld?** Mit `expand` sähe man auf einem breiteren Bildschirm mehr von der Welt, also auch mehr Gegner, die noch weit weg sind. Das wäre unfair: Wer einen breiten Bildschirm hat, sieht die Gefahr früher. Mit `keep` sieht jeder genau 384 × 216 Pixel.

### 1.3 Die Kollisionsebenen benennen

*Project Settings → Layer Names → 2D Physics*:

| Ebene | Name | Kommt in |
|---|---|---|
| 1 | `Held` | Kapitel 1 |
| 2 | `Gegner` | Kapitel 2 |
| 3 | `Waffe` | Kapitel 3 |
| 4 | `Beute` | Kapitel 4 |

Eine Ebene `Welt` gibt es diesmal nicht: Auf der Wiese gibt es keine Wände.

### 1.4 Die Grafiken von Kenney 🆓

Zwei Pakete von kenney.nl, beide CC0 und kostenlos. Sie sind vom selben Zeichner und passen deshalb zusammen:
- **Tiny Dungeon** kennst du vom Kerkerheld: Helden, Monster, Waffen und Tränke.
- **Tiny Town** ist neu: Gras, Bäume, Blumen, Zäune und Häuser. Daraus kommt die Wiese.

Beide Pakete haben ihr Kachelblatt unter demselben Namen `tilemap_packed.png`. Deshalb bekommt jedes einen eigenen Ordner:

1. Im FileSystem einen Ordner `kenney` anlegen, darin `tiny-dungeon` und `tiny-town`.
2. Aus beiden Paketen jeweils `Tilemap/tilemap_packed.png` und `License.txt` in den passenden Ordner kopieren. Die Tiny-Dungeon-Datei kannst du auch aus `06-kerkerheld` nehmen, sie ist dieselbe.

Beide Blätter haben Kacheln mit **16 × 16** Pixeln, 12 Stück nebeneinander und 11 untereinander.

### 1.5 Die Steuerung

*Project Settings → Input Map*:

| Aktion | Tastatur | Xbox-Controller |
|---|---|---|
| `links` | Links, A | D-Pad links, linker Stick nach links (Axis 0 −) |
| `rechts` | Rechts, D | D-Pad rechts, linker Stick nach rechts (Axis 0 +) |
| `hoch` | Hoch, W | D-Pad hoch, linker Stick nach oben (Axis 1 −) |
| `runter` | Runter, S | D-Pad runter, linker Stick nach unten (Axis 1 +) |
| `pause` | Esc | Start |
| `ok` | Leertaste, Enter | A |

**Eine Angriffstaste gibt es nicht.** Die Waffen feuern von selbst. Das ganze Spiel ist: Wohin laufe ich? `ok` brauchst du erst im Level-Up-Menü in Kapitel 4, und `pause` kommt in Kapitel 9.

Nimm bei den Tasten wieder **Physical Keycode**, wie beim Kerkerheld. Dann liegen WASD auch auf einer französischen Tastatur an derselben Stelle.

### 1.6 Der Held

1. *Scene → New Scene* → **Other Node** → `CharacterBody2D` → umbenennen in `Held`.
2. Im Inspector: **Motion Mode** → `Floating`. Von oben gesehen gibt es keinen Boden, das kennst du vom Kerkerheld.
3. **Collision → Layer** nur `1` (Held). **Mask** ganz leer: Der Held stößt gegen nichts. Die Gegner sollen ihn nicht wegschieben, sie sollen ihm wehtun. Das kommt in Kapitel 2.
4. Kinder:
   - `Sprite2D` → `Bild`. **Texture** = `kenney/tiny-dungeon/tilemap_packed.png`, **Hframes** `12`, **Vframes** `11`, **Frame** einen Helden aussuchen. Nimm ruhig einen anderen als im Kerkerheld.
   - `CollisionShape2D` → **New CircleShape2D**, **Radius** `5`, **Position** `0, 3`.
   - `Camera2D`. Als Kind vom Held läuft sie einfach mit, ohne eine Zeile Code. **Anchor Mode** bleibt diesmal `Drag Center`: Der Held steht immer in der Mitte.

   Warum ein Kreis? Im Kerkerheld war die Form ein flaches Rechteck an den Füßen, weil der Held an Wänden entlanggleiten sollte. Hier gibt es keine Wände. Treffer kommen von allen Seiten, und ein Kreis ist in jeder Richtung gleich groß.
5. Skript anhängen, **Template: Empty**:

```gdscript
extends CharacterBody2D

const TEMPO = 70.0        # Pixel pro Sekunde
const WACKELN = 15.0      # so schnell wackelt er beim Laufen hin und her
const WACKEL_WINKEL = 0.15   # so weit, in Radiant (0.15 sind etwa 9 Grad)

var lauf_zeit := 0.0


func _physics_process(delta: float) -> void:
	var richtung := Input.get_vector("links", "rechts", "hoch", "runter")
	velocity = richtung * TEMPO
	move_and_slide()

	if richtung.x != 0:
		$Bild.flip_h = richtung.x < 0
	# Ein Bild pro Figur reicht: Beim Laufen wackelt sie hin und her
	if richtung != Vector2.ZERO:
		lauf_zeit += delta
		$Bild.rotation = sin(lauf_zeit * WACKELN) * WACKEL_WINKEL
	else:
		lauf_zeit = 0.0
		$Bild.rotation = 0.0
```

6. Speichern als `held.tscn`.

Die Figuren auf dem Kachelblatt haben nur ein einziges Bild, keine Laufanimation. Das Wackeln mit `sin` ist ein alter Trick: Ein Sinus schwingt gleichmäßig zwischen -1 und 1 hin und her. Mal `WACKEL_WINKEL` ergibt das eine kleine Drehung nach links und rechts. Mehr braucht es nicht, damit die Figur lebendig wirkt. Bei Hunderten Gegnern ist das auch viel billiger als ein AnimationPlayer pro Gegner. Dazu mehr in Kapitel 6.

### 1.7 Eine Wiese ohne Ende

Die Welt soll keinen Rand haben: Man kann ewig in eine Richtung laufen. Eine TileMap kann das nicht. Sie müsste unendlich groß sein.

**Der Trick:** Der Boden ist nur ein einziges Bild, gerade so groß wie der Bildschirm und eine Kachel extra an jedem Rand. Das Bild wiederholt eine Graskachel immer wieder. Und es läuft mit der Kamera mit, aber immer nur in **ganzen Kachelschritten**. Weil alle Kacheln gleich aussehen, merkt niemand, dass der Boden springt. Es sieht aus, als stünde er still und der Held liefe darüber.

1. Neue Szene: **2D Scene** → Root umbenennen in `Welt`.
2. Kind: `Sprite2D` → `Boden`. **Ordering → Z Index** `-10`, damit er unter allem liegt.
3. Skript an `Boden`:

```gdscript
extends Sprite2D

# Der Boden: ein Bild, das eine Kachel immer wieder wiederholt.
# Es ist so groß wie der Bildschirm plus eine Kachel an jedem Rand und springt mit der Kamera mit,
# immer um eine ganze Kachel. Weil alle Kacheln gleich aussehen, merkt man das Springen nicht.

const KACHEL = 16

@export var kachelblatt: Texture2D
@export var kachel := Vector2i(0, 0)   # welche Kachel vom Blatt, gezählt in Kacheln (Spalte, Zeile)


func _ready() -> void:
	# Die eine Kachel aus dem Blatt ausschneiden. Wiederholen kann Godot nur ein ganzes Bild.
	var bild := kachelblatt.get_image().get_region(Rect2i(kachel * KACHEL, Vector2i(KACHEL, KACHEL)))
	texture = ImageTexture.create_from_image(bild)
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	centered = false
	# region größer als das Bild selbst: Dann wird es wiederholt, bis die Fläche voll ist
	region_enabled = true
	region_rect = Rect2(Vector2.ZERO, get_viewport_rect().size + Vector2(KACHEL, KACHEL) * 2)


func _process(_delta: float) -> void:
	# Die linke obere Ecke vom Bildschirm, in der Welt
	var ecke := get_viewport().get_camera_2d().get_screen_center_position() - get_viewport_rect().size / 2
	# Auf ganze Kacheln abrunden, und eine Kachel Vorsprung, damit am Rand nie etwas fehlt
	global_position = (ecke / KACHEL).floor() * KACHEL - Vector2(KACHEL, KACHEL)
```

4. Im Inspector bei `Boden`: **Kachelblatt** = `kenney/tiny-town/tilemap_packed.png`. Bei **Kachel** trägst du die Spalte und Zeile einer Graskachel ein, beide ab 0 gezählt. Öffne dazu das Blatt mit Doppelklick und zähl nach. Am besten eignet sich eine Kachel, deren Ränder nahtlos aneinanderpassen, also ohne Rand und ohne Ecke.
5. Den Held aus `held.tscn` in die Welt ziehen, Position `0, 0`.
6. Speichern als `welt.tscn`.

**Warum `get_image()`?** Eine Textur liegt auf der Grafikkarte. `get_image()` holt eine Kopie davon in den normalen Speicher, wo man sie bearbeiten kann. `get_region()` schneidet ein Stück heraus, und `ImageTexture` macht daraus wieder eine Textur. Das passiert nur einmal beim Start, deshalb ist es egal, dass es etwas langsam ist.

**Warum `floor()`?** Teilen durch 16, abrunden, mal 16: Das ergibt die nächste Kachelgrenze links oberhalb. Ohne `floor()` würde der Boden jedes Pixel mitlaufen und stünde auf dem Bildschirm still. Der Held sähe dann aus, als liefe er auf der Stelle.

### 1.8 Ausprobieren

1. **F5** → Hauptszene: `welt.tscn` → **Select Current**.
2. Mit dem Controller in alle Richtungen laufen, auch schräg, und eine ganze Weile geradeaus.

Der Held steht in der Mitte, die Wiese zieht unter ihm durch, und nirgends taucht ein Rand auf. Beim Laufen wackelt er, im Stand steht er still.

Schieb den Stick nur ein kleines bisschen: Der Held läuft langsamer. `get_vector` liefert beim Stick nicht nur die Richtung, sondern auch, wie weit er gedrückt ist.

### 1.9 Was ist neu?

- **16:9 mit `keep`:** Jeder sieht gleich viel von der Welt.
- **Zwei Kenney-Pakete**, die zusammenpassen, in eigenen Ordnern.
- **Wackeln mit `sin`:** Bewegung ohne Animation, billig genug für Hunderte Figuren.
- **Die Kamera als Kind:** Sie folgt dem Held ohne Code.
- **Ein Boden ohne Ende:** ein wiederholtes Bild, das in Kachelschritten mitspringt. `get_image()`, `get_region()` und `ImageTexture`, um ein Stück aus einem Kachelblatt auszuschneiden.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 1

1. **Langsam schleichen (leicht):** Wie weit musst du den Stick drücken, bevor sich der Held überhaupt bewegt? Das ist die **Deadzone**. Sie steht in der Input Map bei jeder Aktion, Standard ist `0.5`. Stell sie bei allen vier Richtungen auf `0.2` und probier es noch einmal. Was ist besser? Warum gibt es überhaupt eine Deadzone? (Tipp: Leg den Controller hin und schau, ob der Held von selbst losläuft.)
2. **Weiche Kamera (mittel):** Schalte an der `Camera2D` **Position Smoothing** ein. Die Kamera läuft jetzt hinterher, statt am Held zu kleben. Gefällt dir das? Achte auf die Pixel: Zittern der Held oder der Boden beim Anhalten? Probier dann *Project Settings → Rendering → 2D → **Snap 2D Transforms to Pixel***. Was ändert sich?
3. **Nicht so gleichförmig (mittel):** Eine einzige Kachel, immer wieder, sieht auf Dauer langweilig aus. Mach aus `kachel` einen Ausschnitt aus **2 × 2** Kacheln, zum Beispiel Gras mit Gras und Blumen. Was musst du in `_ready` und in `_process` ändern? Und was passiert, wenn du in `_process` vergisst, dass ein Muster jetzt 32 Pixel groß ist? (Tipp: Lauf langsam und schau genau auf die Blumen.)

---

## Kapitel 2: Gegner kommen von überall

Bis jetzt ist die Wiese friedlich. Das ändert sich jetzt: Gegner tauchen außerhalb vom Bild auf, laufen stur auf den Held zu und kosten Leben, solange sie ihn berühren. Es werden schnell mehr. Eine Waffe hast du noch nicht. Du kannst nur weglaufen, und lange geht das nicht gut. 🕷️

### 2.1 Der Held kommt in eine Gruppe

Die Gegner müssen wissen, wo der Held ist. Am einfachsten geht das über eine **Gruppe**, wie beim Kerkerheld:

1. `held.tscn` öffnen, den Root `Held` auswählen.
2. Rechts der Tab **Node** → **Groups** → `held` eintragen → **Add**.

Wer den Held sucht, fragt dann `get_tree().get_first_node_in_group("held")`.

### 2.2 Der Gegner

1. Neue Szene: **Other Node** → `CharacterBody2D` → umbenennen in `Gegner`.
2. **Motion Mode** → `Floating`.
3. **Collision → Layer** nur `2` (Gegner), **Mask** auch nur `2`. Gegner stoßen also gegeneinander, aber nicht gegen den Held.
4. Tab **Node** → **Groups** → `gegner`. Die Gruppe braucht der Zähler weiter unten, und in Kapitel 3 sucht die Waffe darin nach Zielen.
5. Kinder:
   - `Sprite2D` → `Bild`, das Tiny-Dungeon-Blatt, **Hframes** `12`, **Vframes** `11`. Bei **Frame** suchst du dir ein Monster aus der vorletzten oder letzten Reihe aus. `122` ist eine Spinne.
   - `CollisionShape2D` → **New CircleShape2D**, **Radius** `6`, **Position** `0, 2`.
6. Skript anhängen, **Template: Empty**:

```gdscript
extends CharacterBody2D

const WACKELN = 12.0
const WACKEL_WINKEL = 0.15

@export var tempo := 30.0   # Pixel pro Sekunde, langsamer als der Held

var held: Node2D
# Jeder Gegner fängt an einer anderen Stelle der Wackel-Welle an. Sonst wackeln alle im Gleichtakt.
var lauf_zeit := randf() * TAU


func _ready() -> void:
	held = get_tree().get_first_node_in_group("held")


func _physics_process(delta: float) -> void:
	# Immer stur auf den Held zu
	var richtung := global_position.direction_to(held.global_position)
	velocity = richtung * tempo
	move_and_slide()

	$Bild.flip_h = richtung.x < 0
	lauf_zeit += delta
	$Bild.rotation = sin(lauf_zeit * WACKELN) * WACKEL_WINKEL
```

7. Speichern als `gegner.tscn`.

**`direction_to`** gibt die Richtung von hier zu einem anderen Punkt, als Vektor der Länge 1. Mal `tempo` wird daraus die Geschwindigkeit. Mehr Verstand hat der Gegner nicht, und mehr braucht er auch nicht. Gefährlich wird er erst durch seine Kumpel.

**Warum `randf() * TAU`?** `TAU` ist ein ganzer Kreis in Radiant, also 2π. `randf()` ist eine Zufallszahl zwischen 0 und 1. Ohne diese Zeile würden alle Gegner, die gleichzeitig entstehen, auch gleichzeitig nach links und rechts kippen. Das sieht aus wie eine Tanzgruppe.

**Warum Mask `2`?** Damit drängeln sich die Gegner. Ohne Mask laufen alle zur selben Stelle und liegen am Ende genau übereinander. Hundert Spinnen sähen dann aus wie eine einzige. Den Held haben sie nicht in der Mask, deshalb schieben sie ihn nicht weg, sondern rücken ihm auf die Pelle. Was das Drängeln kostet, schauen wir uns in Kapitel 6 an.

### 2.3 Der Held nimmt Schaden

Bei Vampire Survivors tut ein Gegner weh, **solange** er dich berührt, und nicht nur einmal beim Zusammenstoß. Drei Gegner am Held tun dreimal so schnell weh wie einer.

In `held.tscn`:
1. Kind von `Held`: `Area2D` → `Trefferzone`. **Collision → Layer** ganz leer, **Mask** nur `2`. Sie bemerkt also Gegner.
2. Kind von `Trefferzone`: `CollisionShape2D` → **New CircleShape2D**, **Radius** `6`, **Position** `0, 3`. Einen Pixel größer als der Kreis vom Held: Die Gegner stoßen ja nicht an ihn, sie sollen nur nah genug herankommen.
3. Kind von `Held`: `ProgressBar` → `Lebensbalken`. Im Inspector, in dieser Reihenfolge:
   - **Show Percentage** aus. Sonst will der Balken Platz für die Zahl und lässt sich nicht flach machen.
   - **Value** `100`.
   - **Theme Overrides → Styles → Background** → **New StyleBoxFlat**, aufklappen, **Bg Color** fast schwarz.
   - **Theme Overrides → Styles → Fill** → **New StyleBoxFlat**, **Bg Color** kräftiges Rot.
   - **Layout → Transform**: **Position** `-8, 10`, **Size** `16, 2`. Das ist ein dünner Strich unter den Füßen.
   - **Ordering → Z Index** `1`. Warum, steht in 2.5.

Das Skript `held.gd` bekommt zwei Konstanten, eine Variable und am Ende von `_physics_process` einen neuen Block:

```gdscript
const MAX_LEBEN = 100.0
const SCHADEN = 10.0      # so viel Leben kostet ein Gegner pro Sekunde, solange er den Held berührt

var lauf_zeit := 0.0
var leben := MAX_LEBEN
```

```gdscript
	# Wie viele Gegner berühren mich gerade?
	var treffer: int = $Trefferzone.get_overlapping_bodies().size()
	if treffer > 0:
		leben -= treffer * SCHADEN * delta
		$Lebensbalken.value = leben
		if leben <= 0:
			get_tree().reload_current_scene()
	$Bild.modulate = Color(1, 0.4, 0.4) if treffer > 0 else Color.WHITE
```

- **`get_overlapping_bodies()`** liefert alle Körper, die gerade in der Area stecken, als Array. `.size()` zählt sie. Mit dem Signal `body_entered` wie im Kerkerheld ginge das nicht so leicht: Das kommt nur einmal beim Hineinlaufen. Wir wollen aber wissen, wie viele **jetzt gerade** da sind.
- **`* delta`**: 10 Schaden pro Sekunde, egal wie viele Bilder pro Sekunde das Spiel schafft. 100 Leben reichen also für 10 Sekunden mit einem Gegner, oder für eine Sekunde mit zehn.
- **`var treffer: int =`** statt `:=`: Godot weiß bei `$Trefferzone` nur, dass es *irgendein* Node ist. Was `get_overlapping_bodies()` zurückgibt, kann es deshalb nicht erraten. Mit `: int` sagst du es ihm.
- **`modulate`** färbt das Bild. Weiß lässt es, wie es ist. Rot heißt: Hier tut gerade etwas weh.
- **`reload_current_scene()`** fängt einfach von vorn an. Einen richtigen Game-Over-Bildschirm gibt es in Kapitel 9.

### 2.4 Der Spawner

„Spawnen“ sagen Spieleentwickler, wenn etwas im Spiel entsteht. Der Spawner macht immer wieder einen neuen Gegner, irgendwo knapp außerhalb vom Bild, und mit der Zeit immer schneller.

In `welt.tscn`:
1. Kind von `Welt`: `Node2D` → `Horde`. Alle Gegner kommen als Kinder hier hinein. So liegen sie nicht wild verteilt in der Welt, und die Szene bleibt übersichtlich.
2. Skript an `Horde`, als `spawner.gd` speichern:

```gdscript
extends Node2D

const ABSTAND = 240.0   # so weit vom Held entsteht ein Gegner, knapp außerhalb vom Bild
const START_TAKT = 1.0  # am Anfang eine Sekunde zwischen zwei Gegnern
const MIN_TAKT = 0.1    # schneller wird es nicht: zehn Gegner pro Sekunde
const SCHNELLER = 0.97  # nach jedem Gegner wird der Takt 3 % kürzer

@export var gegner_szene: PackedScene

var takt := START_TAKT
var warten := START_TAKT


func _process(delta: float) -> void:
	warten -= delta
	# while statt if: Ist der Takt kürzer als ein Bild, kommen mehrere Gegner im selben Bild
	while warten <= 0:
		neuer_gegner()
		takt = maxf(MIN_TAKT, takt * SCHNELLER)
		warten += takt


func neuer_gegner() -> void:
	var held := get_tree().get_first_node_in_group("held") as Node2D
	var gegner := gegner_szene.instantiate()
	# Ein zufälliger Punkt auf einem Kreis um den Held
	gegner.position = held.global_position + Vector2.from_angle(randf() * TAU) * ABSTAND
	add_child(gegner)
```

3. Im Inspector bei `Horde`: **Gegner Szene** = `gegner.tscn`.

**Warum 240?** Der Bildschirm ist 384 × 216 Pixel groß, der Held steht in der Mitte. Die Ecken sind am weitesten weg: 192 Pixel zur Seite und 108 nach oben. Nach Pythagoras sind das √(192² + 108²) ≈ 220 Pixel. Dazu kommt noch ein halber Gegner, damit er nicht halb im Bild entsteht, und etwas Luft: 240. Auf diesem Kreis ist jeder Punkt außerhalb vom Bild.

**`Vector2.from_angle(winkel)`** macht aus einem Winkel einen Pfeil der Länge 1 in diese Richtung. Mal `ABSTAND` ist das ein Punkt auf dem Kreis.

**Warum `warten += takt` und nicht `warten = takt`?** Angenommen, `warten` ist schon bei −0,01, weil das Bild etwas zu spät kam. Mit `=` ginge diese Hundertstelsekunde verloren, mit `+=` wird sie beim nächsten Gegner abgezogen. Bei einem Gegner pro Sekunde merkt man das nicht. Bei zehn pro Sekunde fehlen sonst mit der Zeit einige.

**Wie schnell wird es voll?** Der Takt schrumpft mit jedem Gegner auf 97 %. Nach etwa 75 Gegnern ist er bei 0,1 Sekunden angekommen, das ist nach ungefähr einer halben Minute. Ab dann kommen zehn pro Sekunde. Nach einer Minute laufen über 300 Gegner herum, nach zwei Minuten fast tausend. Genau die brauchen wir in Kapitel 6.

### 2.5 Wer steht vorn?

Läuft eine Spinne unter dem Held vorbei, sollte sie **vor** ihm zu sehen sein, läuft sie oberhalb vorbei, **hinter** ihm. Godot malt aber einfach in der Reihenfolge der Szene. Dafür gibt es **Y-Sort**: Wer weiter unten steht, wird später gemalt.

1. `Welt` auswählen → **Ordering → Y Sort Enabled** an.
2. Dasselbe bei `Horde`.

Weil beide eingeschaltet sind, sortiert Godot die Kinder von `Horde` zusammen mit dem Held, als lägen alle direkt in der Welt. Der Boden bleibt dank **Z Index** `-10` trotzdem unter allem.

Und der Lebensbalken? Der gehört zum Held und würde mit ihm hinter Gegnern verschwinden, die weiter unten stehen. Deshalb hat er **Z Index** `1`: Er wird über allem gemalt, was auf Stufe 0 liegt.

### 2.6 Ein Zähler

Wie viele Gegner sind gerade da, und wie viele Bilder pro Sekunde schafft das Spiel? Das willst du ab jetzt immer im Blick haben.

1. Aus `06-kerkerheld/Kenney` die Datei `Kenney Pixel.ttf` in deinen Ordner `kenney` kopieren.
2. Kind von `Welt`: `CanvasLayer` → `Anzeige`. Was darin liegt, bewegt sich nicht mit der Kamera.
3. Kind von `Anzeige`: `Label` → `Info`. **Position** `4, 0`. **Label Settings** → **New LabelSettings**: **Font** = `Kenney Pixel.ttf`, **Outline → Size** `4`, **Color** schwarz. Mit dem Rand ist die Schrift auf dem bunten Gras lesbar.
4. Skript an `Info`, als `info.gd` speichern:

```gdscript
extends Label


func _process(_delta: float) -> void:
	text = "Gegner: %d   FPS: %d" % [get_tree().get_node_count_in_group("gegner"), Engine.get_frames_per_second()]
```

**FPS** heißt *frames per second*, Bilder pro Sekunde. 60 ist das Ziel. Fällt die Zahl, kommt das Spiel nicht mehr hinterher. Und `get_node_count_in_group` zählt, wer gerade in der Gruppe ist. Darum hat der Gegner eine.

### 2.7 Ausprobieren

**F5**:
- **Stehen bleiben:** Nach etwa acht Sekunden kommen die ersten Spinnen an. Der Held wird rot, der Balken schrumpft, und nach ein paar Sekunden geht es von vorn los.
- **Laufen:** Die Spinnen sind langsamer als du und ziehen hinter dir her wie eine Schleppe. Vorn tauchen aber immer neue auf.
- **Schräg laufen:** Der Held läuft schräg genauso schnell wie gerade, `get_vector` sorgt dafür. Die Spinnen holen trotzdem nicht auf.
- **Zähler:** Bei mir waren nach 40 Sekunden rund 175 Gegner unterwegs, bei 60 FPS. Wie viele schafft dein Rechner, bevor die FPS fallen? Merk dir die Zahl für Kapitel 6.

Ohne Waffe hast du keine Chance. Das ist Absicht. Die Waffe kommt in Kapitel 3.

### 2.8 Was ist neu?

- **Gegner mit einer Zeile Verstand:** `direction_to` und los. Die Gefahr kommt von der Menge.
- **Schaden, solange man sich berührt:** `get_overlapping_bodies()` zählt und `* delta` macht daraus Schaden pro Sekunde.
- **Ein Spawner** mit einem Takt, der immer kürzer wird, und Punkten auf einem Kreis außerhalb vom Bild. `Vector2.from_angle` und ein bisschen Pythagoras.
- **Y-Sort:** Wer weiter unten steht, wird davor gemalt, auch über mehrere Nodes hinweg.
- **Ein ProgressBar in der Welt:** Controls gehen auch als Kind von einem Node2D.
- **Ein Zähler für Gegner und FPS**, damit du siehst, wann es eng wird.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 2

1. **Ohne Drängeln (leicht):** Stell bei `gegner.tscn` die **Mask** ganz aus und lass 30 Sekunden laufen, ohne dich zu bewegen. Wie viele Spinnen siehst du am Ende, und wie viele zeigt der Zähler? Wie schnell stirbt der Held jetzt? Stell die Mask danach wieder auf `2`. 🥞
2. **Fledermäuse (mittel):** Mach einen zweiten Gegner, der schneller ist. Rechtsklick auf `gegner.tscn` → **New Inherited Scene**: Die neue Szene erbt alles und ändert nur, was du änderst. **Frame** `120`, **Tempo** `50`, speichern als `fledermaus.tscn`. Dann soll der Spawner zufällig wählen: Aus `gegner_szene` wird `@export var gegner_szenen: Array[PackedScene]`, und `pick_random()` sucht eine aus. Was passiert, wenn du die Fledermaus zweimal ins Array einträgst? 🦇
3. **Rechteck statt Kreis (mittel):** Der Kreis hat einen Haken: Der Bildschirm ist breit, aber nicht hoch. Ein Gegner, der rechts entsteht, ist nach 48 Pixeln im Bild. Einer, der oben entsteht, braucht dafür 132 Pixel. Lass die Gegner stattdessen auf einem Rechteck knapp um den Bildschirm entstehen. Würfle erst, an welcher Seite. Und warum sollten oben und unten öfter drankommen als links und rechts? (Tipp: Wie lang sind die Seiten?)
4. **Nachzügler (mittel):** Wer lange in eine Richtung läuft, zieht eine Schleppe aus Spinnen hinter sich her, die nie aufholt. Lass einen Gegner, der weiter als 300 Pixel vom Held weg ist, auf die **andere Seite** springen, also vor den Held. Dann ist vorn immer was los. (Tipp: Der Vektor vom Gegner zum Held, noch einmal vom Held aus angelegt.) Warum ist das besser, als ihn zu löschen und einen neuen zu machen?

---

## Kapitel 3: Die Waffe schießt von selbst

Endlich darf der Held zurückschlagen. Seine erste Waffe ist ein **Wurfmesser**: Alle paar Zehntelsekunden fliegt eines auf den nächsten Gegner zu. Zielen musst du nicht, nur gut laufen. 🔪

### 3.1 Gegner bekommen Leben

Bis jetzt sind die Gegner unverwundbar. In `gegner.gd` kommt ein Export dazu, gleich unter `tempo`:

```gdscript
@export var leben := 2      # so viele Treffer hält er aus
```

Und ganz unten eine neue Funktion. Die ruft später das Messer auf, wenn es trifft:

```gdscript
func treffer(schaden: int) -> void:
	leben -= schaden
	if leben <= 0:
		queue_free()
```

Weil die Fledermaus von `gegner.tscn` erbt, hat sie jetzt auch Leben. Öffne `fledermaus.tscn` und stell **Leben** auf `1`. Sie ist schnell, aber zerbrechlich. Den Wert zeigt der Inspector **ohne** den kleinen Pfeil zum Zurücksetzen, solange er noch geerbt ist. Sobald du ihn änderst, erscheint der Pfeil. So siehst du immer, was die Fledermaus anders macht als der Grund-Gegner.

### 3.2 Das Messer

1. Neue Szene: **Other Node** → `Area2D` → umbenennen in `Messer`.
2. **Collision → Layer** nur `3` (Waffe), **Mask** nur `2` (Gegner). **Monitorable** aus: Niemand muss das Messer bemerken, das Messer bemerkt die Gegner.
3. Kinder:
   - `Sprite2D` → `Bild`, das Tiny-Dungeon-Blatt, **Hframes** `12`, **Vframes** `11`, **Frame** `103`. Das ist ein kleiner Dolch, die Spitze zeigt nach oben.
   - `CollisionShape2D` → **New CircleShape2D**, **Radius** `4`.
4. Skript anhängen, **Template: Empty**:

```gdscript
extends Area2D

const TEMPO = 200.0        # Pixel pro Sekunde
const LEBENSDAUER = 1.5    # Sekunden, dann ist das Messer weg, auch wenn es nichts getroffen hat

var richtung := Vector2.RIGHT   # setzt die Waffe, bevor das Messer in die Welt kommt
var schaden := 1                # das auch
var zeit := LEBENSDAUER


func _ready() -> void:
	# Das Bild zeigt nach oben, der Winkel 0 aber nach rechts. Darum eine Vierteldrehung dazu.
	rotation = richtung.angle() + PI / 2


func _physics_process(delta: float) -> void:
	position += richtung * TEMPO * delta
	zeit -= delta
	if zeit <= 0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Trifft das Messer zwei Gegner im selben Bild, zählt nur der erste
	if is_queued_for_deletion():
		return
	body.treffer(schaden)
	queue_free()
```

5. Signal verbinden: Tab **Node** → **Signals** → `body_entered` → Doppelklick → **Connect** an `Messer`. Godot findet die Funktion `_on_body_entered`, die schon im Skript steht.
6. Speichern als `messer.tscn`.

**Warum `richtung.angle() + PI / 2`?** `angle()` gibt den Winkel eines Vektors. 0 heißt nach rechts, und es geht im Uhrzeigersinn weiter, weil in Godot y nach unten zählt. Der Dolch auf dem Kachelblatt zeigt aber nach oben, und das ist eine Vierteldrehung, also `PI / 2`, weniger als rechts. Mit `+ PI / 2` zeigt die Spitze genau in Flugrichtung.

**Warum eine Lebensdauer?** Ein Messer, das danebengeht, fliegt sonst ewig weiter. Nach ein paar Minuten wären Tausende unterwegs, die niemand sieht, und jedes kostet Rechenzeit. 1,5 Sekunden mal 200 Pixel sind 300 Pixel, das reicht bis weit hinter den Bildschirmrand.

**Warum `is_queued_for_deletion()`?** `queue_free()` löscht nicht sofort, sondern am Ende des Bildes. Stecken zwei Spinnen dicht beieinander, kann `body_entered` im selben Bild zweimal kommen. Ohne die Abfrage träfe ein Messer dann beide. In Übung 3 machst du genau das mit Absicht.

### 3.3 Die Waffe

Die Waffe ist ein eigener Node am Held. Sie sucht den nächsten Gegner, wirft ein Messer und wartet dann.

1. `held.tscn` öffnen. Kind von `Held`: `Node2D` → `Waffe`.
2. Skript an `Waffe`, als `waffe.gd` speichern:

```gdscript
extends Node2D

@export var geschoss_szene: PackedScene
@export var abklingzeit := 0.6    # Sekunden zwischen zwei Würfen
@export var schaden := 1
@export var reichweite := 150.0   # auf Gegner, die weiter weg sind, wird nicht geworfen

var warten := 0.0


func _physics_process(delta: float) -> void:
	warten -= delta
	if warten > 0:
		return
	var ziel := naechster_gegner()
	if ziel == null:
		return   # niemand da: warten bleibt unter 0, beim nächsten Gegner wird sofort geworfen

	var geschoss := geschoss_szene.instantiate()
	geschoss.richtung = global_position.direction_to(ziel.global_position)
	geschoss.schaden = schaden
	# In die Welt, nicht an den Held: Sonst liefe das Messer mit, wenn der Held läuft
	get_tree().current_scene.add_child(geschoss)
	geschoss.global_position = global_position
	warten = abklingzeit


func naechster_gegner() -> Node2D:
	var bester: Node2D = null
	var bester_abstand := reichweite * reichweite
	for gegner: Node2D in get_tree().get_nodes_in_group("gegner"):
		var abstand := global_position.distance_squared_to(gegner.global_position)
		if abstand < bester_abstand:
			bester = gegner
			bester_abstand = abstand
	return bester
```

3. Im Inspector bei `Waffe`: **Geschoss Szene** = `messer.tscn`.

**Warum nicht als Kind vom Held?** Ein Kind bewegt sich mit seinem Eltern-Node mit. Ein Messer am Held würde jeden Schritt mitmachen und eine Kurve fliegen, sobald du die Richtung wechselst. Darum kommt es mit `current_scene.add_child` direkt in die Welt. `current_scene` ist die Szene, die gerade läuft, also `welt.tscn`. Erst danach wird `global_position` gesetzt: Jetzt hängt das Messer in der Welt, und Godot weiß, wovon aus es rechnen soll.

**`richtung` und `schaden` vor `add_child`:** `_ready()` vom Messer läuft beim `add_child`. Dann muss die Richtung schon stimmen, sonst dreht sich das Messer nach rechts statt zum Ziel.

**Warum `warten = abklingzeit` und nicht `+=` wie beim Spawner?** Wenn eine Weile niemand in Reichweite ist, wird `warten` immer kleiner, zum Beispiel −5. Mit `+=` käme `warten` erst nach neun Würfen wieder über 0, und es flögen neun Messer direkt hintereinander los, eines pro Bild. Beim Spawner wollten wir genau das: Kein Gegner soll verloren gehen. Hier wäre es ein Fehler.

**`distance_squared_to`** ist der Abstand **zum Quadrat**. Um den echten Abstand auszurechnen, braucht der Rechner eine Wurzel (Pythagoras), und Wurzeln sind vergleichsweise teuer. Um herauszufinden, wer am nächsten ist, ist das Quadrat genauso gut: Wer näher ist, hat auch das kleinere Quadrat. Darum ist auch `bester_abstand` am Anfang `reichweite * reichweite`. Bei 500 Gegnern und mehreren Waffen spart das spürbar Rechenzeit. Mehr dazu in Kapitel 6.

**`for gegner: Node2D in ...`:** Mit `: Node2D` sagst du Godot, was in der Liste steckt. Dann kennt es `global_position` und kann dir beim Tippen helfen.

### 3.4 Ausprobieren

**F5**:
- Sobald eine Spinne näher als 150 Pixel ist, fliegt ein Messer. Die Spitze zeigt zum Ziel.
- Spinnen brauchen zwei Treffer, Fledermäuse einen.
- Ist niemand in Reichweite, wird nicht geworfen.
- Messer, die danebengehen, verschwinden nach 300 Pixeln.

In meinem Test hat der Held die ersten 20 Sekunden gut ausgesehen. Danach kommen mehr Gegner, als ein einzelnes Messer schafft, und nach etwa 30 Sekunden war die Horde stärker. Das ist so gewollt: Stärker wird der Held mit Edelsteinen und Upgrades, und die kommen in Kapitel 4 und 5.

### 3.5 Was ist neu?

- **Eine Waffe, die selbst zielt:** Sie geht alle Gegner durch und merkt sich den nächsten.
- **`distance_squared_to`:** Vergleichen ohne Wurzel, schneller bei vielen Gegnern.
- **Geschosse kommen in die Welt**, nicht an den, der schießt. Werte setzen vor `add_child`, Position danach.
- **Eine Lebensdauer**, damit danebengegangene Messer nicht ewig fliegen.
- **`is_queued_for_deletion()`:** Was schon gelöscht werden soll, macht nichts mehr.
- **Geerbte Werte überschreiben:** Die Fledermaus hat weniger Leben, alles andere bleibt geerbt.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 3

1. **Maschinengewehr (leicht):** Stell **Abklingzeit** auf `0.05`. Wie lange hältst du jetzt durch? Schau auch auf den Zähler und die FPS. Warum wäre das im fertigen Spiel trotzdem langweilig? Stell es danach wieder zurück. 🔫
2. **Fächer (mittel):** Neuer Export `anzahl := 1` in `waffe.gd`. Bei `3` fliegen drei Messer auf einmal: eines genau aufs Ziel, die anderen 15 Grad links und rechts daneben. (Tipp: `richtung.rotated(deg_to_rad(15))`. Und was machst du bei `2`, wo es keine Mitte gibt, oder bei `5`?)
3. **Durchschlag (mittel):** Das Messer soll durch zwei Gegner fliegen und erst am dritten hängen bleiben. Gib dem Messer eine Variable `durchschlag` und zähl sie bei jedem Treffer herunter. Brauchst du `is_queued_for_deletion()` dann noch? Kann es passieren, dass ein Messer **denselben** Gegner zweimal trifft?
4. **Rückstoß (mittel):** Ein getroffener Gegner soll ein paar Pixel zurückgeschubst werden. Dafür braucht `treffer` die Flugrichtung des Messers als zweiten Parameter. Der Schaden bleibt gleich, die Waffe fühlt sich aber stärker an. Warum? (Mehr davon in Kapitel 8.)
