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
6. Hunderte Gegner: Der Profiler zeigt, was bremst ✔
7. Die Horde wird billiger: Gedränge ohne teure Physik ✔
8. Game Feel: Wackeln, Blitzen, Zahlen ✔
9. Die Uhr: Wellen, Elite-Gegner, Sieg und Game Over ✔
10. Titelbild, Musik und Web-Export ← *du bist hier*

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

In diesem Kapitel baust du dir deshalb zuerst Werkzeuge: eine Anzeige, die mehr verrät als die FPS, einen Knopf für 100 Gegner mehr und einen Testmodus, in dem der Held nicht stirbt und kein Level-Up das Spiel anhält. Dann misst du mit den Werkzeugen von Godot selbst, dem **Monitor** und dem **Profiler**. Und am Ende weißt du, was wirklich bremst. Kleiner Hinweis vorab: Es ist nicht das, was man vermutet. 🔬

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
	if held.testmodus:
		text += "   TESTMODUS"
```

**`Performance.get_monitor()`** fragt die Messwerte ab, die Godot sowieso mitschreibt. `TIME_PHYSICS_PROCESS` ist die Zeit für den **längsten** Physik-Schritt der letzten Sekunde, in Sekunden. Godot rechnet sie einmal pro Sekunde neu aus. Mal 1000 sind es Millisekunden. `%.1f` zeigt eine Kommazahl mit einer Stelle nach dem Komma.

`held.testmodus` gibt es noch nicht, das kommt jetzt.

### 6.2 Ein Werkzeugkasten zum Testen

**Der Testmodus.** Zum Messen braucht der Held zwei Dinge: Er darf nicht sterben, sonst ist der Versuch vorbei. Und er darf keine Erfahrung sammeln. Sonst kommt bei hundert Gegnern ständig das Level-Up-Menü, hält das Spiel an, und du siehst nur noch Menüs statt Messwerte. In `held.gd` eine neue Variable zu den anderen:

```gdscript
var testmodus := false   # unverwundbar und keine Erfahrung, schaltet das Werkzeug um
```

Beim Schaden eine Bedingung mehr:

```gdscript
	if treffer > 0 and not testmodus:
```

Und ganz am Anfang von `erfahrung_dazu()`:

```gdscript
func erfahrung_dazu(wert: int) -> void:
	if testmodus:
		return   # keine Level-Ups, die das Spiel beim Messen anhalten
	erfahrung += wert
```

Die Edelsteine fliegen trotzdem zum Held und verschwinden. Sie bringen nur nichts.

**Das Werkzeug.** In `welt.tscn`: Kind von `Welt` → `Node` → `Werkzeug`. Skript `werkzeug.gd`:

```gdscript
extends Node

# Werkzeuge zum Messen und Testen. Nur auf der Tastatur:
# F1 = 100 Gegner mehr, F2 = Testmodus an/aus

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
			held.testmodus = not held.testmodus
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

1. **F5**, dann gleich **F2**, bevor das erste Level-Up kommt. In der Anzeige steht `TESTMODUS`. (Während das Menü offen ist, ist alles angehalten, auch das Werkzeug. Dann erst eine Karte wählen.)
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

`move_and_slide()` bewegt den Körper und prüft dabei, ob er an etwas anstößt. Stößt er an, rutscht er an der Kante entlang und prüft **noch einmal**. Bis zu viermal pro Aufruf, so steht es in der Eigenschaft **`max_slides`**.

Ein Gegner allein auf der Wiese: ein kurzer Test, fertig. Ein Gegner mitten in einem Klumpen aus tausend: Er stößt rundherum an Nachbarn, rutscht, stößt wieder an, rutscht wieder. Und jeder Nachbar macht im selben Schritt dasselbe. Darum steigen die Kollisionspaare viel schneller als die Gegner. Doppelt so viele Gegner ergeben fast dreimal so viele Paare.

Wer misst, muss den **schlimmsten Fall** messen. Ich hatte hier zuerst behauptet, das sei Stillstehen. Falsch, wie du in Übung 1 herausgefunden hast: Läuft der Held, wird es noch teurer. Warum, steht in Kapitel 7.

### 6.8 Eine schnelle Hilfe

Viermal rutschen braucht ein Gegner gar nicht. Im Inspector findest du das nicht: `max_slides` versteckt Godot dort, man kann es nur im Code setzen. Also in `gegner.gd` in `_ready()` eine Zeile dazu:

```gdscript
func _ready() -> void:
	held = get_tree().get_first_node_in_group("held")
	max_slides = 1   # nur einmal rutschen statt viermal, spart im Gedränge viel Zeit
```

Die Fledermaus hat dasselbe Skript, sie bekommt es also auch.

Jetzt rutscht ein Gegner nicht mehr um ein Hindernis herum, er bleibt davor stehen und drückt. Im Gedränge sieht man den Unterschied kaum, die Horde schiebt trotzdem. Gemessen, wieder bei 1000 Gegnern:

| `max_slides` | Physik pro Schritt | FPS |
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
- **F2** schaltet `TESTMODUS` an und aus. Die Gegner färben den Held weiter rot, aber der Lebensbalken bleibt voll, und der Erfahrungsbalken bleibt stehen.
- Jedes **F1** bringt 100 Gegner vom Bildrand. Im Monitor springt **Hordenheld/Gegner** um 100 nach oben.
- Stirb einmal (F2 aus) und mach weiter: Die Monitore gibt es weiter, ohne Fehlermeldung.
- Mit `max_slides = 1` bleiben 1000 stillstehende Gegner flüssig.

### 6.11 Was ist neu?

- **Millisekunden statt FPS:** Das Budget ist 16,7 ms pro Bild. FPS zeigen erst ein Problem, wenn es schon da ist.
- **`Performance.get_monitor()`** für eigene Anzeigen, **`add_custom_monitor()`** für eigene Kurven im Debugger.
- **`Callable.bind()`**: einer Funktion vorher Werte mitgeben.
- **Der Monitor-Tab** für Verläufe, **der Profiler** für den Schuldigen.
- **Die Todesspirale:** Über dem Budget fallen die FPS nicht langsam, sondern stürzen ab.
- **Den schlimmsten Fall messen**, und **erst messen, dann ändern**.
- **`max_slides`:** wie oft `move_and_slide()` es pro Aufruf nochmal versucht.
- **Ein Werkzeug-Node**, der nur fürs Entwickeln da ist.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 6

1. **Stehen oder laufen (leicht):** Hol dir mit F1 etwa 800 Gegner. Steh erst still und lies `Physik` und die **Collision Pairs** ab. Dann lauf große Kreise. Wie stark ändern sich die beiden Werte? Erklär, warum. 🏃
2. **Ganz ohne Rutschen (mittel):** Ersetz in `gegner.gd` zum Ausprobieren `move_and_slide()` durch `position += velocity * delta`. Was passiert mit der Horde, mit `Physik` und mit den Collision Pairs? Warum ist die Physik trotzdem noch beschäftigt, obwohl keiner mehr `move_and_slide()` aufruft? (Tipp: Schau dir die **Collision Mask** der Gegner an.) Danach alles zurückbauen. 🧪
3. **Der Ruckler zählt (mittel):** Die Zahl hinter `Physik` ändert sich nur einmal pro Sekunde. Finde heraus, was sie genau zeigt: den letzten Schritt, den Durchschnitt oder den höchsten Wert der Sekunde? Warum ist der höchste Wert wichtiger als der Durchschnitt? 📈
4. **Wo ist die Grenze? (schwer):** Neue Taste **F3**: Ab jetzt kommen jede Sekunde automatisch 50 Gegner dazu, bis ein Physik-Schritt länger als 16,7 ms dauert. Dann hört es auf, und im **Output** steht, bei wie vielen Gegnern die Grenze war. Lass den Held dabei stillstehen. Wie viele schafft dein Rechner mit `max_slides` `4`, wie viele mit `1`? ⏱️


### Antworten zu Kapitel 6
1. Wenn man läuft wird die performance noch schlechter. Vermutlich, weil sich die Gegner noch zusätzlich teleportieren.
2. Die Gegner merken einander und wenn alle übereinander liegen löst es irgendwo aus, auch ohne move_and_slide()
3. Sieht gut aus. Anscheinend rechent Godot diese Zahl bereits ein mal pro Sekunde aus.
4. 1106 bei max_slides = 1, 647 bei max_slides = [default]


---

## Kapitel 7: Die Horde wird billiger: Gedränge ohne teure Physik

Kapitel 6 hat den Täter gefunden: `move_and_slide()` der Gegner im Gedränge. In diesem Kapitel nimmst du ihn aus dem Spiel. Die Gegner stoßen nicht mehr über die Physik aneinander, stattdessen schiebt die Horde sie selbst auseinander. Damit das schnell genug geht, lernst du einen Trick, den schon DOOM benutzt hat: ein **Raster**.

Und weil "erst messen, dann ändern" weiter gilt, misst du nach jedem Schritt. Einmal wird dabei etwas herauskommen, das man so nicht erwartet. 🧮

### 7.1 Warum Laufen noch teurer ist

Deine Antwort zu Übung 1 aus Kapitel 6 stimmt, ich habe es nachgemessen. 1000 Gegner, nur das Startmesser, Zeit pro Physik-Schritt im Schnitt:

| | stehen | laufen |
|---|---|---|
| `move_and_slide()` mit `max_slides = 1` | 12,5 ms | **17 ms** |

Und deine Vermutung stimmt auch: Es liegt am Teleport. Läuft der Held, fallen hinten ständig Gegner zurück. Jeder, der mehr als 300 Pixel hinter ihm ist, springt nach vorn. Die springen aber nicht einzeln, sondern als ganze Traube, und landen auf einem Fleck vor dem Held, mitten in den Gegnern, die dort schon stehen. Lauter Körper, die ineinander stecken. `move_and_slide()` muss sie alle auseinanderdrücken, und die Kollisionspaare schießen in die Höhe.

Im echten Spiel läuft der Held fast immer. Der teure Fall ist also der normale.

### 7.2 Der Plan

In Übung 2 aus Kapitel 6 hast du schon gesehen, was passiert, wenn die Gegner einfach mit `position += velocity * delta` laufen: Die Horde fällt auf einem Punkt zusammen. Die Physik war trotzdem noch beschäftigt, weil die Gegner sich über ihre **Collision Mask** gegenseitig wahrnehmen.

Der Plan hat darum zwei Teile:

1. **Die Physik vergisst das Gedränge.** Die Gegner bekommen keine Collision Mask mehr. Ihren **Collision Layer** 2 behalten sie. Den brauchen Messer, Glutring, Äxte und die Trefferzone des Helds, um sie zu finden.
2. **Die Horde schiebt selbst.** Einmal pro Physik-Schritt schaut die Horde, welche Gegner sich zu nah sind, und schiebt sie auseinander.

Die einfachste Art für Teil 2: Jeder Gegner misst den Abstand zu jedem anderen. Bei 1000 Gegnern sind das 1000 × 999, also rund **eine Million** Abstände pro Schritt. GDScript schafft in meinem Test zwei bis drei Millionen solcher Abstände pro Sekunde. Ein einziger Schritt würde also rund 400 ms dauern, mehr als 20-mal so lange wie das ganze Budget. So geht es nicht.

### 7.3 Das Raster

Die meisten der Million Abstände sind Unsinn. Ein Gegner links am Bildrand kann einen Gegner rechts am Bildrand nie berühren. Man muss nur die Nachbarn fragen. Aber woher weiß man, wer die Nachbarn sind, ohne alle Abstände zu messen?

Man legt ein **Raster** über die Welt, wie Kästchenpapier. Jedes Kästchen ist 12 × 12 Pixel groß, genau so groß wie der Abstand, den zwei Gegner halten wollen. Jeder Gegner landet in dem Kästchen, in dem er gerade steht. Wer einem Gegner näher als 12 Pixel ist, steht dann entweder im selben Kästchen oder in einem der acht drumherum. Weiter weg kann er nicht sein:

```
┌───┬───┬───┐
│ ↖ │ ↑ │ ↗ │
├───┼───┼───┤
│ ← │ X │ → │   X ist der Gegner. Nur in diesen neun Kästchen
├───┼───┼───┤   kann jemand stehen, der ihm zu nah ist.
│ ↙ │ ↓ │ ↘ │
└───┴───┴───┘
```

Statt 999 Abständen misst jeder Gegner nur noch zu denen in neun Kästchen. Im Gedränge sind das etwa ein Dutzend.

Welches Kästchen? Position geteilt durch 12, abgerundet. Ein Gegner bei `(30, -5)`: 30 / 12 = 2,5 → **2**. -5 / 12 = -0,4 → **-1** (abgerundet heißt bei Minuszahlen: weiter weg von null). Er steht im Kästchen `(2, -1)`. Kästchen haben ganze Zahlen, darum ist es ein `Vector2i`, das i steht für integer, ganze Zahl.

> **DOOM macht das genauso.** Jede DOOM-Karte hat eine **Blockmap**: ein Raster aus Blöcken von 128 × 128 Einheiten. Jeder Block weiß, welche Wände und welche Monster gerade in ihm stecken. Läuft ein Monster, prüft DOOM nur die Wände und Monster in den Blöcken drumherum, nicht die ganze Karte. Damals lief das auf Rechnern, die tausendmal langsamer waren als deiner. Das Raster, das du jetzt baust, ist dasselbe in klein.

### 7.4 Die Gegner verlassen die Physik

In `gegner.tscn`: `Gegner` auswählen → **CollisionObject2D** → **Collision** → **Mask**: den Haken bei **2** wegnehmen, sodass gar kein Feld mehr markiert ist. **Layer** bleibt bei 2. Die Fledermaus erbt das.

In `gegner.gd` fliegt in `_ready()` die Zeile mit `max_slides` raus. Ohne `move_and_slide()` hat sie keine Bedeutung mehr. Und in `_physics_process()` wird aus

