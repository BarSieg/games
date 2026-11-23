# Hordenheld – Schritt-für-Schritt-Anleitung

Überleben gegen Hunderte Gegner auf einmal, im Stil von Vampire Survivors. Du steuerst nur die Laufrichtung. Die Waffen feuern von selbst, besiegte Gegner lassen Edelsteine fallen, und mit jedem Level wählst du ein Upgrade. Wer eine bestimmte Zeit überlebt, hat gewonnen.

Wie immer baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Vieles kennst du aus dem Kerkerheld: CharacterBody2D, Kollisionsebenen, Autoloads, Signale, Tweens, Optionen, Musik, Web-Export. Darum geht es schnell voran. Neu ist vor allem eine Frage: **Was passiert, wenn sehr viel gleichzeitig los ist?** Dafür lernst du den **Profiler**, misst, was wirklich bremst, und lernst ein paar Tricks, die DOOM später genauso braucht. Dazu ein **Upgrade-System** und viel **Game Feel**: Treffer müssen sich gut anfühlen.

Gespielt wird mit dem Controller. Die Tastatur geht natürlich auch.

**Geplante Kapitel:**
1. Projekt, Held und eine Wiese ohne Ende ✔
2. Gegner kommen von überall ✔
3. Die Waffe schießt von selbst ✔
4. Edelsteine, Erfahrung und Level-Up ✔
5. Upgrades als Daten: mehrere Waffen mit Stufen ✔
6. Hunderte Gegner: Der Profiler zeigt, was bremst ← *du bist hier*
7. Die Horde wird billiger: Gedränge ohne teure Physik
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

---

## Kapitel 4: Edelsteine, Erfahrung und Level-Up

Jeder besiegte Gegner lässt einen Edelstein fallen. Kommt der Held nah genug heran, saust der Stein zu ihm hin und bringt Erfahrung. Ist der Balken oben voll, steigt der Held ein Level auf: Das Spiel hält an, und du wählst eines von drei Upgrades. Ab jetzt wird der Held stärker, je länger er durchhält. 💎

### 4.1 Der Edelstein

Auf den Kenney-Blättern gibt es keinen Edelstein, also malst du ihn selbst, wie die Münzen und Herzen im Kerkerheld: mit `_draw()` und einem Bild aus Text.

1. Neue Szene: **Other Node** → `Area2D` → umbenennen in `Edelstein`.
2. **Collision → Layer** nur `4` (Beute), **Mask** ganz leer. **Monitoring** aus: Der Stein muss selbst niemanden bemerken. Ihn bemerkt gleich der Magnet vom Held.
3. Kind: `CollisionShape2D` → **New CircleShape2D**, **Radius** `3`.
4. Skript anhängen, **Template: Empty**:

```gdscript
extends Area2D

const BESCHLEUNIGUNG = 500.0   # so schnell wird er schneller, wenn er zum Held fliegt

# Das Bild, Zeichen für Zeichen. Was nicht in FARBEN steht, bleibt durchsichtig.
const BILD = [
	"...o...",
	"..o+o..",
	".o+##o.",
	"o+####o",
	".o###o.",
	"..o#o..",
	"...o...",
]
const FARBEN = {
	"o": Color(0.05, 0.1, 0.3),   # dunkler Rand
	"#": Color(0.2, 0.5, 1.0),    # blau
	"+": Color(0.75, 0.9, 1.0),   # Glanz
}

var wert := 1             # so viel Erfahrung bringt er, setzt der Gegner
var ziel: Node2D = null   # wohin er fliegt, setzt der Magnet
var tempo := -60.0        # negativ: erst ein kleiner Hüpfer weg vom Held, dann hin


func _draw() -> void:
	# Die Mitte vom Bild soll auf der Position vom Stein liegen
	var mitte := Vector2i(BILD[0].length(), BILD.size()) / 2
	for y in BILD.size():
		for x in BILD[y].length():
			var zeichen: String = BILD[y][x]
			if zeichen in FARBEN:
				draw_rect(Rect2(Vector2i(x, y) - mitte, Vector2.ONE), FARBEN[zeichen])


func anziehen(held: Node2D) -> void:
	ziel = held


func _physics_process(delta: float) -> void:
	if ziel == null:
		return   # liegt einfach da
	tempo += BESCHLEUNIGUNG * delta
	global_position = global_position.move_toward(ziel.global_position, tempo * delta)
	if global_position.distance_squared_to(ziel.global_position) < 4 * 4:
		ziel.erfahrung_dazu(wert)
		queue_free()
```

5. Speichern als `edelstein.tscn`.

**`move_toward(ziel, schritt)`** geht von einem Punkt aus höchstens `schritt` Pixel auf das Ziel zu, und nie darüber hinaus. Ist `schritt` negativ, geht es **weg** vom Ziel. Darum fängt `tempo` bei −60 an: Der Stein hüpft erst ein kleines Stück vom Held weg, wird dann langsamer, dreht um und saust immer schneller zu ihm hin. Das kostet eine Zeile und sieht viel lebendiger aus, als wenn er einfach angeflogen käme.

**Warum malt `_draw()` nicht jedes Bild neu?** Godot ruft `_draw()` nur einmal auf und merkt sich das Ergebnis. Erst `queue_redraw()` würde neu malen. Hundert Edelsteine kosten deshalb kaum etwas.

### 4.2 Gegner lassen Edelsteine fallen

In `gegner.gd` zwei neue Exports, gleich unter `leben`:

```gdscript
@export var beute_szene: PackedScene   # das bleibt liegen, wenn er stirbt
@export var erfahrung := 1             # so viel ist die Beute wert
```

In `treffer()` wird aus `queue_free()` ein `sterben()`. Und ganz unten kommt die neue Funktion:

```gdscript
func sterben() -> void:
	var beute := beute_szene.instantiate()
	beute.wert = erfahrung
	beute.position = global_position
	# call_deferred: erst am Ende des Bildes einfügen, siehe unten
	get_tree().current_scene.add_child.call_deferred(beute)
	queue_free()
```

In `gegner.tscn`: **Beute Szene** = `edelstein.tscn`. Die Fledermaus erbt das.

**Warum `call_deferred`?** `sterben()` wird vom Messer aufgerufen, und zwar aus `body_entered`, also mitten in der Physik-Berechnung. In diesem Moment darf man keine neuen Körper oder Areas einfügen, Godot meldet sonst einen Fehler: *Can't change this state while flushing queries*. `call_deferred` heißt: Mach das, aber erst, wenn die Physik fertig ist. Den Wert und die Position kannst du trotzdem sofort setzen, nur das Einfügen in die Welt wartet.

### 4.3 Der Magnet und die Erfahrung

In `held.tscn`:
1. Kind von `Held`: `Area2D` → `Magnet`. **Collision → Layer** ganz leer, **Mask** nur `4` (Beute). **Monitorable** aus.
2. Kind von `Magnet`: `CollisionShape2D` → **New CircleShape2D**, **Radius** `40`. Dann den Kreis aufklappen → **Resource** → **Local To Scene** an. Warum, steht in 4.6.
3. `Magnet` auswählen → Tab **Node** → **Signals** → `area_entered` → **Connect** an `Held`.

Das Skript `held.gd` bekommt ganz oben eine Zeile **vor** `extends`, darunter zwei Signale:

```gdscript
class_name Held
extends CharacterBody2D

signal erfahrung_geaendert(erfahrung: int, ziel: int)
signal level_auf(level: int)
```

Zu den Variablen kommen drei dazu:

```gdscript
var erfahrung := 0
var level := 1
var naechstes_level := 5   # so viel Erfahrung braucht das nächste Level
```

Und unten drei neue Funktionen:

