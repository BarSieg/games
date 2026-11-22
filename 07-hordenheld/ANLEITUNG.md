# Hordenheld – Schritt-für-Schritt-Anleitung

Überleben gegen Hunderte Gegner auf einmal, im Stil von Vampire Survivors. Du steuerst nur die Laufrichtung. Die Waffen feuern von selbst, besiegte Gegner lassen Edelsteine fallen, und mit jedem Level wählst du ein Upgrade. Wer eine bestimmte Zeit überlebt, hat gewonnen.

Wie immer baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Vieles kennst du aus dem Kerkerheld: CharacterBody2D, Kollisionsebenen, Autoloads, Signale, Tweens, Optionen, Musik, Web-Export. Darum geht es schnell voran. Neu ist vor allem eine Frage: **Was passiert, wenn sehr viel gleichzeitig los ist?** Dafür lernst du den **Profiler**, **Object Pooling** und ein paar Tricks, die DOOM später genauso braucht. Dazu ein **Upgrade-System** und viel **Game Feel**: Treffer müssen sich gut anfühlen.

Gespielt wird mit dem Controller. Die Tastatur geht natürlich auch.

**Geplante Kapitel:**
1. Projekt, Held und eine Wiese ohne Ende ← *du bist hier*
2. Gegner kommen von überall
3. Die Waffe schießt von selbst
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