```gdscript
	move_and_slide()
```

ein

```gdscript
	position += velocity * delta
```

Der Gegner bleibt ein `CharacterBody2D`. Ein Körper muss er bleiben, sonst finden ihn Messer und Glutring nicht mehr, und `velocity` ist weiter eine praktische Variable für sein Tempo.

**F5**, F2, ein paarmal F1: Die Horde läuft zu einem Haufen zusammen, wie in der Übung. Dafür ist `Physik` ganz unten. Jetzt muss die Horde nur noch Platz machen.

### 7.5 Die Horde macht Platz

Alles kommt in `spawner.gd`, das Skript der `Horde`. Zuerst drei neue Konstanten unter die anderen:

```gdscript
const PLATZ = 12.0       # so viel Abstand will jeder Gegner zu jedem anderen
const KAESTCHEN = 12.0   # so groß ist ein Kästchen im Raster, nie kleiner als PLATZ
const SCHIEBEN = 0.25    # so viel von der Überlappung wird pro Schritt weggeschoben
```

12 Pixel sind zwei Kollisionskreise mit Radius 6, so weit wie vorher mit der Physik.

Dann zwischen `_process()` und `neuer_gegner()`:

```gdscript
func _physics_process(_delta: float) -> void:
	platz_machen()


func platz_machen() -> void:
	var gegner := get_children()

	# 1. Jeden Gegner nur einmal nach seiner Position fragen
	var orte := PackedVector2Array()
	for einer: Node2D in gegner:
		orte.append(einer.position)

	# 2. Das Raster: zu jedem Kästchen die Nummern der Gegner darin
	var raster: Dictionary[Vector2i, PackedInt32Array] = {}
	for i in orte.size():
		var kaestchen := Vector2i((orte[i] / KAESTCHEN).floor())
		if not raster.has(kaestchen):
			raster[kaestchen] = PackedInt32Array()
		raster[kaestchen].append(i)

	# 3. Jeder Gegner schaut in sein Kästchen und in die acht drumherum
	var schub := PackedVector2Array()
	schub.resize(orte.size())
	for i in orte.size():
		var kaestchen := Vector2i((orte[i] / KAESTCHEN).floor())
		for x in range(-1, 2):
			for y in range(-1, 2):
				var nachbar := kaestchen + Vector2i(x, y)
				if not raster.has(nachbar):
					continue
				for j in raster[nachbar]:
					var weg := orte[i] - orte[j]
					var abstand := weg.length()
					if abstand < PLATZ and i != j:
						if abstand < 0.01:
							# genau aufeinander: irgendeine Richtung
							weg = Vector2.from_angle(randf() * TAU)
							abstand = 1.0
						schub[i] += weg / abstand * (PLATZ - abstand) * SCHIEBEN

	# 4. Alle auf einmal verschieben
	for i in gegner.size():
		gegner[i].position += schub[i]
```

Das ist viel auf einmal, darum Schritt für Schritt:

- **Wer kommt zuerst dran?** Die Gegner sind Kinder der Horde. Godot ruft `_physics_process` immer zuerst beim Elternteil auf, dann bei den Kindern. Die Horde schiebt also, danach läuft jeder Gegner seinen Schritt.
- **Schritt 1, die Liste:** Ein **`PackedVector2Array`** ist eine Liste, in der nur `Vector2` stehen dürfen. Dafür ist sie eng gepackt und schnell. Gegner Nummer `i` steht an der Stelle `orte[i]`. Warum wird jeder Gegner nur einmal gefragt? Eine Frage an einen Knoten wie `einer.position` geht durch Godots Innereien und ist viel langsamer als ein Blick in eine Liste. In Schritt 3 braucht jeder Gegner die Positionen von etwa einem Dutzend Nachbarn. Lieber 1000 Fragen und danach nur noch in die Liste schauen als 12 000 Fragen. Wie viel das ausmacht, misst du in Übung 1.
- **Schritt 2, das Raster:** Ein **Dictionary** kennst du: zu jedem Schlüssel ein Wert. Hier ist der Schlüssel ein Kästchen, der Wert eine Liste mit den Nummern der Gegner darin. **`PackedInt32Array`** ist eine gepackte Liste für ganze Zahlen. `.floor()` rundet beide Werte eines Vektors ab, `Vector2i(...)` macht ganze Zahlen daraus. Kästchen, in denen niemand steht, kommen gar nicht ins Dictionary. Darum fragt Schritt 3 vorher mit `has()`.
- **Schritt 3, der Schub:** `range(-1, 2)` zählt -1, 0, 1. Zwei davon ineinander ergeben die neun Kästchen. `weg / abstand` ist die Richtung vom Nachbarn weg, mit der Länge 1. `PLATZ - abstand` ist, wie weit die beiden ineinanderstecken. Davon nur ein Viertel (`SCHIEBEN`), damit es weich bleibt. Würde jeder die ganze Überlappung auf einmal wegschieben, würden sie übers Ziel hinausschießen und zittern.
- **`i != j`:** Jeder Gegner steht ja auch selbst in seinem Kästchen. Von sich selbst muss er nicht wegrücken.
- **Genau aufeinander:** Nach einem Teleport stehen manchmal zwei auf demselben Pixel. Dann ist der Abstand 0, und es gibt keine Richtung, in die man schieben könnte. Durch 0 teilen geht auch nicht. Also eine zufällige Richtung.
- **Schritt 4:** Erst wenn für alle der Schub feststeht, wird verschoben. So wird jeder nach denselben Positionen beurteilt, egal ob er vorn oder hinten in der Liste steht.

**F5**. Die Horde verteilt sich wieder. Sie steht etwas dichter als mit der Physik, weil Schieben weicher ist als Anstoßen. Und die Teleport-Trauben lösen sich in ein paar Schritten auf.

### 7.6 Messen: eine Überraschung

So misst du in diesem Kapitel:

1. **F5** und **sofort F2**, bevor das erste Level-Up kommt. Dann hat der Held nur das Startmesser, und es sterben kaum Gegner. So misst du nur das Gedränge.
2. Zehnmal **F1**, warten, bis alle beim Held sind.
3. Erst stillstehen und ablesen, dann große Kreise laufen und ablesen.

Bei mir, im Schnitt pro Physik-Schritt:

| | stehen | laufen |
|---|---|---|
| `move_and_slide()` | 12,5 ms | 17 ms |
| Raster, erste Fassung | 11,5 ms | 11,5 ms |

Im Laufen ein großer Gewinn. Im Stehen aber fast nichts, obwohl die Physik jetzt fast nichts mehr tut. Wo bleibt die Zeit?

Der **Profiler** zeigt es: `platz_machen()` braucht etwa 6 ms. Die Physik in C++, wie Godot selbst gebaut ist, war schnell. GDScript ist viel langsamer. Dieselbe Arbeit kostet in GDScript ein Vielfaches. Wer die Physik durch GDScript ersetzt, muss deshalb deutlich **weniger** Arbeit machen als die Physik, nicht nur dieselbe.

> Deine Anzeige zeigt höhere Zahlen als meine Tabelle, oft 3 bis 5 ms mehr. Das ist kein Fehler. Sie zeigt den **längsten** Schritt der letzten Sekunde, meine Tabelle den Durchschnitt. Für den Vergleich vorher/nachher taugen beide. Zum Vergleich: Ganz ohne Schieben, also mit dem Haufen aus 7.4, waren es bei mir 6,5 ms. Darunter kommt man mit 1000 einzelnen Gegner-Nodes nicht.

### 7.7 Jedes Paar nur einmal

Schau dir an, wie oft gerechnet wird. Gegner 5 und Gegner 8 stehen sich zu nah. Wenn Nummer 5 dran ist, misst er den Abstand zu 8 und rückt weg. Wenn Nummer 8 dran ist, misst er **denselben** Abstand zu 5 und rückt in die andere Richtung. Jedes Paar wird zweimal gerechnet.

Dabei ist das Ergebnis jedes Mal genau gleich, nur umgedreht. Schiebt 8 den Gegner 5 nach links, schiebt 5 den Gegner 8 genauso weit nach rechts. (In der Physik heißt das **Actio gleich Reactio**.) Es reicht also, jedes Paar einmal zu rechnen und beiden ihren Schub zu geben.

Nur: Wie sorgt man dafür, dass jedes Paar genau einmal drankommt? Nicht mehr jeder Gegner schaut in neun Kästchen, sondern jedes **Kästchen** schaut in sich selbst und nur in **vier** Nachbarn:

```
┌───┬───┬───┐
│   │   │   │
├───┼───┼───┤
│   │ X │ → │   X schaut nur in sich selbst und in diese vier.
├───┼───┼───┤   Die anderen vier schauen zu X, wenn sie selbst dran sind.
│ ↙ │ ↓ │ ↘ │
└───┴───┴───┘
```

Nimm zwei Kästchen nebeneinander, A links und B rechts. A schaut nach rechts, also zu B. B schaut nicht nach links. Das Paar A–B kommt genau einmal dran. Das gilt für jede Richtung: Von zwei benachbarten Kästchen schaut immer genau eins zum anderen.

Bleibt das eigene Kästchen. Stehen dort die Gegner 3, 7 und 9, rechnet 3 mit 7 und 9, und 7 nur noch mit 9. Jeder rechnet nur mit denen, die nach ihm in der Liste stehen.

Oben bei den Konstanten:

```gdscript
# das eigene Kästchen, rechts daneben und die drei darunter
const HALBE_NACHBARN = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)]
```

In `platz_machen()` ersetzt du den ganzen **Schritt 3**, bis kurz vor `# 4.`:

```gdscript
	# 3. Jedes Paar nur einmal: Jedes Kästchen schaut in sich selbst und in vier Nachbarn
	var schub := PackedVector2Array()
	schub.resize(orte.size())
	for kaestchen in raster:
		var hier := raster[kaestchen]
		for richtung in HALBE_NACHBARN:
			if not raster.has(kaestchen + richtung):
				continue
			var dort := raster[kaestchen + richtung]
			for a in hier.size():
				var i := hier[a]
				# im eigenen Kästchen nur mit denen, die nach mir in der Liste stehen
				var anfang := a + 1 if richtung == Vector2i.ZERO else 0
				for b in range(anfang, dort.size()):
					var j := dort[b]
					var weg := orte[i] - orte[j]
					var abstand := weg.length()
					if abstand < PLATZ:
						if abstand < 0.01:
							# genau aufeinander: irgendeine Richtung
							weg = Vector2.from_angle(randf() * TAU)
							abstand = 1.0
						var stoss := weg / abstand * (PLATZ - abstand) * SCHIEBEN
						schub[i] += stoss   # i wird weggeschoben,
						schub[j] -= stoss   # j genauso weit in die andere Richtung
```

- **`for kaestchen in raster`** geht durch alle Schlüssel des Dictionarys, also durch alle Kästchen, in denen jemand steht.
- **`a` und `i`:** `a` ist die Stelle in der Liste des Kästchens, `i` die Nummer des Gegners. Mit `a` weiß man, wer "nach mir" kommt, mit `i` findet man die Position in `orte`.
- **`a + 1 if ... else 0`:** Im eigenen Kästchen fängt `b` hinter `a` an. Bei einem Nachbarkästchen sind alle dran, da gibt es keine Doppelten.
- **`i != j`** fällt weg: Im eigenen Kästchen fängt `b` hinter `a` an, also trifft keiner mehr sich selbst.

Gemessen:

| | stehen | laufen |
|---|---|---|
| `move_and_slide()` | 12,5 ms | 17 ms |
| Raster, erste Fassung | 11,5 ms | 11,5 ms |
| Raster, jedes Paar einmal | **9 ms** | **9 ms** |
| (ganz ohne Schieben) | 6,5 ms | 6,5 ms |

Halb so viele Abstände, und statt neunmal pro Gegner wird nur noch fünfmal pro Kästchen im Dictionary nachgeschlagen. Das Schieben selbst kostet jetzt nur noch 2,5 ms. Und Stehen und Laufen kosten gleich viel, der Teleport ist kein Problem mehr.

### 7.8 Was es gebracht hat

Im normalen Spiel mit bis zu 250 Gegnern merkst du von alldem nichts mehr, da sind es jetzt nur noch 2 bis 3 ms. Und wenn Kapitel 9 die Wellen bringt, ist Platz für viel mehr.

Eine Nebenwirkung, damit sie dich nicht überrascht: Mit allen Waffen kann die Anzeige trotzdem kurz hochspringen. Die Horde ist jetzt weicher und drängt schneller in den Glutring. Der erwischt dann alle halbe Sekunde viele Gegner auf einmal. Jeder Tod kostet etwas: Ein Edelstein wird gebaut, der Gegner wird weggeräumt. Bei hundert Toten im selben Schritt sind das ein paar Millisekunden. Dafür sterben die Gegner jetzt auch schneller. 🔥

### 7.9 Ausprobieren

**F5**:
- Die Horde verteilt sich wie vorher, nur etwas dichter. Keiner steckt dauerhaft in einem anderen.
- Lauf große Kreise mit 1000 Gegnern: Die Trauben nach dem Teleport lösen sich auf, und `Physik` bleibt unten.
- Messer, Glutring und Äxte treffen wie vorher, und die Gegner machen den Held weiter rot.
- Im Monitor sind die **Collision Pairs** fast bei null.
- **F3** aus deiner Übung: Wo liegt deine Grenze jetzt?

### 7.10 Was ist neu?