```gdscript
func erfahrung_dazu(wert: int) -> void:
	erfahrung += wert
	erfahrung_geaendert.emit(erfahrung, naechstes_level)
	level_pruefen()


func level_pruefen() -> void:
	if erfahrung < naechstes_level:
		return
	erfahrung -= naechstes_level   # was zu viel war, bleibt fürs nächste Level
	level += 1
	naechstes_level += 5           # jedes Level braucht 5 mehr als das davor
	erfahrung_geaendert.emit(erfahrung, naechstes_level)
	level_auf.emit(level)


func _on_magnet_area_entered(area: Area2D) -> void:
	area.anziehen(self)
```

- **`class_name Held`:** Jetzt kennt Godot den Held als eigenen Typ, so wie `Monster` im Kerkerheld. Wer `var held: Held` schreibt, bekommt beim Tippen `level`, `erfahrung_dazu` und die Signale vorgeschlagen, und Tippfehler fallen schon im Editor auf.
- **Signale mit Werten:** `erfahrung_geaendert` schickt gleich mit, wie viel Erfahrung da ist und wie viel gebraucht wird. Der Balken muss dann nicht selbst beim Held nachfragen.
- **Der Magnet** ist eine zweite Area am Held, viel größer als die Trefferzone. Sobald ein Edelstein hineinkommt, bekommt der Stein Bescheid und fliegt los. Den Rest macht er selbst. Das gilt auch für Steine, die direkt im Magnet entstehen, weil ein Gegner neben dem Held stirbt: `area_entered` kommt dann gleich im ersten Bild.
- **5, 10, 15, 20 …:** Die ersten Level gehen schnell, danach wird es zäher. Für Level 10 brauchst du schon 225 Erfahrung.

### 4.4 Der Erfahrungsbalken

In `welt.tscn`, in der `Anzeige`:
1. Kind von `Anzeige`: `ProgressBar` → `Erfahrung`. Wie beim Lebensbalken, in dieser Reihenfolge: **Show Percentage** aus, **Background** fast schwarz, **Fill** blau wie die Edelsteine. Dann **Layout → Transform**: **Position** `0, 0`, **Size** `384, 3`. Ein dünner Strich über die ganze Breite, ganz oben.
2. Zieh `Erfahrung` im Szenenbaum **über** `Info`, und setz bei `Info` die **Position** auf `4, 3`, damit die Schrift unter dem Balken steht.
3. Skript an `Erfahrung`, als `erfahrung.gd` speichern:

```gdscript
extends ProgressBar


func _ready() -> void:
	var held: Held = get_tree().get_first_node_in_group("held")
	held.erfahrung_geaendert.connect(_on_erfahrung_geaendert)
	max_value = held.naechstes_level
	value = 0


func _on_erfahrung_geaendert(erfahrung: int, ziel: int) -> void:
	max_value = ziel
	value = erfahrung
```

Und `info.gd` zeigt jetzt auch das Level:

```gdscript
extends Label

var held: Held


func _ready() -> void:
	held = get_tree().get_first_node_in_group("held")


func _process(_delta: float) -> void:
	text = "Level %d   Gegner: %d   FPS: %d" % [held.level, get_tree().get_node_count_in_group("gegner"), Engine.get_frames_per_second()]
```

**Signal im Code verbinden:** Den Held gibt es in `welt.tscn` nur als Instanz, sein Signal lässt sich im Editor nicht so einfach mit einem Node in der `Anzeige` verbinden. `connect()` macht dasselbe wie der **Connect**-Knopf, nur im Skript.

### 4.5 Das Level-Up-Menü

Steigt der Held auf, hält das Spiel an, und drei Upgrades stehen zur Wahl.

In `welt.tscn`:
1. Kind von `Welt`: `CanvasLayer` → `LevelUp`. **Layer** `10`, damit es über der Anzeige liegt. **Process → Mode** → `Always`. Warum, steht unten.
2. Kind von `LevelUp`: `ColorRect` → `Abdunkeln`. Oben im Editor das **Anker-Symbol** → **Full Rect**. **Color** schwarz, Alpha etwa `150`. Das dunkelt das Spiel dahinter ab.
3. Kind von `LevelUp`: `VBoxContainer` → `Kasten`. **Anker-Symbol** → **Center**. **Theme Overrides → Constants → Separation** `6`.
4. Vier Kinder von `Kasten`, alle `Label`: `Titel`, `Wahl1`, `Wahl2`, `Wahl3`. Bei allen **Horizontal Alignment** → `Center`.

   Die Schrift soll aussehen wie beim Zähler. Damit du sie nicht viermal einstellen musst: Bei `Info` neben **Label Settings** auf den Pfeil → **Save As** → `schrift.tres`. Bei den vier neuen Labels dann **Label Settings** → **Load** → `schrift.tres`. Änderst du später die Schrift, ändert sie sich überall.
5. Skript an `LevelUp`, als `levelup.gd` speichern:

```gdscript
extends CanvasLayer

var held: Held
var angebot: Array[String] = []   # die drei Upgrades, die gerade zur Wahl stehen
var auswahl := 0                  # welches davon markiert ist

@onready var zeilen: Array[Label] = [$Kasten/Wahl1, $Kasten/Wahl2, $Kasten/Wahl3]


func _ready() -> void:
	hide()
	held = get_tree().get_first_node_in_group("held")
	held.level_auf.connect(zeigen)


func zeigen(level: int) -> void:
	$Kasten/Titel.text = "Level %d!" % level
	# Alle Upgrades mischen und die ersten drei nehmen: drei verschiedene, zufällig
	angebot.assign(Held.UPGRADES)
	angebot.shuffle()
	angebot.resize(3)
	for i in 3:
		zeilen[i].text = angebot[i]
	auswahl = 0
	markieren()
	show()
	get_tree().paused = true


func _process(_delta: float) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("runter"):
		auswahl = wrapi(auswahl + 1, 0, 3)
		markieren()
	elif Input.is_action_just_pressed("hoch"):
		auswahl = wrapi(auswahl - 1, 0, 3)
		markieren()
	elif Input.is_action_just_pressed("ok"):
		waehlen()


func markieren() -> void:
	for i in 3:
		zeilen[i].modulate = Color.YELLOW if i == auswahl else Color(1, 1, 1, 0.5)


func waehlen() -> void:
	hide()
	get_tree().paused = false
	held.upgrade(angebot[auswahl])
	# Hat der Held genug Erfahrung für noch ein Level, kommt das Menü gleich noch einmal
	held.level_pruefen()
```

- **`get_tree().paused = true`** hält alles an, was **Process Mode** `Inherit` hat, und das ist fast alles: Held, Gegner, Messer, Edelsteine, der Spawner. Das Menü selbst muss aber weiterlaufen, sonst könnte man nie wieder etwas auswählen. Darum steht `LevelUp` auf `Always`.
- **`is_action_just_pressed`** statt eines eigenen `_input`: Das kennst du vom Pausenmenü im Kerkerheld. Der Stick schickt bei jeder kleinen Bewegung ein neues Ereignis, und die Auswahl würde wild springen. `just_pressed` meldet nur den Moment, in dem die Richtung gedrückt wird.
- **`wrapi(wert, 0, 3)`** hält eine Zahl zwischen 0 und 2. Aus 3 wird 0, aus −1 wird 2. Wer unten weiterdrückt, landet wieder oben.
- **`assign`, `shuffle`, `resize`:** `assign` kopiert die Liste der Upgrades in `angebot`. Ohne Kopie würde `shuffle` die Liste im Held durcheinanderbringen, und die ist eine Konstante. `resize(3)` schneidet alles nach dem dritten Eintrag ab.
- **`Held.UPGRADES`** mit großem H: Das ist die Konstante der **Klasse** `Held`, die gibt es auch ohne einen bestimmten Held. Das geht dank `class_name`.