- **Physik nur, wo sie gebraucht wird:** Layer ja, damit die Waffen die Gegner finden. Mask nein, damit sie nicht miteinander rechnen.
- **Das Raster** (bei DOOM die **Blockmap**): Wer sich berühren kann, steht im selben oder im Nachbarkästchen.
- **`Dictionary` mit `Vector2i` als Schlüssel** für Kästchen, `floor()` zum Abrunden.
- **`PackedVector2Array`** und **`PackedInt32Array`:** schnelle Listen für nur einen Typ.
- **Knoten fragen ist teuer:** einmal abfragen, in eine Liste schreiben, dann nur noch in der Liste rechnen.
- **Actio gleich Reactio:** Jedes Paar nur einmal rechnen, beiden den Schub geben.
- **GDScript ist langsamer als Godots eigener Code.** Wer Engine-Arbeit selbst übernimmt, muss weniger davon machen.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 7

1. **Was kostet eine Frage? (leicht):** Ersetz in Schritt 3 `orte[i] - orte[j]` durch `gegner[i].position - gegner[j].position`. Weil `gegner` eine Liste von Knoten ist, weiß Godot den Typ nicht mehr, also schreib `var weg: Vector2 = ...` statt `:=`. Miss mit 1000 Gegnern. Wie viel teurer wird es durch die eine Zeile? Danach zurückbauen. 🔍
2. **Wie groß ist ein Kästchen? (leicht):** Stell `KAESTCHEN` auf `48`, dann auf `6`. Was passiert mit `Physik`, was mit der Horde? Warum steht bei der Konstante "nie kleiner als PLATZ"? 📏
3. **Weich oder hart? (mittel):** Mach aus der Konstante `SCHIEBEN` ein `@export var schieben := 0.25` und benenn sie überall um. Starte das Spiel, wähl im Scene-Dock oben **Remote** und dort die `Horde`. Jetzt kannst du `Schieben` im Inspector ändern, während das Spiel läuft. Probier `0.05`, `0.5` und `1.0`. Was siehst du jeweils, und warum? 🎚️
4. **Halbe Arbeit (schwer):** Lass in jedem Physik-Schritt nur jedes zweite Kästchen rechnen, im Wechsel wie die Felder eines Schachbretts: einmal die weißen, einmal die schwarzen. Damit die Horde nicht zu weich wird, schiebt jeder dafür doppelt so stark. Wie viel spart das? Und warum geht dabei kein Paar verloren? Tipp: Du brauchst einen Zähler für die Schritte und `(kaestchen.x + kaestchen.y + schritt) % 2`. Achtung: In GDScript ist `-3 % 2` nicht `1`, sondern `-1`. ♟️


### Antworten zu Kapitel 7
F3 liefert 1430 nach dem Umbau
1. 1051 mit Positionabfragen
2. Mit KAESTCHEN = 48 bricht alles zusammen schon bei 696 Gegner -> möglichst kleine Kästchen lohnen sich
Mit KAESTCHEN = 6 braucht es 1420 Gegner um Das Limit zu erreichen, die Gegner kommen aber noch dichter aneinander. Der Grund ist dass bei kleinen Kästchen Gegner näher als gewünschte 12 Pixel kommen können ohne die benachbarte Kästchen zu belegen.
3. Bei dem Wert 0.05 wirkt Schieben gar nicht, alle laufen ineinnader. Die Spinnen laufen 0,5 Pixel pro Frame, konstant, der Schub ist aber nur 0,6 Pixel pro Frame und nicht konstant. Die Fledermäuse mit der Geschwindigkeiten 0,83 Pixel pro Frame setzten sich gegen so einen Schub einfach durch.
Bei dem Wert 0.5 gehen die Gegner weiter auseinander, aber neben dem Helden sind mehr von denen und sie springen hin und her. Der Grund ist wenn sie dichter aneinander kommen bekommt jeder mehrere Nachbarn und jeder macht einen Schub. 
Bei dem Wert 1.0 Springen alle hin und her. Hier kann schon ein einziger Gegner um 12 Pixel schieben und dabei wird ein Gegner einfach durch einen anderen durchgeschoben...
4. Spart schon ordentlich, das Ende ist bei 1538 Gegnern. Doppelter Schub wirkt zu holprig, also habe ich den Schub ein wenig verkleinert. Die Paare werden nicht verloren, sie werden nur jedes zweites Bild gerechnet. Theoretisch kann es dazu kommen dass ein Monster in einem "weißen" Schritt auf ein "schwarzes" Feld geschoben wird und deswegen in nächstem Bild auch dran kommt.

---

## Kapitel 8: Game Feel: Wackeln, Blitzen, Zahlen

Bis jetzt *funktioniert* das Spiel. Ein Messer trifft, ein Gegner verschwindet, die Zahl im Info-Text steigt. Aber es fühlt sich noch nicht nach etwas an. Ob ein Treffer Spaß macht, hängt an Kleinigkeiten: Der Gegner leuchtet kurz auf, eine Zahl springt heraus, das Bild bebt, der Controller brummt in der Hand. Das nennt man **Game Feel**, und die vielen kleinen Effekte dafür heißen unter Spieleentwicklern liebevoll **Juice**, Saft.

Jeder einzelne Effekt ist klein. Zusammen machen sie aus "funktioniert" ein "fühlt sich gut an". In diesem Spiel gilt dabei eine Regel aus den letzten beiden Kapiteln: **Jeder Effekt passiert tausendmal.** Er muss also billig sein. 🧃

### 8.1 Der Treffer-Blitz

Ein normaler Gegner hält zwei Messer aus. Beim ersten Treffer passiert bis jetzt sichtbar nichts. Ab jetzt leuchtet er kurz weiß auf.

Dafür nimmst du `modulate`. Das kennst du vom Held, der rot wird. `modulate` **multipliziert** jede Farbe im Bild: Rot mit Rot, Grün mit Grün, Blau mit Blau. `Color.WHITE` ist `(1, 1, 1)`, also bleibt alles, wie es ist. Mit `(0.5, 0.5, 0.5)` wird alles halb so hell.

Der Trick: Werte über 1 gehen auch. `Color(4, 4, 4)` macht jede Farbe viermal so hell. Heller als ganz hell geht nicht, also wird fast alles weiß. Nur der schwarze Rand bleibt schwarz, denn 0 × 4 ist immer noch 0. Heraus kommt eine weiße Figur mit dunklem Rand, genau der Blitz, den man aus vielen Spielen kennt.

In `gegner.gd` zwei neue Konstanten zu den anderen:

```gdscript
const BLITZ_DAUER = 0.1      # so lange leuchtet ein Gegner nach einem Treffer
const BLITZ_FARBE = Color(4, 4, 4)   # mehr als 1: heller als das Bild selbst, fast weiß
```

eine neue Variable unter `var held`:

```gdscript
var blitz := 0.0   # wie lange er noch leuchtet
```

in `treffer()` beim `else` eine Zeile dazu:

```gdscript
	else:
		position += stoss
		blitz = BLITZ_DAUER
```

und ganz unten in `_physics_process()`:

```gdscript
	if blitz > 0.0:
		blitz -= delta
		$Bild.modulate = BLITZ_FARBE if blitz > 0.0 else Color.WHITE
```

Die Farbe wird nur gesetzt, solange der Blitz läuft, und einmal am Ende zurück auf Weiß. Die anderen 990 Gegner prüfen nur `blitz > 0.0` und sind fertig. Billiger geht es nicht.

### 8.2 Sterben mit Schwung

Bis jetzt ist ein Gegner im selben Bild weg, in dem er stirbt. Das ist ehrlich, aber hart. Schöner ist es, wenn er kurz aufleuchtet und zusammenschrumpft.

Dafür darf er aber noch nicht weg sein. Eine Konstante dazu:

```gdscript
const STERBE_DAUER = 0.2     # so lange schrumpft ein Gegner, bevor er verschwindet
```

Und in `sterben()` wird aus dem `queue_free()` am Ende:

```gdscript
	# Noch nicht weg: kurz aufleuchten und zusammenschrumpfen
	remove_from_group("gegner")   # die Waffen zielen nicht mehr auf ihn
	collision_layer = 0           # nichts trifft ihn mehr, er tut dem Held nicht mehr weh
	set_physics_process(false)    # er läuft nicht mehr und flattert nicht mehr
	$Bild.modulate = BLITZ_FARBE
	var tween := create_tween()
	tween.tween_property($Bild, "scale", Vector2.ZERO, STERBE_DAUER)
	tween.tween_callback(queue_free)
```

Ein toter Gegner, der noch 0,2 Sekunden herumsteht, muss aus dem Spiel sein, ohne dass er verschwindet:

- **`remove_from_group("gegner")`:** Die Messer-Waffe sucht ihr Ziel in der Gruppe `gegner`. Ohne diese Zeile würde sie weiter auf Leichen werfen. Auch der Info-Text und dein F3 zählen ihn nicht mehr.
- **`collision_layer = 0`:** Er ist nicht mehr auf Ebene 2. Messer, Glutring, Äxte und die Trefferzone des Helds finden ihn nicht mehr.
- **`set_physics_process(false)`:** Sein `_physics_process()` läuft nicht mehr. Sonst würde er weiterlaufen, der Blitz würde das Weiß zurücksetzen, und die Fledermaus würde beim Flattern das `scale.x` vom Schrumpfen überschreiben.
- **Den Tween** kennst du aus dem Kerkerheld: Er schrumpft das Bild in 0,2 Sekunden auf nichts. `tween_callback(queue_free)` kommt danach dran, erst dann ist der Gegner wirklich weg.

Die Horde schiebt ihn in der Zeit übrigens noch herum, er ist ja noch ihr Kind. Das stört nicht, im Gegenteil: Die Lebenden drängen ihn schon beiseite.

### 8.3 Schadenszahlen: tausend Zahlen, ein Knoten

Jetzt sollen Zahlen aus den Gegnern springen. Der erste Gedanke: Bei jedem Treffer ein `Label` bauen, nach oben schweben lassen, wegräumen. Das geht, aber denk an Kapitel 7: Knoten sind teuer. Mit Glutring und Äxten gibt es Hunderte Treffer pro Sekunde. Das wären Hunderte Labels, die gebaut und wieder weggeräumt werden.

Darum machst du es wie die Horde: **Ein einziger Knoten zeichnet alle Zahlen.** Eine Zahl ist kein Knoten, sondern nur ein Eintrag in drei Listen: wo sie ist, welcher Wert, wann sie entstanden ist. Das Zeichnen mit `_draw()` kennst du vom Glutring und von den Edelsteinen.

**Der Knoten:** In `welt.tscn` ein **Node2D** als Kind von `Welt`, Name `Zahlen`. Im Inspector:
- **Node** → **Groups**: Gruppe `zahlen` dazu, damit die Gegner ihn finden.
- **CanvasItem** → **Ordering** → **Z Index**: `10`. Die `Welt` sortiert ihre Kinder nach der Höhe auf dem Bildschirm, damit untere Figuren vor oberen stehen. Die Zahlen sollen aber immer ganz vorne sein. Ein höherer Z Index gewinnt immer gegen das Sortieren.

Dazu ein neues Skript `zahlen.gd`:

```gdscript
extends Node2D

# Alle Schadenszahlen auf einmal, gezeichnet von einem einzigen Knoten.
# Jede Zahl ist nur ein Eintrag in drei Listen: wo, welcher Wert, wann entstanden.

const DAUER = 0.6        # so lange ist eine Zahl zu sehen
const STEIGEN = 20.0     # so viele Pixel steigt sie in der Zeit nach oben
const HOECHSTENS = 300   # mehr Zahlen gleichzeitig nicht, sonst sieht man nichts mehr
const GROESSE = 16       # Schriftgröße
const BREITE = 40.0      # in so einem breiten Kasten wird die Zahl mittig geschrieben

var orte := PackedVector2Array()
var werte := PackedInt32Array()
var geburt := PackedFloat32Array()
var zeit := 0.0
var schrift: Font


func _ready() -> void:
	schrift = load("res://schrift.tres").font


func zeigen(ort: Vector2, wert: int) -> void:
	if orte.size() >= HOECHSTENS:
		weg_mit_der_aeltesten()
	orte.append(ort + Vector2(randf_range(-4, 4), -8))
	werte.append(wert)
	geburt.append(zeit)


func weg_mit_der_aeltesten() -> void:
	orte.remove_at(0)
	werte.remove_at(0)
	geburt.remove_at(0)


func _process(delta: float) -> void:
	zeit += delta
	# Neue Zahlen kommen hinten dazu, also stehen die ältesten immer vorne
	while geburt.size() > 0 and zeit - geburt[0] > DAUER:
		weg_mit_der_aeltesten()
	queue_redraw()


func _draw() -> void:
	for i in orte.size():
		var alter := (zeit - geburt[i]) / DAUER   # 0 = neu, 1 = gleich weg
		var ort := orte[i] + Vector2(-BREITE / 2, -STEIGEN * alter)
		var farbe := Color(1, 1, 1, 1.0 - alter * alter)
		var rand := Color(0, 0, 0, farbe.a)
		draw_string_outline(schrift, ort, str(werte[i]), HORIZONTAL_ALIGNMENT_CENTER, BREITE, GROESSE, 4, rand)
		draw_string(schrift, ort, str(werte[i]), HORIZONTAL_ALIGNMENT_CENTER, BREITE, GROESSE, farbe)
```

Was darin steckt:

- **`schrift`:** Die Kenney-Schrift steckt schon in deiner `schrift.tres`, den LabelSettings für Info-Text und Menü. `load(...).font` holt sie da heraus. So sehen die Zahlen aus wie der Rest.
- **Die drei Listen** gehören zusammen: `orte[5]`, `werte[5]` und `geburt[5]` sind dieselbe Zahl. Darum muss jede Änderung immer alle drei treffen. Deshalb gibt es `weg_mit_der_aeltesten()`, damit man keine vergisst.
- **Die ältesten stehen vorne.** Jede Zahl lebt gleich lange, und neue kommen immer hinten dazu. Also muss `_process()` nicht alle durchsuchen, sondern nur vorne schauen: Ist die erste zu alt, weg damit, nächste prüfen. Ist die erste noch jung, sind es alle dahinter auch.
- **`alter`** geht von 0 bis 1. Daraus wird alles andere: Die Zahl steigt um `STEIGEN * alter` Pixel und wird durchsichtiger. `1.0 - alter * alter` hält sie erst lange kräftig und lässt sie am Ende schnell verblassen. Mit `1.0 - alter` würde sie gleichmäßig blasser und man sähe sie schlechter.
- **`draw_string_outline()`** malt erst einen schwarzen Rand, `draw_string()` dann die weiße Zahl darauf. So liest man sie auf Gras und auf Gegnern.
- **`BREITE`:** Mittig schreiben geht nur in einem Kasten mit Breite. Der Kasten fängt `BREITE / 2` links vom Ort an, so landet die Mitte genau über dem Gegner.
- **`randf_range(-4, 4)`:** Trifft der Glutring zehn Gegner nebeneinander, stehen die Zahlen leicht versetzt und nicht als ein Brei.
- **`HOECHSTENS`:** Wird es zu voll, fliegt die älteste raus. Das hält die Kosten nach oben fest, egal was los ist.

**Die Gegner melden ihre Treffer.** In `gegner.gd` eine Variable unter `var held`:

```gdscript
var zahlen: Node2D
```

in `_ready()`:

```gdscript
	zahlen = get_tree().get_first_node_in_group("zahlen")
```

und in `treffer()` direkt nach `leben -= schaden`:

```gdscript
	zahlen.zeigen(global_position, schaden)
```

Die Zahl kommt vor dem `if`, damit auch der tödliche Treffer seine Zahl bekommt.

### 8.4 Das Bild bebt, der Controller brummt

Bis jetzt wird der Held rot, wenn ihn Gegner beißen. Das sieht man, aber man spürt es nicht. Jetzt bebt das Bild, und der Controller brummt in der Hand. Je mehr Gegner beißen, desto stärker.

In `held.gd` drei Konstanten zu den anderen:

```gdscript
const BEBEN_PRO_GEGNER = 0.25   # so viel Beben bringt jeder Gegner, der den Held berührt
const BEBEN_TEMPO = 3.0         # so schnell steigt und fällt das Beben, pro Sekunde
const BEBEN_PIXEL = 4.0         # so weit wackelt das Bild bei vollem Beben
```

eine Variable unter `stufen`:

```gdscript
var beben := 0.0   # 0 = ruhig, 1 = volles Beben
```

und ganz unten in `_physics_process()`, nach der Zeile mit `modulate`:

```gdscript
	# Je mehr Gegner beißen, desto mehr bebt es
	var ziel := 0.0 if testmodus else minf(treffer * BEBEN_PRO_GEGNER, 1.0)
	beben = move_toward(beben, ziel, BEBEN_TEMPO * delta)
	var staerke := beben * beben   # zum Quadrat: wenig Beben bleibt fast ruhig, viel Beben wird heftig
	$Camera2D.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * staerke * BEBEN_PIXEL
	if staerke > 0.0:
		Input.start_joy_vibration(0, staerke, staerke * staerke, 0.1)
```

Schritt für Schritt:

- **`ziel`:** Ein Gegner bringt ein Viertel, ab vier Gegnern ist es das volle Beben. `minf` hält es bei höchstens 1. Im Testmodus bebt nichts, sonst wackelt dir beim Messen das Bild.
- **`move_toward()`:** `beben` springt nicht sofort aufs Ziel, sondern läuft hin, höchstens `BEBEN_TEMPO` pro Sekunde. Beißt keiner mehr, ist das Ziel 0, und das Beben klingt in einer Drittelsekunde aus.
- **Zum Quadrat:** Ein Gegner gibt `beben` 0,25, die `staerke` ist dann nur 0,06, kaum ein Zittern. Vier Gegner geben 1 × 1 = 1, volles Beben. Das Quadrat macht kleine Werte sehr klein und lässt große groß. So bebt es nur, wenn es wirklich gefährlich wird. Das ist ein bekannter Trick für Bildschirmwackeln: Wer bei jedem kleinen Treffer heftig wackelt, nervt nach zehn Sekunden.
- **`offset`** verschiebt nur das Bild der Kamera, nicht die Kamera selbst. Ihre Position und das weiche Folgen bleiben, wie sie sind. Jeden Schritt kommt ein neuer zufälliger Versatz, das ergibt das Zittern.
- **`Input.start_joy_vibration()`** lässt den Controller brummen: welcher Controller (`0` ist der erste), der **schwache** Motor (hohes Surren), der **starke** Motor (tiefes Rumpeln), wie viele Sekunden. Der starke bekommt noch einmal das Quadrat, er setzt also erst bei richtig viel Gefahr ein.
- **0,1 Sekunden** sind kurz, aber jeder Schritt startet das Brummen neu. Hört das Beben auf, startet keiner mehr neu, und nach 0,1 Sekunden ist Ruhe. Darum muss man es nie ausschalten. Ist kein Controller angeschlossen, passiert einfach nichts.

> **Wackeln ist nicht für jeden schön.** Manchen Leuten wird von Bildschirmwackeln schlecht, andere mögen kein Brummen. Gute Spiele haben dafür einen Schalter in den Optionen. Den bekommt der Hordenheld später. Bis dahin schaltet `BEBEN_PIXEL = 0` das Wackeln aus.

### 8.5 Was kostet der Saft?

Gemessen wie in Kapitel 7, 1000 Gegner, alle Waffen voll ausgebaut, Zeit pro Schritt im Schnitt:

| | Zeit pro Schritt |
|---|---|
| Kapitel 7 | 9,2 ms |
| Kapitel 8, mit Blitz, Schrumpfen, Zahlen und Beben | **10 ms** |

Alles zusammen kostet weniger als eine Millisekunde, bei mehreren Hundert Zahlen gleichzeitig. Die Anzeige `Physik` sprang in meinen Messungen sogar etwas weniger hoch als vorher. Ein Teil der Arbeit beim Sterben verteilt sich jetzt auf die 0,2 Sekunden, statt alles im selben Schritt zu passieren.

### 8.6 Ausprobieren

**F5**:
- Ein normaler Gegner blitzt beim ersten Messer weiß auf, beim zweiten schrumpft er weg.
- Über jedem Treffer springt eine Zahl hoch und verblasst. Mit dem Glutring regnet es Einsen.
- Lass dich von ein, zwei Gegnern beißen: Kaum ein Zittern. Steh mitten in der Horde: Das Bild bebt, und der Controller brummt. Geh raus: Nach einer Drittelsekunde ist Ruhe.
- **F2** (Testmodus): kein Beben, kein Brummen.
- Ein toter Gegner tut nicht mehr weh, und die Messer fliegen nicht mehr auf ihn.
- 1000 Gegner mit F1: `Physik` bleibt fast wie vorher.

### 8.7 Was ist neu?

- **Game Feel und Juice:** viele kleine Rückmeldungen, die aus "funktioniert" ein "fühlt sich gut an" machen.
- **`modulate` über 1:** Farben heller als das Bild selbst, für den weißen Treffer-Blitz.
- **Sterben in Ruhe:** `remove_from_group()`, `collision_layer = 0` und `set_physics_process(false)` nehmen einen Knoten aus dem Spiel, ohne dass er verschwindet. Der Tween räumt ihn danach weg.
- **Ein Knoten zeichnet alles:** `draw_string()` und `draw_string_outline()`, mehrere Listen, die zusammengehören.
- **Die ältesten stehen vorne:** Wenn alle gleich lange leben, muss man nur vorne aufräumen.
- **`Camera2D.offset`** für Bildschirmwackeln, **zum Quadrat** für ein Beben, das nur bei Gefahr heftig wird.
- **`Input.start_joy_vibration()`:** Brummen mit schwachem und starkem Motor, kurz und immer wieder neu gestartet.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 8

1. **Die Fledermaus quetscht sich (leicht):** Wenn ein Ballon breiter wird, wird er auch flacher. Lass beim Flattern `$Bild.scale.y` genau andersherum gehen wie `scale.x`: Wird die Fledermaus breiter, wird sie flacher. Probier, wie stark es sein darf, bevor es albern aussieht. Das nennt man **Squash and Stretch**, Quetschen und Strecken. 🦇
2. **Wie viele Zahlen verträgt das Auge? (leicht):** Stell `HOECHSTENS` auf `30`, dann auf `3000`, und spiel jeweils mit dem Glutring. Wann sieht man mehr, wann weniger? Schau auf `Physik` und auf die FPS. Warum ändert sich `Physik` kaum, selbst bei 3000 Zahlen? Tipp: In welchen Funktionen arbeiten die Zahlen? Im Profiler findest du sie unter `zahlen.gd`. 🔢
3. **Die Kamera schaut voraus (mittel):** Wer nach rechts läuft, will sehen, was rechts kommt. Schieb die Kamera ein Stück in die Laufrichtung, zum Beispiel 30 Pixel, und zwar weich, nicht mit einem Sprung. Tipp: `lerp()`. Aber nimm dafür nicht `offset`. Warum nicht? 🎥
4. **Kritische Treffer (schwer):** Jeder zehnte Treffer soll doppelten Schaden machen. Seine Zahl soll gelb und größer sein, damit man es sieht. Dafür braucht `zeigen()` einen dritten Wert, und die Zahlen brauchen eine vierte Liste. Pass auf, dass die vierte Liste überall mitkommt, wo die anderen drei sich ändern. 💥

### Antworten zu Kapitel 8

2. 3000 ist unmöglich zu erreichen, etwa 50 Zahlen sehe ich. Physik betrifft es kaum, weil alle Aufwände linear und auch begrenzt sind. Außerdem, wird es in einer anderen Funktion berechnet: _process() und nicht in _physics_process()
3. Offset funktioniert gar nicht. Der wird für den Beben verwendet. Kein Beben - kein Offset. Die Position funktionert gut, weil die Kamerageschwindigkeit bereits begrenzt ist.

---

## Kapitel 9: Die Uhr: Wellen, Elite-Gegner, Sieg und Game Over

Bis jetzt ist der Hordenheld eine Spielwiese ohne Ende: Die Gegner kommen schneller und schneller, und wer stirbt, steht sofort wieder am Anfang. In diesem Kapitel wird daraus ein richtiges Spiel mit einem Ziel: **Überlebe fünf Minuten.**

Dafür kommen dazu:
- **Eine Uhr**, die von 5:00 herunterzählt.
- **Wellen:** Wer wann kommt und wie schnell, steht in Dateien, genau wie die Upgrades in Kapitel 5.
- **Zwei neue Gegner:** ein langsamer Geist, der viel aushält, und ein riesiger Zyklop als **Elite-Gegner**, der zu Beginn mancher Wellen auftaucht.
- **Ein Ende:** "Gewonnen!", wenn die Uhr abläuft, und "Game Over", wenn der Held stirbt. Mit OK geht es von vorn los. ⏱️

### 9.1 Die Uhr

Die Uhr ist ein **Label** in der `Anzeige`, also neben dem Info-Text. In `welt.tscn`: Rechtsklick auf `Anzeige` → **Add Child Node** → **Label**, Name `Uhr`. Im Inspector:
- **Horizontal Alignment**: Center
- **Label Settings**: deine `schrift.tres`
- **Layout** → **Anchors Preset**: **Center Top**
- **Layout** → **Transform** → **Position**: y auf `16`, damit die Uhr unter dem Info-Text steht und nicht darauf
- **Node** → **Groups**: Gruppe `uhr`

Dazu ein neues Skript `uhr.gd`:

```gdscript
class_name Uhr
extends Label

signal abgelaufen

const SPIELZEIT = 300.0   # so viele Sekunden muss der Held überleben

var zeit := 0.0
var vorbei := false


func _process(delta: float) -> void:
	if vorbei:
		return
	zeit += delta
	if zeit >= SPIELZEIT:
		zeit = SPIELZEIT
		vorbei = true
		abgelaufen.emit()
	text = als_text(SPIELZEIT - zeit)


func als_text(sekunden: float) -> String:
	var ganz := ceili(sekunden)
	return "%d:%02d" % [floori(ganz / 60.0), ganz % 60]
```

- **`class_name Uhr`:** Wie bei `Held` kann jetzt jedes andere Skript `var uhr: Uhr` schreiben, und Godot kennt `zeit` und `als_text()`.
- **`zeit`** zählt in `_process()` hoch. Weil die Uhr nicht `process_mode = Always` hat, bleibt sie stehen, solange das Level-Up-Menü das Spiel anhält. Die Zeit im Menü zählt nicht.
- **`vorbei`** sorgt dafür, dass `abgelaufen` genau einmal kommt.
- **`als_text()`** macht aus Sekunden eine Uhrzeit. `ceili()` rundet auf: Bei 4,3 Sekunden Rest steht `0:05`, und `0:00` erscheint erst, wenn die Zeit wirklich um ist. `floori(ganz / 60.0)` sind die ganzen Minuten, `ganz % 60` die Sekunden, die übrig bleiben. `%02d` schreibt eine Zahl immer zweistellig, also `4:05` statt `4:5`.

Die Uhr zählt die **Restzeit** herunter. Das macht mehr Druck als eine Zeit, die nur hochzählt. 😬

### 9.2 Wellen als Daten

Bis jetzt hat die Horde nur zwei Gegnerarten gekannt und ist immer schneller geworden. Jetzt soll das Spiel einen Plan haben: erst nur Spinnen, dann Fledermäuse, dann Geister, ab und zu ein Zyklop. So ein Plan gehört nicht in den Code, sondern in Daten, die man im Inspector ändern kann. Wie bei den Upgrades in Kapitel 5 baust du dafür eine eigene **Resource**.

Neues Skript `welle.gd`:

```gdscript
class_name Welle
extends Resource

@export var start := 0                        # ab dieser Sekunde gilt die Welle
@export var gegner: Array[PackedScene] = []   # aus diesen wird zufällig gewählt
@export var takt := 1.0                       # so viele Sekunden zwischen zwei Gegnern
@export var elite: PackedScene                # kommt einmal am Anfang der Welle, darf leer bleiben
```

Eine Welle gilt von ihrem `start` bis zum `start` der nächsten.

### 9.3 Zwei neue Gegner

Beide baust du wie die Fledermaus: Rechtsklick auf `gegner.tscn` → **New Inherited Scene**, dann speichern.

**Der Geist** (`geist.tscn`, oberster Knoten heißt `Geist`):
- **Tempo** `35`, **Leben** `5`, **Erfahrung** `2`
- **Bild** → **Frame**: `121`
- Oberster Knoten → **CanvasItem** → **Visibility** → **Modulate**: Alpha (das **A**) auf etwa `180`, damit er durchscheint. Ein Geist eben. 👻

Das `modulate` vom obersten Knoten stört den Treffer-Blitz nicht. Der Blitz setzt das `modulate` vom `Bild`. Godot multipliziert beide, also blitzt der Geist weiß und bleibt trotzdem durchsichtig.

**Der Zyklop** (`zyklop.tscn`, oberster Knoten heißt `Zyklop`):
- **Tempo** `20`, **Leben** `40`, **Erfahrung** `25`
- **Bild** → **Frame**: `109`, **Transform** → **Scale**: `2, 2`
- **CollisionShape2D** → **Position**: y auf `4`

Bleibt noch die Kollisionsform. Die muss doppelt so groß werden, Radius 12 statt 6. **Achtung, Falle:** Die Form ist eine Resource, und alle Gegner teilen sich dieselbe. Änderst du hier einfach den Radius, werden *alle* Spinnen, Fledermäuse und Geister doppelt so dick. Darum erst: **CollisionShape2D** → **Shape** → auf den Pfeil neben der Form → **Make Unique**. Jetzt hat der Zyklop seine eigene Form, und du kannst den **Radius** auf `12` stellen.

Den Zyklop trifft man viel leichter, und mit 40 Leben braucht er eine Weile. Dafür lässt er einen Edelstein mit 25 Erfahrung fallen.

> **Eine Vereinfachung:** Die Horde schiebt alle Gegner auf 12 Pixel Abstand, auch den Zyklop. Kleine Gegner laufen darum ein Stück in ihn hinein. Das sieht man kaum, weil er so groß ist. Für jeden Gegner einen eigenen Abstand zu rechnen würde das Raster aus Kapitel 7 komplizierter machen, ohne dass das Spiel besser wird.

### 9.4 Der Plan für fünf Minuten

Leg einen Ordner `wellen` an. Darin für jede Welle: Rechtsklick → **Create New** → **Resource** → **Welle**, Name wie in der Tabelle. Dann im Inspector ausfüllen:

| Datei | Start | Gegner | Takt | Elite |
|---|---|---|---|---|
| `welle_1.tres` | 0 | Spinne | 1.0 | |
| `welle_2.tres` | 30 | Spinne | 0.5 | |
| `welle_3.tres` | 60 | Spinne, Fledermaus | 0.35 | Zyklop |
| `welle_4.tres` | 90 | Fledermaus | 0.25 | |
| `welle_5.tres` | 120 | Spinne, Geist | 0.25 | Zyklop |
| `welle_6.tres` | 180 | Spinne, Fledermaus, Geist | 0.15 | Zyklop |
| `welle_7.tres` | 240 | Spinne, Fledermaus, Geist | 0.08 | Zyklop |

"Spinne" ist `gegner.tscn`. Bei **Gegner** fügst du mit **Add Element** einen Platz hinzu und ziehst die Szene aus dem FileSystem hinein.

Die Wellen 4 und 5 haben denselben Takt, und trotzdem fühlt sich 5 anders an: Ein Geist hält fünf Treffer aus, eine Fledermaus nur einen. Wie schwer eine Welle ist, hängt nicht nur am Takt.

Welle 7 bringt über 12 Gegner pro Sekunde, so viele wie noch nie. Dass das Spiel das schafft, hast du dir in Kapitel 7 verdient.

### 9.5 Die Horde liest die Wellen

In `spawner.gd` fliegen `START_TAKT`, `MIN_TAKT` und `SCHNELLER` raus, und auch `gegner_szenen` und `takt`. Wie schnell es geht, steht jetzt in den Wellen. Stattdessen:

```gdscript
@export var wellen: Array[Welle] = []

var uhr: Uhr
var welle_nr := 0   # die wievielte Welle gerade läuft, von 0 an gezählt
var warten := 0.0
var schritt := 0   # für halbe Arbeit


func _ready() -> void:
	uhr = get_tree().get_first_node_in_group("uhr")


func _process(delta: float) -> void:
	# Ist die nächste Welle dran?
	if welle_nr + 1 < wellen.size() and uhr.zeit >= wellen[welle_nr + 1].start:
		welle_nr += 1
		if wellen[welle_nr].elite != null:
			einsetzen(wellen[welle_nr].elite.instantiate())

	warten -= delta
	# while statt if: Ist der Takt kürzer als ein Bild, kommen mehrere Gegner im selben Bild
	while warten <= 0:
		neuer_gegner()
		warten += wellen[welle_nr].takt
```

- **Die Horde schaut nur auf die nächste Welle.** Die Wellen stehen nach Startzeit sortiert in der Liste. Ist die Uhr am `start` der nächsten vorbei, ist die dran. Gibt es keine nächste mehr, bleibt die letzte Welle, bis die Uhr abläuft.
- **Der Elite-Gegner** kommt genau einmal, im selben Moment, in dem die Welle wechselt.
- **`warten := 0.0`:** Der erste Gegner kommt sofort, danach im Takt der Welle.

`neuer_gegner()` teilt sich in zwei Teile. Der erste sucht aus, *welcher* Gegner kommt, der zweite, *wo*. Den zweiten Teil braucht auch der Elite-Gegner:

```gdscript
func neuer_gegner() -> void:
	var szenen := wellen[welle_nr].gegner
	einsetzen(szenen[randi() % szenen.size()].instantiate())


# Setzt einen Gegner an eine zufällige Stelle knapp hinter dem Bildrand
func einsetzen(gegner: Node2D) -> void:
	# Eine zufällige Richtung von der Bildmitte aus
	var alpha := Vector2.from_angle(randf() * TAU)
```

Ab `# Eine zufällige Richtung` bleibt alles, wie es war, bis zum `add_child(gegner)`. Dein Werkzeug ruft weiter `neuer_gegner()` auf. F1 und F3 bringen jetzt also Gegner aus der Welle, die gerade läuft.

Zum Schluss: `Horde` auswählen und bei **Wellen** im Inspector die sieben Dateien der Reihe nach hineinziehen.

### 9.6 Game Over und Sieg

Bis jetzt lädt der Held die Szene selbst neu, wenn er stirbt. Das ist nicht seine Aufgabe. Er meldet nur noch, dass er gestorben ist, und um das Ende kümmert sich jemand anders.

In `held.gd` ein neues Signal zu den anderen:

```gdscript
signal gestorben
```

und in `_physics_process()` wird aus `get_tree().reload_current_scene()`:

```gdscript
		if leben <= 0:
			gestorben.emit()
```

**Der Ende-Bildschirm** sieht aus wie das Level-Up-Menü: dunkler Hintergrund, Text in der Mitte. Darum kopierst du es: Rechtsklick auf `LevelUp` → **Duplicate**, Name `Ende`. Dann:
- Beim `Ende` das Skript entfernen (Rechtsklick → **Detach Script**). Es bekommt gleich ein eigenes.
- In `Kasten`: `Wahl3` und `Beschreibung` löschen. `Wahl1` umbenennen in `Werte`, `Wahl2` in `Hinweis`. Beim `Hinweis` als **Text** `OK: nochmal` eintragen.
- `Titel` bleibt.

**Process Mode** steht schon auf **Always**, weil du `LevelUp` kopiert hast. Das ist wichtig: Der Ende-Bildschirm hält das Spiel an und muss trotzdem merken, dass OK gedrückt wird.

Dazu das Skript `ende.gd` an den Knoten `Ende`:

```gdscript
extends CanvasLayer

var held: Held
var uhr: Uhr


func _ready() -> void:
	hide()
	held = get_tree().get_first_node_in_group("held")
	uhr = get_tree().get_first_node_in_group("uhr")
	held.gestorben.connect(zeigen.bind("Game Over"))
	uhr.abgelaufen.connect(zeigen.bind("Gewonnen!"))


func zeigen(titel: String) -> void:
	$Kasten/Titel.text = titel
	$Kasten/Werte.text = "Überlebt: %s   Level: %d" % [uhr.als_text(uhr.zeit), held.level]
	show()
	get_tree().paused = true


func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ok"):
		get_tree().paused = false
		get_tree().reload_current_scene()
```

- **`bind()`** ist neu. `zeigen()` will einen Titel, aber die Signale `gestorben` und `abgelaufen` bringen keinen mit. `zeigen.bind("Game Over")` heißt: Ruf `zeigen()` auf und gib dabei immer `"Game Over"` mit. So hängen zwei Signale an derselben Funktion, und jedes bringt seinen eigenen Titel mit. Du hast `bind()` schon einmal benutzt, im Werkzeug für die Monitore.
- **`uhr.als_text(uhr.zeit)`:** Die Uhr zeigt, was übrig ist. Hier steht, wie lange der Held durchgehalten hat. Deshalb ist `als_text()` eine eigene Funktion, damit beide Stellen sie benutzen können.
- **`paused = false` vor dem Neuladen:** `reload_current_scene()` baut die Szene neu, aber der Pausen-Schalter gehört zum ganzen Baum und bleibt, wie er ist. Ohne die Zeile stünde das neue Spiel still.

### 9.7 Ein Werkzeug für die Zeit

Fünf Minuten warten, um Welle 7 zu testen, das macht niemand gern. Darum bekommt das Werkzeug eine Taste mehr. In `werkzeug.gd` in die Liste oben:

```gdscript
# F1 = 100 Gegner mehr, F2 = Testmodus an/aus, F3 = Grenze suchen, F4 = Uhr 30 Sekunden vor
```

und in das `match`:

```gdscript
		KEY_F4:
			var uhr: Uhr = get_tree().get_first_node_in_group("uhr")
			uhr.zeit += 30.0
```

Mit F2 und dann zehnmal F4 bist du in fünf Sekunden beim Sieg.

### 9.8 Ausprobieren

**F5**:
- Oben steht `5:00` und zählt herunter. Im Level-Up-Menü bleibt die Uhr stehen.
- Erst kommen nur Spinnen, bei `4:00` Fledermäuse und der erste Zyklop. Er ist groß, langsam und hält viel aus.
- Bei `3:00` kommen die Geister. Man sieht durch sie hindurch, und beim Treffer blitzen sie trotzdem.
- Lass dich fressen: "Game Over", die Zeit, die du geschafft hast, dein Level. Das Spiel steht still. **OK** startet neu.
- **F2**, dann **F4** ein paarmal: Die Wellen wechseln schnell durch. Bei `0:00` steht "Gewonnen!".
- Und dann das Wichtigste: Spiel es ohne Testmodus einmal ganz durch. Schaffst du die fünf Minuten?

### 9.9 Was ist neu?

- **Eine Uhr mit Signal:** Wer wissen will, wann die Zeit um ist, verbindet sich mit `abgelaufen`.
- **Zeit als Text:** `ceili()`, `floori()`, `%` und `%02d` für eine Uhrzeit wie `4:05`.
- **Wellen als Resource:** Ein Plan, den man im Inspector ändert statt im Code. Dasselbe Muster wie die Upgrades.
- **Elite-Gegner:** derselbe Gegner, nur größer und stärker, mit eigenen Werten in einer geerbten Szene.
- **Make Unique:** Eine Resource, die sich viele teilen, nur für einen Knoten ändern.
- **Zwei `modulate`, die sich multiplizieren:** eins für den Geist, eins für den Blitz.
- **`Callable.bind()`:** Ein Signal ruft eine Funktion auf und gibt dabei einen festen Wert mit.
- **Wer stirbt, meldet es nur:** Der Held sendet `gestorben`, um das Ende kümmert sich der Ende-Bildschirm.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 9

1. **Rote Steine (leicht):** Ein Zyklop lässt einen Stein mit Wert 25 fallen, der genauso grün aussieht wie ein Stein mit Wert 3. Gib Steinen ab Wert 10 eine dritte Farbe, zum Beispiel Rot. 💎
2. **Wie viele hast du erwischt? (leicht):** Zähl, wie viele Gegner der Held besiegt hat, und zeig es auf dem Ende-Bildschirm unter der Zeit. Überleg vorher: Wo stirbt ein Gegner, und wer sollte die Zahl kennen? 💀
3. **Der Rekord (mittel):** Merk dir die beste Zeit über einen Neustart hinaus, auch wenn das Spiel ganz geschlossen wird. Steht ein neuer Rekord auf dem Ende-Bildschirm, soll man es sehen. Tipp: `ConfigFile` und ein Pfad, der mit `user://` anfängt. 🏆
4. **Das große Finale (schwer):** Wenn die Uhr abläuft, steht bis jetzt sofort "Gewonnen!" da. Schöner: Erst sterben alle Gegner, und zwar wie eine Welle, die vom Held nach außen läuft. Wer nah dran ist, stirbt zuerst, wer weit weg ist, zuletzt. Erst danach kommt der Ende-Bildschirm. Tipp: `get_tree().create_timer()` und die Entfernung zum Held. Und denk daran: Sobald der Ende-Bildschirm das Spiel anhält, passiert in der Welt nichts mehr. 🌊

---