### 4.6 Die Upgrades

Fehlt noch, was die Upgrades tun. In `held.gd` eine neue Konstante zu den anderen:

```gdscript
const UPGRADES = ["Noch ein Messer", "Schneller werfen", "Schärfere Messer", "Großer Magnet", "Heiltrank"]
```

Und unten eine neue Funktion:

```gdscript
func upgrade(wahl: String) -> void:
	match wahl:
		"Noch ein Messer":
			$Waffe.anzahl += 1
		"Schneller werfen":
			$Waffe.abklingzeit *= 0.85
		"Schärfere Messer":
			$Waffe.schaden += 1
		"Großer Magnet":
			$Magnet/CollisionShape2D.shape.radius *= 1.3
		"Heiltrank":
			leben = MAX_LEBEN
			$Lebensbalken.value = leben
```

`anzahl` hast du in Übung 2 von Kapitel 3 eingebaut. Ab jetzt ist es ein Upgrade, und der Fächer mit festem Abstand wird mit jedem Messer breiter.

**Warum Local To Scene beim Magnet?** Eine Form wie der `CircleShape2D` ist eine **Resource**, und Resources teilt Godot: Jeder, der `held.tscn` lädt, bekommt **denselben** Kreis. Das spart Speicher, hat aber einen Haken. Ohne Local To Scene vergrößert „Großer Magnet“ den Kreis, der in `held.tscn` steckt. Stirbt der Held und das Spiel fängt mit `reload_current_scene()` von vorn an, hat der neue Held schon den großen Magnet. Ich habe das ausprobiert, es passiert wirklich. **Local To Scene** heißt: Jede Instanz der Szene bekommt ihre eigene Kopie. Merk dir die Regel: Wer eine Resource im Spiel verändert, braucht eine eigene Kopie davon.

**`* 0.85`** heißt 15 % kürzer. Mehrmals gewählt wird es immer kürzer, aber nie 0: 0,6 → 0,51 → 0,43 → 0,37 …

**Ein Haken, der dir auffallen wird:** Jedes Upgrade steht an **zwei** Stellen, einmal in `UPGRADES` und einmal im `match`. Vertippst du dich an einer, passiert beim Wählen einfach nichts, ohne Fehlermeldung. Und dass es bei „Schneller werfen“ nach dem fünften Mal reicht, steht nirgends. In Kapitel 5 werden die Upgrades deshalb zu **Daten**: jedes eine eigene kleine Datei mit Namen, Beschreibung und Stufen.

### 4.7 Ausprobieren

**F5**:
- Besiegte Gegner lassen blaue Edelsteine liegen. Läufst du hin, hüpfen sie kurz weg und sausen dann zu dir.
- Der blaue Balken oben füllt sich. In meinem Test kam das erste Level nach etwa 20 Sekunden.
- Das Spiel hält an, drei Upgrades erscheinen. Mit dem Stick oder dem D-Pad wählen, mit A bestätigen. Die Auswahl springt nicht.
- Danach geht es genau da weiter, wo es angehalten hat.
- „Noch ein Messer“: Ab jetzt fliegen zwei. „Großer Magnet“: Steine kommen schon von weiter weg.

Steine, die außerhalb vom Magnet liegen, bleiben liegen. Wer sie will, muss hinlaufen, auch mitten durch die Horde. So soll es sein.

### 4.8 Was ist neu?

- **Beute mit `call_deferred`:** Neue Körper und Areas kommen erst nach der Physik in die Welt.
- **`move_toward`** mit wachsendem Tempo, und negativem Tempo für den Hüpfer am Anfang.
- **Ein Magnet aus einer zweiten Area**, viel größer als die Trefferzone.
- **Geteilte Resources:** Wer eine Form im Spiel verändert, braucht **Local To Scene**.
- **`class_name`** für den Held: Typen, Vorschläge beim Tippen und `Held.UPGRADES`.
- **Signale mit Werten**, im Code verbunden mit `connect()`.
- **Pause** mit `get_tree().paused` und **Process Mode** `Always` für das Menü.
- **`wrapi`**, `shuffle` und `resize` für eine Auswahl aus drei.
- **LabelSettings als Datei**, damit alle Texte gleich aussehen.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 4

1. **Fette Beute (leicht):** Fledermäuse sind schwer zu treffen und sollen sich mehr lohnen. Gib ihnen **Erfahrung** `3`. Woran merkst du im Spiel, dass es geklappt hat? 🦇
2. **Grün ist mehr wert (mittel):** Man soll schon von Weitem sehen, welcher Stein mehr bringt. Steine mit `wert` ab `3` sollen grün sein statt blau. Dafür brauchst du eine zweite Farbtabelle neben `FARBEN`. Wo entscheidest du, welche genommen wird? (Tipp: `_draw()` läuft erst, wenn der Stein in der Welt ist. Ist `wert` dann schon gesetzt?) 💚
3. **Flinke Füße (mittel):** Neues Upgrade: Der Held läuft 10 % schneller. `TEMPO` ist eine Konstante, die kann sich nicht ändern. Was musst du umbauen? An wie vielen Stellen musst du den Namen „Flinke Füße“ schreiben?
4. **Zwei Level auf einmal (mittel):** Stell zum Testen die Erfahrung der Fledermaus auf `30`. Was passiert, wenn du eine einsammelst? Nimm dann in `waehlen()` die Zeile `held.level_pruefen()` heraus und probier es noch einmal. Was ist jetzt anders, und wann kommt das fehlende Menü doch noch? Danach wieder zurückstellen.

---

## Kapitel 5: Upgrades als Daten: mehrere Waffen mit Stufen

Am Ende von Kapitel 4 stand jedes Upgrade an zwei Stellen: in `UPGRADES` und im `match`. Mit „Flinke Füße“ hast du es selbst gemerkt. In diesem Kapitel wird jedes Upgrade eine **eigene kleine Datei**, mit Titel, Beschreibung, höchster Stufe und dem, was es bewirkt. Neue Upgrades baust du dann im Inspector zusammen, ganz ohne Code. Und weil das so einfach ist, kommt gleich eine zweite Waffe dazu: der **Glutring**. 🔥

### 5.1 Eine eigene Resource

Eine **Resource** kennst du schon: Der `CircleShape2D` ist eine, die `LabelSettings` in `schrift.tres` auch. Das sind Datenpakete, die Godot in einer Datei speichern und im Inspector anzeigen kann. Jetzt baust du deine eigene.

Im **FileSystem** unten links: Rechtsklick auf `res://` → **Create New** → **Script…**. **Inherits** `Resource`, **Path** `res://upgrade.gd`, **Template** `Empty`:

```gdscript
class_name Upgrade
extends Resource

@export var titel := ""
@export var beschreibung := ""
@export var max_stufe := 5   # so oft kann man es wählen, 0 heißt: beliebig oft

@export_group("Wirkung")
@export var knoten := "."      # welcher Node, vom Held aus gesehen
@export var eigenschaft := ""  # welche Variable von diesem Node
@export var mal := 1.0         # erst malnehmen ...
@export var plus := 0.0        # ... dann dazuzählen
@export var neue_waffe: PackedScene   # gibt es eine, kommt sie beim ersten Mal an den Held


func anwenden(held: Node, stufe: int) -> void:
	if neue_waffe != null and stufe == 0:
		held.add_child(neue_waffe.instantiate())
		return
	var ziel := held.get_node(knoten)
	var alt = ziel.get_indexed(eigenschaft)
	ziel.set_indexed(eigenschaft, alt * mal + plus)
```