## Kapitel 10: Titelbild, Musik und Web-Export

Das letzte Kapitel. Bisher startet der Hordenheld mitten auf der Wiese, es ist still, und wer gewinnt, will sofort weiterlaufen. Jetzt bekommt er ein Titelbild mit Optionen, drei Musikstücke und einen Platz auf der Startseite. Und er lernt endlich, seinen Sieg zu feiern.

Titelbild, Optionen, Musik und Web-Export kennst du vom Kerkerheld. Darum geht es hier zügig. Neu sind ein **Tween, der in der Pause weiterläuft**, **Musik, die zur Welle passt**, und **`OS.is_debug_build()`**: Deine Messwerkzeuge bleiben zu Hause, wenn das Spiel ins Netz geht.

### 10.1 Noch etwas aus Kapitel 9

Zwei Kleinigkeiten aus deinem Ausbalancieren und dem Finale.

**Die Äxte schubsen in die falsche Richtung.** In `aexte.gd` gibst du `-$Axt/Bild.position` als Richtung mit. Das ist die Position des Bildes **in der Axt**, und die ist immer `(56, 0)`, egal wie weit sich die Äxte gerade gedreht haben. Die erste Axt schubst also immer nach links, die zweite immer nach rechts. Steht ein Gegner links vom Held, schiebt die zweite Axt ihn sogar **zum** Held hin.

Was du willst: weg vom Held, in die Richtung, in die die Axt gerade zeigt. Und was ändert sich, während sich die Äxte drehen? Nur `rotation`. Die Axt weiß also schon alles: Die erste sitzt bei Winkel `rotation`, die zweite genau gegenüber, bei `rotation + PI`.

```gdscript
func treffer(body: Node2D, richtung: Vector2) -> void:
	body.treffer(schaden, richtung * SCHUB)


func _on_axt_2_body_entered(body: Node2D) -> void:
	treffer(body, Vector2.from_angle(rotation + PI))


func _on_axt_body_entered(body: Node2D) -> void:
	treffer(body, Vector2.from_angle(rotation))
```

- **`Vector2.from_angle()`** liefert schon einen Vektor der Länge 1. Ein `normalized()` ist nicht nötig.
- **Warum geht `rotation` und nicht `global_rotation`?** `rotation` ist der Winkel relativ zum Eltern-Knoten, also zum Held. Der Held selbst dreht sich nie, nur sein Bild wackelt. Darum ist beides dasselbe. Würde sich der Held einmal drehen, bräuchtest du `global_rotation`.

**Der Timer im Ende-Bildschirm läuft in der Pause weiter.** In `ende.gd` steht `create_timer(2.0)`. Ohne zweites Argument zählt ein Timer auch dann weiter, wenn das Spiel pausiert. Fliegen nach dem Sieg noch Edelsteine heran und bringen ein Level-Up, steht das Level-Up-Menü da, und mittendrin erscheint "Gewonnen!" darüber. Mit `false` wartet der Timer, bis du gewählt hast:

```gdscript
		await get_tree().create_timer(2.0, false).timeout   # Explosion abwarten
```

### 10.2 Der Held feiert

Die Zeit ist um, die Horde zerplatzt, und der Held? Läuft weiter, als wäre nichts. Ab jetzt bleibt er stehen und hüpft vor Freude.

In `held.gd` oben bei den Konstanten:

```gdscript
const HUEPFER = 6.0             # so hoch hüpft er vor Freude, in Pixeln
```

Bei den Variablen:

```gdscript
var feiert := false
```

Am Ende von `_ready()`, unter Schritt 3:

```gdscript

	var uhr: Uhr = get_tree().get_first_node_in_group("uhr")
	uhr.abgelaufen.connect(feiern)
```

Ganz oben in `_physics_process()`:

```gdscript
	if feiert:
		return   # wer feiert, läuft nicht mehr

```

Und ganz unten eine neue Funktion:

```gdscript
# Die Zeit ist um: stehen bleiben und vor Freude hüpfen
func feiern() -> void:
	feiert = true
	$Camera2D.position = Vector2.ZERO   # nicht mehr vorausschauen, der Held rückt in die Mitte
	$Camera2D.offset = Vector2.ZERO     # kein Beben mehr
	Input.stop_joy_vibration(0)
	$Bild.rotation = 0.0
	$Bild.modulate = Color.WHITE
	var tween := create_tween().set_loops()   # ohne Zahl: für immer
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)   # hüpft auch hinter dem Ende-Bildschirm weiter
	tween.tween_property($Bild, "position:y", -HUEPFER, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Bild, "position:y", 0.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void: $Bild.flip_h = not $Bild.flip_h)   # bei jedem Hüpfer in die andere Richtung
	tween.tween_interval(0.1)
```

- **Der Held hört selbst auf die Uhr.** Die Uhr weiß nichts vom Held, der Ende-Bildschirm auch nicht. Jeder, den das Ende angeht, verbindet sich mit `abgelaufen`: der Spawner fürs Finale, der Ende-Bildschirm für "Gewonnen!", jetzt der Held fürs Feiern. Das ist der Vorteil von Signalen. Wer neu dazukommt, muss niemand anderen ändern.
- **`return` ganz oben:** Danach passiert in `_physics_process()` nichts mehr. Kein Laufen, keine Bisse, kein Beben. Darum setzt `feiern()` die Kamera und das Brummen einmal von Hand zurück, sonst bliebe alles so stehen, wie es im letzten Moment war.
- **`set_loops()`:** Ein Tween läuft normalerweise einmal ab. Mit einer Zahl läuft er so oft, ohne Zahl für immer. Ein Tween für immer darf aber nicht 0 Sekunden lang sein, sonst würde er in einem einzigen Bild unendlich oft laufen. Godot bricht dann mit einer Fehlermeldung ab.
- **`TWEEN_PAUSE_PROCESS`:** Ein Tween hält normalerweise an, wenn das Spiel pausiert. Sobald der Ende-Bildschirm kommt, würde der Held mitten im Sprung in der Luft hängen bleiben. So hüpft er hinter dem abgedunkelten Bild weiter.
- **`set_trans()` und `set_ease()`:** wie beim Hüpfheld. Hoch wird er langsamer, runter schneller. So sieht ein Sprung aus, als ob ihn etwas nach unten zieht.
- **`func() -> void: ...` in einer Zeile:** eine Funktion ohne Namen, direkt da, wo sie gebraucht wird. Du kennst sie von `filter()` und `any()` im Kerkerheld.

### 10.3 Ein Skript komponiert

Im Projektordner liegt schon `musik.py`. Es funktioniert genauso wie das aus dem Kerkerheld, nur mit drei neuen Stücken. **Mach das als Erstes, noch vor allem anderen**, sonst meckert `musik.gd` über Dateien, die es noch nicht gibt (Kerkerheld, Kapitel 14.10). Im Ordner `07-hordenheld`:

```bash
python musik.py
```

```
musik_titel.wav: 8 Takte, 19.2 s, 826 KB
musik_kampf.wav: 8 Takte, 14.5 s, 626 KB
musik_endspurt.wav: 8 Takte, 12.0 s, 516 KB
```

- **`musik_titel`:** mutig, aber noch ruhig, mit einer Begleitung, die Akkorde zerlegt.
- **`musik_kampf`:** treibend, für die ersten vier Minuten.
- **`musik_endspurt`:** schneller und mit mehr Trommel, für die letzte Welle.

Neu im Skript ist nur eine kleine Hilfe: `acht("E2", "G2", ...)` schreibt für jeden Akkord einen ganzen Takt Bass in Achteln, tief und hoch im Wechsel. Das spart viel Tipparbeit. Schau dir an, was sie macht, bevor du die Stücke umschreibst.

Ich kann nichts hören. Die Stücke sind also nach Notenlehre geschrieben, nicht nach Gehör. Gefällt dir ein Takt nicht, schreib ihn um. Wie das geht, steht oben im Skript.

### 10.4 Ein eigener Bus und der Musik-Autoload

**Der Bus:** Unten im Editor auf **Audio** → **Add Bus** → Doppelklick auf den Namen → `Musik`. Unten am Bus steht `Master`, so soll es sein.

**Der Autoload:** Neues Skript `musik.gd`. Fast wie im Kerkerheld, mit einem Unterschied, der weiter unten erklärt wird:

```gdscript
extends AudioStreamPlayer

# Die Hintergrundmusik. Ein Autoload, darum spielt sie über jeden Szenenwechsel hinweg weiter.

const TITEL = preload("res://musik_titel.wav")
const KAMPF = preload("res://musik_kampf.wav")
const ENDSPURT = preload("res://musik_endspurt.wav")
const BLENDE = 0.6     # so lange dauert das Aus- und Einblenden, in Sekunden
const LEISE = -40.0    # in dB: so gut wie nichts mehr zu hören

var blende: Tween
var ziel: AudioStream   # was gerade laufen soll, null = Ruhe


func _ready() -> void:
	bus = &"Musik"
	# Level-Up und Ende-Bildschirm pausieren das Spiel. Die Musik soll trotzdem weiterspielen.
	process_mode = Node.PROCESS_MODE_ALWAYS


# Ein Stück spielen. Soll es schon laufen, passiert nichts. Sonst wird das alte aus- und das neue eingeblendet.
func spielen(stueck: AudioStream) -> void:
	if ziel == stueck:
		return
	ziel = stueck
	if blende:
		blende.kill()
	blende = create_tween()
	if playing:
		blende.tween_property(self, "volume_db", LEISE, BLENDE)
	else:
		volume_db = LEISE
	blende.tween_callback(wechseln.bind(stueck))
	blende.tween_property(self, "volume_db", 0.0, BLENDE)


func wechseln(stueck: AudioStream) -> void:
	stream = stueck
	play()


# Ausblenden und Ruhe
func stoppen() -> void:
	ziel = null
	if blende:
		blende.kill()
	blende = create_tween()
	blende.tween_property(self, "volume_db", LEISE, BLENDE)
	blende.tween_callback(stop)
```

*Project Settings → Globals → Autoload*: `res://musik.gd`, Name **`Musik`**.

**Warum `ziel` statt `stream == stueck and playing` wie im Kerkerheld?** Beim Hordenheld kann man nach Game Over sofort **OK** drücken. Stell dir vor, du stirbst in den ersten vier Minuten:
1. Der Ende-Bildschirm ruft `stoppen()`. Die Kampfmusik blendet aus, das dauert 0,6 Sekunden.
2. Du drückst gleich **OK**, das Spiel startet neu, und der Spawner wünscht sich `KAMPF`.
3. Die alte Abfrage sagt: Kampfmusik ist drin und läuft noch, also nichts zu tun.
4. Eine Zehntelsekunde später ist das Ausblenden fertig, `stop()` wird aufgerufen, und die ganze Runde bleibt still.

`ziel` merkt sich, was laufen **soll**, nicht was gerade zufällig noch klingt. Nach `stoppen()` ist es `null`, und der nächste Wunsch wird auf jeden Fall erfüllt.

### 10.5 Wer bestellt welche Musik?

**Im Kampf:** In `spawner.gd`, in `_ready()`, unter dem `connect`:

```gdscript
	Musik.spielen(Musik.KAMPF)
```

**Im Endspurt:** Die letzte Welle kennt nur der Spawner. In `_process()`, unter `leben_mal = ...`:

```gdscript
		if welle_nr == wellen.size() - 1:
			Musik.spielen(Musik.ENDSPURT)   # die letzte Welle: Endspurt
```

**Am Ende:** Ruhe, beim Sieg wie bei Game Over. In `ende.gd` als erste Zeile in `zeigen()`:

```gdscript
	Musik.stoppen()
```

- **`wellen.size() - 1` statt `6`:** Fügst du eine achte Welle hinzu, ist der Endspurt automatisch wieder die letzte.
- **Warum nicht die Uhr?** Die wüsste auch, wann die letzte Minute anfängt. Aber wenn du die Wellen änderst, müsstest du an die Uhr denken. So hängt die Musik an der Welle, und die Welle steht im Inspector.

### 10.6 Die Optionen

Neues Skript `optionen.gd` (ohne Szene):

```gdscript
extends Node

# Einstellungen, die für jedes Spiel gelten. Sie stehen in einer eigenen Datei.

const DATEI = "user://optionen.cfg"

var musik := 7          # 0 bis 10
var beben := true       # wackelt das Bild, wenn Gegner beißen?
var brummen := true     # brummt der Controller, wenn Gegner beißen?
var vollbild := false


func _ready() -> void:
	laden()


func laden() -> void:
	var datei := ConfigFile.new()
	datei.load(DATEI)   # Gibt es die Datei noch nicht, liefert get_value einfach die Ersatzwerte
	musik = datei.get_value("optionen", "musik", 7)
	beben = datei.get_value("optionen", "beben", true)
	brummen = datei.get_value("optionen", "brummen", true)
	vollbild = datei.get_value("optionen", "vollbild", false)
	anwenden()


func speichern() -> void:
	var datei := ConfigFile.new()
	datei.set_value("optionen", "musik", musik)
	datei.set_value("optionen", "beben", beben)
	datei.set_value("optionen", "brummen", brummen)
	datei.set_value("optionen", "vollbild", vollbild)
	datei.save(DATEI)
	anwenden()


# Was sich nicht von selbst einstellt, wird hier eingestellt. Beben und Brummen fragt der Held selbst.
func anwenden() -> void:
	# linear_to_db: 5 von 10 klingt so wirklich wie „halb so laut“
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musik"), linear_to_db(musik / 10.0))
	if OS.has_feature("web"):
		return   # im Browser gibt es dafür F11
	if vollbild:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
```

*Autoload*: `res://optionen.gd`, Name **`Optionen`**. Schieb ihn mit den Pfeilen **über** `Musik`.

- **Warum über `Musik`?** Autoloads werden von oben nach unten angelegt. `Optionen` stellt beim Laden den Bus `Musik` ein. Den Bus gibt es zwar schon vorher, aber so ist die Reihenfolge klar: erst die Einstellungen, dann die Musik.
- **Warum eine eigene Datei?** Dein Rekord steht in `hordenheld.cfg`. Die Optionen könnten dazu, aber dann müssten sich zwei Skripte eine Datei teilen und dürften sich gegenseitig nichts überschreiben. Zwei Dateien sind einfacher.
- **Musik steht am Anfang auf 7, nicht auf 10.** Im Spiel gibt es sonst noch keine Geräusche. Die Musik soll Platz lassen, falls du welche einbaust (Übung 4).

### 10.7 Das Titelbild

Neue Szene: **Scene → New Scene → User Interface**. Die Wurzel ist ein `Control`, nenne sie `Titel`. Speichern als `titel.tscn`. Darunter:

1. **ColorRect** `Hintergrund`: Oben in der Leiste **Anchor Preset → Full Rect**. **Color** ein dunkles Grün, zum Beispiel `171f17`.
2. **Label** `Spielname`: Text `HORDENHELD`. **Anchor Preset → Top Wide**, dann unter **Layout → Transform**: **Position** y 16, **Size** y 48. **Horizontal Alignment** Center. Bei **Label Settings** → **New LabelSettings**, dann darin:
   - **Font:** `kenney/Kenney Pixel.ttf`, **Size** 48, **Color** goldgelb (`ffd94d`)
   - **Outline:** **Size** 8, **Color** dunkelrot (`590d0d`)
3. **Label** `Menue`: **Position** (140, 80), **Size** (120, 80). **Label Settings** → **Load** → `schrift.tres`.
4. **Label** `Hinweis`: **Anchor Preset → Bottom Wide**, dann unter **Layout → Transform**: **Position** (16, 176), **Size** (352, 28). **Horizontal Alignment** Center, **Autowrap Mode** Word (Smart), **Label Settings** `schrift.tres`.

Skript an die Wurzel, `titel.gd`:

```gdscript
extends Control

# Das Titelbild, zugleich die Optionen. Hoch und runter wählt, links und rechts ändert, OK startet.

const WELT = "res://welt.tscn"
const ERKLAERUNG = {
	"Spielen": "Überlebe fünf Minuten. Deine Waffen feuern von selbst.",
	"Musik": "Links und rechts: leiser und lauter.",
	"Beben": "Das Bild wackelt, wenn Gegner dich beißen.",
	"Brummen": "Der Controller brummt, wenn Gegner dich beißen.",
	"Vollbild": "Im Fenster oder auf dem ganzen Bildschirm.",
}

var eintraege: Array[String] = ["Spielen", "Musik", "Beben", "Brummen", "Vollbild"]
var auswahl := 0


func _ready() -> void:
	Musik.spielen(Musik.TITEL)
	if OS.has_feature("web"):
		eintraege.erase("Vollbild")   # im Browser gibt es dafür F11
	anzeigen()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hoch"):
		auswahl = posmod(auswahl - 1, eintraege.size())
	elif Input.is_action_just_pressed("runter"):
		auswahl = posmod(auswahl + 1, eintraege.size())
	elif Input.is_action_just_pressed("links"):
		aendern(-1)
	elif Input.is_action_just_pressed("rechts") or Input.is_action_just_pressed("ok"):
		aendern(1)
	else:
		return   # nichts gedrückt, nichts neu zu schreiben
	anzeigen()


# Den ausgewählten Eintrag eins weiter (oder eins zurück) schalten
func aendern(schritt: int) -> void:
	match eintraege[auswahl]:
		"Spielen":
			if Input.is_action_just_pressed("ok"):
				get_tree().change_scene_to_file(WELT)
			return
		"Musik":
			Optionen.musik = clampi(Optionen.musik + schritt, 0, 10)
		"Beben":
			Optionen.beben = not Optionen.beben
		"Brummen":
			Optionen.brummen = not Optionen.brummen
			if Optionen.brummen:
				Input.start_joy_vibration(0, 0.5, 0.5, 0.2)   # kurz brummen, damit man merkt, wie es sich anfühlt
		"Vollbild":
			Optionen.vollbild = not Optionen.vollbild
	Optionen.speichern()


func anzeigen() -> void:
	var werte := {
		"Musik": str(Optionen.musik),
		"Beben": "an" if Optionen.beben else "aus",
		"Brummen": "an" if Optionen.brummen else "aus",
		"Vollbild": "an" if Optionen.vollbild else "aus",
	}
	var text := ""
	for i in eintraege.size():
		var eintrag := eintraege[i]
		text += ("> " if i == auswahl else "  ") + eintrag
		if eintrag in werte:
			text += ": " + werte[eintrag]
		text += "\n"
	$Menue.text = text
	$Hinweis.text = ERKLAERUNG[eintraege[auswahl]]
```

Zuletzt: *Project Settings → Application → Run → Main Scene* → `titel.tscn`. Ab jetzt startet **F5** im Titelbild. **F6** startet weiter die Szene, die gerade offen ist. Zum Testen der Welt also `welt.tscn` öffnen und **F6** drücken.

- **Titelbild und Optionen in einem:** Beim Kerkerheld war das ein eigener Bildschirm. Hier sind es nur vier Einstellungen, die passen unter "Spielen". Ein Bildschirm weniger, und man sieht sofort, was man einstellen kann.
- **`eintraege.erase("Vollbild")`:** nimmt einen Eintrag aus der Liste. Darum ist `eintraege` eine `var`, keine `const`.
- **Kurz brummen beim Einschalten:** Wer "Brummen: an" wählt, merkt so gleich, was gemeint ist.

**Zurück zum Titelbild:** Bisher kommt man aus der Welt nicht mehr heraus. In `ende.gd` eine Konstante oben:

```gdscript
const TITEL = "res://titel.tscn"
```

Und `_process()` wird zu:

```gdscript
func _process(_delta: float) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("ok"):
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("pause"):
		get_tree().paused = false
		get_tree().change_scene_to_file(TITEL)
```

In `welt.tscn` bei `Ende/Kasten/Hinweis` der Text: `OK: nochmal   Start: Titelbild`. Die Aktion `pause` hast du schon in Kapitel 1 angelegt: **Esc** und der **Start**-Knopf.

### 10.8 Beben und Brummen fragen

In `held.gd`, in `_physics_process()`, die letzten Zeilen:

```gdscript
	if Optionen.beben:
		$Camera2D.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * staerke * BEBEN_PIXEL
	if staerke > 0.0 and Optionen.brummen:
		Input.start_joy_vibration(0, staerke, staerke * staerke, 0.1)
```

- **Warum nicht `beben` gleich auf 0 lassen?** Man könnte auch `beben` gar nicht erst steigen lassen. Aber dann wäre mit "Beben: aus" auch das Brummen aus, denn das hängt an `staerke`. So rechnet der Held weiter, wie stark es beben **würde**, und fragt nur bei der Ausgabe nach.

### 10.9 Das Werkzeug bleibt zu Hause

F1 bis F4 sind für dich, nicht für jemanden, der den Hordenheld im Browser spielt. Wer zufällig **F1** drückt, hat sonst 100 Gegner mehr am Hals. Und die Messwerte oben links interessieren auch niemanden außer dir.

Godot kennt zwei Arten von Export: **mit Debug** und **ohne**. Im Editor läuft das Spiel immer mit Debug. `OS.is_debug_build()` fragt, welches gerade läuft.

In `werkzeug.gd`, ganz oben in `_ready()`:

```gdscript
	if not OS.is_debug_build():
		queue_free()   # im fertigen Spiel gibt es kein Werkzeug
		return
```

Und in `_exit_tree()`, weil die Monitore dann nie angelegt wurden:

```gdscript
func _exit_tree() -> void:
	for monitor in MONITORE:
		if Performance.has_custom_monitor("Hordenheld/" + monitor):
			Performance.remove_custom_monitor("Hordenheld/" + monitor)
```

In `info.gd` wird `_process()` zu:

```gdscript
func _process(_delta: float) -> void:
	text = "Level %d" % held.level
	if not OS.is_debug_build():
		return   # die Messwerte sind nur für dich
	var physik := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000
	text += "   Gegner: %d   FPS: %d   Physik: %.1f ms" % [get_tree().get_node_count_in_group("gegner"), Engine.get_frames_per_second(), physik]
	if held.testmodus:
		text += "   TESTMODUS"
```

- **Warum `has_custom_monitor`?** `queue_free()` entfernt den Knoten, und dabei wird `_exit_tree()` trotzdem aufgerufen. Einen Monitor zu entfernen, den es nicht gibt, ist ein Fehler. Also erst fragen.
- **Für DOOM:** Genau so baut man Cheats und Debug-Menüs ein, die nur die Entwickler haben. Die meisten großen Spiele haben eine Konsole voller solcher Befehle, die im fertigen Spiel abgeschaltet ist.

### 10.10 Die Horde holt auf

Bei deinem Test mit F4 hast du die letzte Minute ganz ohne Upgrades überlebt, einfach indem du um den Klumpen herumgelaufen bist. Der Grund ist das Tempo: Ein normaler Gegner läuft 30 Pixel pro Sekunde, du 70. Wer einmal hinter dir ist, holt dich nie wieder ein. Gefährlich sind nur die, die vor dir auftauchen, und denen weichst du aus. Mehr Gegner oder dickere Gegner ändern daran nichts.

Ich habe die letzte Minute mit einem Bot nachgespielt, der stur im Kreis läuft, nur mit dem Messer. Ausweichen kann er nicht, die Zahlen taugen also nur zum Vergleichen. Schaden in 60 Sekunden:

| Was | enger Kreis | weiter Kreis |
|---|---|---|
| so wie bisher | 379 | 215 |
| alle Gegner 1,3× schneller | 2166 | 881 |
| alle 15 s ein Ring aus 60 Gegnern | 903 | 534 |
| beides, mit den Werten unten | 2782 | 1265 |

Also zwei neue Werte für die Wellen. **Tempo:** Die späten Wellen laufen schneller. **Kessel:** Eine Welle kann mit einem Ring aus Gegnern rund um den Held beginnen. Dann hilft Weglaufen nicht mehr, man muss durch.

In `welle.gd`, unter `leben_mal`:

```gdscript
@export var tempo_mal := 1.0                  # so viel mal schneller laufen die Gegner
@export var kessel := 0                       # so viele Gegner kommen am Anfang im Ring um den Held
```

In `spawner.gd` bei den Variablen:

```gdscript
var tempo_mal := 1.0
```

In `_process()`, wo die nächste Welle anfängt, unter `leben_mal = ...`:

```gdscript
		tempo_mal = wellen[welle_nr].tempo_mal
```

Und am Ende dieses `if`-Blocks, unter dem Elite-Gegner:

```gdscript
		einkesseln(wellen[welle_nr].kessel)
```

In `einsetzen()` werden die letzten drei Zeilen (`position`, `leben`, `add_child`) zu einer einzigen:

```gdscript
	aufstellen(gegner, get_viewport().get_camera_2d().get_screen_center_position() + (minf(tx, ty) + ABSTAND) * alpha)
```

Und zwei neue Funktionen unter `einsetzen()`:

```gdscript
# Ein Ring aus Gegnern rund um den Held, überall knapp hinter dem Bildrand
func einkesseln(anzahl: int) -> void:
	var held: Node2D = get_tree().get_first_node_in_group("held")
	var radius := get_viewport_rect().size.length() / 2 + ABSTAND   # die halbe Bildschirmdiagonale reicht bis in jede Ecke
	# nur die erste Sorte der Welle: Fledermäuse wären viel früher da, und der Ring hätte Lücken
	var szene := wellen[welle_nr].gegner[0]
	for i in anzahl:
		aufstellen(szene.instantiate(), held.global_position + Vector2.from_angle(TAU * i / anzahl) * radius)


# Der Gegner kommt an seinen Platz, mit den Werten der Welle
func aufstellen(gegner: Node2D, ort: Vector2) -> void:
	gegner.position = ort
	gegner.leben = ceili(gegner.leben * leben_mal)
	gegner.tempo *= tempo_mal
	add_child(gegner)
```

Zuletzt die Werte in den Wellen, im Inspector:

| Welle | Tempo mal | Kessel |
|---|---|---|
| 5 | 1.1 | 40 |
| 6 | 1.2 | 60 |
| 7 | 1.3 | 80 |

- **`aufstellen()`:** Zwei Stellen brauchen jetzt dieselben Zeilen: Position, Leben, Tempo, `add_child`. Statt sie zweimal zu schreiben, gibt es eine Funktion. Bekommen die Wellen später noch einen Wert, zum Beispiel `schaden_mal`, änderst du nur eine Stelle.
- **`size.length() / 2`:** Die Länge des Vektors (384, 216) ist die Bildschirmdiagonale. Die Hälfte davon reicht von der Mitte bis in jede Ecke. Ein Kreis mit diesem Radius liegt also überall außerhalb des Bildes. Weil die Kamera ein Stück vorausschaut, kann der Ring in einer Ecke kurz zu sehen sein. Das stört nicht, es warnt sogar.
- **`TAU * i / anzahl`:** verteilt die Gegner gleichmäßig auf den ganzen Kreis. `TAU` ist eine volle Umdrehung.
- **Der Zyklop wird auch schneller.** Er kommt über `einsetzen()`, und damit über `aufstellen()`. In Welle 7 läuft er 26 statt 20.
- **„Flinke Füße“ lohnt sich jetzt.** Fledermäuse fliegen in Welle 7 mit 65 Pixeln pro Sekunde, fast so schnell wie du. Mit drei Stufen läufst du 93 und bist ihnen wieder davon.