- **`extends Resource` und `class_name Upgrade`:** Damit kennt Godot einen neuen Typ von Resource, so wie `CircleShape2D`. Im nächsten Schritt kannst du ihn ganz normal über das Menü anlegen.
- **`@export_group("Wirkung")`** macht im Inspector eine aufklappbare Gruppe. Alles darunter gehört dazu. Oben stehen Titel und Beschreibung fürs Menü, unten in der Gruppe, was das Upgrade tut.
- **Ein Upgrade ist eine Rechnung:** Nimm die Variable `eigenschaft` vom Node `knoten`, mal `mal`, plus `plus`. Damit gehen drei Arten von Upgrades:

| Art | mal | plus | Beispiel |
|---|---|---|---|
| etwas dazu | `1` | `1` | Noch ein Messer: aus 1 wird 2 |
| prozentual mehr oder weniger | `0.85` | `0` | Schneller werfen: aus 0,6 wird 0,51 |
| auf einen festen Wert | `0` | `100` | Heiltrank: egal wie viel, danach 100 |

- **`get_node(knoten)`:** `knoten` ist ein Pfad vom Held aus, so wie bei `$`. `"Waffe"` ist `$Waffe`, und `"."` ist der Held selbst.
- **`get_indexed` und `set_indexed`** lesen und schreiben eine Variable, deren Namen in einem Text steht. `get_indexed("anzahl")` ist dasselbe wie `.anzahl`. Mit Doppelpunkt geht es auch tiefer hinein: `"shape:radius"` heißt `.shape.radius`. Damit kommt das Upgrade sogar an den Radius vom Magnet-Kreis.
- **`var alt` ohne Typ**, mit `=` statt `:=`: Was herauskommt, kann eine ganze Zahl sein (`anzahl`) oder eine Kommazahl (`abklingzeit`). Erst beim Spielen steht fest, was es ist.
- **Ganze Zahlen:** `1 * 1.0 + 1.0` ergibt die Kommazahl `2.0`. `anzahl` ist aber eine ganze Zahl. Godot schneidet beim Speichern die Nachkommastellen ab, und aus `2.0` wird `2`. Das passt. Aber Vorsicht bei `mal 1.5` auf eine ganze Zahl: Aus 3 wird 4,5, und abgeschnitten bleibt 4.
- **`neue_waffe`:** Ist hier eine Szene eingetragen, hängt das Upgrade sie beim ersten Wählen an den Held. Ab dem zweiten Mal macht es die normale Rechnung. Dazu mehr beim Glutring.

**Und Tippfehler?** Schreibst du `anzhal` statt `anzahl`, liefert `get_indexed` nichts (`null`), und beim Malnehmen bleibt das Spiel mit *Invalid operands 'Nil' and 'float'* stehen. Ein falscher Knoten-Pfad meldet *Node not found*. Das ist besser als vorher: Da ist bei einem Tippfehler einfach nichts passiert, und keiner hat es gemerkt.

### 5.2 Die Upgrade-Dateien

1. Im **FileSystem**: Rechtsklick auf `res://` → **Create New** → **Folder…** → `upgrades`.
2. Rechtsklick auf `upgrades` → **Create New** → **Resource…** → oben `Upgrade` eintippen → **Create** → als `noch_ein_messer.tres` speichern.
3. Die Datei ist im Inspector offen. Trag die Werte aus der ersten Zeile der Tabelle ein und speichere mit **Strg+S**.
4. Für die nächste: Rechtsklick auf die fertige Datei → **Duplicate…** → neuer Name. Dann nur noch die Werte ändern. Das geht schneller als jedes Mal von vorn.

| Datei | Titel | Beschreibung | Max Stufe | Knoten | Eigenschaft | Mal | Plus |
|---|---|---|---|---|---|---|---|
| `noch_ein_messer` | Noch ein Messer | Ein Messer mehr bei jedem Wurf | 4 | `Waffe` | `anzahl` | 1 | 1 |
| `schneller_werfen` | Schneller werfen | 15 % kürzere Pause zwischen den Würfen | 5 | `Waffe` | `abklingzeit` | 0.85 | 0 |
| `schaerfere_messer` | Schärfere Messer | Jedes Messer macht 1 Schaden mehr | 5 | `Waffe` | `schaden` | 1 | 1 |
| `grosser_magnet` | Großer Magnet | Edelsteine kommen von weiter her | 3 | `Magnet/CollisionShape2D` | `shape:radius` | 1.3 | 0 |
| `flinke_fuesse` | Flinke Füße | 10 % schneller laufen | 3 | `.` | `tempo` | 1.1 | 0 |
| `heiltrank` | Heiltrank | Alle Lebenspunkte zurück | 0 | `.` | `leben` | 0 | 100 |

Die Knoten-Pfade müssen genau so heißen wie in deinem `held.tscn`. Heißt dein Kreis im Magnet anders, nimm deinen Namen.

Jetzt steht auch fest, wie oft man etwas wählen kann. Vier zusätzliche Messer sind genug, und nach fünfmal „Schneller werfen“ ist Schluss. Nur den Heiltrank gibt es beliebig oft.

### 5.3 Der Held merkt sich die Stufen

In `held.gd` fliegen die Konstante `UPGRADES` und die ganze Funktion `upgrade()` mit dem `match` raus. Dafür kommt unter die Konstanten ein Export:

```gdscript
@export var upgrades: Array[Upgrade] = []
```

`leben` bekommt einen Setter, und eine neue Variable kommt dazu:

```gdscript
var leben := MAX_LEBEN:
	set(wert):
		leben = clampf(wert, 0, MAX_LEBEN)
		$Lebensbalken.value = leben
var stufen: Dictionary[Upgrade, int] = {}   # wie oft welches Upgrade schon gewählt wurde
```

Den Setter kennst du aus dem Kerkerheld. Er ist für den Heiltrank da: Das Upgrade schreibt nur `leben`, vom Lebensbalken weiß es nichts. Der Setter sorgt dafür, dass der Balken trotzdem mitgeht. In `_physics_process` kannst du deshalb die Zeile `$Lebensbalken.value = leben` löschen, das macht jetzt auch der Setter.

`tempo` als Variable hast du aus Übung 3 von Kapitel 4. Falls nicht: `const TEMPO` in `const STARTTEMPO` umbenennen, `var tempo := STARTTEMPO` dazu, und in `_physics_process` mit `tempo` statt `TEMPO` rechnen.

Unten, wo vorher `upgrade()` stand, kommen drei neue Funktionen hin:

```gdscript
func stufe(upgrade: Upgrade) -> int:
	return stufen.get(upgrade, 0)


func moegliche_upgrades() -> Array[Upgrade]:
	var liste: Array[Upgrade] = []
	for upgrade in upgrades:
		if upgrade.max_stufe == 0 or stufe(upgrade) < upgrade.max_stufe:
			liste.append(upgrade)
	return liste


func upgrade_waehlen(upgrade: Upgrade) -> void:
	upgrade.anwenden(self, stufe(upgrade))
	stufen[upgrade] = stufe(upgrade) + 1
```

Jetzt die Liste füllen: `held.tscn` öffnen, `Held` auswählen. Im Inspector steht **Upgrades**. Klapp es auf, klick sechsmal **Add Element**, und zieh die sechs Dateien aus dem FileSystem in die leeren Felder.

- **`Dictionary[Upgrade, int]`** ist ein Dictionary mit Typen, wie das Inventar im Kerkerheld, nur dass Godot jetzt aufpasst: Schlüssel sind Upgrades, Werte ganze Zahlen. Etwas anderes hineinzustecken gibt schon im Editor einen Fehler.
- **`stufen.get(upgrade, 0)`:** Wurde das Upgrade noch nie gewählt, steht es nicht im Dictionary. `get` liefert dann die `0` statt eines Fehlers.
- **`moegliche_upgrades()`** sammelt alles, was noch nicht ausgereizt ist.