Die Werte sind nur mit dem Bot gemessen, nicht gespielt. Ob die fünf Minuten jetzt richtig schwer sind, zeigt nur ein ganzer Durchlauf mit Upgrades. Ist es zu viel, dreh im Inspector an `tempo_mal` und `kessel`, Code musst du dafür nicht ändern.

### 10.11 Ab ins Web

Wie beim Kerkerheld (Kapitel 14.8):

1. In `07-hordenheld` einen Ordner **`web`** mit einer leeren **`.gdignore`** darin.
2. *Project → Export → Add… → Web*: **Export Path** `web/index.html`, **Thread Support** aus.
3. **Export Project**, **Export With Debug** ausschalten.
4. Im Ordner `games`:

```bash
python -m http.server 8000
```

Dann `http://localhost:8000/07-hordenheld/web/` öffnen.

- **Die Größe:** `index.pck`, also dein ganzes Spiel mit Musik, ist gut 500 KB groß. Godot packt die Musik beim Import zusammen. `index.wasm` ist wie immer die Engine, knapp 40 MB.
- **Erst ein Tastendruck, dann Ton:** Wie beim Kerkerheld setzt die Titelmusik erst mit dem ersten Tastendruck ein. Das ist kein Fehler.
- **Kein Vollbild im Menü:** Im Browser fehlt der Eintrag, dafür gibt es **F11**.
- **Oben links steht nur das Level, und F1 bringt keine Gegner:** Das ist richtig so, siehe 10.9.

**Auf die Startseite:** In `games/index.html` aus dem Hordenheld-Eintrag:

```js
  { num: '07', name: 'Hordenheld', folder: '07-hordenheld/web', color: '#e74c3c', highscoreKey: null,
    desc: 'Fünf Minuten gegen Hunderte Gegner. Die Waffen feuern von selbst, du wählst die Upgrades.' },
```

Die Beschreibung darfst du natürlich selbst schreiben. In `07-hordenheld/README.md` kommt das "_In Arbeit._" weg, dazu ein **Im Browser** bei *Starten* und bei der Steuerung **Start: zurück zum Titelbild**. Unter die Lizenzen gehört noch: "Musik: mit `musik.py` selbst erzeugt". Und in `games/README.md` wandert der Hordenheld von "In Arbeit" in die Spieltabelle.

### 10.12 Wie viele schafft der Browser?

Der ganze Hordenheld dreht sich um eine Frage: Wie viele Gegner gehen, bevor es ruckelt? Im Browser ist die Antwort eine andere. Dort läuft Godot als **WebAssembly**, und das ist langsamer als ein echtes Programm. Außerdem hast du ohne Threads exportiert, also macht ein einziger Prozessorkern alles.

Miss es selbst:
1. Exportiere noch einmal, diesmal **mit** **Export With Debug**. Dann ist das Werkzeug dabei.
2. Im Browser **Spielen**, dann **F2** und **F3**. Warte, bis keine Gegner mehr dazukommen, und lies oben links die Zahl ab.
3. Danach wieder **ohne** Debug exportieren! Sonst hat jeder im Netz deine F-Tasten.

Bei mir sind **F1 bis F4** im Browser beim Spiel angekommen, auch **F3**, mit dem der Browser sonst die Suche öffnet. Godot fängt die Tasten ab, solange man ins Spiel geklickt hat. Eine verlässliche Zahl habe ich nicht: Mein Browser lief im Hintergrund und hat das Spiel dabei stark gebremst. Darum bist du dran.

Vergleich mit dem Editor: F3 schafft dort bei dir über 1500 Gegner. Wie viele sind es im Browser? Schreib die Zahl in deine Antworten. Und überleg: Reicht das für Welle 7, oder sollte die Web-Version weniger Gegner schicken?

### 10.13 Brummen im Browser

Im Browser brummt der Controller nicht. Das liegt nicht an deinem Code: Godot 4.7 hat für den Browser schlicht keinen Code zum Vibrieren. Ich habe im Export nachgeschaut, `index.js` fragt den Browser nur nach Knöpfen und Sticks. `Input.start_joy_vibration()` tut dort einfach nichts.

Der Browser selbst kann es aber, zumindest Chrome und Edge. Godot bietet dafür eine Hintertür: **`JavaScriptBridge.eval()`** führt ein Stück JavaScript im Browser aus, also in der Sprache, in der du Ballwechsel bis Weltraumsteine geschrieben hast.

Damit Held und Titelbild das nicht beide wissen müssen, kommt es an eine Stelle: in die Optionen. Die wissen sowieso schon, ob Brummen an ist. In `optionen.gd` ganz unten:

```gdscript
# Den Controller brummen lassen, wenn es eingeschaltet ist. schwach und stark: 0 bis 1, dauer in Sekunden.
func brummen_lassen(schwach: float, stark: float, dauer: float) -> void:
	if not brummen:
		return
	if not OS.has_feature("web"):
		Input.start_joy_vibration(0, schwach, stark, dauer)
		return
	# Im Browser kann Godot das nicht. Darum fragen wir den Browser selbst, in seiner Sprache: JavaScript.
	JavaScriptBridge.eval("""
		for (const pad of navigator.getGamepads()) {
			if (pad && pad.vibrationActuator) {
				pad.vibrationActuator.playEffect("dual-rumble",
					{duration: %d, weakMagnitude: %f, strongMagnitude: %f});
			}
		}
	""" % [dauer * 1000, schwach, stark])
```

In `held.gd` werden die beiden Brumm-Zeilen aus 10.8 zu:

```gdscript
	if staerke > 0.0:
		Optionen.brummen_lassen(staerke, staerke * staerke, 0.1)
```

Und in `titel.gd`, beim Einschalten:

```gdscript
				Optionen.brummen_lassen(0.5, 0.5, 0.2)   # kurz brummen, damit man merkt, wie es sich anfühlt
```

- **`"""` drei Anführungszeichen:** ein Text über mehrere Zeilen. Das JavaScript steht so lesbar da, wie man es auch in einer `.js`-Datei schreiben würde.
- **`%d` und `%f`:** Die Werte kommen mit `%` in den Text, wie bei der Uhr. Der Browser will die Dauer in Millisekunden, darum `dauer * 1000`.
- **Was das JavaScript macht:** `navigator.getGamepads()` liefert alle Controller, die der Browser kennt. Leere Plätze sind `null`, darum `pad &&`. Hat ein Controller einen `vibrationActuator`, also einen Motor, spielt er einen Effekt: `"dual-rumble"` heißt zwei Motoren, ein schwacher und ein starker. Das ist dasselbe wie die beiden Zahlen bei `start_joy_vibration()`.
- **Warum alle Controller?** Godot zählt die Controller anders als der Browser. Controller 0 bei Godot muss nicht Platz 0 im Browser sein. Bei einem Spiel für einen Spieler ist „alle“ einfach und richtig.
- **`stop_joy_vibration()` in `feiern()`** wirkt im Browser auch nicht. Das macht nichts: Jedes Brummen dauert nur 0,1 Sekunden und hört von selbst auf.
- **Erst drücken, dann brummen:** Der Browser zeigt der Seite einen Controller erst, wenn auf ihm ein Knopf gedrückt wurde. Wer nur mit der Tastatur ins Titelbild kommt, bekommt kein Brummen, bis er einmal den Controller benutzt.
- **Nicht jeder Browser kann das.** Chrome und Edge ja. Firefox konnte es zuletzt nicht, dort passiert einfach nichts, ohne Fehler.

Ich habe das im Browser ausprobiert: Es gibt keine Fehler, und das JavaScript läuft. Einen Controller hatte ich nicht, **ob es wirklich brummt, merkst nur du**.

### 10.14 Ausprobieren

- [ ] **F5:** Das Titelbild mit Musik. Hoch und runter wandert der Pfeil, unten steht die passende Erklärung.
- [ ] Musik leiser und lauter: Man hört es sofort. Auf 0 ist sie weg.
- [ ] Brummen ausschalten und wieder an: Beim Einschalten brummt der Controller kurz.
- [ ] Vollbild an und aus.
- [ ] Spiel beenden und neu starten: Alle Einstellungen sind noch da.
- [ ] **Spielen:** Die Titelmusik blendet aus, die Kampfmusik ein. Beim Level-Up läuft sie weiter.
- [ ] Beben aus: Das Bild steht still, auch wenn zehn Gegner beißen. Der Controller brummt trotzdem. Und umgekehrt.
- [ ] **F2**, **F4** bis `1:00`: Der Endspurt beginnt.
- [ ] Bei `0:00`: Stille, die Horde zerplatzt, der Held bleibt stehen und hüpft. Er hüpft auch hinter "Gewonnen!" weiter.
- [ ] **Start** auf dem Ende-Bildschirm: zurück zum Titelbild, mit Titelmusik.
- [ ] Game Over und sofort **OK**: Die Kampfmusik ist wieder da.
- [ ] Die Äxte schubsen die Gegner von dir weg, egal von welcher Seite sie kommen.
- [ ] **F2**, **F4** bis `3:00`: Ein Ring aus 40 Spinnen zieht sich um dich zusammen. Bei `2:00` und `1:00` kommen größere Ringe, und die Gegner sind schneller.
- [ ] Im Browser: Musik nach dem ersten Tastendruck, kein "Vollbild" im Menü, kein F1, oben links nur das Level.
- [ ] Im Browser mit Controller: Lass dich beißen, der Controller brummt. Brummen aus: Ruhe.
- [ ] Die Startseite zeigt den Hordenheld, und ein Klick startet ihn.

### 10.15 Was ist neu?

- **Ein Tween für immer:** `set_loops()` ohne Zahl. Er darf nur nicht 0 Sekunden lang sein.
- **Ein Tween in der Pause:** `set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)`.
- **Jeder hört selbst aufs Signal:** Spawner, Ende-Bildschirm und Held verbinden sich mit `abgelaufen`, ohne voneinander zu wissen.
- **Wünschen statt nachschauen:** `ziel` merkt sich, was laufen soll. Das ist sicherer als zu fragen, was gerade läuft.
- **Einmal schreiben statt zweimal:** `aufstellen()` macht für jeden neuen Gegner dasselbe, egal woher er kommt.
- **Ein Kreis aus Winkeln:** `Vector2.from_angle(TAU * i / anzahl)` verteilt Dinge gleichmäßig rundherum.
- **Musik hängt an den Daten:** Die letzte Welle bringt den Endspurt, egal wie viele Wellen es gibt.
- **`JavaScriptBridge.eval()`:** Was Godot im Browser nicht kann, fragt man den Browser selbst, in JavaScript.
- **`OS.is_debug_build()`:** Werkzeuge und Messwerte nur für dich.
- **Ein Titelbild als Hauptszene:** *Main Scene* in den Project Settings. **F5** startet dort, **F6** die offene Szene.

Fertig! Committen und Bescheid geben. 🎉

### Übungsaufgaben zu Kapitel 10

1. **Der Rekord im Titelbild (leicht):** Dein Rekord steht nur auf dem Ende-Bildschirm. Zeig ihn auch im Titelbild, zum Beispiel unter "HORDENHELD": "Rekord: 1234 Monster". Gibt es noch keinen, steht dort nichts. Das Laden kennst du schon aus `ende.gd`. Muss das Titelbild die Datei auch speichern können? 🏆
2. **Eine Pause (mittel):** **Start** im Spiel hält alles an und zeigt ein kleines Menü: "Weiter", "Musik", "Beben", "Brummen", "Zum Titelbild". Tipp: Bau es wie den Ende-Bildschirm, ein CanvasLayer mit **Process Mode** Always. Was passiert, wenn du im Level-Up-Menü **Start** drückst? Und auf dem Ende-Bildschirm? Dort ist **Start** ja schon "Titelbild". ⏸️
3. **Eine Fanfare zum Sieg (mittel):** Nach dem Sieg ist es still. Kopier `fanfare.py` aus dem Kerkerheld, lass es laufen und spiel `fanfare.wav` ab, wenn die Horde zerplatzt ist. Wo baust du den AudioStreamPlayer ein, damit er auch in der Pause spielt? Und auf welchen Bus gehört er: `Musik` oder `Master`? 🎺
4. **Tausend Treffer, ein Geräusch (schwer):** Jeder Treffer soll ein kurzes "Plopp" machen. Ein AudioStreamPlayer in jedem Gegner wäre einfach, aber dann spielen bei 50 Treffern pro Sekunde 50 Geräusche auf einmal, und das klingt wie ein Rauschen. Bau **einen** Player in die Welt und gib ihm bei **Max Polyphony** zum Beispiel 4. Was passiert, wenn ein fünftes Plopp kommt, während noch vier laufen? Ein kurzes Geräusch kannst du dir mit einem kleinen Python-Skript bauen, so wie `fanfare.py`. Miss danach mit F3: Kostet das Plopp etwas? 🔊
5. **Für alle (leicht, freiwillig):** Lad den Hordenheld auf 🆓 **itch.io** hoch, wie den Kerkerheld (Kapitel 14, Übung 5). Diesmal ohne Touch-Knöpfe, also schreib dazu: "Mit Controller oder Tastatur." 🎮

### Antworten zu Kapitel 10
Im Browser hat F3 bei 1300+ Gegner gestoppt
1. Nein, auf dem Titelbild kann man keine neue Rekorde aufstellen.
2. Im Level-Up passiert nichts, weil der Knoten vom Helden nicht läuft, der den Pausenbildschirm einschalten kann. Beim Ende feiert der Held schon und kommt nicht bis zur bearbeitung der "pause" Taste: return steht ganz am Anfang von _physics_process.
3. Es hängt gut im "ende" Knoten, der läuft ja weiter. Der Bus soll Musik sein, damit die Lautstärke stimmt.
4. Godot Hilfe sinngemäß: die älteren Plopps werden abgebrochen, wenn neue kommen. Gemessen habe ich nichts, plopp.wav ist nur 3KB groß. 