**Warum steht die Stufe nicht in der Upgrade-Datei?** Das wäre doch praktisch: `upgrade.stufe += 1`, fertig. Aber denk an den Magnet aus Kapitel 4: Resources teilt Godot. Die Datei `noch_ein_messer.tres` gibt es im ganzen Spiel genau einmal. Stirbt der Held und das Spiel fängt neu an, hätte sie immer noch Stufe 3, und der neue Held käme nie wieder auf vier Messer. Darum gilt: Die Datei sagt, **was** ein Upgrade ist. **Wie oft** es gewählt wurde, merkt sich der Held. Und der fängt bei jedem Neustart wieder bei null an.

### 5.4 Das Menü zeigt Stufen und Beschreibung

In `welt.tscn`:
1. Noch ein Kind von `LevelUp/Kasten`, ganz unten: `Label` → `Beschreibung`. **Horizontal Alignment** `Center`, **Vertical Alignment** `Bottom`, **Label Settings** → **Load** → `schrift.tres`.
2. Bei **Layout → Custom Minimum Size** das **y** auf `20`. Dadurch ist das Label höher als die Schrift, und weil sie unten steht, entsteht eine Lücke. Ohne die Lücke sieht die Beschreibung aus wie eine vierte Wahl.

Das neue `levelup.gd`, im Ganzen:

```gdscript
extends CanvasLayer

var held: Held
var angebot: Array[Upgrade] = []   # die Upgrades, die gerade zur Wahl stehen
var auswahl := 0                   # welches davon markiert ist

@onready var zeilen: Array[Label] = [$Kasten/Wahl1, $Kasten/Wahl2, $Kasten/Wahl3]


func _ready() -> void:
	hide()
	held = get_tree().get_first_node_in_group("held")
	held.level_auf.connect(zeigen)


func zeigen(level: int) -> void:
	angebot = held.moegliche_upgrades()
	if angebot.is_empty():
		return   # alles ausgereizt, dann gibt es eben nichts
	angebot.shuffle()
	angebot.resize(mini(angebot.size(), 3))

	$Kasten/Titel.text = "Level %d!" % level
	for i in 3:
		zeilen[i].visible = i < angebot.size()
		if zeilen[i].visible:
			zeilen[i].text = beschriftung(angebot[i])
	auswahl = 0
	markieren()
	show()
	get_tree().paused = true


func beschriftung(upgrade: Upgrade) -> String:
	var stufe := held.stufe(upgrade)
	if upgrade.neue_waffe != null and stufe == 0:
		return upgrade.titel + "  NEU!"
	if upgrade.max_stufe == 0:
		return upgrade.titel
	return "%s  %d/%d" % [upgrade.titel, stufe + 1, upgrade.max_stufe]


func _process(_delta: float) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("runter"):
		auswahl = wrapi(auswahl + 1, 0, angebot.size())
		markieren()
	elif Input.is_action_just_pressed("hoch"):
		auswahl = wrapi(auswahl - 1, 0, angebot.size())
		markieren()
	elif Input.is_action_just_pressed("ok"):
		waehlen()


func markieren() -> void:
	for i in angebot.size():
		zeilen[i].modulate = Color.YELLOW if i == auswahl else Color(1, 1, 1, 0.5)
	$Kasten/Beschreibung.text = angebot[auswahl].beschreibung


func waehlen() -> void:
	hide()
	get_tree().paused = false
	held.upgrade_waehlen(angebot[auswahl])
	held.level_pruefen()
```

Was sich geändert hat:
- **Weniger als drei:** Ist fast alles ausgereizt, bleiben vielleicht nur noch zwei oder eins übrig. `mini(angebot.size(), 3)` nimmt die kleinere Zahl. Ein `resize(3)` bei nur zwei Einträgen würde die Liste sonst mit `null` auffüllen. Leere Zeilen werden versteckt, und `wrapi` springt nur über so viele Zeilen, wie da sind.
- **Kein `assign` mehr:** `moegliche_upgrades()` baut jedes Mal eine neue Liste. `shuffle` bringt also nur diese Kopie durcheinander, nicht die Liste im Held.
- **`2/4` hinter dem Titel** zeigt, welche Stufe man bekommt, wenn man es wählt. Eine neue Waffe bekommt ein „NEU!“, der Heiltrank nichts.
- **Die Beschreibung** wechselt mit der Auswahl, darum steht sie in `markieren()`.

Jetzt **F5**. Das Spiel sollte genauso laufen wie vorher, nur das Menü zeigt mehr. Erst wenn das klappt, kommt die neue Waffe.

### 5.5 Eine zweite Waffe: der Glutring

Ein glühender Ring um den Held, der alles verbrennt, was ihm zu nahe kommt. Er zielt nicht, er wirft nichts. Er ist einfach da und hilft genau dann, wenn die Horde schon ganz nah ist.

1. Neue Szene: **Other Node** → `Area2D` → `Glutring`.
2. **Collision → Layer** nur `3` (Waffe), **Mask** nur `2` (Gegner). **Monitorable** aus. Wie beim Messer.
3. **CanvasItem → Ordering → Z Index** `-1`. Dann liegt das Glühen unter dem Held und den Gegnern, aber über dem Boden (der hat `-10`).
4. Kind: `CollisionShape2D` → **New CircleShape2D**, **Radius** `24`, und wieder **Resource → Local To Scene** an. Der Radius wird gleich per Upgrade wachsen, das kennst du jetzt.
5. Skript anhängen, `glutring.gd`:

```gdscript
extends Area2D

@export var schaden := 1
@export var takt := 0.5   # alle so viele Sekunden brennt er

var warten := 0.0
var zeit := 0.0


func _physics_process(delta: float) -> void:
	warten -= delta
	if warten > 0:
		return
	warten = takt
	for gegner: Node2D in get_overlapping_bodies():
		gegner.treffer(schaden)


func _process(delta: float) -> void:
	zeit += delta
	queue_redraw()


func _draw() -> void:
	var radius: float = $CollisionShape2D.shape.radius
	var flackern := 0.8 + 0.2 * sin(zeit * 8.0)
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.3, 0.0, 0.3 * flackern))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1.0, 0.8, 0.2, flackern))
```

6. Speichern als `glutring.tscn`. **Nicht** in den Held ziehen! Das macht nachher das Upgrade.

Dann die siebte Upgrade-Datei, `upgrades/glutring.tres`:

| Titel | Beschreibung | Max Stufe | Knoten | Eigenschaft | Mal | Plus | Neue Waffe |
|---|---|---|---|---|---|---|---|
| Glutring | Brennt Gegner rund um dich, jede Stufe größer | 4 | `Glutring/CollisionShape2D` | `shape:radius` | 1.25 | 0 | `glutring.tscn` |

Bei **Neue Waffe** ziehst du `glutring.tscn` aus dem FileSystem ins Feld. Dann die Datei in die **Upgrades**-Liste vom Held, als siebtes Element.

- **Stufe 1 hängt den Ring an den Held**, so steht es in `anwenden()`. Stufe 2 bis 4 machen ihn jeweils ein Viertel größer: 24 → 30 → 37,5 → 47 Pixel. Dass das Upgrade den Ring unter `Glutring/...` findet, liegt daran, dass ein Node beim Einfügen so heißt wie die Wurzel seiner Szene.
- **`get_overlapping_bodies()`** statt `body_entered`: Das Messer trifft einmal beim Hineinfliegen. Der Ring soll aber jeden brennen, **solange** er drin ist, alle halbe Sekunde wieder. Das ist dieselbe Frage wie beim Schaden vom Held: Wer ist gerade da?
- **`queue_redraw()` in jedem Bild:** Beim Edelstein hieß es, `_draw()` läuft nur einmal. Der Ring soll aber flackern und mitwachsen. Mit `queue_redraw()` malt er jedes Bild neu. Bei einem einzigen Kreis kostet das nichts. Bei hundert Edelsteinen würde man es lassen.
- **`draw_circle` und `draw_arc`:** eine halb durchsichtige Fläche und ein heller Rand. Das `flackern` schwankt mit `sin` zwischen 0,6 und 1,0 und macht beides mal heller, mal dunkler.

Und das Schönste: Für das neue Upgrade hast du am Held **keine einzige Zeile** geändert.

### 5.6 Ein Gegner stirbt zweimal

Mit dem Glutring kann etwas passieren, das es vorher fast nie gab: Ein Gegner bekommt im **selben Bild** zwei Treffer, einen vom Ring und einen vom Messer. Bei deinem Fächer geht das übrigens auch schon: Zwei Messer starten am selben Punkt, und steht eine Fledermaus direkt daneben, treffen beide sie im ersten Bild.

Was passiert dann? Der erste Treffer bringt `leben` auf 0, `sterben()` lässt einen Edelstein fallen und ruft `queue_free()` auf. Aber `queue_free()` räumt erst **am Ende des Bildes** auf. Bis dahin ist der Gegner noch da, und der zweite Treffer bringt `leben` auf −1. Das ist auch ≤ 0, also noch einmal `sterben()`, und noch ein Edelstein. Doppelte Erfahrung für einen Gegner. Ich habe es ausprobiert: Zwei Treffer im selben Bild auf eine Fledermaus, zwei Edelsteine.

Die Lösung ist eine Zeile ganz oben in `treffer()` in `gegner.gd`:

```gdscript
func treffer(schaden: int, stoss: Vector2 = Vector2.ZERO) -> void:
	if leben <= 0:
		return   # schon tot, wartet nur noch aufs Wegräumen
	leben -= schaden
	...
```

Ein toter Gegner nimmt keine Treffer mehr an. Merk dir das Muster, du brauchst es in DOOM wieder: Zwischen „ist gestorben“ und „ist weg“ gibt es immer einen kurzen Moment, in dem noch Dinge passieren können.

### 5.7 Ausprobieren

**F5**:
- Das erste Level kommt wieder nach etwa 20 Sekunden. Im Menü stehen jetzt Stufen wie `1/5` und unten eine Beschreibung, die mit der Auswahl wechselt.
- Wähl den Glutring, sobald er kommt. Ein flackernder oranger Ring erscheint um den Held, und Gegner, die hineinlaufen, sterben nach ein bis zwei Bränden. Beim nächsten Mal steht `Glutring  2/4` da, und der Ring wird größer.
- „Noch ein Messer“ kommt nach `4/4` nicht mehr. Der Heiltrank kommt immer wieder.
- Stirb einmal und fang neu an: Alles ist wieder auf Stufe 0, auch der Glutring ist weg.

In meinem Test mit dem Glutring kamen die Level schneller als ohne: Level 2 nach 20 Sekunden, Level 7 nach 42. Wer viele Gegner verbrennt, sammelt viele Edelsteine.

### 5.8 Was ist neu?

- **Eine eigene Resource-Klasse** mit `extends Resource` und `class_name`. Jede Datei davon ist ein Datenpaket, das man im Inspector ausfüllt.
- **Daten statt Code:** Ein neues Upgrade ist eine neue Datei, kein neuer `match`-Zweig. Titel, Beschreibung, Stufen und Wirkung stehen an **einer** Stelle.
- **`get_indexed` und `set_indexed`:** eine Variable lesen und schreiben, deren Name in einem Text steht, mit `:` auch tiefer hinein.
- **`@export_group`** für Ordnung im Inspector.
- **Ein Dictionary mit Typen:** `Dictionary[Upgrade, int]`.
- **Was eine Datei weiß und was der Held weiß:** Geteilte Resources dürfen sich im Spiel nicht ändern. Der Spielstand gehört in den Node.
- **Eine Waffe, die erst durch ein Upgrade entsteht**, und **`get_overlapping_bodies()`** für Schaden, solange jemand drin ist.
- **Tote nehmen keine Treffer an:** Zwischen `queue_free()` und dem Verschwinden ist noch ein Moment Zeit.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 5

1. **Weiter werfen (leicht):** Ein neues Upgrade „Weiter werfen“: Die `reichweite` der Waffe steigt um 30 Pixel, höchstens dreimal. Wie viele Zeilen Code musst du dafür schreiben? 🎯
2. **Heiße Glut (mittel):** Noch ein Upgrade: Der Glutring macht 1 Schaden mehr. Probier es aus und wähl es, **bevor** du den Glutring hast. Was passiert, und warum? Bau dann in `upgrade.gd` ein `@export var braucht: Upgrade` ein, und sorg in `moegliche_upgrades()` dafür, dass ein Upgrade erst angeboten wird, wenn das, was es braucht, mindestens Stufe 1 hat. 🔥
3. **Tippfehler-Wächter (mittel):** Fehler sollen nicht erst auffallen, wenn man im Spiel zufällig das kaputte Upgrade wählt. Prüf in `_ready()` vom Held alle Upgrades: Gibt es den Knoten, und hat er die Eigenschaft? Wenn nicht, gib mit `push_error()` aus, welches Upgrade kaputt ist. Tipps: `get_node_or_null()` liefert `null` statt eines Fehlers, und `get_indexed()` liefert `null`, wenn es die Eigenschaft nicht gibt. Und was machst du mit dem Glutring, den es beim Start ja noch gar nicht gibt? 🔍
4. **Kreisende Äxte (schwer):** Eine dritte Waffe: Zwei Äxte kreisen um den Held. Eine Szene `aexte.tscn` mit einem `Node2D` als Wurzel, das sich mit `rotation += drehtempo * delta` dreht. Darunter zwei `Area2D` mit je einer Axt vom Kenney-Blatt, 30 Pixel links und rechts vom Mittelpunkt, die mit `body_entered` Schaden machen. Dazu ein Upgrade mit **Neue Waffe**, dessen weitere Stufen das `drehtempo` erhöhen. Wird ein Gegner, der im Kreis stehen bleibt, bei jeder Runde wieder getroffen? 🪓

---

## Kapitel 6: Hunderte Gegner: Der Profiler zeigt, was bremst

Dein Held ist so stark geworden, dass er die Horde klein hält. Mehr als 250 Gegner auf einmal schafft das Spiel gar nicht mehr. Für das Spiel ist das ein Problem für später: In Kapitel 9 kommen Wellen und Elite-Gegner. Fürs Messen ist es jetzt eins. Wer wissen will, wo die Grenze liegt, muss sie erreichen können.

In diesem Kapitel baust du dir deshalb zuerst Werkzeuge: eine Anzeige, die mehr verrät als die FPS, einen Knopf für 100 Gegner mehr und einen unverwundbaren Held. Dann misst du mit den Werkzeugen von Godot selbst, dem **Monitor** und dem **Profiler**. Und am Ende weißt du, was wirklich bremst. Kleiner Hinweis vorab: Es ist nicht das, was man vermutet. 🔬

### 6.1 Warum die FPS lügen

Oben steht `FPS: 60`. Klingt gut, sagt aber wenig. Godot wartet nach jedem Bild auf den Bildschirm (das heißt **V-Sync**), und der zeigt meist 60 Bilder pro Sekunde. Ob dein Rechner für ein Bild 2 Millisekunden braucht oder 16, die Anzeige sagt in beiden Fällen 60. Erst wenn es zu spät ist, fällt die Zahl.

Ehrlicher ist die Frage: **Wie lange dauert ein Bild?** Bei 60 Bildern pro Sekunde hat jedes Bild 1000 / 60 = **16,7 Millisekunden**. Das ist das Budget. Solange alles zusammen darunter bleibt, läuft das Spiel flüssig. Wie weit du vom Rand entfernt bist, sieht man nur an den Millisekunden.

Die meiste Arbeit in deinem Spiel passiert in `_physics_process`: Gegner laufen, Messer fliegen, Edelsteine sausen. Darum zeigt die Anzeige ab jetzt, wie lange das zuletzt gedauert hat. `info.gd`:

```gdscript
extends Label

var held: Held


func _ready() -> void:
	held = get_tree().get_first_node_in_group("held")


func _process(_delta: float) -> void:
	var physik := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000
	text = "Level %d   Gegner: %d   FPS: %d   Physik: %.1f ms" % [held.level, get_tree().get_node_count_in_group("gegner"), Engine.get_frames_per_second(), physik]
	if held.unverwundbar:
		text += "   UNVERWUNDBAR"
```

**`Performance.get_monitor()`** fragt die Messwerte ab, die Godot sowieso mitschreibt. `TIME_PHYSICS_PROCESS` ist die Zeit für den letzten Physik-Schritt, in Sekunden. Mal 1000 sind es Millisekunden. `%.1f` zeigt eine Kommazahl mit einer Stelle nach dem Komma.

`held.unverwundbar` gibt es noch nicht, das kommt jetzt.

### 6.2 Ein Werkzeugkasten zum Testen

**Der Held wird unverwundbar.** In `held.gd` eine neue Variable zu den anderen:

```gdscript
var unverwundbar := false   # zum Testen, schaltet das Werkzeug um
```

Und beim Schaden eine Bedingung mehr:

```gdscript
	if treffer > 0 and not unverwundbar:
```

**Das Werkzeug.** In `welt.tscn`: Kind von `Welt` → `Node` → `Werkzeug`. Skript `werkzeug.gd`:

```gdscript
extends Node

# Werkzeuge zum Messen und Testen. Nur auf der Tastatur:
# F1 = 100 Gegner mehr, F2 = Held unverwundbar an/aus

const MONITORE = ["Gegner", "Messer", "Edelsteine"]
const GRUPPEN = ["gegner", "messer", "beute"]


func _ready() -> void:
	for i in MONITORE.size():
		Performance.add_custom_monitor("Hordenheld/" + MONITORE[i], get_tree().get_node_count_in_group.bind(GRUPPEN[i]))


func _exit_tree() -> void:
	for monitor in MONITORE:
		Performance.remove_custom_monitor("Hordenheld/" + monitor)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_F1:
			for i in 100:
				$"../Horde".neuer_gegner()
		KEY_F2:
			var held: Held = get_tree().get_first_node_in_group("held")
			held.unverwundbar = not held.unverwundbar
```

Die Monitore brauchen noch Gruppen: In `messer.tscn` kommt `Messer` in die Gruppe `messer`, in `edelstein.tscn` kommt `Edelstein` in die Gruppe `beute`. Tab **Node** → **Groups**, wie beim Held.

- **Nur Tastatur, mit Absicht:** Das Spiel wird mit dem Controller gespielt. Das Werkzeug ist aber für **dich** am Rechner, nicht für die Spieler. Darum fragt es die Tasten direkt ab, ohne Eintrag in der Input Map. So kommt es keiner Aktion vom Controller in die Quere.
- **`event.echo`:** Hältst du eine Taste gedrückt, schickt Windows sie nach einer Weile immer wieder. Das sind Echos. Die werden ignoriert, sonst kämen bei langem Drücken Tausende Gegner.
- **`$"../Horde"`:** Der Pfad hat zwei Punkte, also geht er erst eine Stufe nach oben zur `Welt` und dann zur `Horde`. Mit Anführungszeichen, weil `..` sonst kein gültiger Name wäre. `neuer_gegner()` aus deinem Spawner setzt jeden neuen Gegner an den Bildrand, wie sonst auch.
- **`add_custom_monitor`** kommt gleich in 6.4 dran.

### 6.3 Der Monitor

Godot schreibt beim Spielen ständig Messwerte mit. **F5**, dann unten im Editor den Tab **Debugger** → **Monitors**. Links steht eine lange Liste zum Anhaken. Hak diese an:

| Gruppe | Wert | Was es zeigt |
|---|---|---|
| Time | **FPS** | wie gehabt |
| Time | **Physics Process** | die Zeit pro Physik-Schritt, wie in deiner Anzeige |
| Object | **Nodes** | wie viele Nodes es gerade gibt |
| Physics 2D | **Collision Pairs** | wie viele Paare von Körpern sich gerade so nah sind, dass die Physik genauer hinschauen muss |

Rechts erscheint für jeden Wert ein Verlauf über die Zeit. Spiel eine Minute und schau zu, wie die Kurven wachsen.

### 6.4 Eigene Monitore

Ganz unten in der Liste steht jetzt eine Gruppe **Hordenheld** mit **Gegner**, **Messer** und **Edelsteine**. Das sind deine. Hak sie auch an.

- **`Performance.add_custom_monitor(name, funktion)`:** Godot ruft die Funktion beim Messen immer wieder auf und malt, was sie zurückgibt. Der Teil vor dem `/` ist die Gruppe in der Liste.
- **`.bind(...)`:** `get_node_count_in_group` braucht den Namen der Gruppe. Godot ruft die Funktion aber ohne Werte auf. `bind` hängt den Wert vorher an. `get_node_count_in_group.bind("gegner")` ist eine fertige Funktion, die man ohne Werte aufrufen kann, und sie zählt trotzdem die Gegner.
- **`_exit_tree()`:** Stirbt der Held, lädt `reload_current_scene()` die Welt neu, und ein neues `Werkzeug` meldet seine Monitore an. Die alten gibt es aber noch, und zweimal derselbe Name ergibt einen Fehler. Darum meldet das Werkzeug sie ab, wenn es die Welt verlässt.

### 6.5 Der Versuch

Jetzt geht es an die Grenze.

1. **F5**, dann **F2**. In der Anzeige steht `UNVERWUNDBAR`.
2. Nicht bewegen. Drück **F1**, warte, bis die neuen Gegner beim Held angekommen sind, und schau auf `Physik`. Dann wieder **F1**. Immer so weiter.
3. Schau dir dabei die Kurven im Monitor an.

So sah es bei mir aus, auf einer Kopie deines Projekts mit allen Waffen auf der höchsten Stufe:

| Gegner | Physik pro Schritt | Kollisionspaare | FPS |
|---|---|---|---|
| 250 | 5 ms | 350 | 60 |
| 500 | 10 ms | 1000 | 60 |
| 1000 | 25 ms | 2200 | **5** |
| 2000 | 42 ms | 6500 | **3** |

Bis 500 merkt man nichts. Bei 1000 ist das Budget von 16,7 ms überschritten. Und dann fallen die FPS nicht auf 40, sondern **auf 5**. Warum so tief?

**Die Todesspirale:** Die Physik soll immer genau 60 Schritte pro Sekunde machen, egal wie schnell der Rechner ist. Sonst würden die Gegner auf langsamen Rechnern langsamer laufen. Dauert ein Schritt aber 25 ms, schafft Godot in einer Sekunde nur 40. Also hängt es an jedes Bild ein paar Schritte dran, um aufzuholen. Die dauern auch 25 ms, das Bild wird noch länger, es fehlen noch mehr Schritte … Bis zu acht Physik-Schritte macht Godot pro Bild, dann gibt es auf. Darum gibt es kein langsames Abrutschen. Unterhalb der Grenze läuft alles flüssig, darüber bricht es zusammen.

### 6.6 Der Profiler

Jetzt wissen wir, **dass** die Physik zu lange dauert. Aber **wer** ist schuld? Dafür gibt es den Profiler.

1. **F5**, **F2**, dann so lange **F1**, bis etwa 1000 Gegner da sind und das Spiel ruckelt.
2. **Debugger** → **Profiler** → **Start**. Ein paar Sekunden warten, dann **Stop**.
3. Links steht eine Liste mit allem, was Zeit gekostet hat. Klapp **Script Functions** auf.

Ganz oben steht mit großem Abstand `_physics_process` aus `gegner.gd`. Messer, Edelsteine, Glutring und Äxte kommen weit dahinter.

Der Profiler zeigt Funktionen, keine einzelnen Zeilen. Die Zeit von `move_and_slide()` zählt er mit zu `_physics_process`, weil sie von dort aufgerufen wird. Um herauszufinden, welche Zeile es ist, habe ich die Zeit um `move_and_slide()` herum mit der Stoppuhr gemessen (`Time.get_ticks_usec()` davor und danach). Bei 1000 Gegnern:

| | pro Physik-Schritt |
|---|---|
| alle Gegner-Skripte zusammen | 20 ms |
| davon nur `move_and_slide()` | **18 ms** |
| alles andere: Richtung, Teleport, Wackeln | 2 ms |

Neun Zehntel der Zeit stecken in **einer Zeile**.

### 6.7 Warum `move_and_slide()` im Gedränge so teuer ist

`move_and_slide()` bewegt den Körper und prüft dabei, ob er an etwas anstößt. Stößt er an, rutscht er an der Kante entlang und prüft **noch einmal**. Bis zu viermal pro Aufruf, so steht es bei **Max Slides**.

Ein Gegner allein auf der Wiese: ein kurzer Test, fertig. Ein Gegner mitten in einem Klumpen aus tausend: Er stößt rundherum an Nachbarn, rutscht, stößt wieder an, rutscht wieder. Und jeder Nachbar macht im selben Schritt dasselbe. Darum steigen die Kollisionspaare viel schneller als die Gegner. Doppelt so viele Gegner ergeben fast dreimal so viele Paare.

Das erklärt vermutlich auch, warum du beim Ausprobieren ohne Waffen locker auf 1000 gekommen bist: Wenn der Held läuft, zieht die Horde als lange Schlange hinterher, und es gibt wenig Gedränge. Steht er still, wird daraus ein dichter Klumpen. Wer misst, muss den **schlimmsten Fall** messen, und der ist hier: stillstehen.

### 6.8 Eine schnelle Hilfe

Viermal rutschen braucht ein Gegner gar nicht. In `gegner.tscn`: `Gegner` auswählen → **CharacterBody2D** → **Max Slides** von `4` auf `1`. Die Fledermaus erbt das.

Jetzt rutscht ein Gegner nicht mehr um ein Hindernis herum, er bleibt davor stehen und drückt. Im Gedränge sieht man den Unterschied kaum, die Horde schiebt trotzdem. Gemessen, wieder bei 1000 Gegnern:

| Max Slides | Physik pro Schritt | FPS |
|---|---|---|
| 4 | 25 ms | 5 |
| 1 | **15 ms** | **60** |

Mit einer Zahl im Inspector bist du wieder unter dem Budget. Knapp, aber drunter. Bei 2000 Gegnern hilft das allerdings auch nicht mehr, da sind es immer noch über 30 ms.

### 6.9 Was nicht bremst

Genauso wichtig wie der Täter: wer es **nicht** war.

- **Die Waffen:** Mit allen Waffen auf höchster Stufe und ganz ohne Waffen waren die Zeiten fast gleich. Bei 1000 Gegnern 25 ms mit und 22 ms ohne.
- **Die Messer:** Schau auf deinen Monitor **Messer**. Es sind nur eine Handvoll gleichzeitig unterwegs, weil jedes nach spätestens anderthalb Sekunden verschwindet.
- **Die Edelsteine:** meist ein paar Dutzend. Die meisten werden gleich eingesammelt, und wer nur herumliegt, kostet fast nichts: `_physics_process` endet sofort mit `return`.
- **Das Malen:** Die Zeit für `_process` lag selbst bei 2000 Gegnern unter 2 ms.

Für Kapitel 7 war **Object Pooling** geplant: Messer und Edelsteine nicht wegwerfen und neu bauen, sondern wiederverwenden. Das ist eine gute Technik, aber hier würde sie fast nichts bringen. Bei fünf Messern gleichzeitig gibt es nichts zu sparen. Darum nimmt sich Kapitel 7 stattdessen das vor, was wirklich bremst: die Gegner und ihr Gedränge.

Das ist die wichtigste Regel beim Schnellermachen: **Erst messen, dann ändern.** Hättest du ohne Messen angefangen, hättest du vermutlich die Messer optimiert. Viel Arbeit, kein Gewinn.

### 6.10 Ausprobieren

**F5**:
- Oben steht jetzt auch `Physik: … ms`. Am Anfang deutlich unter 1 ms.
- **F2** schaltet `UNVERWUNDBAR` an und aus. Die Gegner färben den Held weiter rot, aber der Lebensbalken bleibt voll.
- Jedes **F1** bringt 100 Gegner vom Bildrand. Im Monitor springt **Hordenheld/Gegner** um 100 nach oben.
- Stirb einmal (F2 aus) und mach weiter: Die Monitore gibt es weiter, ohne Fehlermeldung.
- Mit **Max Slides** `1` bleiben 1000 stillstehende Gegner flüssig.

### 6.11 Was ist neu?

- **Millisekunden statt FPS:** Das Budget ist 16,7 ms pro Bild. FPS zeigen erst ein Problem, wenn es schon da ist.
- **`Performance.get_monitor()`** für eigene Anzeigen, **`add_custom_monitor()`** für eigene Kurven im Debugger.
- **`Callable.bind()`**: einer Funktion vorher Werte mitgeben.
- **Der Monitor-Tab** für Verläufe, **der Profiler** für den Schuldigen.
- **Die Todesspirale:** Über dem Budget fallen die FPS nicht langsam, sondern stürzen ab.
- **Den schlimmsten Fall messen**, und **erst messen, dann ändern**.
- **Max Slides:** wie oft `move_and_slide()` es pro Aufruf nochmal versucht.
- **Ein Werkzeug-Node**, der nur fürs Entwickeln da ist.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 6

1. **Stehen oder laufen (leicht):** Hol dir mit F1 etwa 800 Gegner. Steh erst still und lies `Physik` und die **Collision Pairs** ab. Dann lauf große Kreise. Wie stark ändern sich die beiden Werte? Erklär, warum. 🏃
2. **Ganz ohne Rutschen (mittel):** Ersetz in `gegner.gd` zum Ausprobieren `move_and_slide()` durch `position += velocity * delta`. Was passiert mit der Horde, mit `Physik` und mit den Collision Pairs? Warum ist die Physik trotzdem noch beschäftigt, obwohl keiner mehr `move_and_slide()` aufruft? (Tipp: Schau dir die **Collision Mask** der Gegner an.) Danach alles zurückbauen. 🧪
3. **Der Ruckler zählt (mittel):** Die Zahl hinter `Physik` zappelt, man kann sie kaum lesen. Zeig stattdessen den **höchsten** Wert der letzten Sekunde. Warum ist der höchste Wert wichtiger als der Durchschnitt? 📈
4. **Wo ist die Grenze? (schwer):** Neue Taste **F3**: Ab jetzt kommen jede Sekunde automatisch 50 Gegner dazu, bis ein Physik-Schritt länger als 16,7 ms dauert. Dann hört es auf, und im **Output** steht, bei wie vielen Gegnern die Grenze war. Lass den Held dabei stillstehen. Wie viele schafft dein Rechner mit Max Slides `4`, wie viele mit `1`? ⏱️
