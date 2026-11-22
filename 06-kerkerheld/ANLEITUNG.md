# Kerkerheld – Schritt-für-Schritt-Anleitung

Ein Dungeon von oben, nach dem Vorbild des ersten Dungeons aus The Legend of Zelda. Wie bei Hüpfheld baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Vieles kennst du schon: TileMapLayer, Kollisionsebenen, Tweens, Autoload, HUD, Szenenwechsel, Web-Export. Dafür geht es in den ersten Kapiteln schneller. Neu sind vor allem **State Machines**, **Räume**, ein **Inventar** und **Speichern in eine Datei**.

**Geplante Kapitel:**
1. Projekt, Grafiken und der erste Raum ✔
2. Laufen in vier Richtungen, mit Animation ✔
3. Das Schwert: Angriff, Hitbox und Hurtbox ✔
4. Gegner mit State Machine: umherlaufen, verfolgen, angreifen ✔
5. Mehrere Räume: Die Kamera schaltet um wie im Original, Monster bleiben in ihrem Raum ✔
6. Herzen, Schaden und die Anzeige oben ✔
7. Schlüssel, Truhen und verschlossene Türen (Inventar), Masterschlüssel für den Bossraum, dazu Karte und Kompass ✔
8. Dialoge: Schilder, ein alter Mann, Münzen und ein Händler ✔
9. Die Welt merkt sich alles: Speichern und Laden ✔
10. Titelbild und zwei Spielarten: Normal und Iron Man ✔
11. Der Boss, Spielzeit, Erkundung und ein Abspann ✔
12. Rätsel und Fallen: Schalter, Gitter, Felsbrocken, Wasserspeier, Klingenfalle ✔
13. Optionen und eine zweite Sprache: schräg laufen, Deutsch und Englisch ✔
14. Musik und Web-Export ✔
15. Touch-Knöpfe fürs Handy ← *du bist hier*

---

## Kapitel 1: Projekt, Grafiken und der erste Raum

### 1.1 Das Projekt anlegen

Im Godot-Projekt-Manager → **Create**:

| Feld | Wert |
|---|---|
| Project Name | `Kerkerheld` |
| Project Path | `...\games\06-kerkerheld` (der Ordner mit dieser Anleitung) |
| Renderer | **Compatibility** (für den Web-Export) |
| Version Control Metadata | **Git** |

### 1.2 Pixel-Art-Einstellungen

Wie bei Hüpfheld, nur mit anderen Zahlen. Ein Raum im Original ist **16 × 11 Kacheln** groß, eine Kachel hat 16 Pixel. Das sind 256 × 176 Pixel. Darüber kommen 48 Pixel für die Anzeige (Herzen, Schlüssel, Karte). *Project → Project Settings* (mit **Advanced Settings**):

| Einstellung | Wert | Warum |
|---|---|---|
| Display → Window → **Viewport Width / Height** | `256` × `224` | 176 Pixel Raum + 48 Pixel Anzeige. |
| Display → Window → **Window Width Override / Height Override** | `768` × `672` | Dreimal so groß zum Testen. |
| Display → Window → Stretch → **Mode** | `viewport` | Pixel bleiben Pixel. |
| Display → Window → Stretch → **Aspect** | `keep` | Neu! Siehe unten. |
| Display → Window → Stretch → **Scale Mode** | `integer` | Jedes Pixel gleich groß. |
| Rendering → Textures → Canvas Textures → **Default Texture Filter** | `Nearest` | Keine Glättung. |

**Warum diesmal `keep`?** Bei Hüpfheld durfte das Bild im Browser breiter werden (`expand`), man sah dann einfach mehr vom Level. Hier ist das Bild immer genau **ein Raum**. Ein breiteres Fenster würde ein Stück vom Nachbarraum zeigen. Mit `keep` bleibt das Bild 256 × 224, und der Rest des Fensters wird schwarz.

### 1.3 Die Kollisionsebenen benennen

Gleich am Anfang, damit du später nicht raten musst. *Project Settings → Layer Names → 2D Physics*:

| Ebene | Name |
|---|---|
| 1 | `Welt` |
| 2 | `Held` |
| 3 | `Gegner` |

Weitere kommen dazu, wenn wir sie brauchen (das Schwert in Kapitel 3).

### 1.4 Die Grafiken von Kenney 🆓

Diesmal malst du die Spielfigur nicht selbst. Das Kenney-Paket hat schon passende Helden und Monster. Wer mag, kann später trotzdem eine eigene Figur einbauen.

1. Auf kenney.nl das Paket **Tiny Dungeon** herunterladen (CC0, kostenlos).
2. Aus dem Ordner `Tilemap` die Datei **`tilemap_packed.png`** ins FileSystem ziehen. Die Kacheln sind **16 × 16** Pixel groß.
3. `License.txt` in einen Unterordner `kenney/` kopieren.

Auf dem Blatt sind Wände, Böden, Türen, Truhen, Schlüssel, Tränke, Waffen, Helden und Monster. Fast alles, was wir in diesem Projekt brauchen.

### 1.5 Die Steuerung

*Project Settings → Input Map*. Wie bei Hüpfheld, nur mit vier Richtungen:

| Aktion | Tastatur | Xbox-Controller |
|---|---|---|
| `links` | Links, A | D-Pad links, linker Stick nach links (Axis 0 −) |
| `rechts` | Rechts, D | D-Pad rechts, linker Stick nach rechts (Axis 0 +) |
| `hoch` | Hoch, W | D-Pad hoch, linker Stick nach oben (Axis 1 −) |
| `runter` | Runter, S | D-Pad runter, linker Stick nach unten (Axis 1 +) |
| `angriff` | Leertaste, J | A |

`angriff` brauchen wir erst in Kapitel 3, aber dann ist alles an einem Ort.

### 1.6 Der Raum

1. *Scene → New Scene* → **2D Scene** → Root umbenennen in `Raum`.
2. Kind hinzufügen: `TileMapLayer` → umbenennen in `Boden`. **Tile Set** → **New TileSet** → **Tile Size** `16, 16`. Das Kachelblatt in den TileSet-Tab ziehen → **Yes**.
3. **Gleich speichern:** Im Inspector beim TileSet auf den Pfeil → **Save As** → `kacheln.tres`. Das kennst du aus Kapitel 9 von Hüpfheld: So können alle Räume dasselbe TileSet benutzen.
4. Im TileSet: **Physics Layers** → **Add Element**. Bei Physics Layer 0 ist **Collision Layer** schon `1` (Welt). Dann mit **Paint → Physics Layer 0** alle Wandkacheln anklicken. Böden bekommen keine Kollision.
5. Eine zweite `TileMapLayer` namens `Waende` anlegen und bei **Tile Set** über den Pfeil → **Load** → `kacheln.tres` laden.
6. Malen: Auf `Boden` den Fußboden, auf `Waende` die Wände drumherum. Der Raum ist **16 × 11 Kacheln** groß und beginnt oben links bei (0, 0). Lass in der Mitte der oberen Wand eine Lücke von 2 Kacheln für eine Tür.
7. Kind von `Raum`: `Camera2D`.
   - **Anchor Mode** → `Fixed Top Left`. Die Kamera zeigt jetzt ab ihrer Position nach rechts unten, nicht um die Position herum.
   - **Position** → `0, -48`. So bleiben oben 48 Pixel für die Anzeige frei, und der Raum füllt genau den Rest.
8. Speichern als `raum.tscn`.

Warum zwei Ebenen? Wände und Boden getrennt zu malen, ist praktisch. Du kannst den Boden einmal flächig füllen und die Wände darüber setzen, ohne den Boden zu zerstören.

### 1.7 Der Held

1. *Scene → New Scene* → **Other Node** → `CharacterBody2D` → umbenennen in `Held`.
2. Im Inspector: **Motion Mode** → `Floating`. Der Standard `Grounded` ist für Plattformer gedacht: Er unterscheidet zwischen Boden, Wand und Decke. Von oben gesehen gibt es keinen Boden, alles ist Wand. Mit `Floating` gleitet der Held an jeder Wand gleich gut entlang.
3. **Collision → Layer** nur `2` (Held), **Mask** nur `1` (Welt).
4. Kinder:
   - `Sprite2D` → `Bild`. **Texture** = `tilemap_packed.png`, **Hframes** `12`, **Vframes** `11`. Dann bei **Frame** durchklicken, bis du einen Helden findest, der dir gefällt.
   - `CollisionShape2D` → **New RectangleShape2D**, **Size** `10, 6`, **Position** `0, 5`.

   Warum so klein und so weit unten? Von oben gesehen zählen nur die **Füße**. Der Kopf darf ruhig ein Stück über die Wand oberhalb ragen, so sieht es aus, als stünde der Held davor. Das machen fast alle Top-Down-Spiele so.
5. Skript anhängen, diesmal mit **Template: Empty**. Die Plattformer-Vorlage hilft hier nicht, es gibt keine Schwerkraft und keinen Sprung:

```gdscript
extends CharacterBody2D


const SPEED = 80.0


func _physics_process(_delta: float) -> void:
	var richtung := Input.get_vector("links", "rechts", "hoch", "runter")
	velocity = richtung * SPEED
	move_and_slide()

	# Nach links und rechts schauen
	if richtung.x != 0:
		$Bild.flip_h = richtung.x < 0
```

6. Speichern als `held.tscn`.

Schaut deine Figur auf dem Kachelblatt nach links statt nach rechts? Dann dreh den Vergleich um: `richtung.x > 0`.

### 1.8 Ausprobieren

1. In `raum.tscn` den Held einsetzen und mitten in den Raum stellen.
2. **F5** → Hauptszene: `raum.tscn` → **Select Current**.
3. Laufen in alle Richtungen, auch schräg.

Der Held sollte an den Wänden stoppen und schräg an ihnen entlanggleiten. Lauf an die Wand oben: Sein Kopf ragt ein Stück über die Wand, die Füße bleiben davor. So sieht es aus, als stünde er vor der Wand. Durch die Lücke oben kommt er hinaus ins Leere. Darum kümmern wir uns in Kapitel 5.

### 1.9 Was ist neu?

- **`Input.get_vector()`**: Liest vier Aktionen auf einmal und liefert einen Vektor. Wichtig: Schräg ist der Vektor nicht (1, 1), sondern ungefähr (0,7, 0,7). Er hat immer höchstens die **Länge 1**. Erinnerst du dich an Weltraumsteine? Ohne das wäre der Held schräg um 41 % schneller.
- **Keine Schwerkraft:** `velocity` wird jedes Bild komplett neu gesetzt, nicht nur `velocity.x`.
- **Motion Mode Floating** und eine Kollisionsform nur für die Füße.
- **Fixed Top Left:** Die Kamera folgt diesmal niemandem. Sie steht still und zeigt einen Raum.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 1

1. **Schräg zu schnell (leicht):** Ersetz `get_vector` testweise durch `Vector2(Input.get_axis("links", "rechts"), Input.get_axis("hoch", "runter"))`. Lauf schräg durch den Raum und vergleich. Wie lang ist der Vektor schräg? Was macht `.normalized()`? Danach wieder zurück zu `get_vector`.
2. **Alle Türen (leicht):** Mach auch in die anderen drei Wände eine Tür-Lücke, jeweils in der Mitte. Die brauchen wir in Kapitel 5 für die Nachbarräume.
3. **Anlaufen oder nicht (mittel):** Bei Hüpfheld hat der Held Zeit gebraucht, um schnell zu werden. Probier es hier auch: `velocity = velocity.move_toward(richtung * SPEED, BESCHLEUNIGUNG * delta)` mit einer Konstante `BESCHLEUNIGUNG`. `move_toward` gibt es also auch für Vektoren! Fühlt es sich für ein Zelda besser an? (Im Original läuft Link sofort los und bleibt sofort stehen.)
4. **Davor und dahinter (mittel):** Bau eine Szene `Saeule`: ein `StaticBody2D` mit einem `Sprite2D` (eine Säule oder Statue vom Kachelblatt) und einer kleinen Kollisionsform unten, wie beim Held. Stell zwei Säulen in den Raum. Läuft der Held oberhalb einer Säule vorbei, soll er **dahinter** verschwinden. Tipp: Bei `Raum` im Inspector **Ordering → Y Sort Enabled** einschalten. Dann malt Godot alles mit kleinerem y zuerst. Was musst du beim Held und bei der Säule beachten, damit die Füße die Position bestimmen? (Tipp: **Offset** am Sprite.)

### Antworten zu Kapitel 1

1. Wie erwartet, läuft der Held schräg schneller. Mit `.normalized()` ist alles wie vorher.
3. Ein paar Pixel weiterzulaufen, sieht besser aus. Bei `BESCHLEUNIGUNG = 1` läuft der Held wie auf Eis!

---

## Kapitel 2: Laufen in vier Richtungen, mit Animation

Der Held läuft, aber er gleitet steif wie eine Schachfigur über den Boden. Und für das Schwert in Kapitel 3 müssen wir wissen, **wohin er schaut**. Außerdem bekommt er eine kleine Hilfe an Türkanten, die fast jedes Top-Down-Spiel heimlich eingebaut hat.

### 2.1 Beschleunigung mit `delta`

Erst eine Korrektur an deiner Übung 3. Du hast geschrieben:

```gdscript
velocity = velocity.move_toward(richtung * SPEED, BESCHLEUNIGUNG)
```

Das funktioniert, aber `BESCHLEUNIGUNG` ist so „Pixel pro Bild“, nicht „Pixel pro Sekunde“. Weil `_physics_process` immer 60-mal pro Sekunde läuft, fällt das nicht auf. Ändert man aber mal die Physik-Rate (Project Settings → Physics → Common → **Physics Ticks per Second**), läuft der Held plötzlich anders. Mit `delta` bleibt es immer gleich. Aus 20 pro Bild werden 20 × 60 = **1200 pro Sekunde**:

```gdscript
const BESCHLEUNIGUNG = 1200.0   # Pixel pro Sekunde², volle Geschwindigkeit nach 1/15 Sekunde

func _physics_process(delta: float) -> void:
	var richtung := Input.get_vector("links", "rechts", "hoch", "runter")
	velocity = velocity.move_toward(richtung * SPEED, BESCHLEUNIGUNG * delta)
```

Aus `_delta` wird dabei `delta`: Der Unterstrich sagt Godot nur „den Parameter benutze ich nicht“, damit es nicht warnt.

### 2.2 Die Blickrichtung

Der Held läuft in acht Richtungen, aber er **schaut** nur in vier: hoch, runter, links, rechts. Das Schwert schlägt später in genau diese Richtung. Läuft er schräg, gewinnt die stärkere Richtung.

Neue Variable oben und eine kleine Funktion:

```gdscript
var blick := Vector2.DOWN   # wohin der Held schaut, nur vier Richtungen


# Aus einer beliebigen Richtung wird eine der vier: die stärkere Achse gewinnt
func vier_richtungen(v: Vector2) -> Vector2:
	if abs(v.x) > abs(v.y):
		return Vector2(sign(v.x), 0)
	return Vector2(0, sign(v.y))
```

In `_physics_process` nach `move_and_slide()`:

```gdscript
	if richtung != Vector2.ZERO:
		blick = vier_richtungen(richtung)
		queue_redraw()
```

Warum `if richtung != Vector2.ZERO`? Lässt man los, soll der Held weiter dahin schauen, wohin er zuletzt gelaufen ist, und nicht nach (0, 0).

### 2.3 Die Blickrichtung sichtbar machen

Die Figur von Kenney hat nur ein Bild, sie kann nicht nach oben oder unten schauen. Bis das Schwert kommt, zeigt ein kleiner Punkt, wohin der Held schaut. Jeder Node, den man sieht, kann sich mit `_draw()` selbst bemalen:

```gdscript
# Vorläufig: ein Punkt zeigt die Blickrichtung. In Kapitel 3 übernimmt das das Schwert.
func _draw() -> void:
	draw_rect(Rect2(blick * 10 - Vector2(1, 1), Vector2(2, 2)), Color.WHITE)
```

`_draw()` wird nicht jedes Bild aufgerufen, sondern nur einmal. Godot merkt sich das Gemalte. Deshalb steht oben `queue_redraw()`: „Bitte beim nächsten Bild neu malen.“

### 2.4 Watscheln mit dem AnimationPlayer

Bei Hüpfheld hattest du für jede Bewegung eigene Bilder (AnimatedSprite2D). Hier gibt es nur ein Bild. Wir bewegen es stattdessen: ein bisschen hüpfen und hin und her kippen. Das macht der **AnimationPlayer**. Er kann **jede Eigenschaft** jedes Nodes über die Zeit verändern: Position, Drehung, Farbe, sogar Funktionen aufrufen. Ein Tween ist für eine Bewegung, die man im Code anstößt. Der AnimationPlayer ist für Abläufe, die man im Editor gestaltet und immer wieder abspielt.

1. In `held.tscn`: Kind von `Held` → `AnimationPlayer`.
2. Unten öffnet sich der Tab **Animation**. Dort auf **Animation → New** → Name `laufen`.
3. Rechts in der Leiste des Tabs: Länge auf `0.4` Sekunden stellen (das Feld mit der Uhr) und **Loop** einschalten (die Pfeile im Kreis).
4. **Keyframes setzen:** Wähl den Node `Bild`. Im Inspector steht jetzt neben jeder Eigenschaft ein kleiner **Schlüssel**. Ein Klick darauf setzt an der aktuellen Stelle der Zeitleiste einen Keyframe. Beim ersten Mal fragt Godot nach einem **RESET-Track** → **Create**. Der merkt sich die Ausgangswerte.

   Setz diese Keyframes (die Zeitleiste mit dem blauen Strich verschieben, Wert im Inspector ändern, Schlüssel klicken):

   | Zeit | Position | Rotation |
   |---|---|---|
   | 0.0 | `0, 0` | `-6` |
   | 0.1 | `0, -1` | |
   | 0.2 | `0, 0` | `6` |
   | 0.3 | `0, -1` | |
   | 0.4 | `0, 0` | `-6` |

   Zwei kleine Hüpfer pro Durchgang, einer pro Fuß, und dabei kippt er von links nach rechts.
5. Zweite Animation: **Animation → New** → `stehen`. Bei 0.0 einen Keyframe für Position `0, 0` und einen für Rotation `0`. Länge und Loop sind hier egal.
6. Ausprobieren: Oben im Tab auf **Play** drücken. Der Held watschelt schon im Editor.

Im Skript, wieder in `_physics_process`:

```gdscript
	if richtung != Vector2.ZERO:
		blick = vier_richtungen(richtung)
		queue_redraw()
		$AnimationPlayer.play("laufen")
	else:
		$AnimationPlayer.play("stehen")
```

`play()` jedes Bild aufzurufen ist kein Problem. Läuft die Animation schon, macht Godot einfach weiter und fängt nicht von vorn an.

### 2.5 Hilfe an Ecken

Probier mal: Stell dich unter die Tür-Lücke, aber ein paar Pixel zu weit links, und lauf nach oben. Der Held bleibt an der Kante hängen und du musst nachkorrigieren. Das nervt, vor allem mit dem Controller.

Fast jedes Top-Down-Spiel hilft hier heimlich: Stößt der Held gerade gegen eine Kante, und ein paar Pixel daneben wäre frei, dann rutscht er von selbst zur Seite. Wie Coyote Time bei Hüpfheld merkt man es nicht, man vermisst es nur, wenn es fehlt.

```gdscript
const ECKEN_HILFE = 6         # so viele Pixel neben einer Lücke hilft der Held noch nach
const ECKEN_TEMPO = 60.0      # so schnell rutscht er dabei zur Seite


# Stößt der Held gerade gegen eine Kante, und daneben ist frei: zur Seite rutschen
func ecke_umrunden(richtung: Vector2, delta: float) -> void:
	# Nur wenn er gegen etwas läuft, und nur fast gerade (nicht schräg)
	if get_slide_collision_count() == 0 or min(abs(richtung.x), abs(richtung.y)) > 0.2:
		return
	var vor := vier_richtungen(richtung) * 2   # zwei Pixel nach vorn
	var seite := Vector2(vor.y, vor.x).normalized()   # quer zur Laufrichtung
	for abstand in range(1, ECKEN_HILFE + 1):
		for s: Vector2 in [seite, -seite]:
			# Wäre der Held hier, um abstand zur Seite versetzt: Käme er dann nach vorn?
			if not test_move(global_transform.translated(s * abstand), vor):
				position += s * ECKEN_TEMPO * delta
				return
```

Aufruf in `_physics_process` direkt nach `move_and_slide()`:

```gdscript
	ecke_umrunden(richtung, delta)
```

Neu daran:
- **`test_move(von, bewegung)`** probiert eine Bewegung aus, **ohne** den Held zu bewegen. Es antwortet nur: Würde er irgendwo anstoßen? Damit tastet die Funktion die Seiten ab, erst 1 Pixel daneben, dann 2 … bis 6.
- **`Vector2(vor.y, vor.x)`**: x und y vertauschen ergibt die Richtung quer dazu. Aus „hoch“ (0, −2) wird (−2, 0), also eine Seite. Die andere Seite ist das Minus davon.
- **`for s: Vector2 in [...]`**: Eine Schleife über eine kleine Liste. Das `: Vector2` sagt Godot, welcher Typ drin ist (sonst kann es den Typ nicht ableiten, wie damals bei `gegner_liste`).
- **`min(abs(richtung.x), abs(richtung.y)) > 0.2`**: Mit dem Controller ist die Richtung fast nie genau (0, −1), sondern eher (0,05, −0,98). Deshalb nicht `!= 0` prüfen, sondern „ist die schwächere Achse fast null“.

### 2.6 Das ganze Skript

```gdscript
extends CharacterBody2D


const SPEED = 80.0
const BESCHLEUNIGUNG = 1200.0   # Pixel pro Sekunde², volle Geschwindigkeit nach 1/15 Sekunde
const ECKEN_HILFE = 6           # so viele Pixel neben einer Lücke hilft der Held noch nach
const ECKEN_TEMPO = 60.0        # so schnell rutscht er dabei zur Seite

var blick := Vector2.DOWN       # wohin der Held schaut, nur vier Richtungen


func _physics_process(delta: float) -> void:
	var richtung := Input.get_vector("links", "rechts", "hoch", "runter")
	velocity = velocity.move_toward(richtung * SPEED, BESCHLEUNIGUNG * delta)
	move_and_slide()
	ecke_umrunden(richtung, delta)

	if richtung != Vector2.ZERO:
		blick = vier_richtungen(richtung)
		queue_redraw()
		$AnimationPlayer.play("laufen")
	else:
		$AnimationPlayer.play("stehen")

	# Nach links und rechts schauen
	if richtung.x != 0:
		$Bild.flip_h = richtung.x < 0


# Aus einer beliebigen Richtung wird eine der vier: die stärkere Achse gewinnt
func vier_richtungen(v: Vector2) -> Vector2:
	if abs(v.x) > abs(v.y):
		return Vector2(sign(v.x), 0)
	return Vector2(0, sign(v.y))


# Stößt der Held gerade gegen eine Kante, und daneben ist frei: zur Seite rutschen
func ecke_umrunden(richtung: Vector2, delta: float) -> void:
	# Nur wenn er gegen etwas läuft, und nur fast gerade (nicht schräg)
	if get_slide_collision_count() == 0 or min(abs(richtung.x), abs(richtung.y)) > 0.2:
		return
	var vor := vier_richtungen(richtung) * 2   # zwei Pixel nach vorn
	var seite := Vector2(vor.y, vor.x).normalized()   # quer zur Laufrichtung
	for abstand in range(1, ECKEN_HILFE + 1):
		for s: Vector2 in [seite, -seite]:
			# Wäre der Held hier, um abstand zur Seite versetzt: Käme er dann nach vorn?
			if not test_move(global_transform.translated(s * abstand), vor):
				position += s * ECKEN_TEMPO * delta
				return


# Vorläufig: ein Punkt zeigt die Blickrichtung. In Kapitel 3 übernimmt das das Schwert.
func _draw() -> void:
	draw_rect(Rect2(blick * 10 - Vector2(1, 1), Vector2(2, 2)), Color.WHITE)
```

### 2.7 Ausprobieren

- Laufen: Der Held watschelt, im Stehen steht er gerade.
- Der weiße Punkt zeigt immer in eine der vier Richtungen, auch beim Schräglaufen.
- Stell dich knapp neben die Tür-Lücke und lauf hinein: Der Held rutscht von selbst hinein. Steht er zu weit daneben (mehr als 6 Pixel), bleibt er hängen.
- Dasselbe an den Säulen: Läuft er knapp an der Kante dagegen, rutscht er drumherum.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 2

1. **Wie im Original (leicht):** Im ersten Zelda konnte Link nicht schräg laufen. Bau das ein: Bevor `velocity` berechnet wird, mach aus `richtung` mit deiner neuen Funktion eine der vier Richtungen. Wie fühlt es sich an? Was passiert, wenn du schräg drückst? Danach entscheidest du, welche Variante bleibt.
2. **Ein Schatten (leicht):** Mal in Pixelorama einen kleinen ovalen Schatten, etwa 12 × 4 Pixel, schwarz. Als `Sprite2D` namens `Schatten` an die Füße des Helden, **Modulate** mit Alpha etwa 80. Probier aus: Was passiert, wenn der Schatten in der Node-Liste unter `Bild` steht, und was, wenn darüber? Warum? Watschelt der Schatten mit?
3. **Schritte hören (mittel):** Mach mit 🆓 jsfxr ein ganz kurzes, leises Tapsen und häng es als `AudioStreamPlayer` namens `Schritt` an den Held. Schreib eine Funktion `schritt()`, die die Tonhöhe (`pitch_scale`) zufällig zwischen 0,9 und 1,1 wählt und den Ton abspielt. Im AnimationPlayer bei `laufen`: **Add Track → Call Method Track** → Node `Held` → an den Stellen 0.1 und 0.3 einen Key mit der Methode `schritt`. So passen die Schritte immer genau zu den Hüpfern. Warum die zufällige Tonhöhe?
4. **Atmen (leicht):** Im Stehen soll der Held ganz leicht atmen: `stehen` mit Loop und 1,6 Sekunden Länge, **Scale** des Bildes von `1, 1` auf `1, 1.06` und zurück. Du wirst merken, dass er dabei mit den Füßen vom Boden abhebt, weil das Bild von seiner Mitte aus wächst. Wie bekommst du die Mitte an die Füße? (Tipp: **Offset** und **Position** am Bild, wie bei der Y-Sort-Übung.)
5. **Wie viel Hilfe (leicht):** Stell `ECKEN_HILFE` testweise auf `0`, dann auf `12`. Wann fühlt es sich wie Hilfe an, wann wie Schummeln?

### Antworten zu Kapitel 2

1. Schräg laufen fühlt sich besser an. Ich möchte das (in den nächsten Kapiteln) als eine Einstellungsoption machen, so dass der Spieler selbst entscheiden kann, ob der Held schräg laufen soll oder nicht.
2. Der Schatten muss in der Node-Liste vor dem Bild stehen, sonst überdeckt er den Helden.
5. Bei 12 läuft er brav um die Säulen, wie es ein normaler Mensch auch machen würde. Aber eine Spielfigur muss an Hindernissen stecken bleiben, sonst sind es gar keine Hindernisse.

---

## Kapitel 3: Das Schwert

Jetzt bekommt der Held eine Waffe. Wie im ersten Zelda sticht er geradeaus in Blickrichtung, und solange er sticht, bleibt er stehen. Damit wir etwas zum Draufhauen haben, bauen wir einen Topf, der zerbricht.

Neu sind vor allem zwei Ideen: **Hitbox und Hurtbox**, und ein erster kleiner **Zustand** (State) für den Helden.

### 3.1 Hitbox und Hurtbox

Bisher hatte jedes Ding genau eine Kollisionsform: die Füße. Die bestimmen, wo man stehen und laufen kann. Für Kämpfe reicht das nicht:

- Die **Hitbox** ist die Fläche, die **Schaden macht**. Hier: die Klinge des Schwerts.
- Die **Hurtbox** ist die Fläche, die **Schaden bekommt**. Beim Topf ist das der ganze Topf, nicht nur sein Fuß.

Beide sind `Area2D`, also Flächen, die nichts aufhalten, sondern nur melden: „Da ist etwas in mir.“ Damit sich Hitbox und Hurtbox finden, bekommen sie eine eigene Kollisionsebene. *Project Settings → Layer Names → 2D Physics*:

| Ebene | Name |
|---|---|
| 4 | `Schwert` |

Die Hitbox **liegt** auf Ebene 4. Die Hurtbox **schaut** auf Ebene 4. Das ist dasselbe Prinzip wie bei der Münze in Hüpfheld, nur zwischen zwei Areas statt zwischen Area und Körper.

### 3.2 Das Schwert am Helden

Auf dem Kachelblatt sind bei den Frames **103 bis 107** Schwerter. Sie zeigen alle **nach oben**: Klinge oben, Griff unten. Das ist praktisch.

Der Aufbau in `held.tscn`, als Kinder von `Held`:

```
Held
├── Schatten
├── Bild
├── Schwert          (Node2D)        ← dreht sich in Blickrichtung
│   └── Klinge       (Sprite2D)      ← sticht nach vorn
│       └── Hitbox   (Area2D)
│           └── CollisionShape2D
├── CollisionShape2D
├── AnimationPlayer
└── Schritt
```

1. `Schwert`: ein einfacher **Node2D**, Position `0, 0`. Er macht nichts anderes, als sich zu drehen.
2. `Klinge`: ein **Sprite2D**, Texture `tilemap_packed.png`, Hframes `12`, Vframes `11`, ein Schwert-Frame deiner Wahl. **Offset** `0, -8`: Damit liegt der Griff am Ursprung, und die Klinge ragt nach oben. **Visible** aus.
3. `Hitbox`: eine **Area2D**. **Collision → Layer** nur `4` (Schwert), **Mask** leer. **Monitoring** aus (sie selbst muss niemanden bemerken), **Monitorable** an (sie soll bemerkt werden).
4. Deren `CollisionShape2D`: **New RectangleShape2D**, Size `4, 12`, Position `0, -9`, also da, wo die Klinge ist. **Disabled** an.

Warum zwei Nodes, `Schwert` und `Klinge`? Das ist der Trick des Kapitels:

- `Schwert` **dreht** sich in die Blickrichtung: 0° nach oben, 90° nach rechts, 180° nach unten, 270° nach links.
- `Klinge` **bewegt** sich in der Animation immer nur nach „oben“, also von `0, -4` nach `0, -8`.

Weil die Klinge ein Kind des gedrehten `Schwert` ist, heißt ihr „oben“ in Wahrheit „in Blickrichtung“. Eine einzige Animation reicht so für alle vier Richtungen.

### 3.3 Die Animation `angriff`

Im AnimationPlayer: **Animation → New** → `angriff`. Länge `0.25`, **kein** Loop.

| Zeit | Klinge: Visible | Klinge: Position | Hitbox/CollisionShape2D: Disabled |
|---|---|---|---|
| 0.0 | an | `0, -4` | aus |
| 0.05 | | `0, -8` | |
| 0.2 | | `0, -8` | an |
| 0.25 | aus | `0, -4` | |

Zuerst schießt die Klinge nach vorn, dann bleibt sie kurz stehen, dann ist sie weg. Die Hitbox ist nur so lange aktiv, wie die Klinge wirklich draußen ist.

Dazu noch drei Keys für das `Bild` bei 0.0: **Position** `0, 8`, **Rotation** `0`, **Scale** `1, 1`. Sonst friert der Held beim Zustechen mitten im Watscheln ein, schief und halb in der Luft.

Das ist die allgemeine Regel beim AnimationPlayer: **Eine Animation verändert nur, wofür sie Tracks hat.** Alles andere bleibt, wie die vorige Animation es hinterlassen hat. Merk dir das, in den Übungen wird es noch einmal wichtig.

### 3.4 Ein Zustand für den Helden

Solange der Held sticht, soll er nicht laufen. Das könnte man mit einer Variable `sticht := true/false` lösen. Wir nehmen aber gleich ein `enum`, wie bei `ZielStates` in Hüpfheld. In Kapitel 4 bekommen die Gegner genau so etwas, nur mit mehr Zuständen.

1. Alles, was bisher in `_physics_process` stand, wandert in eine neue Funktion `laufen(delta: float)`. Am Inhalt änderst du nichts.
2. Neues `_physics_process`:

```gdscript
enum Zustand { LAUFEN, ANGRIFF }

var zustand := Zustand.LAUFEN


func _physics_process(delta: float) -> void:
	match zustand:
		Zustand.LAUFEN:
			laufen(delta)
			if Input.is_action_just_pressed("angriff"):
				angreifen()
		Zustand.ANGRIFF:
			# Beim Zustechen abbremsen, nicht weiterlaufen
			velocity = velocity.move_toward(Vector2.ZERO, BESCHLEUNIGUNG * delta)
			move_and_slide()


# Zustechen in Blickrichtung, danach wieder laufen
func angreifen() -> void:
	zustand = Zustand.ANGRIFF
	$Schwert.rotation = blick.angle() + PI / 2
	$AnimationPlayer.play("angriff")
	await $AnimationPlayer.animation_finished
	zustand = Zustand.LAUFEN
```

3. Der weiße Punkt hat ausgedient: `_draw()` und `queue_redraw()` löschen.

Zu `blick.angle() + PI / 2`: `angle()` liefert den Winkel eines Vektors im Bogenmaß, gemessen ab „rechts“. Rechts ist 0, unten ist π/2, links ist π, oben ist −π/2. Unser Schwert-Bild zeigt aber nach oben. Damit es bei „oben“ ungedreht bleibt, rechnen wir π/2 dazu. Erinnerst du dich an das Raumschiff in Weltraumsteine? Dort war es dasselbe Problem.

Und `await $AnimationPlayer.animation_finished`: Die Funktion wartet hier, bis die Animation fertig ist, und macht dann weiter. Das kennst du von `await tween.finished`.

### 3.5 Ein Topf zum Zerschlagen

Neue Szene:

```
Topf (StaticBody2D)
├── Bild (Sprite2D)
├── CollisionShape2D
└── Hurtbox (Area2D)
    └── CollisionShape2D
```

1. `Topf`: **StaticBody2D**, Layer `1` (Welt), Mask leer. Er steht im Weg wie eine Säule.
2. `Bild`: Kachelblatt, Hframes/Vframes wie immer, ein Frame, der zerbrechlich aussieht, zum Beispiel `66`.
3. `CollisionShape2D`: unten am Fuß, wie bei der Säule, etwa `12, 6` auf Position `0, 5`.
4. `Hurtbox`: **Area2D**, Layer leer, **Mask** nur `4` (Schwert). Ihre Form deckt den **ganzen** Topf ab, also `14, 14`.
5. Skript an `Topf`, dann bei `Hurtbox` das Signal **area_entered** mit dem Topf verbinden:

```gdscript
extends StaticBody2D


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	zerbrechen()


# Kurz plattdrücken, dann weg
func zerbrechen() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_property($Bild, "scale", Vector2(1.5, 0.2), 0.1)
	tween.tween_callback(queue_free)
```

6. Speichern als `topf.tscn`, drei Töpfe in den Raum stellen.

Warum `set_deferred`? Das Signal kommt mitten aus der Physik-Berechnung, da darf man nichts an der Physik ändern. Das kennst du vom Block in Hüpfheld.

Warum ein Signal und nicht in jedem Bild prüfen, wie beim Gegner in Hüpfheld? Dort war das Problem: Bleibt der Held im Gegner stehen, kommt kein neues Signal. Hier ist genau das gewollt. Jeder Stich schaltet die Hitbox neu ein, also kommt pro Stich genau ein Signal.

### 3.6 Ausprobieren

- Angriffstaste: Die Klinge schießt in Blickrichtung heraus, in alle vier Richtungen.
- Beim Zustechen bleibt der Held stehen und richtet sich gerade auf.
- Dauerhaft gedrückt halten sticht nur einmal (`is_action_just_pressed`).
- Stich gegen einen Topf: Er wird platt und verschwindet. Daneben vorbeistechen: nichts passiert.
- Stich von allen Seiten. Weil die Hurtbox den ganzen Topf abdeckt, trifft man auch von oben, obwohl der Fuß des Topfs weiter unten liegt.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 3

1. **Ungeduldig, aber richtig (mittel):** Deine Ungeduld aus Kapitel 2 hat drei Haken:
   - `szenen_zeit` zählt, seit die Szene läuft, nicht, seit der Held steht. Nach einer Minute Spielen wird er sofort ungeduldig, sobald er anhält.
   - `randf()` wird **jedes Bild** neu gewürfelt. Dann wechselt `play()` ständig zwischen `stehen` und `ungeduldig`, und beide fangen jedes Mal von vorn an. Von der Ungeduld sieht man so fast nichts.
   - `laufen` und `ungeduldig` haben keine Tracks für alles, was die anderen verändern (siehe 3.3). Wer aus `ungeduldig` losläuft, bleibt platt gedrückt. Wer aus `laufen` ungeduldig wird, bleibt schief.

   Bau es so um: eine Variable `steh_zeit`, die beim Laufen auf 0 springt und im Stehen hochzählt. Ab einer bestimmten Zeit (zum Beispiel 5 Sekunden, nicht 60) spielt `ungeduldig`. Und jede Animation bekommt bei 0.0 Keys für Position, Rotation und Scale des Bildes.
2. **Wusch (leicht):** Mach mit 🆓 jsfxr ein kurzes „Wusch“ für das Schwert. Diesmal nicht mit einer Funktion wie beim Schritt, sondern direkt in der Animation: einen `AudioStreamPlayer` namens `Schwung` an den Held hängen, dann in `angriff` **Add Track → Audio Playback Track** → `Schwung` wählen und bei 0.0 die WAV-Datei als Key einfügen (Rechtsklick → Insert Key).
3. **Scherben (leicht):** Beim Zerbrechen sollen Scherben fliegen, wie die Ziegel in Hüpfheld. Häng einen `CPUParticles2D` an den Topf. Aber Vorsicht: `queue_free()` löscht den Topf samt Partikeln, bevor man sie sieht. Wie kannst du das Bild verstecken, die Partikel abspielen und den Topf erst danach löschen? (Tipp: `one_shot`, `emitting` und das Signal `finished`.)
4. **Angriff vormerken (mittel):** Drückst du die Angriffstaste, während der Held noch sticht, passiert nichts. In schnellen Kämpfen fühlt sich das an, als hätte das Spiel den Knopfdruck verschluckt. Merk dir den Druck wie beim Jump Buffering in Hüpfheld und stich sofort noch einmal, sobald der erste Stich fertig ist.
5. **Überraschung (mittel):** In manchen Töpfen wohnt jemand. Gib dem Topf `@export var bewohnt := false`. Ist er bewohnt, krabbelt beim Zerbrechen eine Spinne heraus (Frame `122`): ein neues `Sprite2D` an der Stelle des Topfs, das mit einem Tween schnell aus dem Raum flitzt und dann verschwindet. Bonus: Sie quiekt empört. 🕷️
6. **Treffer-Stopp (mittel):** Fühlt sich ein Treffer kräftiger an, wenn das Spiel für einen winzigen Moment einfriert? Probier im Topf beim Zerbrechen:

   ```gdscript
   Engine.time_scale = 0.0
   await get_tree().create_timer(0.06, true, false, true).timeout
   Engine.time_scale = 1.0
   ```

   Das vierte `true` heißt: Dieser Timer läuft weiter, obwohl die Zeit angehalten ist. Was passiert ohne? DOOM (2016) macht so etwas bei jedem Glory Kill. Das heißt **Hit Stop**.

---

## Kapitel 4: Gegner mit State Machine

Zeit für den ersten Bewohner des Dungeons: der **Glibber**, ein grüner Schleimgeist (Frame `108`). Er schlendert ziellos herum, bis er den Helden bemerkt. Dann kriecht er ihm nach, zittert kurz und springt ihn an. Wer ihn mit dem Schwert trifft, schleudert ihn zurück. Nach zwei Treffern macht es *plopp*.

Dass der Glibber dem Helden schon wehtut, kommt erst in Kapitel 6 mit den Herzen. Heute geht es um sein **Verhalten**.

### 4.1 Was ist eine State Machine?

Der Glibber tut immer genau **eine** Sache: herumlaufen **oder** verfolgen **oder** zum Sprung ansetzen. Jede dieser Sachen ist ein **Zustand** (State). Eine **State Machine** (Zustandsautomat) besteht aus zwei Dingen:

1. **Was tue ich in jedem Zustand?** Das steht im `match` in `_physics_process`, wie beim Helden mit LAUFEN und ANGRIFF.
2. **Wann wechsle ich wohin?** Die Übergänge.

Bevor man programmiert, zeichnet man das am besten auf. Für den Glibber:

```
               Held näher als 64                Held näher als 28
   WANDERN  ─────────────────────▶  JAGEN  ─────────────────────▶  ANLAUF
      ▲      ◀─────────────────────    ▲                              │
      │        Held weiter als 96      │                              │ nach 0,4 s
      │                                │ nach 0,6 s                   ▼
      │                              RUHE  ◀───────────────────────  SPRUNG
      │                                                nach 0,25 s
      │
  (Zeit um oder an die Wand: neue Richtung würfeln)

   Von überall: Schwerttreffer ─▶ GETROFFEN ─▶ nach 0,3 s ─▶ JAGEN
```

Ein paar Ideen stecken da drin:

- **Zwei verschiedene Weiten:** Der Glibber bemerkt den Helden bei 64 Pixeln, vergisst ihn aber erst bei 96. Wäre es dieselbe Zahl, würde er an der Grenze in jedem Bild hin- und herschalten. Diesen Abstand zwischen zwei Schwellen nennt man **Hysterese**. Ein Thermostat macht das auch, sonst würde die Heizung ständig an- und ausgehen.
- **ANLAUF ist eine Warnung:** Bevor er springt, bleibt er stehen und zittert. Der Spieler sieht: Gleich passiert was! Das heißt **Telegraphing**, und gute Spiele machen es bei jedem Angriff. In DOOM (2016) holt ein Imp sichtbar mit dem Feuerball aus, bevor er wirft.
- **RUHE ist eine Atempause:** Nach dem Sprung ist der Glibber kurz erschöpft. Das ist das Zeitfenster, in dem der Spieler zuschlagen kann. Ohne Pause würde er pausenlos springen, und das macht keinen Spaß.

### 4.2 Die Szene

Kollisionsebenen zuerst: Der Glibber liegt auf Ebene 3 (Gegner).

```
Glibber (CharacterBody2D)
├── Bild (Sprite2D)
├── CollisionShape2D
├── Hurtbox (Area2D)
│   └── CollisionShape2D
└── Anzeige (Label)
```

1. `Glibber`: **CharacterBody2D**, **Motion Mode** `Floating`. **Layer** nur `3` (Gegner), **Mask** `1` (Welt) und `3` (Gegner). So stoßen Glibber an Wände und aneinander, laufen aber durch den Helden hindurch. Das ändern wir in Kapitel 6.
2. `Bild`: Kachelblatt, Hframes `12`, Vframes `11`, Frame `108`.
3. `CollisionShape2D`: an die Füße, `10, 6` auf `0, 5`, wie beim Helden.
4. `Hurtbox`: **Area2D**, Layer leer, **Mask** nur `4` (Schwert). Form `14, 14`, deckt den ganzen Glibber ab. Signal **area_entered** mit dem Glibber verbinden.
5. `Anzeige`: ein **Label** über dem Kopf, Position etwa `-24, -20`, Size `48, 10`, **Horizontal Alignment** `Center`. Es zeigt den aktuellen Zustand an. Das ist nur zum Lernen und Testen, später schalten wir es aus.

   Die Standardschrift ist bei 256 Pixeln Bildbreite viel zu groß. Kopier aus Hüpfheld den Ordner `Kenney` mit `Kenney Pixel.ttf` ins Projekt und gib dem Label eine **New LabelSettings** mit dieser Schrift und **Size** `16`. Kenney Pixel ist für genau diese Größe gezeichnet.

6. Damit der Glibber den Helden finden kann, kommt der Held in eine Gruppe: `held.tscn` öffnen, `Held` auswählen, rechts neben dem Inspector der Tab **Node → Groups** → `held` eintippen → **Add**. Das kennst du aus Hüpfheld.

### 4.3 Das Skript

```gdscript
extends CharacterBody2D

enum Zustand { WANDERN, JAGEN, ANLAUF, SPRUNG, RUHE, GETROFFEN }

const WANDER_TEMPO = 25.0
const JAGD_TEMPO = 40.0
const SPRUNG_TEMPO = 160.0
const RUECKSTOSS = 180.0      # so schnell fliegt er nach einem Treffer zurück
const BREMSE = 600.0          # so schnell kommt er danach zum Stehen
const SEHWEITE = 64.0         # so nah muss der Held kommen, damit der Glibber ihn bemerkt
const VERGESSWEITE = 96.0     # so weit weg muss der Held sein, damit er ihn wieder vergisst
const SPRUNGWEITE = 28.0      # aus dieser Nähe springt er an

@export var leben := 2

var zustand := Zustand.WANDERN
var zustand_zeit := 0.0       # wie lange der aktuelle Zustand noch dauert
var richtung := Vector2.ZERO

@onready var held: Node2D = get_tree().get_first_node_in_group("held")


func _ready() -> void:
	wechseln(Zustand.WANDERN)


func _physics_process(delta: float) -> void:
	zustand_zeit -= delta
	var abstand := global_position.distance_to(held.global_position)

	match zustand:
		Zustand.WANDERN:
			velocity = richtung * WANDER_TEMPO
			if abstand < SEHWEITE:
				wechseln(Zustand.JAGEN)
			elif zustand_zeit <= 0 or is_on_wall():
				wechseln(Zustand.WANDERN)   # neue Richtung würfeln
		Zustand.JAGEN:
			velocity = global_position.direction_to(held.global_position) * JAGD_TEMPO
			if abstand > VERGESSWEITE:
				wechseln(Zustand.WANDERN)
			elif abstand < SPRUNGWEITE:
				wechseln(Zustand.ANLAUF)
		Zustand.ANLAUF:
			velocity = Vector2.ZERO
			$Bild.position.x = randi_range(-1, 1)   # zittern: Gleich passiert was!
			if zustand_zeit <= 0:
				wechseln(Zustand.SPRUNG)
		Zustand.SPRUNG:
			velocity = richtung * SPRUNG_TEMPO
			if zustand_zeit <= 0:
				wechseln(Zustand.RUHE)
		Zustand.RUHE, Zustand.GETROFFEN:
			velocity = velocity.move_toward(Vector2.ZERO, BREMSE * delta)
			if zustand_zeit <= 0:
				wechseln(Zustand.JAGEN)

	move_and_slide()
	$Anzeige.text = Zustand.keys()[zustand]


# Einen Zustand betreten: alles einstellen, was zu ihm gehört
func wechseln(neu: Zustand) -> void:
	zustand = neu
	$Bild.position.x = 0
	match neu:
		Zustand.WANDERN:
			# Stehen bleiben gehört auch zum Herumlaufen
			richtung = [Vector2.ZERO, Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].pick_random()
			zustand_zeit = randf_range(0.5, 1.5)
		Zustand.ANLAUF:
			zustand_zeit = 0.4
		Zustand.SPRUNG:
			# Die Richtung wird beim Absprung festgelegt. Wer jetzt ausweicht, wird verfehlt.
			richtung = global_position.direction_to(held.global_position)
			zustand_zeit = 0.25
		Zustand.RUHE:
			zustand_zeit = 0.6
		Zustand.GETROFFEN:
			zustand_zeit = 0.3


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	if zustand == Zustand.GETROFFEN:
		return
	leben -= 1
	velocity = held.global_position.direction_to(global_position) * RUECKSTOSS   # weg vom Helden
	wechseln(Zustand.GETROFFEN)
	var tween := create_tween()
	tween.tween_property($Bild, "modulate", Color.RED, 0.05)
	tween.tween_property($Bild, "modulate", Color.WHITE, 0.2)
	if leben <= 0:
		sterben()


# Zusammenschrumpfen und weg
func sterben() -> void:
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	$Anzeige.hide()
	var tween := create_tween()
	tween.tween_property($Bild, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)
```

Speichern als `glibber.tscn`, zwei Glibber in den Raum stellen.

### 4.4 Lies das Skript

Das meiste kennst du. Neu ist vor allem der Aufbau:

- **`_physics_process` sagt, was in jedem Zustand passiert**, und prüft die Übergänge. Gewechselt wird aber nie mit `zustand = ...`, sondern immer mit **`wechseln()`**.
- **`wechseln()` macht alles, was beim Betreten eines Zustands einmal passieren muss**: Zeit stellen, Richtung würfeln, das Zittern zurücksetzen. Stünde das verstreut an jeder Stelle, an der gewechselt wird, würde man es garantiert irgendwo vergessen. So steht alles, was zu SPRUNG gehört, an genau zwei Stellen: was er *tut* (oben) und wie er *anfängt* (unten).
- **`Zustand.RUHE, Zustand.GETROFFEN:`** Zwei Zustände, die dasselbe tun, teilen sich einen Zweig im `match`. Sie unterscheiden sich nur in der Dauer, und die steht in `wechseln()`.
- **`Zustand.keys()[zustand]`**: `keys()` liefert die Namen eines `enum` als Liste: `["WANDERN", "JAGEN", ...]`. Ein `enum` ist in Wahrheit nur eine Zahl (WANDERN = 0, JAGEN = 1 …), also holt `[zustand]` den passenden Namen heraus.
- **`pick_random()`** sucht sich ein zufälliges Element aus einer Liste aus.
- **`randi_range(-1, 1)`** statt `randf_range`: ganze Zahlen, also ganze Pixel. Bei Pixel-Art zittert es sonst unscharf.
- **`@onready var held`**: `get_first_node_in_group` gibt es erst, wenn der Glibber im Szenenbaum hängt. `@onready` wartet genau bis dahin. Ohne `@onready` würde die Zeile schon beim Erzeugen des Glibbers ausgeführt, bevor er im Szenenbaum hängt. Dann ist `get_tree()` noch `null`, und es gibt einen Fehler.

### 4.5 Ausprobieren

- Bleib weit weg: Die Glibber schlendern herum, bleiben mal stehen und drehen an Wänden um. Die Anzeige zeigt `WANDERN`.
- Geh näher heran: `JAGEN`. Der Glibber kriecht dir nach.
- Lauf weg: Erst ein ganzes Stück weiter vergisst er dich wieder.
- Bleib stehen: `ANLAUF`, er zittert, dann `SPRUNG`. Weich während des Zitterns zur Seite aus, dann springt er ins Leere.
- Stich zu, am besten in der `RUHE` nach seinem Sprung: Er wird rot und fliegt zurück. Beim zweiten Treffer schrumpft er weg.
- Treib einen Glibber in eine Ecke: Der Rückstoß hört an der Wand auf, weil `move_and_slide` ihn bremst.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 4

1. **Anzeige aus (leicht):** Die Zustands-Anzeige ist zum Lernen gut, im fertigen Spiel stört sie. Bau ein `@export var zeige_zustand := false` ein, mit dem man sie pro Glibber im Inspector einschalten kann.
2. **Glibber-Matsch (leicht):** Der Glibber ist ein Schleim, also soll er auch so aussehen: Beim Wandern und Jagen wabbelt er mit einem AnimationPlayer (Scale abwechselnd breit und schmal, Discrete, wie beim ungeduldigen Helden). Im ANLAUF drückt er sich platt, bevor er springt. Welche Animation spielt in welchem Zustand? Wo im Skript gehört `play()` hin: oben in `_physics_process` oder unten in `wechseln()`?
3. **Hit Stop auch hier (leicht):** Bau den Treffer-Stopp aus dem Topf auch beim Glibber ein. Fühlt sich der Kampf anders an? Tipp: Der Stopp sollte das Letzte sein, was beim Treffer passiert, damit der Rückstoß schon eingestellt ist.
4. **Er sieht nicht durch Wände (mittel):** Steht eine Säule zwischen dir und dem Glibber, bemerkt er dich trotzdem. Gib ihm einen `RayCast2D`, der jedes Bild auf den Helden zeigt (`target_position = held.global_position - global_position`, Mask nur `1` Welt). Trifft der Strahl eine Wand (`is_colliding()`), sieht er dich nicht. Wo im Skript muss das geprüft werden?
5. **Die Fledermaus (knifflig):** Bau mit dem, was du gelernt hast, einen zweiten Gegner: die Fledermaus (Frame `120`). Sie hat ganz andere Zustände: FLATTERN (wilde Zickzack-Bewegung, alle 0,2 Sekunden eine neue zufällige Richtung, auch schräg), SITZEN (hängt eine Weile still) und dann wieder FLATTERN. Den Helden beachtet sie gar nicht, sie ist einfach nur lästig. Zeichne zuerst die Zustände und Übergänge auf, wie in 4.1, dann programmiere sie. Und: Sollte eine Fledermaus an Wänden abprallen oder über alles hinwegfliegen? Was musst du dafür an der Mask ändern?

---

## Kapitel 5: Mehrere Räume

Ein Dungeon mit nur einem Raum ist eine Abstellkammer. In diesem Kapitel wird daraus ein richtiger Dungeon mit mehreren Räumen. Läuft der Held durch eine Tür, schiebt sich das Bild wie im Original zum nächsten Raum, und solange steht alles still. Und die Monster bleiben, wo sie hingehören.

### 5.1 Wie die Räume liegen

Alle Räume kommen in **dieselbe Szene**, auf dieselben zwei TileMapLayer, wie Kästchen auf Karopapier. Jeder Raum ist genau 16 × 11 Kacheln groß, also 256 × 176 Pixel:

```
            x = 0          x = 256        x = 512
  y = -176  ┌──────────────┬──────────────┐
            │ Raum (0, -1) │ Raum (1, -1) │
  y = 0     ├──────  ──────┼──────────────┘
            │ Raum (0, 0)  │
            │   (Start)    │
  y = 176   └──────────────┘
```

Jetzt zahlt sich aus, dass dein erster Raum genau bei (0, 0) anfängt. In welchem Raum ein Punkt liegt, ist eine einzige Rechnung:

```gdscript
Vector2i((punkt / Vector2(256, 176)).floor())
```

Ein Punkt bei (300, 50) liegt in Raum (1, 0), einer bei (100, −20) in Raum (0, −1). `floor()` rundet immer **nach unten**, auch bei negativen Zahlen: −0,1 wird zu −1, nicht zu 0. Deshalb funktionieren auch Räume oberhalb und links vom Start.

`Vector2i` ist ein Vektor aus ganzen Zahlen. Räume haben keine halben Nummern.

### 5.2 Neue Räume malen

1. Zuerst ein Name, der passt: Im FileSystem `raum.tscn` → Rechtsklick → **Rename** → `dungeon.tscn`. Den Root-Node `Raum` umbenennen in `Dungeon`. Godot passt alle Verweise selbst an, auch die Hauptszene.
2. **Räume kopieren:** Wie beim Umziehen in Kapitel 1: Auf `Waende` mit dem Auswahl-Werkzeug den ganzen Raum markieren, **Strg+C**, **Strg+V** und an der neuen Stelle absetzen. Danach dasselbe auf `Boden`. Am leichtesten triffst du die richtige Stelle mit eingeschaltetem Raster (oben in der Werkzeugleiste des TileMap-Tabs).
   - Der Raum rechts vom Start beginnt bei Kachel (16, 0).
   - Der Raum über dem Start beginnt bei Kachel (0, −11).
3. Mal mindestens **drei Räume**, gern in L-Form wie in der Skizze. Gestalte sie unterschiedlich: mal mehr Säulen, mal einen Gang in der Mitte, mal einfach einen leeren Raum mit vielen Glibbern.
4. **Türen:** Zwei Räume nebeneinander haben jeweils ihre eigene Wand, die Wand dazwischen ist also zwei Kacheln dick. Damit man durchkommt, brauchen **beide** Wände eine Lücke an derselben Stelle. Das gibt einen kurzen Gang, wie im Original.
5. Türen, die ins Nichts führen (zum Beispiel aus Übung 2 von Kapitel 1), wieder zumauern.
6. Verteil Töpfe, Glibber und die Fledermaus auf die Räume.

### 5.3 Die Kamera schiebt

Die Kamera hängt schon als `Camera2D` in der Szene, auf `0, -48`. Sie bekommt jetzt ein Skript:

```gdscript
extends Camera2D

const RAUM_GROESSE = Vector2(256, 176)   # 16 × 11 Kacheln
const ANZEIGE_HOEHE = 48                 # Platz für die Anzeige oben
const SCHIEBE_ZEIT = 0.6                 # so lange dauert ein Raumwechsel

var raum := Vector2i.ZERO   # welchen Raum die Kamera gerade zeigt

@onready var held: Node2D = get_tree().get_first_node_in_group("held")


func _ready() -> void:
	# Beim Start ohne Schieben gleich zum Raum des Helden
	raum = raum_von(held.global_position)
	position = kamera_position(raum)


func _process(_delta: float) -> void:
	var neu := raum_von(held.global_position)
	if neu != raum:
		schieben(neu)


# In welchem Raum liegt dieser Punkt?
func raum_von(punkt: Vector2) -> Vector2i:
	return Vector2i((punkt / RAUM_GROESSE).floor())


# Wo muss die Kamera stehen, damit sie diesen Raum zeigt?
func kamera_position(r: Vector2i) -> Vector2:
	return Vector2(r) * RAUM_GROESSE - Vector2(0, ANZEIGE_HOEHE)


# Zum neuen Raum schieben. Solange steht das ganze Spiel still.
func schieben(neu: Vector2i) -> void:
	raum = neu
	get_tree().paused = true
	var tween := create_tween()
	tween.tween_property(self, "position", kamera_position(neu), SCHIEBE_ZEIT)
	await tween.finished
	get_tree().paused = false
```

**Wichtig:** Bei der `Camera2D` im Inspector **Process → Mode** auf `Always` stellen. `get_tree().paused = true` hält alles an, was auf `Inherit` oder `Pausable` steht, also auch die Kamera selbst und ihren Tween. Dann würde sie nie ankommen, und das Spiel bliebe für immer stehen. Process Mode kennst du aus Flatterfisch.

Warum das Spiel beim Schieben anhalten? Erstens macht es das Original so. Zweitens wäre es unfair: Während das Bild noch schiebt, sieht der Spieler den neuen Raum nicht richtig, und ein Glibber könnte schon zuschlagen.

### 5.4 Oben schwarz

Die Kamera steht 48 Pixel über dem Raum. Liegt darüber ein anderer Raum, sieht man oben dessen untere Wand. Dort kommt in Kapitel 6 die Anzeige hin. Für jetzt reicht ein schwarzer Balken:

1. Kind von `Dungeon`: **CanvasLayer** → umbenennen in `Anzeige`.
2. Darin ein **ColorRect**: Farbe Schwarz, Position `0, 0`, Size `256, 48`.

Eine CanvasLayer bewegt sich nicht mit der Kamera, das kennst du vom HUD in Hüpfheld.

### 5.5 Monster bleiben im Raum

Jetzt kommt die Sperre, nach der du gefragt hast. *Project Settings → Layer Names → 2D Physics*:

| Ebene | Name |
|---|---|
| 5 | `Gegnersperre` |

Die Sperre läuft **rundherum an der Raumgrenze entlang**, nicht nur in den Türen. So kommt auch ein Geist, der durch Wände schwebt, nicht in den Nachbarraum. Und ein Monster kann bis zur Mitte des Gangs folgen. Der Held kann sich also nicht im Türgang verstecken.

Neue Szene `raumgrenze.tscn`:

1. Root: **StaticBody2D** → `Raumgrenze`. **Layer** nur `5`, **Mask** leer.
2. Vier Kinder `CollisionShape2D`, jedes mit **New RectangleShape2D**. Sie bilden einen Rahmen um einen 256 × 176 großen Raum, der bei (0, 0) beginnt:

   | Name | Size | Position |
   |---|---|---|
   | `Oben` | `256, 8` | `128, 0` |
   | `Unten` | `256, 8` | `128, 176` |
   | `Links` | `8, 176` | `0, 88` |
   | `Rechts` | `8, 176` | `256, 88` |

3. In `dungeon.tscn` bekommt **jeder Raum** eine Raumgrenze, und zwar genau an seiner linken oberen Ecke: `0, 0` für den Startraum, `256, 0` für den Raum rechts daneben, `0, -176` für den Raum darüber. Die Ränder zweier Nachbarräume liegen dann genau übereinander, das macht nichts.

Die Raumgrenze ist unsichtbar. Mit **Debug → Visible Collision Shapes** im Menü siehst du sie beim Testen.

Warum 8 Pixel dick? Ein springender Glibber legt pro Bild fast 3 Pixel zurück. Bei einer hauchdünnen Wand könnte er im ungünstigen Fall durchrutschen.

Dann die Masks anpassen:

| Wer | Mask |
|---|---|
| Held | `1` (Welt), wie bisher. Die Grenze ist für ihn Luft. |
| Glibber, Fledermaus | `1` (Welt), `3` (Gegner) und neu `5` (Gegnersperre) |

Dasselbe Prinzip wie bei Hitbox und Hurtbox: Eine Fläche ist nur für die eine Wand, deren Mask sie sieht.

### 5.6 Monster in anderen Räumen schlafen

Die Glibber in den anderen Räumen laufen die ganze Zeit herum, obwohl man sie nicht sieht. Das kostet Rechenzeit, und ein Glibber, der hinter der Wand jagt, steht beim Betreten des Raums plötzlich an der Tür.

Die Kamera weiß, welcher Raum gerade dran ist. Also weckt sie die Monster dieses Raums und schickt alle anderen schlafen:

1. Jedes Monster kommt in eine Gruppe `monster`: in `glibber.tscn` und `fledermaus.tscn` beim Root-Node **Node → Groups** → `monster`.
2. Neue Funktion in der Kamera:

```gdscript
# Nur die Monster im aktuellen Raum sind wach, alle anderen schlafen
func monster_wecken() -> void:
	for monster in get_tree().get_nodes_in_group("monster"):
		if raum_von(monster.global_position) == raum:
			monster.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			monster.process_mode = Node.PROCESS_MODE_DISABLED
```

3. Aufrufen an zwei Stellen: am Ende von `_ready()` und in `schieben()` direkt nach `await tween.finished`, also bevor die Pause endet.

`PROCESS_MODE_DISABLED` schaltet einen Node komplett ab: kein `_physics_process`, keine Animation, und er nimmt nicht mehr an der Physik teil. `PROCESS_MODE_INHERIT` heißt: Mach, was dein Eltern-Node macht, also ganz normal mit.

Warum nicht `VisibleOnScreenEnabler2D`, den Bruder des Notifiers aus Hüpfheld? Der schaltet seinen Node ab, solange er nicht im Bild ist. Bei uns gehören aber die 48 Pixel unter dem schwarzen Balken auch „zum Bild“, und dort liegt der untere Rand des Raums darüber. Ein Monster dort wäre wach, obwohl man es nicht sieht. Die Kamera dagegen fragt nicht „Was sehe ich?“, sondern „Welcher Raum ist dran?“. Das ist genau die richtige Frage.

### 5.7 Ausprobieren

- Lauf durch eine Tür: Sobald die Mitte des Helden die Raumgrenze überschreitet, schiebt sich das Bild weiter. Alles steht still, dann geht es weiter.
- Kehr im Gang um: Das Bild schiebt zurück.
- Oben ist ein schwarzer Balken, egal welcher Raum darüber liegt.
- Lock einen Glibber in den Gang: Er folgt dir bis zur Mitte, dann stößt er an die unsichtbare Grenze.
- Die Fledermaus prallt an der Grenze ab wie an einer Wand.
- Geh in einen anderen Raum und zurück: Die Glibber stehen genau da, wo du sie verlassen hast, denn sie haben geschlafen.

### 5.8 Noch drei Dinge aus Kapitel 4

Sie wirken sich auf das Verhalten aus, deshalb gehören sie hierher:

1. **Die Fledermaus braucht Motion Mode `Floating`.** Bei ihr steht noch `Grounded`. Dann zählen die obere und untere Wand als „Decke“ und „Boden“, und `is_on_wall()` meldet nur die linke und rechte Wand. An der oberen und unteren Wand schrammt sie entlang, statt abzuprallen.
2. **Der RayCast des Glibbers rechnet ein Bild zu spät.** Ein `RayCast2D` aktualisiert sein Ergebnis nur einmal pro Physik-Bild. Setzt du `target_position` neu und fragst gleich danach `is_colliding()`, bekommst du die Antwort für das **alte** Ziel. In RUHE und GETROFFEN ist das alte Ziel vielleicht Sekunden alt. Abhilfe: direkt nach dem Setzen `$RayCast2D.force_raycast_update()` aufrufen. Dann rechnet er sofort neu.
3. **Die Zustandsanzeige sitzt schief.** Beim Label `Anzeige` ist **Offset Left** `-24`, aber **Offset Right** `44`. Die Mitte liegt so bei 10 statt bei 0, und der Text steht rechts neben dem Glibber. Mach `-34` und `34` daraus.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 5

1. **Hereinspazieren (mittel):** Im Original läuft Link nach dem Schieben von selbst ein Stück in den neuen Raum. Bei uns steht der Held danach mitten im Gang. Gib der Kamera ein Signal `raum_gewechselt(richtung: Vector2)`, das sie nach dem Schieben aussendet. Der Held hört darauf und läuft mit einem Tween 16 Pixel weiter in diese Richtung. Woher kennt die Kamera die Richtung? (Tipp: `neu - raum`, bevor `raum` überschrieben wird.)
2. **Ruckelfrei (leicht):** Schau beim Schieben genau hin: Die Kacheln zittern ein wenig, weil die Kamera auch auf halben Pixeln steht. Probier *Project Settings → Rendering → 2D → **Snap 2D Transforms to Pixel*** (Advanced Settings). Was ändert sich? Gibt es Nachteile, zum Beispiel beim Watscheln?
3. **Der Geist (mittel):** Jetzt kannst du den Geist bauen, von dem du gesprochen hast (Frame `121`). Er schwebt langsam und stetig auf den Helden zu, durch Wände und Säulen hindurch, aber nicht aus dem Raum hinaus. Welche Mask braucht er? Mach ihn halb durchsichtig (Modulate) und lass ihn sanft auf und ab schweben. Bonus: Kann man ihn mit dem Schwert treffen, oder geht die Klinge durch ihn hindurch?
4. **Wiedersehen (Nachdenken):** Triff einen Glibber einmal, verlass den Raum und komm zurück. Er hat immer noch nur 1 Leben. Im Original sind beim Wiederkommen alle Gegner wieder da und frisch. Was gefällt dir besser? Was davon wäre schwerer zu bauen? Darum geht es in Kapitel 9.
5. **Die Karte (knifflig):** Oben in der schwarzen Anzeige soll eine kleine Karte entstehen: Für jeden besuchten Raum ein graues Kästchen (6 × 4 Pixel), für den aktuellen ein helles. Merk dir die besuchten Räume in der Kamera, zum Beispiel in einem `Dictionary` mit dem Raum als Schlüssel: `besucht[neu] = true`. Ein Node in der Anzeige malt die Kästchen mit `_draw()`, wie der weiße Punkt in Kapitel 2. Wie erfährt er, dass er neu malen soll?

### Antworten zu Kapitel 5

4. Die Monster sollen alle Leben zurückbekommen, aber nicht wiedererweckt werden.
5. Die Karte wird 60 Pixel breit, Platz für 7x5 Räume (wobei die Karte nichts davon weiß, das muss also beim Platzieren der Räume berücksichtigt werden).

---

## Kapitel 6: Herzen, Schaden und die Anzeige

Bisher sind die Monster harmlos, man läuft einfach durch sie hindurch. Jetzt bekommt der Held **Herzen**, wie im Original. Wer ein Monster berührt, verliert ein halbes Herz, wird zurückgestoßen und blinkt eine Sekunde lang. In der Zeit kann ihm nichts passieren. Sind alle Herzen weg, dreht er sich ein letztes Mal, und alles beginnt von vorn.

Neu sind vor allem ein **Setter** (eine Variable, die meldet, wenn sie sich ändert) und **Pixel-Art aus Text**: Die Herzen zeichnen wir nicht in Pixelorama, sondern schreiben sie als Daten ins Skript.

### 6.1 Der Spielstand

Die Herzen gehören nicht dem Helden allein. Die Anzeige muss sie kennen, und in Kapitel 9 sollen sie gespeichert werden. Also kommen sie in einen **Autoload**, wie bei Hüpfheld.

Neues Skript `spielstand.gd`, dann *Project Settings → Globals → Autoload* → `spielstand.gd` mit dem Namen `Spielstand` hinzufügen:

```gdscript
extends Node

signal leben_geaendert

const START_LEBEN = 6   # in halben Herzen: 6 sind drei ganze Herzen

var max_leben := START_LEBEN
var leben := START_LEBEN:
	set(wert):
		leben = clampi(wert, 0, max_leben)
		leben_geaendert.emit()


# Alles auf Anfang, für ein neues Spiel
func neues_spiel() -> void:
	max_leben = START_LEBEN
	leben = max_leben
```

**Neu ist der Setter** (`set(wert):`). Er wird jedes Mal ausgeführt, wenn jemand `leben` einen neuen Wert gibt, egal wo im Spiel. Hier macht er zwei Dinge:

- **`clampi(wert, 0, max_leben)`**: Die Leben bleiben immer zwischen 0 und dem Maximum. Ein Herz aufsammeln bei vollen Herzen? Kein Problem, es wird einfach abgeschnitten.
- **`leben_geaendert.emit()`**: Bei jeder Änderung geht ein Signal raus. Wer die Herzen anzeigen will, muss nicht jedes Bild nachfragen, sondern wird benachrichtigt.

Innerhalb des Setters schreibt `leben = ...` direkt in die Variable, ohne den Setter noch einmal aufzurufen. Sonst würde er sich endlos selbst aufrufen.

Warum halbe Herzen als ganze Zahl? Weil es keine Viertel gibt. Mit 6 statt 3,0 kann nie ein krummer Wert wie 2,4999 entstehen.

### 6.2 Herzen aus Text

Auf dem Kachelblatt gibt es keine Herzen. Wir malen sie mit `_draw()`, Pixel für Pixel, aus einem kleinen Bild aus Text:

```
.##.##.
#######
#######
.#####.
..###..
...#...
```

Jedes `#` ist ein Pixel. Erinnerst du dich an die Level in Ziegelbrecher? Dort war es dasselbe: Ein Bild als Daten im Code.

In der CanvasLayer `Anzeige` ein neuer **Node2D** namens `Herzen`, Position etwa `176, 20` (rechts neben der Karte). Skript `herzen.gd`:

```gdscript
extends Node2D

const HERZ = [
	".##.##.",
	"#######",
	"#######",
	".#####.",
	"..###..",
	"...#...",
]
const ABSTAND = 8                        # 7 Pixel Herz, 1 Pixel Luft
const VOLL = Color(0.85, 0.1, 0.15)
const LEER = Color(0.3, 0.3, 0.3)


func _ready() -> void:
	Spielstand.leben_geaendert.connect(queue_redraw)


func _draw() -> void:
	for herz in range(int(Spielstand.max_leben / 2.0)):
		# Wie viele Hälften dieses Herzens sind noch voll: 2, 1 oder 0 (oder weniger)?
		var haelften := Spielstand.leben - herz * 2
		for y in HERZ.size():
			for x in HERZ[y].length():
				if HERZ[y][x] == "#":
					# Ein halbes Herz: nur die linke Hälfte (Spalten 0 bis 3) ist rot
					var voll: bool = haelften >= 2 or (haelften == 1 and x <= 3)
					draw_rect(Rect2(herz * ABSTAND + x, y, 1, 1), VOLL if voll else LEER)
```

- **`connect(queue_redraw)`**: Jedes Mal, wenn der Spielstand meldet „Leben geändert“, malt sich die Anzeige neu. Das ist die Verbindung aus 6.1.
- **`HERZ[y][x]`**: `HERZ[y]` ist eine Zeile (ein Text), `[x]` holt daraus ein einzelnes Zeichen.
- **`int(Spielstand.max_leben / 2.0)`**: 6 halbe Herzen sind 3 Herzen. Mit `/ 2` würde Godot warnen, dass bei einer Division ganzer Zahlen der Rest verloren geht. Mit `2.0` rechnet es mit Kommazahlen, und `int()` sagt: Ich will bewusst eine ganze Zahl.

Bonus für die Optik: ein Label `-LEBEN-` in Kenney Pixel darüber, rot, wie im Original.

### 6.3 Die Hurtbox des Helden

Der Held bekommt, was der Topf schon hat: eine Hurtbox.

1. In `held.tscn`: Kind von `Held` → **Area2D** → `Hurtbox`. **Layer** leer, **Mask** nur `3` (Gegner).
2. Darin eine `CollisionShape2D`, **RectangleShape2D** `10, 12`, Position `0, 0`. Sie deckt fast den ganzen Helden ab.
3. Ein `AudioStreamPlayer` namens `Autsch` mit einem kurzen Treffer-Ton aus 🆓 jsfxr (dort heißt das „Hit/Hurt“).

Diesmal **ohne** Signal, sondern mit Nachfragen in jedem Bild, wie beim Gegner in Hüpfheld. Der Grund ist derselbe wie damals: Steht der Held nach seiner Schonzeit immer noch im Glibber, kommt kein neues `body_entered`. Er soll aber wieder Schaden nehmen.

Jedes Monster sagt selbst, wie viel Schaden es macht. In `glibber.gd`, `fledermaus.gd` und `geist.gd` oben:

```gdscript
@export var schaden := 1   # in halben Herzen
```

### 6.4 Getroffen werden

Der Held bekommt einen dritten Zustand und ein paar neue Konstanten und Variablen:

```gdscript
enum Zustand { LAUFEN, ANGRIFF, GETROFFEN }

const RUECKSTOSS = 160.0          # so schnell fliegt der Held nach einem Treffer zurück
const RUECKSTOSS_ZEIT = 0.2       # so lange fliegt er
const SCHONZEIT = 1.0             # so lange kann ihm danach nichts passieren

var unverwundbar := 0.0
var rueckstoss_zeit := 0.0
```

In `_physics_process` kommt ein neuer Zweig ins `match`, und **nach** dem `match` wird jedes Bild auf Treffer geprüft:

```gdscript
		Zustand.GETROFFEN:
			velocity = velocity.move_toward(Vector2.ZERO, BESCHLEUNIGUNG * delta)
			move_and_slide()
			rueckstoss_zeit -= delta
			if rueckstoss_zeit <= 0:
				zustand = Zustand.LAUFEN
	treffer_pruefen(delta)
```

Und drei neue Funktionen:

```gdscript
# Jedes Bild: Berührt der Held gerade ein Monster?
func treffer_pruefen(delta: float) -> void:
	if unverwundbar > 0:
		unverwundbar -= delta
		$Bild.visible = fmod(unverwundbar, 0.1) < 0.05   # blinken, zehnmal pro Sekunde
		return
	$Bild.visible = true
	for monster in $Hurtbox.get_overlapping_bodies():
		getroffen(monster)
		return   # ein Treffer pro Bild reicht


func getroffen(monster: Node2D) -> void:
	Spielstand.leben -= monster.schaden
	$Autsch.play()
	if Spielstand.leben <= 0:
		sterben()
		return
	unverwundbar = SCHONZEIT
	zustand = Zustand.GETROFFEN
	rueckstoss_zeit = RUECKSTOSS_ZEIT
	velocity = monster.global_position.direction_to(global_position) * RUECKSTOSS   # weg vom Monster


# Ein letztes Mal drehen, dann alles von vorn
func sterben() -> void:
	set_physics_process(false)
	$Bild.visible = true
	var tween := create_tween()
	tween.tween_property($Bild, "rotation", TAU * 3, 1.0)
	tween.tween_property($Bild, "modulate:a", 0.0, 0.3)
	await tween.finished
	Spielstand.neues_spiel()
	get_tree().reload_current_scene()
```

**Eine Falle beim Angriff:** Wird der Held mitten im Zustechen getroffen, ist er im Zustand GETROFFEN. Aber `angreifen()` wartet noch auf das Ende der Animation und setzt danach stur `zustand = Zustand.LAUFEN`. Dann wäre der Rückstoß plötzlich vorbei. Deshalb in `angreifen()` die letzte Zeile ändern:

```gdscript
	await $AnimationPlayer.animation_finished
	if zustand == Zustand.ANGRIFF:   # nur, wenn nicht inzwischen etwas anderes passiert ist
		zustand = Zustand.LAUFEN
```

Das ist eine Regel, die du bei jedem `await` im Hinterkopf haben solltest: **Während man wartet, kann sich die Welt verändern.** Nach dem Warten erst prüfen, ob das, was man vorhatte, noch stimmt.

### 6.5 Lies das Skript

- **`fmod(unverwundbar, 0.1) < 0.05`**: `fmod` ist der Rest einer Division für Kommazahlen. Die Schonzeit läuft von 1,0 rückwärts, der Rest durch 0,1 läuft dabei immer wieder von 0,1 bis 0. Die halbe Zeit ist er kleiner als 0,05, dann ist der Held sichtbar, die andere Hälfte nicht. So blinkt er, ohne dass man sich merken muss, ob er gerade an oder aus ist.
- **`monster.schaden`**: Der Held weiß nicht, ob er einen Glibber, eine Fledermaus oder einen Geist berührt. Er fragt einfach jedes Monster nach seinem Schaden. Neue Monster brauchen nur ein `schaden`, und der Held muss nicht geändert werden.
- **`TAU`**: eine volle Umdrehung im Bogenmaß, also 2π. `TAU * 3` sind drei Umdrehungen.
- **`reload_current_scene()`**: Die Szene wird komplett neu geladen, alle Monster und Töpfe sind wieder da. Nur der Autoload `Spielstand` überlebt. Deshalb muss er vorher mit `neues_spiel()` wieder auf volle Herzen gestellt werden.

### 6.6 Ausprobieren

- Lauf in einen Glibber: Ein halbes Herz wird grau, der Held fliegt zurück und blinkt.
- Bleib im Glibber stehen: Nach der Schonzeit kommt der nächste Treffer.
- Lass dich beim Zustechen treffen: Der Rückstoß wird nicht abgebrochen.
- Verlier alle Herzen: Der Held dreht sich, wird durchsichtig, und alles beginnt mit drei vollen Herzen von vorn.
- Durch eine Tür geflüchtet? Die Herzen bleiben, wie sie sind.

### 6.7 Noch eine Sache aus Kapitel 5

Die Gruppe `monster` hast du in `dungeon.tscn` bei jedem einzelnen Monster eingetragen, nicht in den Szenen `glibber.tscn`, `fledermaus.tscn` und `geist.tscn`. Das funktioniert, aber ein neu hineingezogener Glibber ist dann **nicht** in der Gruppe und schläft nie ein. Trag die Gruppe besser in den drei Szenen beim Root-Node ein. Dann hat jedes neue Monster sie automatisch, und in `dungeon.tscn` kannst du sie wieder entfernen.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 6

1. **Herzen zum Aufsammeln (mittel):** Im Original lassen besiegte Monster manchmal ein Herz fallen. Bau eine Szene `herz.tscn`: eine `Area2D` mit **Mask** `2` (Held), die ein Herz malt (Tipp: dasselbe `HERZ`-Bild wie in der Anzeige, ganz rot). Berührt der Held es, gibt es ein ganzes Herz zurück (`Spielstand.leben += 2`). Beim Sterben lässt ein Glibber mit 30 % Wahrscheinlichkeit eins fallen. Wie erzeugst du eine Szene im Code? Das kennst du von den Münzen aus den Blöcken in Hüpfheld.
2. **Es rumst (leicht):** Bei einem Treffer soll das Bild kurz wackeln: **Screen Shake**. Die Kamera hat dafür die Eigenschaft `offset`: Sie verschiebt das Bild, ohne dass sich `position` ändert. Stell sie für 0,2 Sekunden jedes Bild auf einen zufälligen Wert zwischen −2 und 2 Pixeln, danach wieder auf `Vector2.ZERO`. Warum `offset` und nicht `position`? (Tipp: Was passiert, wenn gerade ein Raumwechsel läuft?)
3. **Letztes Herz (leicht):** Im Original piept es nervig, wenn nur noch ein Herz übrig ist. Mach mit jsfxr einen kurzen Piepton, häng ihn als `AudioStreamPlayer` in die Anzeige und lass ihn alle 0,5 Sekunden spielen, solange `Spielstand.leben <= 2` ist. Wo passt das am besten hin? (Tipp: Das Signal `leben_geaendert` gibt es schon.)
4. **Der Glibber gönnt sich eine Pause (mittel):** Hat ein Glibber den Helden erwischt, soll er kurz in die RUHE wechseln, statt sofort nachzusetzen. Wie erfährt der Glibber davon, dass er getroffen hat? Tipp: Der Held könnte nach dem Treffer `if monster.has_method("hat_getroffen"): monster.hat_getroffen()` aufrufen. Was macht `has_method`, und warum braucht man es hier?
5. **Herzcontainer (knifflig):** In jedem Dungeon gibt es einen Herzcontainer: Er erhöht `max_leben` um 2 und füllt alle Herzen auf. Bau ihn (am besten wieder mit dem `HERZ`-Bild, aber doppelt so groß, also jedes Pixel als 2 × 2-Quadrat). Was passiert in der Anzeige, wenn es mehr als 8 Herzen werden? Wie würdest du eine zweite Reihe anfangen, wie im Original?

---

## Kapitel 7: Schlüssel, Truhen und verschlossene Türen

Ein Dungeon ohne verschlossene Türen ist nur ein Keller. In diesem Kapitel bekommt der Held ein **Inventar**. In Truhen liegen Schlüssel, und jeder Schlüssel öffnet genau eine Tür. Hinter einer goldenen Tür wartet der Bossraum, und die öffnet nur der **Masterschlüssel**. Dazu kommen die beiden Schätze aus dem Original: Die **Karte** zeigt alle Räume, der **Kompass** den Bossraum.

Neu sind ein Inventar als **Dictionary**, eine Klasse mit **`class_name`** und **`static func`**, und ein `@export` mit Auswahlmenü für einen `enum` aus einer anderen Datei.

### 7.1 Was es alles gibt: die Klasse `Gegenstand`

Schlüssel, Masterschlüssel, Karte und Kompass tauchen an vielen Stellen auf: in der Truhe, im Inventar, in der Anzeige, an der Tür. Damit sie überall gleich heißen und gleich aussehen, bekommen sie eine eigene Datei. Sie ist kein Node, sondern nur eine Sammlung von Namen, Bildern und einer Malfunktion.

Neues Skript `gegenstand.gd` (*FileSystem → Rechtsklick → New → Script*, **Inherits** egal, der Inhalt wird ersetzt):

```gdscript
class_name Gegenstand

# Alles, was in einer Truhe liegen und ins Inventar wandern kann
enum Art { SCHLUESSEL, MASTERSCHLUESSEL, KARTE, KOMPASS }

# Zu jeder Art ein Bild aus Text und welche Farbe welches Zeichen hat. Andere Zeichen bleiben durchsichtig.
const BILDER = {
	Art.SCHLUESSEL: [
		[
			"..ooo..",
			".o###o.",
			"o##o##o",
			"o##o##o",
			".o###o.",
			"..o#o..",
			"..o#oo.",
			"..o##o.",
			"..o#oo.",
			"..o##o.",
			"..o#o..",
			"...o...",
		],
		{"o": Color(0.16, 0.12, 0.08), "#": Color(0.78, 0.78, 0.84)},
	],
	Art.MASTERSCHLUESSEL: [
		[
			"...ooo...",
			"..o###o..",
			".o##+##o.",
			"o##+++##o",
			".o##+##o.",
			"..o###o..",
			"...o#o...",
			"...o#oo..",
			"...o###o.",
			"...o#oo..",
			"...o##o..",
			"...o#oo..",
			"...o#o...",
			"....o....",
		],
		{"o": Color(0.24, 0.14, 0.04), "#": Color(1.0, 0.8, 0.3), "+": Color(0.86, 0.12, 0.16)},
	],
	Art.KARTE: [
		[
			"oooooooooo",
			"o##-##-##o",
			"o##-##-##o",
			"o--------o",
			"o##-##-##o",
			"o##-##-xxo",
			"o--------o",
			"o##-##-##o",
			"oooooooooo",
		],
		{"o": Color(0.31, 0.2, 0.1), "#": Color(0.92, 0.84, 0.63), "-": Color(0.63, 0.43, 0.24), "x": Color(0.82, 0.12, 0.12)},
	],
	Art.KOMPASS: [
		[
			"..ooooo..",
			".o#####o.",
			"o###r###o",
			"o##rrr##o",
			"o###o###o",
			"o##sss##o",
			"o###s###o",
			".o#####o.",
			"..ooooo..",
		],
		{"o": Color(0.24, 0.14, 0.04), "#": Color(0.94, 0.94, 0.9), "r": Color(0.82, 0.12, 0.12), "s": Color(0.47, 0.47, 0.55)},
	],
}


# Einen Gegenstand malen. Die Stelle ist die Mitte seiner Unterkante, also da, wo er "steht".
static func malen(leinwand: CanvasItem, art: Art, mitte_unten: Vector2) -> void:
	var bild: Array = BILDER[art][0]
	var ecke := mitte_unten - Vector2(bild[0].length() / 2.0, bild.size()).floor()
	bild_malen(leinwand, bild, ecke, BILDER[art][1])


# Ein Bild aus Text malen, Pixel für Pixel. Geht nur aus dem _draw() der Leinwand heraus.
static func bild_malen(leinwand: CanvasItem, bild: Array, ecke: Vector2, farben: Dictionary) -> void:
	for y in bild.size():
		for x in bild[y].length():
			var zeichen: String = bild[y][x]
			if zeichen in farben:
				leinwand.draw_rect(Rect2(ecke + Vector2(x, y), Vector2.ONE), farben[zeichen])
```

So sehen die vier aus: ein silberner Schlüssel, ein goldener Masterschlüssel mit rotem Stein, eine Karte auf Pergament mit einem roten Kreuz und ein Kompass mit roter Nadel.

Drei neue Dinge stecken darin:

- **`class_name Gegenstand`** gibt der Datei einen Namen, den das ganze Projekt kennt. Überall kannst du jetzt `Gegenstand.Art.SCHLUESSEL` oder `Gegenstand.malen(...)` schreiben, ohne die Datei zu laden. Wie bei einem Autoload, nur ohne Node, der im Spiel herumhängt.
- **`static func`** ist eine Funktion, die zur Klasse gehört und nicht zu einem einzelnen Ding. Man braucht kein `Gegenstand.new()`, um sie aufzurufen. Dafür kennt sie kein `self` und keine Variablen, sondern nur, was man ihr übergibt. Deshalb bekommt sie die **Leinwand** mit: den Node, in dessen `_draw()` gerade gemalt wird. Gemalt wird mit `leinwand.draw_rect(...)`, genau wie in deinen Herzen.
- **`const BILDER = { Art.SCHLUESSEL: [bild, farben], ... }`**: ein Dictionary, das zu jeder Art eine kleine Liste mit zwei Einträgen speichert: `[0]` ist das Bild, `[1]` die Farben. Die Farben sind selbst ein Dictionary: Zeichen → Farbe. Jedes Zeichen, das darin nicht vorkommt, bleibt durchsichtig. So braucht `bild_malen` kein `match` mehr, und jedes Bild darf seine eigenen Zeichen haben.

Die Herzen hast du in den Übungen schon ganz ähnlich gelöst. In Übung 5 kannst du sie hierher umziehen lassen.

### 7.2 Das Inventar im Spielstand

Was der Held besitzt, gehört in den Spielstand. Unten an `spielstand.gd` anhängen, und in `neues_spiel()` das Inventar leeren:

```gdscript
signal inventar_geaendert

var inventar := {}   # Gegenstand.Art -> Anzahl


# Wie viele davon hat der Held?
func anzahl(art: Gegenstand.Art) -> int:
	return inventar.get(art, 0)


func hinzufuegen(art: Gegenstand.Art) -> void:
	inventar[art] = anzahl(art) + 1
	inventar_geaendert.emit()


# Einen verbrauchen, falls der Held einen hat. Die Antwort sagt, ob es geklappt hat.
func verbrauchen(art: Gegenstand.Art) -> bool:
	if anzahl(art) == 0:
		return false
	inventar[art] -= 1
	inventar_geaendert.emit()
	return true
```

In `neues_spiel()` dazu:

```gdscript
	inventar.clear()
	inventar_geaendert.emit()
```

- **Ein Dictionary als Inventar:** Der Schlüssel ist die Art des Gegenstands, der Wert, wie viele der Held davon hat. Bei Karte und Kompass ist das nur 0 oder 1, bei normalen Schlüsseln auch mal 3. Ein neuer Gegenstand in Kapitel 10? Ein neuer Eintrag im `enum`, fertig, der Spielstand muss nicht geändert werden.
- **`inventar.get(art, 0)`**: Holt den Wert zum Schlüssel. Steht der Schlüssel noch gar nicht im Dictionary, kommt die `0` zurück statt eines Fehlers.
- **`verbrauchen` antwortet mit `bool`**: Wer eine Tür aufschließen will, fragt nicht erst „Hast du einen?“ und nimmt dann einen weg. Er sagt nur „Nimm einen“ und erfährt dabei, ob es geklappt hat. So kann man nie vergessen, einen Schlüssel abzuziehen.
- **Warum leeren beim Tod?** `reload_current_scene()` stellt alle Truhen wieder zu. Würde das Inventar überleben, könnte man sterben, die Truhe noch einmal öffnen und Schlüssel sammeln. Also beginnt nach dem Tod alles von vorn. Wie man Fortschritt richtig behält, kommt in Kapitel 9.

### 7.3 Die Hand des Helden

Truhen und Türen öffnet man mit der **Angriffstaste**: Steht etwas Benutzbares direkt vor dem Helden, wird es benutzt, sonst wird zugestochen. Woher weiß der Held, was vor ihm steht? Mit einer kleinen Fläche in Blickrichtung, der **Hand**.

Der Node `Schwert` dreht sich ja schon in die Blickrichtung. Die Hand hängt sich einfach dazu:

1. In `held.tscn`: Kind von `Schwert` → **Area2D** → `Hand`. **Layer** leer, **Mask** nur `1` (Welt). **Monitoring** und **Monitorable** bleiben an. (Ohne Monitorable bemerkt die Hand in Godot 4.7 keine StaticBody2D, obwohl sie selbst nur sucht.)
2. Darin eine `CollisionShape2D`, **RectangleShape2D** `8, 8`, Position `0, -8`: ein Stückchen vor dem Helden. Weiter weg darf sie nicht: Steht der Held unter einer Truhe, würde die Hand sonst knapp darüber in der Luft greifen.
3. Damit die Hand immer dahin zeigt, wohin der Held schaut, und nicht nur beim Zustechen, wandert die Zeile `$Schwert.rotation = blick.angle() + PI / 2` aus `angreifen()` nach `laufen()`, direkt unter `blick = vier_richtungen(richtung)`.

Neue Funktion im Helden:

```gdscript
# Steht vor dem Helden etwas, das man benutzen kann? Dann benutzen statt zustechen.
func benutzen() -> bool:
	for ding in $Schwert/Hand.get_overlapping_bodies():
		if ding.has_method("benutzen"):
			ding.benutzen()
			return true
	return false
```

Und in `_physics_process` im Zweig LAUFEN:

```gdscript
			if Input.is_action_just_pressed("angriff") or angriff_buffer_timer > 0:
				angriff_buffer_timer = 0.0
				if not benutzen():
					angreifen()
```

- **`has_method("benutzen")`** kennst du aus Übung 4 von Kapitel 6. Die Hand berührt auch Wände und Säulen, die liegen ja auch auf Ebene 1. Die haben aber kein `benutzen()` und werden übersprungen. Jedes Ding, das man benutzen kann, sagt das einfach, indem es diese Funktion hat. Der Held muss keine Truhen und keine Türen kennen.
- **`angriff_buffer_timer = 0.0`**: Dein vorgemerkter Angriff aus Kapitel 3 hat den Timer bisher nicht zurückgesetzt, er lief einfach ab. Das ging gut, solange danach immer ein Angriff von 0,25 Sekunden kam. Jetzt kann das Benutzen sofort fertig sein. Ohne das Zurücksetzen würde im nächsten Bild der Timer noch laufen, und der Held würde zusätzlich zustechen.

### 7.4 Die Truhe

Zuerst eine kleine Szene für den **Schatz**, der beim Öffnen aus der Truhe aufsteigt. Neues Skript `schatz.gd`:

```gdscript
class_name Schatz
extends Node2D

var art := Gegenstand.Art.SCHLUESSEL


func _draw() -> void:
	Gegenstand.malen(self, art, Vector2.ZERO)
```

Neue Szene: Root **Node2D** → `Schatz`, Skript `schatz.gd` anhängen, speichern als `schatz.tscn`. Mehr braucht er nicht.

Dann die Truhe:

```
Truhe (StaticBody2D)
├── Bild (Sprite2D)
├── CollisionShape2D
└── Fanfare (AudioStreamPlayer)
```

1. `Truhe`: **StaticBody2D**, Layer `1` (Welt), Mask leer.
2. `Bild`: Kachelblatt, Frame `90` (geschlossen). Frame `91` ist die offene Truhe.
3. `CollisionShape2D`: `14, 10` auf `0, 3`. Etwas größer als bei Säule und Topf, damit die Hand sie gut erwischt.
4. `Fanfare`: ein kurzer, fröhlicher Ton. Aus 🆓 jsfxr (**Powerup**) oder ein kurzes Stück aus den Kenney-Jingles von Hüpfheld.
5. Skript:

```gdscript
extends StaticBody2D

const SCHATZ = preload("res://schatz.tscn")
const BILD_OFFEN = 91

@export var inhalt: Gegenstand.Art = Gegenstand.Art.SCHLUESSEL

var offen := false


# Der Held steht davor und drückt den Knopf
func benutzen() -> void:
	if offen:
		return
	offen = true
	$Bild.frame = BILD_OFFEN
	$Fanfare.play()
	Spielstand.hinzufuegen(inhalt)
	zeigen()


# Der Schatz steigt aus der Truhe auf, bleibt kurz stehen und verblasst
func zeigen() -> void:
	var schatz: Schatz = SCHATZ.instantiate()
	schatz.art = inhalt
	schatz.position = Vector2(0, -4)
	add_child(schatz)
	var tween := schatz.create_tween()
	tween.tween_property(schatz, "position:y", -18.0, 0.5)
	tween.tween_interval(0.6)
	tween.tween_property(schatz, "modulate:a", 0.0, 0.3)
	tween.tween_callback(schatz.queue_free)
```

6. Speichern als `truhe.tscn`.

**`@export var inhalt: Gegenstand.Art`**: Weil `Gegenstand` einen `class_name` hat, kennt der Inspector seinen `enum`. Wähl eine Truhe im Dungeon aus: Bei **Inhalt** gibt es ein Auswahlmenü mit allen vier Arten, wie bei deinen Blöcken in Hüpfheld.

**`var schatz: Schatz`**: Auch die Schatz-Szene hat einen `class_name`. Dadurch weiß Godot, dass das Ergebnis von `instantiate()` ein `Schatz` mit einer Variablen `art` ist, und kann `schatz.art = inhalt` prüfen. Bei deinem `herzchen` in Kapitel 6 stand nur `var herzchen = ...` ohne Typ. Das funktioniert auch, aber ein Tippfehler wie `herzchen.dorp` fällt erst beim Spielen auf.

### 7.5 Verschlossene Türen

```
Tuer (StaticBody2D)
├── Bilder (Node2D)
│   ├── Links (Sprite2D)
│   └── Rechts (Sprite2D)
└── CollisionShape2D
```

1. `Tuer`: **StaticBody2D**, Layer `1`, Mask leer.
2. `Bilder`: ein **Node2D**, nur damit beide Hälften zusammen wackeln können.
3. `Links`: Kachelblatt, Frame `46`, Position `-8, 0`. `Rechts`: Frame `47`, Position `8, 0`. Zusammen ergeben sie eine Doppeltür, genau so breit wie deine Tür-Lücken oben und unten.
4. `CollisionShape2D`: `32, 16`.
5. Skript:

```gdscript
extends StaticBody2D

@export var master := false   # braucht den Masterschlüssel statt eines normalen


func _ready() -> void:
	if master:
		$Bilder.modulate = Color(1.0, 0.85, 0.4)   # golden: Hier geht es zum Boss


# Der Held steht davor und drückt den Knopf
func benutzen() -> void:
	var schluessel := Gegenstand.Art.MASTERSCHLUESSEL if master else Gegenstand.Art.SCHLUESSEL
	if not Spielstand.verbrauchen(schluessel):
		wackeln()
		return
	$CollisionShape2D.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)


# Kein Schlüssel: Die Tür rüttelt nur
func wackeln() -> void:
	var tween := create_tween()
	for i in 3:
		tween.tween_property($Bilder, "position:x", 1.0, 0.04)
		tween.tween_property($Bilder, "position:x", -1.0, 0.04)
	tween.tween_property($Bilder, "position:x", 0.0, 0.04)
```

6. Speichern als `tuer.tscn`.

**Einsetzen:** Eine Tür kommt in die Wand-Lücke **des Raums, aus dem man kommt**, also in einen der beiden Teile des Gangs. Für Türen in der linken oder rechten Wand: **Rotation** `90`. Bei 90° bleiben Pixel scharf.

Der **Masterschlüssel** ist einfach eine Tür mit angehaktem **Master** im Inspector. Sie wird golden und will einen Masterschlüssel statt eines normalen. Sonst ist alles gleich. Ein einziges Häkchen statt einer zweiten Szene.

Eine Kleinigkeit zu **`wackeln()`**: Die Tween-Schleife hängt sechs Schritte hintereinander, die dann nacheinander ablaufen. Das `for` läuft also sofort durch, gewackelt wird erst danach.

### 7.6 Der Bossraum

Für den Masterschlüssel brauchen wir einen Bossraum. Den Boss selbst gibt es erst in Kapitel 10, aber den Raum kannst du schon bauen:

1. Mal einen Raum, der nur durch eine einzige Tür erreichbar ist, und setz dort eine Tür mit **Master** an.
2. Stell in den Raum einen **Marker2D** namens `Bossraum` und steck ihn in die Gruppe `boss`. In Kapitel 10 übernimmt der Boss selbst diese Gruppe, bis dahin hält der Marker den Platz frei.
3. Versteck den Masterschlüssel in einer Truhe, möglichst weit weg und hinter einer normalen verschlossenen Tür. Im Original liegt er meistens tief im Dungeon, kurz bevor man den Boss erreicht.
4. Verteil Karte, Kompass und ein paar Schlüssel auf andere Truhen. Achte darauf, dass man nie hängenbleibt: Bevor eine Tür kommt, muss der Schlüssel dafür erreichbar sein.

### 7.7 Das Inventar in der Anzeige

In der CanvasLayer `Anzeige` ein **Node2D** namens `Inventar`, Position etwa `96, 0`, also zwischen Karte und Herzen. Darin ein **Label** namens `Anzahl` in Kenney Pixel, Position `9, 18`. Skript an `Inventar`:

```gdscript
extends Node2D


func _ready() -> void:
	Spielstand.inventar_geaendert.connect(aktualisieren)
	aktualisieren()


func aktualisieren() -> void:
	$Anzahl.text = "x%d" % Spielstand.anzahl(Gegenstand.Art.SCHLUESSEL)
	queue_redraw()


func _draw() -> void:
	Gegenstand.malen(self, Gegenstand.Art.SCHLUESSEL, Vector2(4, 30))
	if Spielstand.anzahl(Gegenstand.Art.MASTERSCHLUESSEL) > 0:
		Gegenstand.malen(self, Gegenstand.Art.MASTERSCHLUESSEL, Vector2(28, 30))
	if Spielstand.anzahl(Gegenstand.Art.KARTE) > 0:
		Gegenstand.malen(self, Gegenstand.Art.KARTE, Vector2(46, 21))
	if Spielstand.anzahl(Gegenstand.Art.KOMPASS) > 0:
		Gegenstand.malen(self, Gegenstand.Art.KOMPASS, Vector2(46, 34))
```

Die Positionen sind ein Vorschlag. Schieb sie hin, bis es dir gefällt.

### 7.8 Karte und Kompass auf der Karte

Jetzt kommt, was du dir für die Karte gewünscht hast.

1. Den TileMapLayer `Waende` mit Rechtsklick → **Access as Unique Name** für die Karte erreichbar machen.
2. In `karte.gd` eine neue Variable und ein `_ready()`:

```gdscript
var alle_raeume := {}         # jeder Raum, in dem eine Wandkachel liegt


func _ready() -> void:
	# Welche Räume gibt es? Jede Wandkachel verrät ihren Raum.
	for zelle in %Waende.get_used_cells():
		alle_raeume[Vector2i((Vector2(zelle) / Vector2(16, 11)).floor())] = true
	Spielstand.inventar_geaendert.connect(queue_redraw)
```

3. Und ein neues `_draw()`:

```gdscript
func _draw() -> void:
	# Mit der Karte: alle Räume, auch die unbesuchten, ganz dunkel
	if Spielstand.anzahl(Gegenstand.Art.KARTE) > 0:
		for raum in alle_raeume:
			draw_rect(kasten(raum), Color(0.25, 0.25, 0.25))
	for raum in besucht:
		draw_rect(kasten(raum), Color.DARK_GRAY)
	# Mit dem Kompass: der Bossraum in Rot
	var boss: Node2D = get_tree().get_first_node_in_group("boss")
	if boss and Spielstand.anzahl(Gegenstand.Art.KOMPASS) > 0:
		draw_rect(kasten(%Camera2D.raum_von(boss.global_position)), Color.RED)
	draw_rect(kasten(aktuell), Color.WHITE)
```

- **`get_used_cells()`** liefert die Koordinaten aller Zellen, in denen eine Kachel liegt. Jede Wandkachel wird zum Raum umgerechnet, und ein Dictionary merkt sich jeden Raum nur einmal. So weiß die Karte, welche Räume es gibt, ohne dass du sie irgendwo aufzählen musst. Malst du einen neuen Raum, ist er von selbst auf der Karte.
- **Warum `Vector2(zelle) / Vector2(16, 11)` und nicht gleich mit ganzen Zahlen?** Eine Division ganzer Zahlen rundet in Richtung null: −1 ÷ 16 ergibt 0 statt −1. Die Zelle (−1, 0) würde so in Raum (0, 0) landen statt in Raum (−1, 0). Mit Kommazahlen und `floor()` stimmt es auch links und oberhalb vom Start.
- **`%Camera2D.raum_von(...)`**: Die Karte rechnet den Raum des Bosses nicht selbst aus, sondern fragt die Kamera. Die Formel steht so nur an einer Stelle.
- **Reihenfolge beim Malen:** Erst alle Räume dunkel, darüber die besuchten heller, darüber der Bossraum rot, ganz oben der aktuelle Raum weiß. Was später gemalt wird, liegt oben.

### 7.9 Ausprobieren

- Stell dich vor eine Truhe und drück die Angriffstaste: Sie geht auf, die Fanfare spielt, der Schatz steigt auf, und in der Anzeige steht `x1`.
- Noch einmal drücken: nichts, die Truhe ist leer. Steht der Held daneben und schaut weg, sticht er zu.
- Geh an eine verschlossene Tür: Mit Schlüssel verschwindet sie, und die Anzeige zählt herunter. Ohne Schlüssel rüttelt sie nur.
- Die goldene Tür rüttelt, auch wenn du normale Schlüssel hast.
- Öffne die Truhe mit der Karte: Auf der Karte erscheinen alle Räume. Mit dem Kompass leuchtet der Bossraum rot.
- Stirb mit Schlüsseln in der Tasche: Alles ist weg, alle Truhen sind wieder zu.

### 7.10 Noch drei Dinge aus Kapitel 6

Sie wirken sich auf das Verhalten aus:

1. **`max_leben` hat keine Grenze.** In `spielstand.gd` begrenzt der Setter nur `leben` auf höchstens 20. `max_leben` selbst kann aber beliebig wachsen. Nach dem elften Herzcontainer malt die Anzeige 11 Herzen in drei Reihen, obwohl nur 10 gefüllt werden können. Abhilfe: ein Setter auch für `max_leben`, wie ich ihn bei der Herzanzahl vorgeschlagen habe: `max_leben = clampi(wert, START_LEBEN, MAX_HERZEN * 2)`. Dann kann der Setter von `leben` wieder einfach `clampi(wert, 0, max_leben)` sein.
2. **`start_leben` im Glibber merkt sich den falschen Wert.** `var start_leben := leben` steht oben bei den Variablen. Diese Zeile läuft, **bevor** Godot die Werte aus dem Inspector einträgt. Gibst du einem Glibber im Inspector `leben = 3`, merkt sich `start_leben` trotzdem die 2 aus dem Skript, und `heilen()` macht aus ihm einen Glibber mit 2 Leben. Abhilfe: `var start_leben := 0` oben und `start_leben = leben` in `_ready()`. Dann sind die Inspector-Werte schon eingetragen. **Aber Achtung:** Die Kamera steht im Szenenbaum über den Monstern, ihr `_ready()` läuft also zuerst und ruft `monster_wecken()` → `heilen()` auf, bevor die Glibber im Startraum ihr `start_leben` kennen. Die hätten dann 0 Leben. Darum wartet die Kamera in ihrem `_ready()` mit `monster_wecken.call_deferred()`: „Mach das, wenn alle anderen fertig sind.“
3. **Der Warnton piept auch beim Sterben.** `Spielstand.leben <= 2` ist auch bei 0 wahr, also piept es während der letzten Drehung. Mit `0 < Spielstand.leben and Spielstand.leben <= 2` ist Ruhe.

Und ein Hinweis ohne Fehler: Dein Screen Shake setzt den Offset nur einmal beim Treffer und erst nach dem Rückstoß wieder auf null. Das ist ein einzelner Ruck, kein Wackeln. Wenn es dir so gefällt, lass es. Sonst stell `offset` während GETROFFEN in jedem Bild neu ein.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 7

1. **Die Mimik (mittel):** Frame `92` ist eine Truhe mit Zähnen und Zunge. Gib der Truhe `@export var mimik := false` und `@export var schaden := 2`. Eine Mimik zeigt beim Öffnen Frame `92` und beißt zu: Der Held verliert ein Herz und fliegt zurück. Tipp: Der Held hat schon eine Funktion, die genau das macht, wenn man ihr ein Ding mit `schaden` gibt. Wie kommt die Truhe an den Helden? (Tipp: Gruppe `held`.) 😬
2. **Türen auf der Karte (mittel):** Wie besprochen: Für jeden Raum, den die Karte zeigt, nachsehen, ob in der Mitte einer Wand eine Wandkachel fehlt. Die Mitte der oberen Wand ist die Zelle `Vector2i(raum.x * 16 + 7, raum.y * 11)`. `%Waende.get_cell_source_id(zelle)` liefert `-1`, wenn dort keine Kachel liegt. Dann einen kleinen Strich vom Kästchen zum Nachbarn malen. Wo liegen die Mitten der anderen drei Wände?
3. **Belohnung für einen leeren Raum (mittel):** Im Original erscheint oft ein Schlüssel, wenn alle Monster eines Raums besiegt sind. Bau eine Szene `belohnung.tscn` (eine Truhe, die erst unsichtbar ist und keine Kollision hat). Sie prüft in jedem Bild: Gibt es in meinem Raum noch ein Monster aus der Gruppe `monster`? Wenn nicht, taucht sie mit einem Geräusch auf. Tipp: `get_tree().get_nodes_in_group("monster")` und `%Camera2D.raum_von()`. Achtung: Was passiert mit Monstern, die gerade schrumpfen und gleich weg sind?
4. **Klick und Klack (leicht):** Ein Geräusch für die verschlossene Tür beim Rütteln und eins beim Aufschließen. Das Aufschließen ist knifflig: Die Tür löscht sich mit `queue_free()`, und der Ton wäre sofort mit weg. Wo kann der Ton stattdessen hängen? Das kennst du von den Münzen in Hüpfheld.
5. **Aufräumen (leicht):** Du hast jetzt zwei Malfunktionen für Bilder aus Text: deine eigene in den Herzen und `Gegenstand.bild_malen()`. Zieh `HERZ` und deinen `HERZCONTAINER` aus dem Spielstand nach `Gegenstand` um und lass `herz.gd` und `herzcontainer.gd` mit `Gegenstand.bild_malen()` malen. Die Herzanzeige mit ihren halben Herzen darf ihre eigene Schleife behalten. Warum?

---

## Kapitel 8: Dialoge, Münzen und ein Händler

Bisher redet in deinem Dungeon niemand. Das ändert sich jetzt: Schilder geben schlechte Ratschläge, ein alter Mann schenkt dem Helden etwas, und ein Händler will Geld sehen. Dafür braucht der Held **Münzen**, die Monster fallen lassen.

Neu sind eine **Autoload-Szene** (nicht nur ein Skript), **`await` auf eigene Funktionen**, die Schreibmaschinen-Schrift mit **`visible_characters`**, **`_unhandled_input`** statt `Input.is_action_just_pressed`, **`@export_multiline`** für Texte im Inspector, ein Parameter mit **Standardwert** und **geerbte Szenen**.

### 8.1 Die Dialogbox

Die Dialogbox muss von überall erreichbar sein: vom Schild, vom alten Mann, vom Händler. Wie `Spielstand` wird sie ein Autoload, diesmal aber eine ganze **Szene** mit Nodes darin.

Neue Szene:

```
Dialog (CanvasLayer)
└── Rahmen (ColorRect)
    ├── Innen (ColorRect)
    ├── Text (Label)
    ├── Auswahl (Label)
    └── Weiter (Polygon2D)
```

1. `Dialog`: **CanvasLayer**, **Layer** `10` (über der Anzeige). Unter **Process** → **Mode**: **Always**. Die Box muss weiterlaufen, während das Spiel angehalten ist.
2. `Rahmen`: **ColorRect**, unter **Layout → Transform**: Position `8, 164`, Size `240, 56`. Farbe hellgrau. Das ist der Rand.
3. `Innen`: **ColorRect**, Position `1, 1`, Size `238, 54`, schwarz. So bleibt rundherum ein Pixel Rand stehen.
4. `Text`: **Label**, Position `6, 3`, Size `228, 50`. **Label Settings** mit Kenney Pixel wie in der Anzeige. **Autowrap Mode**: **Word (Smart)**, dann bricht der Text von selbst um. Schreib zum Ausprobieren einen langen Satz hinein: Vier Zeilen passen in die Box.
5. `Auswahl`: **Label**, Position `120, 40`, Size `114, 13`, gleiche Schrift, **Horizontal Alignment**: **Right**. Text `> Ja     Nein`.
6. `Weiter`: **Polygon2D**, Position `229, 49`. Unter **Polygon** drei Punkte eintragen: `0, 0`, `6, 0` und `3, 3`. Ein kleines Dreieck, das „Es geht weiter“ sagt.
7. Speichern als `dialog.tscn`.

Skript an `Dialog`:

```gdscript
extends CanvasLayer

signal fertig

const TEMPO = 40.0   # Buchstaben pro Sekunde

var seiten: Array[String] = []   # was noch kommt
var buchstaben := 0.0            # wie viele Buchstaben schon zu sehen sind, mit Komma
var fragend := false             # wartet die letzte Seite auf Ja oder Nein?
var antwort := true

@onready var text: Label = $Rahmen/Text


func _ready() -> void:
	hide()


# Eine oder mehrere Seiten nacheinander zeigen. Solange steht das Spiel still.
func zeigen(neue_seiten: Array[String]) -> void:
	seiten = neue_seiten.duplicate()
	get_tree().paused = true
	show()
	umblaettern()
	await fertig


# Eine Frage stellen. Die Antwort ist true für Ja und false für Nein.
func frage(seite: String) -> bool:
	fragend = true
	antwort = true
	await zeigen([seite])
	fragend = false
	return antwort


func umblaettern() -> void:
	text.text = seiten.pop_front()
	text.visible_characters = 0
	buchstaben = 0.0


func _process(delta: float) -> void:
	if not visible:
		return
	buchstaben += TEMPO * delta
	text.visible_characters = int(buchstaben)
	var letzte := seiten.is_empty()
	# Blinkender Pfeil: Es geht weiter
	$Rahmen/Weiter.visible = alles_da() and not (letzte and fragend) and Time.get_ticks_msec() % 600 < 300
	$Rahmen/Auswahl.visible = alles_da() and letzte and fragend
	$Rahmen/Auswahl.text = "> Ja     Nein" if antwort else "  Ja   > Nein"


func alles_da() -> bool:
	return buchstaben >= text.get_total_character_count()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if $Rahmen/Auswahl.visible and (event.is_action_pressed("links") or event.is_action_pressed("rechts")):
		antwort = not antwort
	elif event.is_action_pressed("angriff"):
		if not alles_da():
			buchstaben = text.get_total_character_count()   # Ungeduldig? Dann alles auf einmal.
		elif not seiten.is_empty():
			umblaettern()
		else:
			schliessen()


func schliessen() -> void:
	hide()
	# Erst weiterspielen, wenn die Taste losgelassen ist. Sonst sticht der Held mit demselben Druck gleich zu.
	while Input.is_action_pressed("angriff"):
		await get_tree().process_frame
	get_tree().paused = false
	fertig.emit()
```

Zum Schluss: *Project → Project Settings → Globals → Autoload*, bei **Path** `res://dialog.tscn` wählen, **Node Name** `Dialog`, **Add**. Ab jetzt kann jedes Skript `Dialog.zeigen(["Hallo!"])` schreiben.

### 8.2 Lies das Skript

- **`await fertig`**: `zeigen()` zeigt die erste Seite und wartet dann, bis das Signal `fertig` kommt, also bis die letzte Seite weggedrückt ist. Wer `zeigen()` aufruft, kann selbst entscheiden: Mit `await Dialog.zeigen(...)` wartet er mit, ohne `await` macht er sofort weiter. Beides brauchen wir gleich.
- **`frage()` gibt eine Antwort zurück**, aber erst später. `var ja: bool = await Dialog.frage("Kaufen?")` wartet, bis der Spieler sich entschieden hat, und hat dann `true` oder `false` in der Hand. Hier muss der Typ dastehen (`: bool`), mit `:=` kann Godot ihn bei `await` nicht erraten.
- **`visible_characters`**: Ein Label kann nur die ersten paar Buchstaben zeigen. `buchstaben` zählt mit Komma hoch, 40 pro Sekunde, und das Label zeigt davon den ganzen Teil. Das ist die Schreibmaschine.
- **`seiten.pop_front()`** nimmt die erste Seite aus der Liste und gibt sie zurück. Ist die Liste leer, war das die letzte Seite. Darum am Anfang `duplicate()`: Sonst würde `pop_front()` die Liste des Schilds leer räumen, und beim zweiten Lesen stünde nichts mehr drauf.
- **`get_tree().paused = true`** kennst du von der Kamera. Monster, Held, Herzanzeige: Alles bleibt stehen. Nur Nodes mit Process Mode **Always** laufen weiter: die Kamera und jetzt die Dialogbox.
- **`_unhandled_input(event)` statt `Input.is_action_just_pressed()`**: Der Held öffnet die Box in seinem `_physics_process`, weil die Angriffstaste gerade gedrückt wurde. Würde die Box mit `is_action_just_pressed` fragen, wäre derselbe Druck im selben Bild noch „gerade gedrückt“, und die Box würde sofort weiterblättern. `_unhandled_input` bekommt dagegen jeden Tastendruck genau einmal als **Ereignis**, und zwar am Anfang des Bilds, bevor der Held überhaupt dran ist. Der Druck, der die Box geöffnet hat, ist da schon vorbei.
- **Warten, bis die Taste losgelassen ist**: Beim Schließen gibt es das umgekehrte Problem. Die Box geht zu, das Spiel läuft weiter, und der Held sieht in seinem `_physics_process`: Angriffstaste gerade gedrückt! Er würde gleich wieder zustechen oder das Schild noch einmal lesen. Darum wartet `schliessen()`, bis die Taste oben ist.
- **`[seite]`** in `frage()` macht aus einem einzelnen Text eine Liste mit einem Eintrag, weil `zeigen()` eine Liste will.

### 8.3 Ein Schild

```
Schild (StaticBody2D)
├── Bild (Sprite2D)
└── CollisionShape2D
```

1. `Schild`: **StaticBody2D**, Layer `1`, Mask leer. Wie die Truhe, damit die Hand es findet.
2. `Bild`: Kachelblatt, Frame `65` (eine Steintafel).
3. `CollisionShape2D`: `14, 10` auf `0, 3`.
4. Skript:

```gdscript
extends StaticBody2D

@export_multiline var seiten: Array[String] = ["Hier könnte Ihre Werbung stehen."]


# Lesen statt zustechen
func benutzen() -> void:
	Dialog.zeigen(seiten)
```

5. Speichern als `schild.tscn` und ein paar Schilder in den Dungeon stellen.

**`@export_multiline var seiten: Array[String]`**: Im Inspector steht jetzt eine Liste. Mit **Add Element** kommt eine Seite dazu, und jede Seite hat ein großes Textfeld. Jedes Schild bekommt so seinen eigenen Text, ohne neues Skript. Ein paar Ideen:

- „Achtung, Glibber! Bitte nicht füttern.“
- „Links: Ausgang. Rechts: auch Ausgang. Schilder dürfen hier lügen.“
- „Dieses Schild wurde von einem Monster aufgestellt. Gehen Sie weiter. Hier gibt es nichts zu sehen.“

Am Schild siehst du, warum die Hand aus Kapitel 7 nur nach `benutzen()` fragt: Der Held muss nichts über Schilder wissen.

### 8.4 Der alte Mann

Eine Figur ist ein Schild, das sich merkt, ob man schon mit ihr geredet hat, und beim ersten Mal etwas schenken kann.

Zuerst eine Kleinigkeit zum Aufräumen. Den aufsteigenden Schatz braucht jetzt nicht nur die Truhe, sondern auch der alte Mann und gleich der Händler. Also wandert er in die Klasse `Schatz`. `schatz.gd` bekommt unten eine `static func`:

```gdscript
# Über wo einen Schatz aufsteigen lassen, kurz zeigen, verblassen.
# Der Tween kommt zurück, falls noch jemand etwas anhängen will.
static func zeigen(wo: Node2D, was: Gegenstand.Art) -> Tween:
	var schatz: Schatz = load("res://schatz.tscn").instantiate()
	schatz.art = was
	schatz.position = Vector2(0, -4)
	wo.add_child(schatz)
	var tween := schatz.create_tween()
	tween.tween_property(schatz, "position:y", -18.0, 0.5)
	tween.tween_interval(0.6)
	tween.tween_property(schatz, "modulate:a", 0.0, 0.3)
	tween.tween_callback(schatz.queue_free)
	return tween
```

In `truhe.gd` wird `zeigen()` dadurch ganz kurz. Dein Bildwechsel hängt sich einfach an den zurückgegebenen Tween:

```gdscript
func zeigen() -> void:
	var tween := Schatz.zeigen(self, inhalt)
	tween.tween_property($Bild, "frame", BILD_OFFEN, 0.0)
```

Die Zeile `const SCHATZ = preload(...)` oben in der Truhe kann weg.

- **Warum `load()` und nicht `preload()`?** `schatz.tscn` enthält `schatz.gd`. Würde `schatz.gd` mit `preload` wiederum `schatz.tscn` laden, bräuchte jede Datei die andere zuerst. `load()` lädt erst, wenn die Funktion wirklich läuft, und dann sind beide längst da.
- **`wo` und `was`** heißen nicht `art`, weil `Schatz` schon eine Variable `art` hat. Gleiche Namen würden sich verdecken, und Godot würde warnen.

Jetzt die Figur. Gleicher Aufbau wie das Schild (StaticBody2D, Bild, CollisionShape2D), Frame `84` (ein alter Zauberer mit Bart). Skript `figur.gd`:

```gdscript
extends StaticBody2D

@export_multiline var seiten: Array[String] = ["Es ist gefährlich, allein zu gehen!", "Nimm das hier."]
@export_multiline var danach: Array[String] = ["Was denn noch? Mehr hab ich nicht."]
@export var geschenk: Gegenstand.Art = Gegenstand.Art.MUENZE
@export var geschenk_anzahl := 0   # 0 heißt: kein Geschenk

var schon_geredet := false


# Beim ersten Mal reden und vielleicht etwas schenken, danach nur noch reden
func benutzen() -> void:
	if schon_geredet:
		Dialog.zeigen(danach)
		return
	schon_geredet = true
	await Dialog.zeigen(seiten)
	if geschenk_anzahl > 0:
		for i in geschenk_anzahl:
			Spielstand.hinzufuegen(geschenk)
		Schatz.zeigen(get_tree().get_first_node_in_group("held"), geschenk)
```

Speichern als `figur.tscn`. `Gegenstand.Art.MUENZE` gibt es noch nicht, Godot meckert. Das kommt im nächsten Abschnitt.

- **`await Dialog.zeigen(seiten)`**: Der alte Mann redet erst zu Ende, dann gibt er das Geschenk her. Ohne `await` käme der Schatz schon während der ersten Seite.
- **`Schatz.zeigen(held, ...)`**: Der Schatz steigt diesmal über dem **Helden** auf, nicht über der Figur. Als hielte der Held ihn hoch.

Stell den alten Mann in einen eigenen kleinen Raum, am besten gleich neben dem Start. Mit **Geschenk** `MUENZE` und **Geschenk Anzahl** `10` hat der Held gleich Taschengeld für den Händler. Eigene Texte sind ausdrücklich erwünscht. Vorschlag für **Danach**: „Ich hab dir doch schon alles gegeben. Mein ganzes Erspartes. Für so was wie dich.“

### 8.5 Münzen

**`gegenstand.gd`**: Eine neue Art hinten an den `enum`, also `..., HERZCONTAINER, MUENZE }`. **Wichtig: hinten anhängen.** Der Inspector speichert für jede Truhe nur die Nummer ihres Inhalts. Käme `MUENZE` an den Anfang, würde aus jedem Schlüssel in deinen Truhen ein Masterschlüssel.

Dazu ein Bild in `BILDER`:

```gdscript
	Art.MUENZE: [
		[
			"..oooo..",
			".o####o.",
			"o##++##o",
			"o#+####o",
			"o#+####o",
			"o######o",
			".o####o.",
			"..oooo..",
		],
		{"o": BRAUN, "#": GOLD, "+": Color(1.0, 0.95, 0.7)},
	],
```

Und für den Händler, der gleich über seine Ware reden will, ein Name zu jeder Art (oben, unter dem `enum`):

```gdscript
# So heißen sie, wenn jemand über sie redet
const NAMEN = {
	Art.SCHLUESSEL: "Ein Schlüssel",
	Art.MASTERSCHLUESSEL: "Der Masterschlüssel",
	Art.KARTE: "Die Karte",
	Art.KOMPASS: "Der Kompass",
	Art.HERZ: "Ein Herz",
	Art.HERZCONTAINER: "Ein Herzcontainer",
	Art.MUENZE: "Eine Münze",
}
```

**`spielstand.gd`**: Münzen sind einfach ein Eintrag im Inventar. Das Dictionary aus Kapitel 7 muss dafür nicht geändert werden. Nur `verbrauchen()` muss jetzt mehr als einen auf einmal nehmen können:

```gdscript
# Einen oder mehrere verbrauchen, falls der Held genug hat. Die Antwort sagt, ob es geklappt hat.
func verbrauchen(art: Gegenstand.Art, menge := 1) -> bool:
	if anzahl(art) < menge:
		return false
	inventar[art] -= menge
	inventar_geaendert.emit()
	return true
```

**`menge := 1`** ist ein Parameter mit **Standardwert**: Wer ihn weglässt, bekommt 1. Deine Türen rufen weiter `Spielstand.verbrauchen(schluessel)` auf und müssen nicht geändert werden. Der Händler schreibt `verbrauchen(Gegenstand.Art.MUENZE, 25)`.

**Das Fundstück**: Etwas, das auf dem Boden liegt und eingesammelt wird. Dein Herz macht genau das schon, aber nur für Herzen. Das Fundstück kann jede Art sein.

```
Fundstueck (Area2D)
├── CollisionShape2D
└── Klimper (AudioStreamPlayer)
```

1. `Fundstueck`: **Area2D**, Layer leer, Mask nur `2` (Held).
2. `CollisionShape2D`: `10, 10`.
3. `Klimper`: Ein kurzer Münzton, in 🆓 jsfxr ist das **Pickup/Coin**.
4. Das Signal `body_entered` von `Fundstueck` mit sich selbst verbinden.
5. Skript `fundstueck.gd`:

```gdscript
extends Area2D

const ZEIT_ZUM_SAMMELN = 15.0
const ZEIT_VERSCHWINDEN = 5.0

@export var art: Gegenstand.Art = Gegenstand.Art.MUENZE

var drop := false   # von einem Monster fallen gelassen: verschwindet nach einer Weile
var zeit := ZEIT_ZUM_SAMMELN


func _physics_process(delta: float) -> void:
	if drop:
		zeit -= delta
		queue_redraw()
		if zeit < 0:
			queue_free()


func _draw() -> void:
	# In den letzten Sekunden verblassen. Liegt es fest im Level, bleibt zeit immer voll.
	var alpha := clampf(zeit / ZEIT_VERSCHWINDEN, 0.0, 1.0)
	var hoehe: float = Gegenstand.BILDER[art][0].size()
	Gegenstand.malen(self, art, Vector2(0, hoehe / 2), alpha)


func _on_body_entered(_body: Node2D) -> void:
	Spielstand.hinzufuegen(art)
	# Unsichtbar werden, klimpern, erst danach weg. Sonst wäre der Ton gleich mit weg.
	set_deferred("monitoring", false)
	drop = false
	hide()
	$Klimper.play()
	await $Klimper.finished
	queue_free()
```

6. Speichern als `fundstueck.tscn`.

- Das `alpha` in `Gegenstand.malen()` ist **deine** Erweiterung aus Kapitel 7. Hier zahlt sie sich aus.
- **`clampf(zeit / ZEIT_VERSCHWINDEN, 0.0, 1.0)`**: Bei 15 Sekunden kommt 3 heraus, das wird auf 1 gekappt, also voll sichtbar. Erst unter 5 Sekunden wird es durchsichtig. Eine Rechnung statt deines `if` im Herz, und ein Fundstück, das fest im Level liegt, zählt gar nicht erst herunter.
- **`hoehe / 2`**: `malen()` will die Mitte der Unterkante. Eine halbe Bildhöhe nach unten, dann sitzt das Bild mittig auf der Kollisionsform, egal ob Münze oder Herz.
- **`await $Klimper.finished`**: Die andere Lösung für das Ton-Problem aus Übung 4 von Kapitel 7. Statt den Ton woanders hinzuhängen, wird das Fundstück erst unsichtbar und taub, wartet den Ton ab und löscht sich dann selbst.

Ein paar Münzen kannst du direkt in den Dungeon legen. Die meisten sollen aber von Monstern kommen. **`glibber.gd`**, oben:

```gdscript
const MUENZ_DROPRATE = 0.4
const FUNDSTUECK = preload("res://fundstueck.tscn")
```

In `sterben()` ersetzt eine Zeile `beute()` den ganzen `if randf() < HERZ_DROPRATE:`-Block. Darunter die neue Funktion:

```gdscript
# Ein Herz oder eine Münze fallen lassen. Oder nichts.
func beute() -> void:
	var los := randf()
	var ding   # ohne Typ: Herz und Fundstück haben beide ein drop, aber sonst wenig gemeinsam
	if los < HERZ_DROPRATE:
		ding = HERZCHEN.instantiate()
	elif los < HERZ_DROPRATE + MUENZ_DROPRATE:
		ding = FUNDSTUECK.instantiate()
	else:
		return
	ding.drop = true
	ding.position = position
	get_parent().add_child.call_deferred(ding)
```

**Ein Los, drei Ausgänge**: `randf()` liefert eine Zahl zwischen 0 und 1. Unter 0,3: Herz. Zwischen 0,3 und 0,7: Münze. Darüber: nichts. Würdest du zweimal würfeln, könnte ein Glibber beides fallen lassen, und die Wahrscheinlichkeiten wären schwerer auszurechnen.

**Die Anzeige**: In `Inventar` ein zweites Label `Muenzen`, gleiche Schrift, Position `9, 33`. In `inventar.gd`:

```gdscript
func aktualisieren() -> void:
	$Anzahl.text = "x%d" % Spielstand.anzahl(Gegenstand.Art.SCHLUESSEL)
	$Muenzen.text = "x%d" % Spielstand.anzahl(Gegenstand.Art.MUENZE)
	queue_redraw()
```

Und als erste Zeile in `_draw()`:

```gdscript
	Gegenstand.malen(self, Gegenstand.Art.MUENZE, Vector2(4, 44))
```

Die Münzen stehen so unter dem Schlüssel. Dein Label `Anzahl` steht bei dir ganz oben links im Inventar. Gedacht war `9, 18`, also rechts neben dem Schlüssel. Sonst stehen beide Zahlen nicht da, wo ihr Bild ist.

### 8.6 Der Händler

Der Händler ist auch eine Figur, nur mit anderem Bild und anderem Text. Statt `figur.tscn` zu kopieren, **erbst** du sie:

1. *Scene → New Inherited Scene* → `figur.tscn` wählen.
2. Es öffnet sich eine Szene, die genau wie die Figur aussieht. Die Nodes sind gelb: Sie gehören der Eltern-Szene.
3. `Bild` auswählen, Frame `112` (ein Kerl mit grünem Stirnband). Die Root in `Haendler` umbenennen.
4. Im Inspector die Texte, zum Beispiel: „Willkommen! Alles muss raus!“, „Wirklich alles. Ich zieh um. Der Vermieter ist ein Drache.“
5. Speichern als `haendler.tscn`.

**Geerbte Szene**: `haendler.tscn` speichert nur, was **anders** ist als bei der Figur, also Bild und Texte. Änderst du später etwas an `figur.tscn`, etwa die Kollisionsform, bekommt der Händler das von selbst mit. Bei einer Kopie müsstest du jede Änderung zweimal machen.

Jetzt die Ware. Jedes Angebot liegt einzeln auf dem Boden, mit dem Preis darunter, wie im Original.

```
Angebot (StaticBody2D)
├── CollisionShape2D
└── Preis (Label)
```

1. `Angebot`: **StaticBody2D**, Layer `1`, Mask leer.
2. `CollisionShape2D`: `14, 14`.
3. `Preis`: **Label**, Kenney Pixel, Position `-12, 8`, Size `24, 12`, **Horizontal Alignment**: **Center**.
4. Skript `angebot.gd`:

```gdscript
extends StaticBody2D

@export var ware: Gegenstand.Art = Gegenstand.Art.HERZ
@export var preis := 10
@export var einmalig := false   # nur einmal zu haben, zum Beispiel der Herzcontainer


func _ready() -> void:
	$Preis.text = str(preis)


func _draw() -> void:
	Gegenstand.malen(self, ware, Vector2(0, 7))


# Fragen, bezahlen, einpacken
func benutzen() -> void:
	var ja: bool = await Dialog.frage("%s für %d Münzen?" % [Gegenstand.NAMEN[ware], preis])
	if not ja:
		Dialog.zeigen(["Gucken kostet nichts. Noch nicht."])
	elif not Spielstand.verbrauchen(Gegenstand.Art.MUENZE, preis):
		Dialog.zeigen(["Das reicht nicht. Komm wieder, wenn du flüssig bist."])
	else:
		Spielstand.hinzufuegen(ware)
		Schatz.zeigen(get_tree().get_first_node_in_group("held"), ware)
		if einmalig:
			queue_free()
		Dialog.zeigen(["Gute Wahl! Umtausch ausgeschlossen."])
```

5. Speichern als `angebot.tscn`.

Bau einen Laden: ein Raum mit dem Händler oben in der Mitte und drei Angeboten in einer Reihe davor. Vorschlag:

| Ware | Preis | Einmalig |
|---|---|---|
| `HERZ` | 10 | nein |
| `SCHLUESSEL` | 25 | nein |
| `HERZCONTAINER` | 50 | ja |

Der Herzcontainer im Laden ist einer von den zehn aus deinem Plan.

- **`"%s für %d Münzen?" % [...]`**: `%s` wird durch einen Text ersetzt, `%d` durch eine ganze Zahl, der Reihe nach. Kennst du von `"x%d"` in der Anzeige, nur mit zwei Lücken.
- **Erst fragen, dann zahlen**: `verbrauchen()` nimmt nur, wenn genug da ist, und sagt, ob es geklappt hat. Wie bei der Tür. Es kann nie passieren, dass Münzen weg sind und die Ware nicht kommt.
- **`queue_free()` vor dem letzten Satz**: Das Angebot verschwindet sofort, die Dialogbox ist ein Autoload und redet trotzdem weiter. Gelöscht wird erst am Ende des Bilds, `Dialog.zeigen` läuft also noch.

Ein Ladentisch macht sich gut: Kachel `72` ist ein Tisch, Kachel `73` ein Hocker. Stell sie hinter die Ware oder mal sie auf die Wände-Ebene, wenn sie eine Kollision haben sollen.

### 8.7 Ausprobieren

- Lies ein Schild: Die Box erscheint unten, der Text tippt sich hin, alles andere steht still. Angriffstaste während des Tippens: Der Rest erscheint auf einmal. Noch einmal: Box zu, und der Held sticht **nicht** zu.
- Rede mit dem alten Mann: zwei Seiten, das Dreieck blinkt zwischen den Seiten. Danach steigen die Münzen über dem Helden auf, und die Anzeige zählt `x10`. Ein zweites Mal reden: Er hat nichts mehr.
- Erschlag ein paar Glibber: Manchmal bleibt eine Münze liegen. Lass sie liegen: Nach zehn Sekunden fängt sie an zu verblassen, nach fünfzehn ist sie weg.
- Im Laden: Frage mit `Ja` und `Nein`, links und rechts schalten um. Bei `Nein` passiert nichts. Mit zu wenig Geld schimpft der Händler. Mit genug Geld wandert die Ware zum Helden, und der Herzcontainer ist danach weg.

### 8.8 Noch zwei Dinge aus Kapitel 7

Zuerst das Lob: Deine Tür spielt ihren Ton über den Helden, weil sie sich selbst löscht. Das war genau die Lösung für Übung 4. Und die Belohnungstruhe als Häkchen an der normalen Truhe statt als eigene Szene ist dieselbe Idee wie der Masterschlüssel an der Tür.

Diese zwei wirken sich auf das Verhalten aus:

1. **`visibility_layer` ist nicht `visible`.** In der Belohnungstruhe steht `$Bild.visibility_layer = false`. `visibility_layer` ist eine Bitmaske, ähnlich wie die Kollisionsebenen, und legt fest, in welchen Ansichten etwas zu sehen ist. `false` wird zu 0, also „in keiner“, und `true` zu 1, „in Ansicht 1“. Das ist zufällig die normale. Es klappt also, aber nur aus Glück, und eine Minikarte oder ein zweiter Bildschirm würde es kaputtmachen. Gemeint ist `$Bild.visible = false` und `true`.
2. **Löschen in der eigenen Schleife.** `for monster in monster_im_raum:` mit `monster_im_raum.erase(monster)` darin: Wird mitten in der Schleife ein Eintrag gelöscht, rücken alle dahinter eins auf, und die Schleife überspringt den nächsten. Bei dir fällt das nicht auf, weil das im nächsten Bild nachgeholt wird. Sauberer ist eine Zeile ohne Schleife:

   ```gdscript
   monster_im_raum = monster_im_raum.filter(is_instance_valid)
   ```

   `filter` behält nur, wofür die Funktion `true` sagt. Wichtig ist das `monster_im_raum =` vorne: `filter` ändert die Liste nicht, sondern baut eine **neue** und gibt sie zurück. Ohne Zuweisung wird die neue Liste sofort weggeworfen, die alte bleibt voll, und die Truhe erscheint nie. Das gilt auch für `map`, `duplicate` und `slice`. Nur Befehle wie `append`, `erase` und `sort` ändern die Liste selbst.

Die Formatierung habe ich korrigiert: Tippfehler in `karte.gd` (`geheime_raeme` → `geheime_raeume`), die nicht mehr benutzten Farben in `spielstand.gd` sind raus, und Kleinkram in `truhe.gd`, `tuer.gd`, `mimic.gd`, `herzcontainer.gd` und `gegenstand.gd`.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 8

1. **Plappern (leicht):** Ein leiser, kurzer Ton bei jedem zweiten Buchstaben, mit zufälliger Tonhöhe (`pitch_scale = randf_range(0.9, 1.1)`), wie bei vielen Pixelspielen. Tipp: Merk dir in `_process`, wie viele Buchstaben im letzten Bild zu sehen waren. Wenn es jetzt mehr sind, ist ein neuer dazugekommen. Leerzeichen sollen still sein.
2. **Kundenservice (leicht):** Bei vollen Herzen ein Herz zu kaufen ist rausgeworfenes Geld. Der Händler soll dann gar nicht erst fragen, sondern sagen: „Du bist kerngesund. Komm wieder, wenn dich was gebissen hat.“ Wo im Skript gehört die Prüfung hin?
3. **Kleingeld im Topf (leicht):** Gib dem Topf `@export var muenzen := 0`. Beim Zerbrechen fallen so viele Münzen heraus, leicht verstreut. Tipp: Schau dir `beute()` im Glibber an, und für das Verstreuen `Vector2(randf_range(-6, 6), randf_range(-6, 6))`.
4. **Wer spricht da? (mittel):** Über der Box ein kleines Namensschild, zum Beispiel „Alter Mann“ oder „Händler“. `zeigen()` bekommt dafür einen zweiten Parameter mit Standardwert `""`. Ohne Namen bleibt das Schild weg, dann können die Schilder alles lassen, wie es ist. Und `frage()`? Achtung: Nenn die Variable in der Figur nicht `name`. Warum nicht?
5. **Türreparatur (mittel):** Im Original sitzt in einem Geheimraum ein Mann, der sagt: „Du hast meine Tür kaputt gemacht! Das macht 20 Münzen.“ Und kassiert, ohne zu fragen. Bau ihn hinter deine falsche Wand. Hat der Held weniger als 20, nimmt er eben alles. Tipp: `verbrauchen()` nimmt nur, wenn genug da ist. Wie viele kann er also höchstens nehmen? `mini()` hilft. 💸

---

## Kapitel 9: Die Welt merkt sich alles

Bisher ist der Tod gnadenlos: Herz weg, Spiel vorbei, alles von vorn. Jede Truhe ist wieder zu, jeder Schlüssel weg, die Karte leer. Und wer das Spiel beendet, fängt beim nächsten Mal auch von vorn an.

Ab jetzt merkt sich die Welt, was der Held getan hat. Bei jedem Raumwechsel wird gespeichert, wie ein Kontrollpunkt. Stirbt der Held, steht er wieder am Eingang des Raums, in dem er zuletzt gespeichert hat, mit allem, was er da hatte. Und beim nächsten Start geht es genau dort weiter.

Neu sind **`ConfigFile`** zum Schreiben und Lesen einer Datei, der Ordner **`user://`**, **Knotenpfade** als Namen für Dinge, **Dictionaries als Verweis** statt als Kopie und **`_enter_tree`**.

### 9.1 Was muss sich die Welt merken?

Bevor du Code schreibst, eine Liste. Was soll nach dem Tod oder nach dem Neustart noch so sein wie vorher?

| Was | Gemerkt? | Warum |
|---|---|---|
| Inventar, Herzcontainer | ja | sonst war alles umsonst |
| Wo der Held steht | ja | der Eingang des letzten Raums |
| Wie viele Herzen gerade voll sind | nein | wie im Original: weiter mit drei Herzen |
| Offene Truhen und Türen | ja | sonst gäbe es Schlüssel doppelt |
| Eingesammelte Fundstücke | ja | ein Herzcontainer liegt nur einmal rum |
| Gekaufte Einmal-Angebote | ja | dasselbe im Laden |
| Mit wem der Held schon geredet hat | ja | sonst schenkt der alte Mann jedes Mal wieder Münzen |
| Zerstörte falsche Wände | ja | ein Geheimnis bleibt entdeckt |
| Besuchte Räume für die Karte | ja | |
| Monster | nein | die kommen wieder, wie im Original |
| Töpfe, Münzen von Monstern | nein | kommen auch wieder (aber schau mal in die Übungen) |

**Die wichtigste Regel:** Inventar und Welt werden **im selben Moment** gespeichert. Stell dir vor, nur das Inventar würde sofort gespeichert und die Welt erst später. Dann öffnest du eine Truhe, der Schlüssel ist im Inventar gespeichert, die Truhe aber noch nicht. Du stirbst, die Truhe ist wieder zu, und du holst dir den Schlüssel noch mal. Unendlich Schlüssel. Wird beides zusammen gespeichert, passt es immer: Stirbst du im selben Raum, ist die Truhe wieder zu **und** der Schlüssel wieder weg.

### 9.2 Jedes Ding braucht einen Namen

Für das Inventar reicht `Gegenstand.Art` als Schlüssel. Aber wie merkt man sich „Truhe 7 ist offen“? Jeder Knoten im Spiel hat einen **Pfad**, wie ein Ordner auf der Festplatte: `/root/Dungeon/Truhe7`. Den liefert `get_path()`, und er ist einmalig. Zwei Knoten mit demselben Namen nebeneinander lässt Godot nicht zu, deshalb heißen sie ja `Truhe`, `Truhe2`, `Truhe3`.

Der Spielstand bekommt ein Dictionary `erledigt`: Jeder Pfad, der drinsteht, ist erledigt. Eine Truhe ist dann offen, eine Tür offen, ein Fundstück eingesammelt. Jedes Ding weiß selbst, was „erledigt“ für es bedeutet.

> **Achtung beim Umbenennen:** Benennst du `Truhe7` später in `Truhe_Kompass` um, findet der Spielstand sie nicht mehr. Dann ist sie wieder zu. Schlimm ist das nicht, aber wundere dich nicht.

### 9.3 Der Spielstand speichert und lädt

`spielstand.gd` bekommt einiges dazu. Hier ist die ganze Datei. Alles ab `func anzahl` ist unverändert:

```gdscript
extends Node

signal leben_geaendert
signal inventar_geaendert

const START_LEBEN = 6   # in halben Herzen: 6 sind drei ganze Herzen
const MAX_HERZEN = 10
const DATEI = "user://spielstand.cfg"

var inventar := {}   # Gegenstand.Art -> Anzahl
var erledigt := {}   # Pfad im Dungeon -> true: offene Truhen und Türen, eingesammelte Dinge, ...
var besucht := {}    # Raum -> true, für die Karte
var startpunkt: Variant = null   # Hier steht der Held nach dem Laden. null heißt: wo er in der Szene steht.
var max_leben := START_LEBEN
var leben := START_LEBEN:
	set(wert):
		max_leben = mini(max_leben, MAX_HERZEN * 2)
		leben = clampi(wert, 0, mini(max_leben, MAX_HERZEN * 2))
		leben_geaendert.emit()


# _init statt _ready: Das läuft, sobald der Spielstand entsteht, noch bevor der Dungeon gebaut wird
func _init() -> void:
	laden()


# Alles auf Anfang, für ein neues Spiel
func neues_spiel() -> void:
	max_leben = START_LEBEN
	leben = max_leben
	inventar.clear()
	erledigt.clear()
	besucht.clear()
	startpunkt = null
	inventar_geaendert.emit()


# Alles, was sich der Held und die Welt merken müssen, in eine Datei
func speichern(wo: Vector2) -> void:
	startpunkt = wo
	var datei := ConfigFile.new()
	datei.set_value("held", "startpunkt", startpunkt)
	datei.set_value("held", "max_leben", max_leben)
	datei.set_value("held", "inventar", inventar)
	datei.set_value("welt", "erledigt", erledigt)
	datei.set_value("welt", "besucht", besucht)
	datei.save(DATEI)


# Den letzten Stand zurückholen. Gibt es noch keinen, beginnt ein neues Spiel.
func laden() -> void:
	var datei := ConfigFile.new()
	if datei.load(DATEI) != OK:
		neues_spiel()
		return
	startpunkt = datei.get_value("held", "startpunkt", null)
	max_leben = datei.get_value("held", "max_leben", START_LEBEN)
	leben = mini(START_LEBEN, max_leben)   # wie im Original: weiter mit drei Herzen
	# assign statt =: dieselben Dictionaries behalten, nur ihren Inhalt austauschen. Die Karte hält besucht fest.
	inventar.assign(datei.get_value("held", "inventar", {}))
	erledigt.assign(datei.get_value("welt", "erledigt", {}))
	besucht.assign(datei.get_value("welt", "besucht", {}))
	inventar_geaendert.emit()


# Hat der Held dieses Ding schon geöffnet, eingesammelt, gekauft, ...?
func ist_erledigt(ding: Node) -> bool:
	return str(ding.get_path()) in erledigt


func erledigen(ding: Node) -> void:
	erledigt[str(ding.get_path())] = true


# Wie viele davon hat der Held?
func anzahl(art: Gegenstand.Art) -> int:
	...
```

### 9.4 Lies das Skript

- **`ConfigFile`** ist Godots einfachste Art, eine Datei zu schreiben. Sie hat **Abschnitte** (hier `held` und `welt`) und darin **Schlüssel** mit Werten, wie ein kleines Dictionary in zwei Stufen. `set_value()` trägt ein, `save()` schreibt alles auf einmal auf die Festplatte.
- **Warum nicht JSON?** JSON kennt nur Zahlen, Texte, Listen und Dictionaries mit Text-Schlüsseln. Aus `Vector2(-38, 90)` müsstest du selbst zwei Zahlen machen, und aus dem Inventar-Schlüssel `0` würde der Text `"0"`. `ConfigFile` schreibt Godot-Werte so, wie sie sind, und liest sie genauso zurück. So sieht die Datei nach einem Raumwechsel aus:

  ```
  [held]
  startpunkt=Vector2(-38.889965, 90)
  max_leben=8
  inventar={
  0: 1
  }
  [welt]
  erledigt={
  "/root/Dungeon/Fundstueck5": true,
  "/root/Dungeon/Truhe3": true,
  "/root/Dungeon/Tuer4": true
  }
  besucht={
  Vector2i(-1, 0): true,
  Vector2i(0, 0): true
  }
  ```

  Ganz normaler Text. Den kannst du lesen und auch ändern (siehe Übung 1).
- **`user://`** ist der Ordner, in den dein Spiel schreiben darf. `res://` ist dein Projekt, und das ist nach dem Export schreibgeschützt. Unter Windows liegt `user://` in `%APPDATA%\Godot\app_userdata\Kerkerheld\`. Am schnellsten findest du ihn über **Projekt → Benutzerdatenordner öffnen**. Im Browser (Kapitel 10) landet die Datei im Speicher des Browsers, und es funktioniert genauso.
- **`get_value(abschnitt, schluessel, standard)`**: Der dritte Wert kommt zurück, wenn der Eintrag fehlt. Das ist praktisch, wenn du später etwas Neues speicherst und eine alte Datei das noch nicht kennt.
- **`if datei.load(DATEI) != OK`**: `load()` gibt einen Fehlercode zurück. `OK` heißt geklappt. Beim allerersten Start gibt es noch keine Datei, dann beginnt einfach ein neues Spiel.
- **`startpunkt: Variant = null`**: Ein `Vector2` kann nicht „nichts“ sein, `Vector2.ZERO` ist ja auch ein Ort. Darum `Variant`: Das darf ein `Vector2` sein oder `null`. `null` heißt hier: Es gibt noch keinen Spielstand, der Held bleibt, wo er in der Szene steht.
- **`str(ding.get_path())`**: `get_path()` liefert einen `NodePath`, also keinen gewöhnlichen Text. Mit `str()` wird daraus ein normaler Text, und der lässt sich als Schlüssel verlässlich vergleichen.
- **`_init()` ruft `laden()` auf, nicht `_ready()`:** Beim Start mit F5 baut Godot zuerst alle Knoten, auch den ganzen Dungeon. Dann hängt es alles in den Baum (`_enter_tree`), und erst ganz am Ende laufen die `_ready()`. Würde der Spielstand erst in `_ready()` laden, hätten der Held (`_enter_tree`, 9.7) und die Karte (`var besucht := ...`, 9.6) schon nachgefragt und nichts bekommen. `_init()` läuft dagegen, sobald der Spielstand selbst entsteht. Autoloads entstehen vor der ersten Szene, also ist der Stand rechtzeitig da.
- **`leben` wird nicht gespeichert.** Nach dem Laden gibt es drei Herzen, mit `mini()`, damit es nicht mehr sind als die Container. Sonst könntest du mit einem halben Herzen speichern und nach jedem Tod mit einem halben Herzen weitermachen.

### 9.5 Die Dinge erinnern sich

Jedes Ding fragt in `_ready()`, ob es schon erledigt ist, und meldet sich als erledigt, sobald der Held etwas mit ihm macht. Immer dasselbe Muster, nur was „erledigt“ heißt, ist verschieden.

**`truhe.gd`**: Eine erledigte Truhe ist offen. Ganz oben in `_ready()`:

```gdscript
func _ready() -> void:
	if Spielstand.ist_erledigt(self):
		offen = true
		$Bild.frame = BILD_OFFEN
		return
	if belohnung:
		...
```

Das `return` ist wichtig: Eine offene Belohnungstruhe soll sich nicht wieder verstecken, nur weil die Monster wieder da sind. In `benutzen()` direkt unter `offen = true`:

```gdscript
	Spielstand.erledigen(self)
```

**`tuer.gd`**: Eine erledigte Tür ist weg. Ganz oben in `_ready()`:

```gdscript
func _ready() -> void:
	if Spielstand.ist_erledigt(self):
		queue_free()
		return
	if master:
		...
```

Und in `benutzen()` direkt nach dem `return` vom Wackeln, also erst, wenn der Schlüssel wirklich verbraucht ist:

```gdscript
	Spielstand.erledigen(self)
```

**`fundstueck.gd`**: Hier gibt es einen Haken. Fundstücke, die ein Glibber oder ein Topf fallen lässt, bekommen von Godot einen ausgedachten Namen wie `@Area2D@37`. Den gibt es beim nächsten Mal vielleicht wieder, aber für ein ganz anderes Ding. Darum merken wir uns nur die, die fest im Level liegen:

```gdscript
func _ready() -> void:
	# Fallen gelassene Dinge sind jedes Mal neu, nur die fest im Level liegenden merken wir uns
	if not drop and Spielstand.ist_erledigt(self):
		queue_free()
```

In `_on_body_entered()` direkt unter `Spielstand.hinzufuegen(art)`, also **bevor** `drop = false` gesetzt wird:

```gdscript
	if not drop:
		Spielstand.erledigen(self)
```

**`angebot.gd`**: Nur Einmal-Angebote merken sich etwas. Ganz oben in `_ready()`:

```gdscript
	if einmalig and Spielstand.ist_erledigt(self):
		queue_free()
		return
```

Und beim Kaufen:

```gdscript
			if einmalig:
				Spielstand.erledigen(self)
				queue_free()
```

**`figur.gd`**: Hier ist „erledigt“ einfach `schon_geredet`. Als erste Zeile in `_ready()`:

```gdscript
	schon_geredet = Spielstand.ist_erledigt(self)
```

Und in `benutzen()` direkt unter `schon_geredet = true`:

```gdscript
	Spielstand.erledigen(self)
```

Das gilt für den alten Mann, den Händler und den Türmann. Alle drei erben ja von der Figur. Der Türmann kassiert also nur einmal, auch nach dem Tod.

**`falschewand.gd`**: Eine erledigte Wand ist weg. Neu:

```gdscript
func _ready() -> void:
	if Spielstand.ist_erledigt(self):
		queue_free()
```

Und als erste Zeile in `zerbrechen()`:

```gdscript
	Spielstand.erledigen(self)
```

### 9.6 Die Karte erinnert sich

Die Karte hat ihr eigenes Dictionary `besucht`. Das muss jetzt in den Spielstand, damit es gespeichert wird. Dafür musst du in `karte.gd` genau eine Zeile ändern:

```gdscript
var besucht := Spielstand.besucht   # dasselbe Dictionary wie im Spielstand, keine Kopie
```

Alles andere in der Karte bleibt, wie es ist. Warum klappt das?

- **Ein Dictionary wird nicht kopiert, sondern geteilt.** Bei `var a := 5` und `var b := a` hat `b` seine eigene 5. Ein Dictionary ist aber zu groß, um es bei jeder Zuweisung zu kopieren. `besucht` in der Karte und `besucht` im Spielstand sind danach **dasselbe** Dictionary, nur unter zwei Namen. Trägt die Karte einen Raum ein, steht er auch im Spielstand. Willst du wirklich eine Kopie, gibt es `duplicate()`, das kennst du aus der Dialogbox.
- **Warum gleich bei `var` und nicht in `_ready()`?** Die Kamera steht im Szenenbaum über der Anzeige. Ihr `_ready()` läuft also zuerst und trägt schon den Startraum in die Karte ein. Würde die Karte erst in ihrem eigenen `_ready()` umschalten, wäre dieser Eintrag im alten, leeren Dictionary gelandet. Werte hinter `var` werden dagegen gesetzt, sobald der Knoten entsteht, also noch vor jedem `_ready()`.
- **Darum `clear()` in `neues_spiel()`:** `clear()` leert dasselbe Dictionary, und die Karte merkt es sofort. `besucht = {}` würde dagegen ein neues Dictionary anlegen, und die Karte hielte noch das alte fest. Aus demselben Grund steht in `laden()` `besucht.assign(...)` statt `besucht = ...`. `assign()` tauscht den Inhalt aus, und das Dictionary bleibt dasselbe. Mit `=` hätte die Karte nach F5 ein leeres altes Dictionary festgehalten, ihre neuen Räume dort eingetragen, und gespeichert worden wäre das andere.

### 9.7 Der Held speichert und steht wieder auf

Drei Stellen in `held.gd`.

**Speichern beim Raumwechsel.** Dein Held läuft nach dem Raumwechsel schon 18 Pixel in den neuen Raum hinein, und die Funktion wartet mit `await tween.finished`, bis er da ist. Genau danach wird gespeichert:

```gdscript
func _on_camera_2d_raumwechsel(wechselrichtung: Variant) -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(18 * wechselrichtung.x, 18 * wechselrichtung.y), 0.2)
	await tween.finished
	Spielstand.speichern(global_position)   # ganz im neuen Raum angekommen: speichern
```

Warum erst danach? Direkt nach dem Wechsel steht der Held noch im Türrahmen auf der Grenze. Nach den 18 Pixeln steht er sicher im Raum. Und spricht ihn beim Betreten jemand an, etwa der Türmann, wartet der Tween, bis der Dialog zu ist. Gespeichert wird also erst, wenn das Geld schon weg ist. Gut so.

**Nach dem Tod laden statt neu anfangen.** In `sterben()` wird aus `Spielstand.neues_spiel()`:

```gdscript
	Spielstand.laden()
	get_tree().reload_current_scene()
```

**Am Startpunkt aufstehen.** Neue Funktion, zum Beispiel direkt unter den Variablen:

```gdscript
# Nach dem Laden dort anfangen, wo zuletzt gespeichert wurde.
# _enter_tree statt _ready: Die Kamera fragt in ihrem _ready schon nach der Position des Helden.
func _enter_tree() -> void:
	if Spielstand.startpunkt != null:
		global_position = Spielstand.startpunkt
		unverwundbar = SCHONZEIT   # kurz Zeit zum Umschauen
```

- **`_enter_tree()`** läuft, sobald der Knoten im Baum hängt, und zwar für **alle** Knoten der Szene, bevor irgendein `_ready()` drankommt. Die Kamera steht über dem Held und hätte in ihrem `_ready()` sonst noch die alte Position gesehen. Dann hätte sie den falschen Raum gezeigt und gleich wieder umgeschaltet.
- **`unverwundbar = SCHONZEIT`**: Wer mitten in einem Raum voller Glibber aufsteht, bekommt eine Sekunde Blinken geschenkt.

### 9.8 Ausprobieren

- Öffne eine Truhe und geh in den nächsten Raum. Lass dich besiegen. Du stehst am Eingang dieses Raums, die Truhe ist offen, und der Schlüssel ist noch da.
- Öffne eine Truhe und stirb, **ohne** den Raum zu verlassen. Die Truhe ist wieder zu und der Schlüssel weg. Genau so soll es sein (9.1).
- Rede mit dem alten Mann, wechsle den Raum, stirb. Er schenkt nichts mehr.
- Mach eine falsche Wand kaputt, wechsle den Raum, stirb. Die Wand bleibt weg, der Raum steht auf der Karte.
- Beende das Spiel und starte es neu. Es geht weiter, wo du zuletzt einen Raum betreten hast.
- Schau dir die Datei an: **Projekt → Benutzerdatenordner öffnen**, dann `spielstand.cfg` mit einem Texteditor öffnen.
- **Von vorn anfangen:** Lösch `spielstand.cfg` in diesem Ordner. Das ist auf Dauer lästig, deshalb kommt in Übung 4 ein besserer Weg, und in Kapitel 10 ein Titelbild mit „Neues Spiel“.

### 9.9 Noch zwei Dinge aus Kapitel 8

Zuerst das Lob: Alle fünf Übungen laufen. Das Plappern piept bei jedem zweiten Buchstaben und bleibt bei Leerzeichen still. Der Händler prüft die vollen Herzen, **bevor** er fragt, genau richtig. Der Türmann kassiert beim Betreten und nimmt mit `mini()` höchstens, was da ist. Und die Inventur meldet alle Ziele erreicht: 7 Herzcontainer, 10 Schlüssel für 10 Türen, je einmal Karte, Kompass, Masterschlüssel und Bosstür. Die Antwort auf die Frage aus Übung 4: Jeder Node hat schon eine Eigenschaft `name`, nämlich seinen Namen im Szenenbaum. Eine eigene Variable `name` darf es daneben nicht geben, Godot meldet dann einen Fehler. `NPC_Name` umgeht das.

Diese zwei wirken sich auf das Verhalten aus:

1. **Die Dornen piksen nur einmal.** `body_entered` meldet sich nur im Moment des Betretens. Bleibt der Held auf den Dornen stehen, passiert nach der Schonzeit nichts mehr. Und wird er gerade blinkend auf ein zweites Dornenfeld gestoßen, ist das Betreten schon vorbei, bevor er wieder verwundbar ist. Ausprobiert: Auf den Dornen festgehalten verliert er in drei Sekunden genau ein halbes Herz. Besser ist es, jedes Bild nachzusehen, wie der Held es bei Monstern auch macht. Neues `dornen.gd`:

   ```gdscript
   extends Area2D

   var schaden := 1   # in halben Herzen


   # Jedes Bild nachsehen, nicht nur beim Betreten: Wer stehen bleibt, wird nach der Schonzeit wieder gepikst
   func _physics_process(_delta: float) -> void:
   	for body in get_overlapping_bodies():
   		if body.is_in_group("held") and body.unverwundbar <= 0:
   			body.getroffen(self)
   ```

   Und in der Dornen-Szene unter **Node → Signale** die Verbindung von `body_entered` trennen (Rechtsklick → **Trennen**). Sonst sucht Godot die Funktion `_on_body_entered`, die es nicht mehr gibt. Danach verliert der Held auf den Dornen jede Sekunde ein halbes Herz. `is_in_group("held")` ist übrigens klarer als `has_method("treffer_pruefen")`: Es fragt, **wer** das ist, nicht, was er zufällig kann.

2. **`herzcontainer.tscn` ist kaputt.** `herz.gd` und `herzcontainer.gd` sind gelöscht, aber in den beiden Szenen steckt der alte Code noch als eingebautes Skript. In `herzcontainer.tscn` ist dabei eine Zeile zerbrochen, und beim Start meldet Godot `Parse Error: Mixed use of tabs and spaces for indentation`. Benutzt werden beide Szenen nicht mehr, das macht ja jetzt das Fundstück. Lösch `herz.tscn` und `herzcontainer.tscn` im Dateisystem-Dock. Rechtsklick → **Löschen** prüft auch gleich, ob sie doch noch irgendwo gebraucht werden.

Die Formatierung habe ich korrigiert: In `figur.gd` stand am `NPC_Name` noch der kopierte Kommentar „0 heißt: kein Geschenk“. `angebot.gd` und `dialog.gd` haben einen Typ und einen Kommentar bekommen. In `topf.gd` sind der kopierte Kommentar über `beute()` und `range(0, muenzen)` korrigiert, `muenzen` allein reicht. Außerdem `00` → `0` in `gegenstand.gd`, `min` → `mini` für ganze Zahlen in `spielstand.gd` und eine fehlende Leerzeile in `held.gd`.

Fertig? Committen und Bescheid geben.

### Übungsaufgaben zu Kapitel 9

1. **Schummeln (leicht):** Öffne `spielstand.cfg` in einem Texteditor und gib dir 99 Münzen. Welcher Schlüssel im Inventar ist die Münze? Schau ins `enum` in `gegenstand.gd`, und denk daran, dass gezählt wird ab 0. Starte das Spiel, geh einkaufen. Und dann überleg: Wie könnte man das verhindern? Tipp: `ConfigFile` hat neben `save()` auch `save_encrypted_pass()`. Für dieses Spiel lohnt es sich nicht, aber jetzt weißt du, dass es geht.
2. **Sparschwein (leicht):** Töpfe kommen nach jedem Tod wieder, und mit ihnen ihre Münzen. Wer will, stirbt sich also reich. Sorg dafür, dass Töpfe **mit** Münzen sich merken, dass sie zerbrochen sind. Leere Töpfe dürfen gern wiederkommen. Wo gehört `ist_erledigt` hin, und wo `erledigen`?
3. **Gespeichert! (leicht):** Ein kleines „Gespeichert“ in einer Ecke der Anzeige, das nach dem Speichern kurz erscheint und dann verblasst. Tipp: Ein neues Signal `gespeichert` im Spielstand, ein Label in der Anzeige, das auf das Signal hört, und ein Tween auf `modulate:a`.
4. **Neu anfangen (mittel):** Stell ein Schild oder eine Figur an den Eingang, die fragt: „Alles vergessen und von vorn anfangen?“ Bei `Ja`: `Spielstand.neues_spiel()`, die Datei löschen mit `DirAccess.remove_absolute(ProjectSettings.globalize_path(Spielstand.DATEI))` und die Szene neu laden. Denkfrage: `neues_spiel()` leert doch schon alles. Warum muss die Datei trotzdem weg? Was passiert sonst, wenn der Held stirbt, bevor er den ersten Raum wechselt?
5. **Friedhof (mittel):** Der Spielstand zählt, wie oft der Held gestorben ist, und speichert es mit. Ein Grabstein-Schild am Eingang sagt dann zum Beispiel: „Hier ruhen 7 Helden. Alle sahen aus wie du.“ Tipp: Schreib in den Text des Schilds ein Zeichen wie `#` und ersetz es mit `replace("#", str(...))` durch die Zahl. Achtung, Falle: Wenn du in `sterben()` zuerst zählst und dann `laden()` aufrufst, was passiert mit deinem frisch erhöhten Zähler? 🪦


---

## Kapitel 10: Zwei Arten zu sterben

Bisher bleibt ein besiegtes Monster weg, bis der Held stirbt. Im Original ist das anders: Wer einen Raum verlässt und wiederkommt, trifft die Monster wieder an. Das machen wir jetzt auch, aber nur im **normalen** Spiel. Dazu kommt eine zweite Art zu spielen, für Leute mit Nerven aus Stahl: **Iron Man**. Tot ist tot, für Monster und für den Helden. Kein Speichern, kein Weiter. Wer stirbt, landet auf dem Titelbild.

Ein Titelbild gab es bisher auch noch nicht. Es kommt jetzt, mit **Weiter**, **Neues Spiel** und **Iron Man**.

Neu sind eine **eigene Klasse, von der die Monster erben**, **`super()`**, eine **Funktion ohne Namen** (Lambda), **`Input.is_action_just_pressed()`** und ein Tween, der auch dann weiterläuft, wenn sein Node schläft.

### 10.1 Was ist anders?

| | Normal | Iron Man |
|---|---|---|
| Speichern beim Raumwechsel | ja | nein |
| Held stirbt | steht am letzten Raumeingang wieder auf | Titelbild, alles vorbei |
| Monster besiegt | kommt zurück, sobald der Held den Raum wieder betritt | bleibt tot |
| Titelbild | „Weiter“ gibt es, wenn eine Datei da ist | startet immer neu |

Iron Man fasst den normalen Spielstand nicht an. Wer mittendrin eine eiserne Runde dreht und stirbt, kann danach mit „Weiter“ sein normales Spiel fortsetzen.

### 10.2 Eine Vorlage für alle Monster

Glibber, Fledermaus und Geist sterben alle gleich: anhalten, Kollision aus, zusammenschrumpfen, `queue_free()`. Das steht dreimal fast gleich da. Jetzt sollen sie auch noch wiederkommen, und das stünde dann auch dreimal da. Zeit für eine **gemeinsame Vorlage**.

Neues Skript `monster.gd`, nicht an einen Node gehängt (**Dateisystem → Rechtsklick → Neu → Skript**, „Erbt von“ `CharacterBody2D`):

```gdscript
class_name Monster
extends CharacterBody2D

# Was alle Monster gemeinsam haben: Sie sterben, und im normalen Spiel kommen sie wieder.

var tot := false
var start_position := Vector2.ZERO   # hier stand das Monster beim Start, hierhin kommt es zurück


func _ready() -> void:
	start_position = global_position


# Der Held betritt meinen Raum: alles wie neu. Nur wer im Iron-Man-Spiel tot ist, bleibt tot.
func wecken() -> void:
	if tot and Spielstand.iron_man:
		return
	tot = false
	show()
	global_position = start_position
	velocity = Vector2.ZERO
	$Bild.scale = Vector2.ONE
	$Bild.modulate = Color.WHITE
	$CollisionShape2D.disabled = false
	$Hurtbox.monitoring = true
	set_physics_process(true)
	heilen()


# Volle Lebenspunkte. Monster, die mehr als einen Treffer aushalten, schreiben ihr eigenes heilen().
func heilen() -> void:
	pass


# Nicht mehr bewegen, nicht mehr treffen, zusammenschrumpfen
func sterben() -> void:
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	# PAUSE_PROCESS: Der Tween läuft auch weiter, wenn der Held schnell den Raum verlässt und das Monster einschläft
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Bild, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(verschwinden)


# Unsichtbar statt gelöscht, damit wecken() mich zurückholen kann
func verschwinden() -> void:
	tot = true
	hide()
```

- **`class_name Monster`** kennst du von `Gegenstand`. Diesmal steht dahinter aber kein Werkzeugkasten mit `static func`, sondern eine Vorlage, von der andere Skripte **erben**. Gleich steht in `glibber.gd` oben `extends Monster` statt `extends CharacterBody2D`. Dann ist der Glibber ein Monster, und ein Monster ist ein CharacterBody2D. Er bekommt alles von beidem: `move_and_slide()` von Godot, `tot`, `wecken()` und `sterben()` von uns.
- **Unsichtbar statt gelöscht:** Was mit `queue_free()` weg ist, kommt nicht wieder. Wer nur versteckt ist, kann mit `wecken()` zurückgeholt werden. Dabei muss alles zurück, was beim Sterben ausgeschaltet wurde: sichtbar, Kollision, Hurtbox, Physik, Größe, Farbe. Und das Monster steht wieder an seinem Startplatz. Auch Monster, die noch leben, laufen beim Betreten zurück an den Start, genau wie im Original.
- **`heilen()` mit `pass`:** Fledermaus und Geist sterben beim ersten Treffer, die müssen nichts heilen. `pass` heißt „nichts tun“. Der Glibber schreibt sein eigenes `heilen()`, und dann gilt seins. Das nennt man **überschreiben**. `wecken()` ruft einfach `heilen()` auf und muss nicht wissen, wer da gerade geweckt wird.
- **`$Bild`, `$Hurtbox` und `$CollisionShape2D`** gibt es in `monster.gd` selbst gar nicht. Das Skript verlässt sich darauf, dass jedes Monster diese drei Kinder hat. Deine drei haben sie. Ein neues Monster ohne `Hurtbox` gäbe einen Fehler, sobald es geweckt wird.
- **`set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)`:** Ein Tween, den ein Node erzeugt, läuft nur, solange der Node selbst läuft. Jetzt stell dir vor, der Held besiegt eine Fledermaus direkt an der Tür und geht sofort hinaus. Die Kamera schickt die Fledermaus schlafen, mitten im Schrumpfen. Der Tween hält an, und `verschwinden()` ist noch nicht gelaufen. Kommt der Held zurück, wird die Fledermaus geweckt, und **danach** läuft der alte Tween weiter: Sie schrumpft und verschwindet, obwohl sie gerade wiederbelebt wurde. Ausprobiert, genau so passiert es. Mit `PAUSE_PROCESS` läuft der Tween einfach weiter, egal was mit dem Node ist.

### 10.3 Die Monster erben

**Glibber.** Drei Stellen in `glibber.gd`. Ganz oben:

```gdscript
extends Monster
```

In `_ready()` als erste Zeile `super()`:

```gdscript
func _ready() -> void:
	super()
	start_leben = leben
	wechseln(Zustand.WANDERN)
	$Anzeige.visible = zeige_zustand
```

`heilen()` und `sterben()` werden kürzer. Den Rest von `sterben()` macht jetzt das Monster:

```gdscript
# Volle Lebenspunkte und von vorn anfangen
func heilen() -> void:
	leben = start_leben
	wechseln(Zustand.WANDERN)
	$Anzeige.visible = zeige_zustand


# Wie jedes Monster sterben, aber vorher noch die Anzeige weg und danach Beute fallen lassen
func sterben() -> void:
	$Anzeige.hide()
	super()
	beute()
```

**Fledermaus und Geist.** Beide bekommen oben `extends Monster` und in `_ready()` als erste Zeile `super()`. Am Ende von `_on_hurtbox_area_entered` fällt alles ab `set_physics_process(false)` weg, bis auf das rote Aufblitzen:

```gdscript
	Engine.time_scale = 1.0
	var tween := create_tween()
	tween.tween_property($Bild, "modulate", Color.RED, 0.05)
	tween.tween_property($Bild, "modulate", Color.WHITE, 0.2)
	sterben()
```

Das Blitzen und das Schrumpfen laufen jetzt gleichzeitig statt nacheinander, wie beim Glibber schon immer. Merkt man kaum.

- **`super()`**: Der Glibber hat sein eigenes `_ready()`. Damit überschreibt er das `_ready()` aus `monster.gd`, und das würde nie laufen. Dann bliebe `start_position` auf (0, 0), und beim ersten Wecken stünde der Glibber in der linken oberen Ecke des Startraums. `super()` heißt: „Mach erst, was die Vorlage hier tun würde.“ Bei `sterben()` genauso: erst die Anzeige weg, dann das ganz normale Monster-Sterben, dann die Beute.
- **Vergessen?** Godot meckert nicht, wenn `super()` fehlt. Das ist der häufigste Fehler beim Erben. Ein Monster, das beim Wiederkommen in der Ecke steht, hat ihn.

### 10.4 Die Kamera weckt, die Truhe zählt Tote

In `camera_2d.gd` weckt `monster_wecken()` jetzt richtig, statt nur zu heilen:

```gdscript
# Nur die Monster im aktuellen Raum sind wach, alle anderen schlafen
func monster_wecken() -> void:
	for monster: Monster in get_tree().get_nodes_in_group("monster"):
		if raum_von(monster.start_position) == raum:
			monster.process_mode = Node.PROCESS_MODE_INHERIT
			monster.wecken()
		else:
			monster.process_mode = Node.PROCESS_MODE_DISABLED
```

- **`for monster: Monster in ...`**: Jetzt weiß Godot, dass in der Gruppe nur Monster stecken, und kennt `start_position` und `wecken()`. Das `has_method("heilen")` braucht es nicht mehr, jedes Monster hat `heilen()`.
- **`start_position` statt `global_position`**: Gezählt wird der Raum, in dem das Monster **zu Hause** ist. Ein totes Monster liegt ja unsichtbar irgendwo herum.

Die Belohnungstruhe hat bisher gewartet, bis alle Monster im Raum **gelöscht** sind. Gelöscht wird jetzt keins mehr. In `truhe.gd`:

```gdscript
func _physics_process(_delta: float) -> void:
	if versteckt and monster_im_raum.all(func(monster: Monster) -> bool: return monster.tot):
		erscheinen()
```

- **`all(...)`** fragt jedes Element der Liste und antwortet `true`, wenn **alle** mit Ja antworten.
- **`func(monster: Monster) -> bool: return monster.tot`** ist eine Funktion ohne Namen, eine **Lambda**. `filter(is_instance_valid)` hat eine fertige Funktion bekommen. Hier gibt es keine fertige, die fragt „bist du tot?“, also wird sie direkt an Ort und Stelle geschrieben. Für eine Zeile lohnt sich keine eigene `func`.
- **Kommen die Monster zurück, wenn die Truhe schon da ist?** Ja, aber die Truhe bleibt. Einmal verdient ist verdient.

### 10.5 Der Spielstand kennt Iron Man

In `spielstand.gd` kommt eine Variable dazu, zum Beispiel unter `gestorben`:

```gdscript
var iron_man := false   # Tot ist tot: kein Speichern, kein Laden
```

`speichern()` hört gleich wieder auf, wenn es eine eiserne Runde ist:

```gdscript
func speichern(wo: Variant) -> void:
	if iron_man:
		return   # Ein eiserner Held hat keinen Kontrollpunkt
	startpunkt = wo
	...
```

Und eine neue Funktion zum Wegwerfen. Das stand bisher im Lotosstein, jetzt braucht es auch das Titelbild:

```gdscript
# Den Spielstand wegwerfen. Sonst holt der erste Tod ihn zurück.
func loeschen() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(DATEI))
```

Im Lotosstein wird aus der langen `DirAccess`-Zeile dann `Spielstand.loeschen()`.

- **Warum wird nicht gespeichert, ob es eine eiserne Runde ist?** Eine eiserne Runde hat gar keine Datei. Gibt es eine Datei, ist sie also immer von einem normalen Spiel.
- **Nur eine Stelle:** Der Held ruft `speichern()` weiter bei jedem Raumwechsel auf und muss von Iron Man nichts wissen. Das Signal `gespeichert` kommt dann auch nicht, also blinkt auch kein „Gespeichert“.

### 10.6 Der eiserne Held stirbt

In `held.gd` bekommt `sterben()` nach dem `await tween.finished` eine Abzweigung:

```gdscript
	await tween.finished
	if Spielstand.iron_man:
		await Dialog.zeigen(["Tot ist tot.", "Hier endet die Geschichte des eisernen Helden."])
		get_tree().change_scene_to_file("res://titel.tscn")
		return
	Spielstand.laden()
	...
```

`change_scene_to_file` kennst du aus Hüpfheld. Die Datei `titel.tscn` gibt es gleich.

### 10.7 Das Titelbild

Neue Szene, Wurzel **Control**, Name `Titel`. Oben im Editor bei Layout **Ganzes Rechteck** (Full Rect) wählen. Speichern als `titel.tscn`. Darunter:

1. **ColorRect** `Hintergrund`: auch **Ganzes Rechteck**, Farbe Schwarz.
2. **Label** `Name`: Text `KERKERHELD`. Position (0, 40), Größe (256, 32), Horizontal Alignment **Center**. Unter **Label Settings → Neue LabelSettings** die Schrift `Kenney Pixel.ttf`, Größe 32, und eine schöne Farbe. Ich hab Gold genommen.
3. **Label** `Menue`: Position (88, 100), Größe (112, 50), Label Settings `schrift_settings.tres`. Text bleibt leer, den schreibt das Skript.
4. **Label** `Hinweis`: Position (16, 170), Größe (224, 44), `schrift_settings.tres`, Horizontal Alignment **Center**, Autowrap Mode **Word (Smart)**. Hier steht, was der ausgewählte Eintrag bedeutet.

Skript an `Titel`, `titel.gd`:

```gdscript
extends Control

const DUNGEON = "res://dungeon.tscn"

# Was unter dem Menü steht, je nachdem, was gerade ausgewählt ist
const ERKLAERUNG = {
	"Weiter": "Da weitermachen, wo du zuletzt einen Raum betreten hast.",
	"Neues Spiel": "Wie im Original: Wer stirbt, steht am Eingang wieder auf. Monster auch.",
	"Iron Man": "Tot ist tot. Für Monster und für dich. Kein Speichern, kein Weiter.",
}

var eintraege: Array[String] = []
var auswahl := 0


func _ready() -> void:
	if Spielstand.spielstand_datei_vorhanden():
		eintraege.append("Weiter")
	eintraege.append_array(["Neues Spiel", "Iron Man"])
	anzeigen()


# Input statt _unhandled_input: just_pressed meldet sich nur einmal, auch wenn der Stick länger gedrückt bleibt
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hoch"):
		auswahl = posmod(auswahl - 1, eintraege.size())
		anzeigen()
	elif Input.is_action_just_pressed("runter"):
		auswahl = posmod(auswahl + 1, eintraege.size())
		anzeigen()
	elif Input.is_action_just_pressed("angriff"):
		starten(eintraege[auswahl])


func anzeigen() -> void:
	var text := ""
	for i in eintraege.size():
		text += ("> " if i == auswahl else "  ") + eintraege[i] + "\n"
	$Menue.text = text
	$Hinweis.text = ERKLAERUNG[eintraege[auswahl]]


func starten(was: String) -> void:
	Spielstand.iron_man = was == "Iron Man"
	match was:
		"Weiter":
			Spielstand.laden()
		"Neues Spiel":
			Spielstand.loeschen()
			Spielstand.neues_spiel()
		"Iron Man":
			Spielstand.neues_spiel()   # der normale Spielstand bleibt, wie er ist
	get_tree().change_scene_to_file(DUNGEON)
```

Zum Schluss **Projekt → Projekteinstellungen → Anwendung → Ausführen → Hauptszene** auf `titel.tscn` stellen. Mit F6 kannst du den Dungeon weiterhin direkt starten. Dann ist es ein normales Spiel mit dem gespeicherten Stand, dafür sorgt das `_init()` im Spielstand.

- **`Input.is_action_just_pressed()`** fragt nicht nach einem Ereignis, sondern nach dem Zustand: „Wurde das genau in diesem Bild gedrückt?“ Mit dem Steuerkreuz macht das keinen Unterschied. Aber ein Analogstick schickt beim Drücken eine ganze Reihe von Bewegungsereignissen, und mit `event.is_action_pressed()` würde die Auswahl durch das Menü rasen. `just_pressed` ist nur ein einziges Bild lang wahr.
- **`posmod(auswahl - 1, 3)`** ist der Rest wie `%`, aber nie negativ. Aus −1 wird 2: Oben über den Rand springt die Auswahl nach unten. `-1 % 3` wäre −1, und dann stünde der Pfeil nirgends, weil kein Eintrag die Nummer −1 hat.
- **`Spielstand.iron_man = was == "Iron Man"`** sieht seltsam aus, ist aber einfach: Rechts steht ein Vergleich, der `true` oder `false` ergibt, und das kommt in die Variable. Erst wird verglichen, dann zugewiesen.
- **Warum `laden()` bei „Weiter“?** Der Spielstand hat beim Start zwar schon geladen. Aber wer gerade aus einer eisernen Runde kommt, hat einen leeren Spielstand im Speicher. Also lieber noch einmal frisch aus der Datei.
- **Warum löschen bei „Neues Spiel“?** Das ist die Denkfrage aus Übung 4 von Kapitel 9: Stirbt der Held, bevor er zum ersten Mal einen Raum wechselt, würde `laden()` sonst den alten Stand zurückholen.

### 10.8 Der Lotosstein

Im Iron-Man-Spiel gibt es nichts zurückzusetzen. Der Stein soll dann verschwinden, auch wenn auf der Platte ein normaler Spielstand liegt. In `restart.gd`:

```gdscript
	var activ := Spielstand.spielstand_datei_vorhanden() and not Spielstand.iron_man
```

Eigentlich kann „Neues Spiel“ auf dem Titelbild jetzt dasselbe. Ob der Stein bleibt, entscheidest du. Er ist ja ganz nett.

### 10.9 Ausprobieren

- **Titelbild ohne Datei:** Nur „Neues Spiel“ und „Iron Man“. Mit hoch und runter wechselt der Text darunter.
- **Normal:** Besiege einen Glibber, geh raus und wieder rein. Er ist zurück, mit vollen Lebenspunkten, an seinem alten Platz.
- **Belohnungstruhe:** Besiege alle Monster im Raum. Die Truhe erscheint, sobald das letzte ganz geschrumpft ist. Raus, wieder rein: Die Monster sind zurück, die Truhe auch.
- **Schnell raus:** Besiege eine Fledermaus direkt an der Tür und lauf sofort hinaus. Wieder rein: Sie ist ganz da, nicht unsichtbar.
- **Iron Man:** Besiege einen Glibber, raus, wieder rein: Er bleibt weg. Es blinkt kein „Gespeichert“. Stirb: „Tot ist tot.“, dann das Titelbild.
- **Danach „Weiter“:** Hattest du vorher ein normales Spiel, geht es da weiter, wo es war.
- **Neues Spiel bei vorhandener Datei:** Der alte Stand ist weg, auch wenn du sofort stirbst.

### 10.10 Noch zwei Dinge aus Kapitel 9

Zuerst das Lob: Alle fünf Übungen laufen, und dazu die Prüfsumme gegen Schummler. Die Töpfe merken sich nur, wenn sie Münzen hatten, leere kommen wieder. Das „Gespeichert“ blinkt dreimal, bevor es verblasst. Der Grabstein zählt **nach** `laden()`, die Falle aus Übung 5 hast du also umgangen. Und der Lotosstein lädt die Szene neu und kümmert sich jetzt selbst darum, wann er sichtbar ist.

Diese zwei wirken sich auf das Verhalten aus:

1. **`speichern(wo: Vector2)` und `null`.** In `sterben()` steht jetzt `Spielstand.speichern(Spielstand.startpunkt)`. Stirbt der Held, bevor er je einen Raum gewechselt hat, ist `startpunkt` aber `null`, und `null` ist kein `Vector2`. Ausprobiert: Godot meldet `Cannot convert argument 1 from Nil to Vector2` und bricht `sterben()` an der Stelle ab. Die Szene wird nie neu geladen, der Held bleibt tot liegen. Lösung: `wo: Variant`, so wie oben in 10.5 schon steht.

2. **Mein Fehler: `null` als Ersatzwert.** Ich hatte dir gesagt, `get_value("held", "startpunkt", null)` liefert einfach `null`, wenn der Schlüssel fehlt. Stimmt nicht ganz. Für Godot heißt `null` als drittes Argument „kein Ersatzwert angegeben“, und es meldet `ERROR: Couldn't find the given section "held" and key "startpunkt", and no default was given.` Das Spiel läuft trotzdem weiter, aber eine rote Fehlermeldung bei jedem Laden ist nicht schön. In `laden()` besser vorher nachfragen, ob es den Schlüssel gibt:

   ```gdscript
   	# Fehlt, wenn vor dem ersten Raumwechsel gespeichert wurde. null als Ersatzwert zählt für Godot nicht.
   	startpunkt = datei.get_value("held", "startpunkt") if datei.has_section_key("held", "startpunkt") else null
   ```

Die Formatierung habe ich korrigiert: In `held.gd` und `restart.gd` fehlten Leerzeilen zwischen Funktionen. Der Kommentar über `init()` im Lotosstein sprach noch von der Kamera, die das gar nicht mehr aufruft. Außerdem habe ich einen Tab in einer Leerzeile in `inventar.gd` entfernt und Kommentare in `spielstand.gd` ergänzt.

### Übungsaufgaben zu Kapitel 10

1. **Sicher ist sicher (leicht):** „Neues Spiel“ löscht den alten Spielstand ohne Nachfrage. Gibt es eine Datei, soll vorher gefragt werden: „Dein altes Spiel wird gelöscht. Wirklich?“ Tipp: `Dialog` ist ein Autoload, `Dialog.frage()` geht also auch auf dem Titelbild. Und das Menü darf nicht auf die Taste reagieren, solange der Dialog offen ist. Woran merkst du das?
2. **Eiserne Anzeige (leicht):** Im Iron-Man-Spiel soll man sehen, dass es ernst ist. Zum Beispiel ein kleiner Totenkopf neben den Herzen oder graue statt roter Herzen. 💀
3. **Zurück zum Titel (mittel):** Eine neue Aktion `pause` (Escape und die Start-Taste am Controller). Sie fragt „Zurück zum Titelbild?“. Im normalen Spiel ist nichts verloren außer dem aktuellen Raum. Und im Iron-Man-Spiel? Ist Aufhören dort nicht dasselbe wie Sterben? Entscheide selbst, und schreib die Frage passend.
4. **Gedächtnis wie im Original (schwer):** In den Dungeons von Zelda bleiben besiegte Monster eine Weile weg. Erst wenn man ein paar andere Räume besucht hat, sind sie wieder da. Lass deine Monster erst zurückkommen, wenn der Held seitdem mindestens 3 **verschiedene** andere Räume betreten hat. Einfach die Raumwechsel zählen reicht nicht, denn dann läuft man zwischen zwei Räumen hin und her, und alles ist wieder da. Die Kamera braucht ein Gedächtnis für die letzten Räume, jeden nur einmal: die Klasse `LetzteRaeume` unten in `camera_2d.gd`. Wann fragst du sie, ob der Raum drin ist, und wann kommt er hinein? Die Reihenfolge ist wichtig.
5. **Ehrentafel:** Verschoben in Kapitel 11. Eine Bestenliste nach Räumen ist nur halb so spannend wie eine nach Zeit, und für eine Zeit braucht es ein Ende: den Boss.

Fertig? Committen und Bescheid geben.

---

## Kapitel 11: Der Boss

Hinter der goldenen Tür wartet bisher: nichts. Ein leerer Raum mit vier Statuen, die sich langweilen. Das ändert sich jetzt. Dort wohnt ab heute die **Kerkerkrabbe**: läuft seitwärts, spuckt Blasen, und wenn sie wütend wird, rennt sie los. Wer sie besiegt, findet die **Kerkerkrone**, und dann kommt ein richtiger **Abspann**.

Ein Abspann ohne Zahlen ist langweilig. Deshalb läuft ab jetzt eine **Uhr** mit, und das Spiel weiß, wie viel du **erkundet** hast: Alle Türen, die falsche Wand und alle Herzcontainer zusammen sind 100 %. So siehst du, ob noch etwas fehlt, aber nicht, was.

Und dann sind da noch die Töpfe. Monster kommen seit Kapitel 10 wieder, Töpfe nur nach dem Laden. Beim normalen Raumwechsel bleiben sie kaputt. Das ist ungerecht gegenüber den Monstern, also kommen die Töpfe jetzt auch wieder.

Neu sind ein **eigenes Signal im Spielstand**, ein Tween, den man **abbricht**, Kreise mit **`draw_circle()`** und ein Boss, der von `Monster` erbt und trotzdem **nie wiederkommt**.

### 11.1 Was kommt wohin?

| Was | Wo |
|---|---|
| Töpfe kommen wieder | `topf.gd`, `topf.tscn`, `camera_2d.gd` |
| Spielzeit | `spielstand.gd`, neues Label `Uhr` mit `uhr.gd`, `held.gd` |
| Erkundet in Prozent | `spielstand.gd` und fünf kleine Zeilen in `tuer.gd`, `falschewand.gd`, `fundstueck.gd`, `truhe.gd`, `angebot.gd` |
| Die Krone | `gegenstand.gd`, `spielstand.gd`, `held.gd` |
| Der Boss | `monster.gd`, neue Szenen `blase.tscn` und `krabbe.tscn` |
| Abspann | neue Szene `abschluss.tscn` mit `abschluss.gd` |

Iron Man und normal unterscheiden sich wieder ein bisschen:

| | Normal | Iron Man |
|---|---|---|
| Töpfe | kommen wieder wie die Monster | bleiben kaputt |
| Uhr | läuft unsichtbar mit, zu sehen in der Pausenfrage und im Abspann | steht oben in der Anzeige: Man spielt gegen die Uhr |
| Boss besiegt | bleibt besiegt, mit „Weiter“ kannst du danach den Rest suchen | Abspann, dann Titelbild |

### 11.2 Töpfe kommen wieder

Die Idee ist dieselbe wie bei den Monstern in Kapitel 10: **verstecken statt löschen**. Was mit `queue_free()` weg ist, kommt nicht wieder.

**Erst die Gruppe.** Öffne `topf.tscn`, wähl den Wurzelnode `Topf` → **Node → Gruppen** → `topf` eintippen → **Hinzufügen**. Damit findet die Kamera alle Töpfe, so wie sie über `monster` alle Monster findet.

**Dann `topf.gd`.** Oben bei den Variablen:

```gdscript
var ganz := true
var tween: Tween   # das Zerbrechen. Gemerkt, damit reparieren() es abbrechen kann.

@onready var start_frame: int = $Bild.frame
@onready var start_bild_position: Vector2 = $Bild.position
```

In `zerbrechen()` drei Änderungen: ganz oben `ganz = false`, aus `var tween := create_tween()` wird `tween = create_tween()`, und die letzten beiden Zeilen (`await tween.finished` und `queue_free()`) fliegen raus:

```gdscript
# Kurz plattdrücken, dann weg
func zerbrechen() -> void:
	ganz = false
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.06, true, false, true).timeout
	Engine.time_scale = 1.0
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	tween = create_tween()
	# ... alles andere wie bisher ...
	beute()
```

In `beute()` ganz unten, nach der Schleife:

```gdscript
	muenzen = 0   # Ein reparierter Topf ist leer
```

Und eine neue Funktion:

```gdscript
# Wieder ganz wie am Anfang. Im Iron-Man-Spiel bleibt kaputt kaputt.
func reparieren() -> void:
	if ganz or Spielstand.iron_man:
		return
	ganz = true
	if tween:
		tween.kill()   # falls es noch nicht fertig ist, zum Beispiel nach einer Pause
	$Bild.frame = start_frame
	$Bild.position = start_bild_position
	$Bild.scale = Vector2.ONE
	$Bild.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	$Hurtbox.set_deferred("monitoring", true)
```

- **`muenzen = 0`:** Ohne diese Zeile wäre jeder Topf mit Münzen eine Geldquelle ohne Boden. Zerschlagen, drei Räume weiter, zurück, wieder zerschlagen, wieder Münzen. Der Händler würde sich freuen, der Spielspaß nicht.
- **Alles zurück, was das Zerbrechen verstellt hat.** Der bewohnte Topf ändert sogar `frame` und `position` seines Bildes, denn da krabbelt ja die Spinne heraus. Deshalb merken wir uns beides gleich beim Start mit `@onready`.
- **`tween.kill()`:** Ein Tween hält an, wenn das Spiel pausiert, zum Beispiel beim Raumwechsel. Er ist dann nicht weg, er wartet nur. Wird der Topf repariert, während der alte Tween noch wartet, läuft er nach der Pause einfach weiter und macht den frisch reparierten Topf wieder platt. Das ist mir beim Testen genau so passiert. `kill()` wirft den Tween endgültig weg. Kennst du das Problem? Richtig, die Fledermaus aus Kapitel 10 hatte es auch. Dort lösen wir es anders herum: Der Tween läuft mit `PAUSE_PROCESS` immer zu Ende.
- **`if tween:`** Ein Topf, der nie zerbrochen ist, hat noch keinen Tween. `tween` ist dann `null`, und `null.kill()` wäre ein Absturz.

**Die Kamera** repariert die Töpfe genau dann, wenn sie auch die Monster weckt statt nur heilt. In `schieben()`:

```gdscript
	await tween.finished
	monster_wecken(letzte_raeume.enthaelt(neu))
	if not letzte_raeume.enthaelt(neu):
		toepfe_reparieren()
	letzte_raeume.hinzufuegen(neu)
```

Und ganz unten in `camera_2d.gd`:

```gdscript
# Zerbrochene Töpfe im aktuellen Raum wieder ganz machen
func toepfe_reparieren() -> void:
	for topf in get_tree().get_nodes_in_group("topf"):
		if raum_von(topf.global_position) == raum:
			topf.reparieren()
```

Wieder vor dem `hinzufuegen()`, aus demselben Grund wie in Übung 4 von Kapitel 10: Danach ist der Raum immer drin, und die Frage wäre sinnlos.

### 11.3 Die Uhr

Die Zeit gehört in den Spielstand, denn sie soll mitgespeichert werden. In `spielstand.gd` bei den Variablen:

```gdscript
var spielzeit := 0.0      # in Sekunden. Läuft nur, wenn das Spiel nicht angehalten ist.
```

In `neues_spiel()`:

```gdscript
	spielzeit = 0.0
```

In `speichern()` zu den anderen `set_value`:

```gdscript
	datei.set_value("held", "spielzeit", int(spielzeit))   # ganze Sekunden: Kommazahlen kommen nicht immer genau so zurück, und die Prüfsumme passt nicht mehr
```

In `laden()` zu den anderen `get_value`:

```gdscript
	spielzeit = datei.get_value("held", "spielzeit", 0.0)
```

Und eine Funktion, die aus Sekunden etwas Lesbares macht:

```gdscript
# Sekunden als Uhrzeit: 125 wird zu "2:05", 3725 zu "1:02:05"
func zeit_text(sekunden: float) -> String:
	var stunden := floori(sekunden / 3600)
	var minuten := floori(sekunden / 60) % 60
	var rest := floori(sekunden) % 60
	if stunden > 0:
		return "%d:%02d:%02d" % [stunden, minuten, rest]
	return "%d:%02d" % [minuten, rest]
```

- **Warum `int(spielzeit)` beim Speichern?** Das habe ich beim Testen auf die harte Tour gelernt. Die Zeit ist eine Kommazahl mit vielen Stellen, zum Beispiel `3726.2345678912345`. `ConfigFile` schreibt sie als Text in die Datei, aber nicht mit allen Stellen. Beim Laden kommt eine minimal andere Zahl heraus, der Text der Datei sieht dadurch beim Nachrechnen anders aus, und die Prüfsumme aus Kapitel 9 passt nicht mehr. Ergebnis: „Spielstand wurde verändert. Selber schuld!“, obwohl niemand etwas verändert hat. Ganze Sekunden kommen immer genau so zurück. Die halbe Sekunde, die dabei verloren geht, verschmerzt der Held.
- **`%02d`:** eine ganze Zahl, mindestens zwei Stellen, vorne mit Nullen aufgefüllt. Sonst stünde da `1:2:5` statt `1:02:05`.
- **`%` bei Zahlen** ist der Rest beim Teilen, wie bei den Herzen in Kapitel 6. 125 Sekunden sind 2 Minuten und **Rest** 5.

**Wer zählt?** Ein neues Label in der Anzeige. Rechtsklick auf `Anzeige` im Dungeon → **Kind-Node hinzufügen** → `Label`, Name `Uhr`. Position etwa (120, 33), also rechts neben den Münzen. Text `0:00`, bei **Label Settings** `schrift_settings.tres`. Neues Skript `uhr.gd`:

```gdscript
extends Label

# Zählt die Spielzeit. Bei Dialogen und Raumwechseln ist das Spiel angehalten, dann steht auch die Uhr.


func _ready() -> void:
	visible = Spielstand.iron_man   # Nur der eiserne Held spielt gegen die Uhr


func _process(delta: float) -> void:
	Spielstand.spielzeit += delta
	text = Spielstand.zeit_text(Spielstand.spielzeit)
```

- **Warum zählt nicht der Spielstand selbst?** Der ist ein Autoload und läuft immer, auch auf dem Titelbild und im Abspann. Die Uhr gibt es nur im Dungeon. Und weil sie ganz normal pausiert, steht die Zeit bei jedem Dialog still. Wer einen Schild in Ruhe liest, wird dafür nicht bestraft. Auch die Pause mit Escape aus Übung 3 hält die Uhr an.
- **Unsichtbar zählt sie trotzdem.** `visible = false` versteckt nur das Bild, `_process` läuft weiter.

**Sterben darf die Zeit nicht zurückdrehen.** In `held.gd` in `sterben()` holt `laden()` alles vom letzten Speichern zurück, auch die Zeit. Dann wären die Sekunden seit dem letzten Raumwechsel verloren. Also kurz festhalten:

```gdscript
	var zeit := Spielstand.spielzeit   # Die Uhr läuft weiter, auch wenn der Held von vorn anfängt
	Spielstand.laden()
	Spielstand.spielzeit = zeit
	Spielstand.gestorben += 1
	Spielstand.speichern(Spielstand.startpunkt)
	get_tree().reload_current_scene()
```

Bei `gestorben` haben wir genau das umgekehrt gemacht: erst laden, dann eins dazu. Beide Male geht es um dieselbe Frage: Was soll das Sterben überleben?

### 11.4 Erkundet

Was zählt für 100 %? Alle Türen, die falsche Wand und alle Herzcontainer, egal ob sie frei herumliegen, in einer Truhe stecken oder beim Händler stehen. Das Schöne: Alle diese Dinge melden sich schon mit `Spielstand.erledigen(self)`, wenn sie geöffnet, zerbrochen, eingesammelt oder gekauft werden. Wir müssen nur noch wissen, wie viele es **insgesamt** gibt.

In `spielstand.gd` bei den Variablen:

```gdscript
var zu_erkunden := {}    # Pfad im Dungeon -> true: alles, was für 100 % zählt. Füllt sich beim Bauen des Dungeons.
```

Und zwei Funktionen:

```gdscript
# Dieses Ding zählt für die Erkundung. Gehört in _ready(), noch vor ein mögliches queue_free().
func zaehlt_mit(ding: Node) -> void:
	zu_erkunden[str(ding.get_path())] = true


# Wie viel Prozent davon schon erledigt ist. floori: 100 % gibt es erst, wenn wirklich alles gefunden ist.
func erkundet() -> int:
	if zu_erkunden.is_empty():
		return 0
	var gefunden := zu_erkunden.keys().filter(func(pfad: String) -> bool: return pfad in erledigt).size()
	return floori(100.0 * gefunden / zu_erkunden.size())
```

Jetzt melden sich die Dinge an, jeweils als **erste Zeile** in `_ready()`:

`tuer.gd` und `falschewand.gd`:

```gdscript
	Spielstand.zaehlt_mit(self)
```

`fundstueck.gd`:

```gdscript
	if art == Gegenstand.Art.HERZCONTAINER and not drop:
		Spielstand.zaehlt_mit(self)
```

`truhe.gd`:

```gdscript
	if inhalt == Gegenstand.Art.HERZCONTAINER:
		Spielstand.zaehlt_mit(self)
```

`angebot.gd`:

```gdscript
	if ware == Gegenstand.Art.HERZCONTAINER and einmalig:
		Spielstand.zaehlt_mit(self)
```

- **Warum als erste Zeile?** Eine offene Tür löscht sich in `_ready()` gleich wieder mit `queue_free()` und `return`. Was danach steht, erreicht sie nie. Dann würde jede offene Tür aus der Rechnung verschwinden, und je mehr du öffnest, desto weniger gäbe es insgesamt. Nach dem Laden hättest du plötzlich 100 %, obwohl noch die Hälfte fehlt.
- **Warum wird `zu_erkunden` nicht gespeichert?** Es ist bei jedem Bauen des Dungeons wieder gleich, denn es hängt nur davon ab, was du im Editor hingestellt hast. Stellst du später einen neuen Herzcontainer auf, zählt er sofort mit, auch für alte Spielstände.
- **`floori` statt `roundi`:** Bei 19 Dingen sind 18 gefunden 94,7 %. `roundi` macht daraus 95 %, das ist in Ordnung. Aber wie wäre es bei 199 von 200? 99,5 % würden auf **100 %** gerundet, obwohl noch etwas fehlt. Genau das soll die Anzeige aber verraten. `floori` rundet immer ab.
- **`filter` mit einer Funktion ohne Namen** kennst du von `all()` aus Kapitel 10. `filter` behält nur die Pfade, für die die Funktion `true` sagt, also die schon erledigten.
- Bei mir zählt dein Dungeon gerade **19** Dinge: 11 Türen, eine falsche Wand, 7 Herzcontainer.

**Wo sieht man das?** In der Pause. In `held.gd` wird die erste Frage etwas länger:

```gdscript
	if Input.is_action_just_pressed("pause"):
		var stand := "Erkundet: %d %%   Zeit: %s\n" % [Spielstand.erkundet(), Spielstand.zeit_text(Spielstand.spielzeit)]
		if await Dialog.frage(stand + "Zurück zum Titelbildschirm?"):
```

**`%%`** ist ein echtes Prozentzeichen. Ein einzelnes `%` hält Godot für den Anfang eines Platzhalters wie `%d`.

### 11.5 Die Krone

Ein neuer Gegenstand. In `gegenstand.gd` kommt `KRONE` ans **Ende** des Enums:

```gdscript
enum Art { SCHLUESSEL, MASTERSCHLUESSEL, KARTE, KOMPASS, HERZ, HERZCONTAINER, MUENZE, KRONE }
```

Bei `NAMEN`:

```gdscript
	Art.KRONE: "Die Kerkerkrone",
```

Und bei `BILDER` ein neues Bild, wie immer aus Text:

```gdscript
	Art.KRONE: [
		[
			".o...o...o.",
			"o+o.o+o.o#o",
			"o#+o#+#o##o",
			"o#########o",
			"o#r##b##r#o",
			"o#########o",
			"ooooooooooo",
		],
		{"o": BRAUN, "#": GOLD, "+": BEIGE, "r": ROT, "b": Color(0.2, 0.5, 1.0)},
	],
```

**Warum ans Ende?** Hinter jedem Namen im Enum steckt eine Zahl: `SCHLUESSEL` ist 0, `MASTERSCHLUESSEL` 1, ... `MUENZE` 6. Im Spielstand steht das Inventar mit diesen **Zahlen**, nicht mit den Namen. Schreibst du `KRONE` zwischen `HERZ` und `HERZCONTAINER`, wird `HERZCONTAINER` zur 6 und `MUENZE` zur 7. Beim nächsten Laden sind aus deinen 42 Münzen plötzlich 42 Herzcontainer geworden. Klingt erst mal gut, ist aber falsch. Und an den Truhen im Editor stehen auch nur Zahlen (`inhalt = 4`), die würden sich genauso verschieben.

**Wer merkt, dass die Krone da ist?** Der Spielstand, denn bei ihm kommt jeder Gegenstand an. Oben ein neues Signal:

```gdscript
signal gewonnen
```

Und ganz unten in `hinzufuegen()`, nach dem `else`-Block:

```gdscript
	if art == Gegenstand.Art.KRONE:
		gewonnen.emit()
```

Die Krone landet dabei ganz normal im Inventar und wird mitgespeichert. Das Signal ruft nur zusätzlich „Gewonnen!“ in die Runde. Wer zuhört, entscheidet selbst, was er damit macht.

**Der Held hört zu.** In `held.gd` in `_ready()`:

```gdscript
	Spielstand.gewonnen.connect(gewinnen)
```

Und neben `sterben()`:

```gdscript
# Die Krone ist da: stehen bleiben, staunen, ab zum Abspann
func gewinnen() -> void:
	set_physics_process(false)
	$AnimationPlayer.play("stehen")
	await get_tree().create_timer(2.0).timeout
	await Dialog.zeigen(["Die Kerkerkrone! Der Kerker ist befreit."])
	Spielstand.speichern(Spielstand.startpunkt)   # Krabbe und Krone merken. Im Iron-Man-Spiel passiert hier nichts.
	get_tree().change_scene_to_file("res://abschluss.tscn")
```

- **`connect` an einen Autoload:** Der Held verbindet sich mit dem Spielstand, der Spielstand lebt aber viel länger als der Held. Stirbt der Held, wird der Dungeon neu gebaut, und der alte Held ist weg. Godot löst die Verbindung dann von selbst, du musst nichts aufräumen.
- **`set_physics_process(false)`:** Während der Held staunt, kann er nicht laufen. Und weil `treffer_pruefen()` auch in `_physics_process` steckt, kann ihn auch keine letzte Blase mehr treffen.
- **Speichern mit dem alten Startpunkt:** Im normalen Spiel steht der Held nach „Weiter“ am Eingang des Bossraums. Die Krabbe ist dann besiegt, die Truhe offen, und du kannst in Ruhe den Rest suchen.

### 11.6 Ein Boss ist größer

Die Krabbe wird dreimal so groß wie die anderen Monster. Das Bild bekommt dafür `scale = (3, 3)`. Aber `wecken()` in `monster.gd` setzt beim Wiederbeleben `$Bild.scale = Vector2.ONE`, und schon wäre der Boss so klein wie ein Glibber. Die Vorlage hat einfach angenommen, dass alle Monster gleich groß sind. Das ändern wir. In `monster.gd`:

```gdscript
var start_groesse := Vector2.ONE     # so groß war das Bild beim Start. Der Boss ist größer als die anderen.
```

In `_ready()`:

```gdscript
func _ready() -> void:
	start_position = global_position
	start_groesse = $Bild.scale
```

Und in `wecken()` aus `$Bild.scale = Vector2.ONE`:

```gdscript
	$Bild.scale = start_groesse
```

Genau wie bei `start_position`: Was beim Start war, merken, und beim Wecken dahin zurück.

### 11.7 Die Blase

Bevor die Krabbe spucken kann, braucht sie etwas zum Spucken. Neue Szene:

1. Wurzel **CharacterBody2D**, Name `Blase`. **Motion Mode** auf **Floating**, wie beim Helden: Oben und unten gibt es in einem Dungeon von oben nicht.
2. **Collision → Layer** nur `3` (Gegner), **Mask** nur `1` (Welt).
3. Kind **CollisionShape2D** mit einem **CircleShape2D**, Radius 4.
4. Kind **Area2D**, Name `Hurtbox`. **Layer** leer, **Mask** nur `4` (Schwert). Darunter wieder eine **CollisionShape2D** mit einem Kreis, Radius 4.
5. Signal `area_entered` der Hurtbox mit der Blase verbinden.
6. Speichern als `blase.tscn`, Skript `blase.gd`:

```gdscript
extends CharacterBody2D

# Eine Blase der Kerkerkrabbe: fliegt geradeaus und platzt an der Wand, am Helden oder am Schwert

const TEMPO = 70.0
const RADIUS = 4.0

@export var schaden := 1   # in halben Herzen

var richtung := Vector2.DOWN


func _physics_process(delta: float) -> void:
	if move_and_collide(richtung * TEMPO * delta):
		platzen()


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(0.6, 0.85, 1.0, 0.5))
	draw_arc(Vector2.ZERO, RADIUS, 0, TAU, 16, Color(0.85, 0.95, 1.0))
	draw_rect(Rect2(-2, -2, 1, 1), Color.WHITE)   # ein Glanzpunkt


# Der Held meldet: getroffen
func hat_getroffen() -> void:
	platzen()


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	platzen()


func platzen() -> void:
	queue_free()
```

- **Kein Bild nötig:** Im Kenney-Paket gibt es keine Blase. Also malen wir eine: ein halb durchsichtiger Kreis, ein heller Rand, ein Glanzpunkt. `draw_circle()` malt einen gefüllten Kreis, `draw_arc()` einen Kreisbogen, und von 0 bis `TAU` ist das einmal ganz herum.
- **Warum trifft die Blase den Helden?** Seine Hurtbox schaut auf Ebene 3 (Gegner) nach Körpern, und die Blase ist ein Körper auf Ebene 3. Für die Hurtbox ist sie ein Monster wie jedes andere. Sie braucht nur ein `schaden`, und das hat sie.
- **`hat_getroffen()`** ruft der Held schon lange bei jedem Monster auf, das ihn erwischt, falls es die Funktion hat. Der Glibber ruht sich danach aus, die Blase platzt.
- **`move_and_collide()`** statt `move_and_slide()`: Es bewegt und meldet die erste Kollision zurück, sonst `null`. Eine Blase soll an der Wand nicht entlangrutschen, sondern platzen.
- **Mit dem Schwert zerstechen:** Die Hurtbox der Blase merkt das Schwert, genau wie bei den Töpfen.

### 11.8 Die Kerkerkrabbe

Neue Szene:

1. Wurzel **CharacterBody2D**, Name `Krabbe`, in die Gruppe `monster`. **Motion Mode** auf **Floating**.
2. **Collision → Layer** nur `3` (Gegner), **Mask** `1` (Welt) und `5` (Gegnersperre). **Nicht** `3`! Sonst stolpert die Krabbe über ihre eigenen Blasen, die ja auch auf Ebene 3 sind und genau unter ihr entstehen.
3. Kind **Sprite2D**, Name `Bild`: `tilemap_packed.png`, **Hframes** 12, **Vframes** 11, **Frame** 110 (das rote Ding mit den Scheren). **Scale** (3, 3).
4. Kind **CollisionShape2D** mit einem Rechteck 36 × 20, **Position** (0, 10). Das sind ihre Füße: Mit dem Kopf darf sie ruhig über eine Wand ragen.
5. Kind **Area2D**, Name `Hurtbox`, **Layer** leer, **Mask** nur `4` (Schwert). Darunter eine **CollisionShape2D** mit einem Rechteck 42 × 40, also fast die ganze Krabbe.
6. Kind **AudioStreamPlayer**, Name `Treffer`, mit `hit.wav`.
7. Signal `area_entered` der Hurtbox mit der Krabbe verbinden.
8. Speichern als `krabbe.tscn`, Skript `krabbe.gd`:

```gdscript
extends Monster

# Die Kerkerkrabbe: läuft seitwärts hin und her, spuckt Blasen, und wenn sie wütend ist, rennt sie los

enum Zustand { SEITWAERTS, ZIELEN, ANLAUF, STURM }

const BLASE = preload("res://blase.tscn")
const MAX_LEBEN = 8
const SEIT_TEMPO = 40.0
const STURM_TEMPO = 150.0
const FAECHER = [-0.35, 0.0, 0.35]   # drei Blasen, leicht gefächert (Winkel im Bogenmaß)
const SCHONZEIT = 0.5                # so lange nach einem Treffer unverwundbar

@export var schaden := 2   # in halben Herzen

var leben := MAX_LEBEN
var zustand := Zustand.SEITWAERTS
var zustand_zeit := 0.0
var richtung := Vector2.LEFT
var schonzeit := 0.0

@onready var held: Node2D = get_tree().get_first_node_in_group("held")


func _ready() -> void:
	super()
	# Schon besiegt? Dann tot bleiben. Nicht löschen, sonst wüsste die Truhe nicht, dass sie erscheinen darf.
	if Spielstand.ist_erledigt(self):
		tot = true
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
		$Hurtbox.set_deferred("monitoring", false)
		set_physics_process(false)
		return
	heilen()


# Ein Boss kommt nie wieder, auch nicht im normalen Spiel
func wecken() -> void:
	if Spielstand.ist_erledigt(self):
		return
	super()


func heilen() -> void:
	leben = MAX_LEBEN
	schonzeit = 0.0
	wechseln(Zustand.SEITWAERTS)


# Wütend ist sie ab der Hälfte
func wuetend() -> bool:
	return leben <= MAX_LEBEN / 2.0


func _physics_process(delta: float) -> void:
	zustand_zeit -= delta
	schonzeit -= delta
	$Bild.position.x = 0

	match zustand:
		Zustand.SEITWAERTS:
			# Erst umdrehen, dann losgehen. Andersherum zappelt sie an der Wand hin und her.
			if is_on_wall():
				richtung = -richtung   # umdrehen, ohne den Kopf zu drehen: Krabben eben
			velocity = richtung * SEIT_TEMPO * (1.5 if wuetend() else 1.0)
			if zustand_zeit <= 0:
				wechseln(Zustand.ANLAUF if wuetend() and randf() < 0.5 else Zustand.ZIELEN)
		Zustand.ZIELEN, Zustand.ANLAUF:
			velocity = Vector2.ZERO
			$Bild.position.x = randi_range(-1, 1)   # zittern: Gleich passiert was!
			if zustand_zeit <= 0:
				if zustand == Zustand.ZIELEN:
					spucken()
					wechseln(Zustand.SEITWAERTS)
				else:
					wechseln(Zustand.STURM)
		Zustand.STURM:
			velocity = richtung * STURM_TEMPO
			if get_slide_collision_count() > 0:   # gegen die Wand gerannt
				wechseln(Zustand.SEITWAERTS)

	move_and_slide()


func wechseln(neu: Zustand) -> void:
	zustand = neu
	match neu:
		Zustand.SEITWAERTS:
			richtung = [Vector2.LEFT, Vector2.RIGHT].pick_random()
			zustand_zeit = randf_range(1.5, 3.0)
		Zustand.ZIELEN:
			zustand_zeit = 0.5
		Zustand.ANLAUF:
			zustand_zeit = 0.7
		Zustand.STURM:
			# Die Richtung wird beim Losrennen festgelegt. Wer jetzt ausweicht, wird verfehlt.
			richtung = global_position.direction_to(held.global_position)


# Drei Blasen auf den Helden zu, wütend fünf
func spucken() -> void:
	var winkel: Array = FAECHER
	if wuetend():
		winkel = [-0.7] + FAECHER + [0.7]
	for w: float in winkel:
		var blase := BLASE.instantiate()
		blase.position = position + Vector2(0, 8)
		blase.richtung = global_position.direction_to(held.global_position).rotated(w)
		get_parent().add_child(blase)


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	if schonzeit > 0:
		return
	schonzeit = SCHONZEIT
	leben -= 1
	$Treffer.play()
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.06, true, false, true).timeout
	Engine.time_scale = 1.0
	var tween := create_tween()
	tween.tween_property($Bild, "modulate", Color.RED, 0.05)
	tween.tween_property($Bild, "modulate", Color.WHITE, 0.2)
	if leben <= 0:
		sterben()


# Erst lange blinken, dann wie jedes Monster verschwinden
func sterben() -> void:
	Spielstand.erledigen(self)
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for i in 8:
		tween.tween_property($Bild, "modulate", Color.RED, 0.1)
		tween.tween_property($Bild, "modulate", Color.WHITE, 0.1)
	await tween.finished
	super()
```

Das meiste kennst du vom Glibber. Neu sind ein paar Dinge:

- **Ein Monster, das nie wiederkommt.** Die Krabbe erbt von `Monster`, damit die Kamera sie schlafen schickt und weckt wie alle anderen. Aber ihr `wecken()` fragt zuerst: Bin ich schon erledigt? Dann bleibt sie, wo sie ist, nämlich unsichtbar und tot. Das gilt auch im normalen Spiel. Gemerkt wird das mit `Spielstand.erledigen(self)` beim Sterben, wie bei einer Truhe. Das kommt also mit in den Spielstand und überlebt auch das Laden.
- **Warum nicht einfach `queue_free()`, wenn sie schon besiegt ist?** Weil die Truhe mit der Krone eine Belohnungstruhe ist. Sie schaut in ihrem `_ready()` nach, welche Monster im Raum sind, und wartet, bis alle `tot` sind. Ist die Krabbe gelöscht, fragt die Truhe ein Monster, das es nicht mehr gibt, und das gibt einen Fehler. Ob die Truhe vorher dran ist oder die Krabbe, hängt nur von der Reihenfolge im Szenenbaum ab. Auf so etwas will man sich nicht verlassen. Eine tote, unsichtbare Krabbe dagegen sagt brav `tot = true`.
- **Erst umdrehen, dann losgehen.** Das hatte ich zuerst andersherum, und die Krabbe ist an der Wand kleben geblieben. Warum? `is_on_wall()` meldet, ob beim **letzten** `move_and_slide()` eine Wand im Weg war. Steht die Berechnung von `velocity` vor dem Umdrehen, läuft sie noch ein Bild lang gegen die Wand. Im nächsten Bild meldet `is_on_wall()` also wieder `true`, sie dreht zurück, läuft wieder gegen die Wand, und so weiter. Ein Bild nach links, eins nach rechts, für immer.
- **`MAX_LEBEN / 2.0`:** Mit `/ 2` wäre das eine Ganzzahl-Division, und Godot warnt davor (bei 8 kommt zwar dasselbe heraus, bei 7 nicht). Mit `2.0` wird gerechnet, wie man es erwartet.
- **`winkel = [-0.7] + FAECHER + [0.7]`:** Arrays kann man mit `+` aneinanderhängen. Wütend spuckt sie also fünf Blasen statt drei. `rotated(w)` dreht die Richtung zum Helden um diesen Winkel. 0.35 im Bogenmaß sind ungefähr 20 Grad.
- **Schonzeit statt GETROFFEN-Zustand:** Der Glibber fliegt nach einem Treffer zurück. Eine Krabbe dreimal so groß wie der Held fliegt nirgendwohin, sie zuckt nur kurz rot. Damit ein Schwertstich nicht mehrfach zählt, ist sie danach eine halbe Sekunde unverwundbar.
- **Ein langer Tod mit `super()` am Ende:** Erst acht Mal rot blinken, dann ruft sie das normale `sterben()` aus `monster.gd` auf: schrumpfen, verschwinden, `tot = true`. In `super()` steht auch noch `beute()`. Die Krabbe stellt aber keine Droprate ein, also fällt nichts heraus. Ihre Beute ist die Krone.

### 11.9 Ab in den Bossraum

Im Dungeon:

1. Zieh `krabbe.tscn` in den Bossraum, oben in die Mitte, ungefähr (1152, -824).
2. Zieh eine `truhe.tscn` in die Mitte darunter, ungefähr (1152, -776). Im Inspector: **Inhalt** auf **Krone**, **Belohnung** an.

Das ist alles. Eine Belohnungstruhe erscheint schon lange von selbst, wenn alle Monster im Raum besiegt sind, und die Krabbe ist ein Monster. Dein Marker `Bossraum` bleibt, wo er ist. Der Kompass braucht ihn weiter.

### 11.10 Der Abspann

Neue Szene, aufgebaut wie das Titelbild:

1. Wurzel **Control**, Name `Abschluss`, **Layout → Ganzes Rechteck** (Full Rect).
2. Kind **ColorRect** `Hintergrund`, ebenfalls Ganzes Rechteck, schwarz.
3. Kind **Label** `Ueberschrift`: Position (0, 30), Größe 256 × 30, Text „DER KERKER IST BEFREIT!“, zentriert, in Gold und gern etwas größer (eigene Label Settings mit der Kenney-Schrift und Größe 16).
4. Kind **Label** `Ergebnis`: Position (16, 80), Größe 224 × 120, `schrift_settings.tres`, zentriert, **Autowrap** auf **Word (Smart)**.
5. Speichern als `abschluss.tscn`, Skript `abschluss.gd`:

```gdscript
extends Control

# Der Abspann: wie lange, wie gründlich, wie oft gestorben


func _ready() -> void:
	var text := "Zeit: %s\nErkundet: %d %%\n" % [Spielstand.zeit_text(Spielstand.spielzeit), Spielstand.erkundet()]
	if Spielstand.iron_man:
		text += "Kein einziges Mal gestorben!"
	else:
		text += "Gestorben: %d-mal" % Spielstand.gestorben
		if Spielstand.erkundet() < 100:
			text += "\n\nDa fehlt noch was ...\nMit \"Weiter\" suchst du es."
	$Ergebnis.text = text


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("angriff"):
		get_tree().change_scene_to_file("res://titel.tscn")
```

- **„Kein einziges Mal gestorben!“** steht da im Iron-Man-Spiel immer. Wer dort stirbt, sieht den Abspann ja nie. Klingt trotzdem gut.
- **`\"` im Text:** ein Anführungszeichen, das den Text nicht beendet.
- **Woher kennt der Abspann `erkundet()`?** `zu_erkunden` steckt im Spielstand, und der Spielstand ist ein Autoload. Er überlebt den Szenenwechsel, mitsamt allem, was der Dungeon beim Bauen hineingeschrieben hat.

### 11.11 Ausprobieren

- [ ] Topf zerschlagen, drei andere Räume besuchen, zurück: Der Topf ist wieder ganz. Ein Topf mit Münzen gibt beim zweiten Mal nichts mehr.
- [ ] Topf zerschlagen, raus und sofort wieder rein: Der Topf bleibt kaputt, wie die Monster.
- [ ] Iron Man: Die Uhr läuft oben neben den Münzen. Sie steht, solange ein Schild offen ist.
- [ ] Escape: In der Pausenfrage stehen Erkundet und Zeit. Tür aufschließen, wieder Escape: Die Prozent sind gestiegen.
- [ ] Normal: Sterben, Escape: Die Zeit ist nicht zurückgesprungen.
- [ ] Spiel beenden, „Weiter“: Die Zeit ist noch da, und es gibt **keine** Warnung „Spielstand wurde verändert“.
- [ ] Bossraum: Die Krabbe läuft seitwärts, zittert, spuckt drei Blasen. Blasen platzen an der Wand, am Helden und am Schwert.
- [ ] Nach vier Treffern ist sie wütend: schneller, fünf Blasen, und manchmal rennt sie auf dich zu.
- [ ] Raus aus dem Bossraum und wieder rein: Sie hat wieder volle Lebenspunkte.
- [ ] Besiegt: langes Blinken, dann erscheint die Truhe. Darin die Krone, dann der Abspann.
- [ ] Normal: Titelbild → „Weiter“: Du stehst am Eingang des Bossraums, die Krabbe ist weg, die Truhe offen.

### 11.12 Was beim Bauen schiefging

Damit du siehst, dass auch ich nicht alles beim ersten Mal richtig mache:

- **Die Prüfsumme und die Kommazahl:** Die Zeit stand zuerst als Kommazahl in der Datei. Nach dem ersten Laden kam „Spielstand wurde verändert. Selber schuld!“, obwohl niemand dran war. Lösung: ganze Sekunden (11.3).
- **Die zappelnde Krabbe:** Erst `velocity`, dann umdrehen, und sie klebte an der Wand (11.8).
- **Der Topf, der sich selbst wieder kaputt macht:** Ohne `tween.kill()` hat ein noch wartender Tween den frisch reparierten Topf nach der Pause wieder plattgedrückt (11.2).

### Übungsaufgaben zu Kapitel 11

1. **Ehrentafel (mittel):** Die Übung aus Kapitel 10, jetzt mit Zeit statt Räumen. Merk dir in einer eigenen Datei `user://ironman.cfg` die **fünf schnellsten** eisernen Helden. Nach dem Abspann im Iron-Man-Spiel kommt die Zeit dazu, wenn sie gut genug ist. Auf dem Titelbild steht dann zum Beispiel „Schnellster eiserner Held: 12:34“, und im Abspann siehst du die ganze Liste. Ein paar Tipps: `Array.sort()` sortiert, `resize(5)` schneidet ab. Speicher ganze Sekunden, du weißt jetzt warum. Und weil man so etwas gern fälscht: Die Prüfsumme aus Kapitel 9 passt hier auch. 🏆
2. **Kein Entkommen (mittel):** Im Original schließen sich die Türen hinter dem Helden, sobald er den Bossraum betritt, und gehen erst wieder auf, wenn der Boss besiegt ist. Bau ein Gitter in den Eingang des Bossraums. Wann geht es zu? Wann auf? Und was ist nach dem Laden, wenn die Krabbe schon besiegt ist?
3. **Lebensbalken (leicht):** Ein Boss ohne Lebensbalken ist wie eine Krabbe ohne Scheren. Mal mit `_draw()` einen kleinen Balken über die Krabbe, der mit jedem Treffer kürzer wird. Tipp: `queue_redraw()` nicht vergessen, wenn sich `leben` ändert.
4. **Fortschritt auf dem Titelbild (mittel):** Unter „Weiter“ soll stehen, wie weit du bist: „Erkundet 63 %, Zeit 1:02:05“. Die Zeit ist leicht, die kommt ja mit `laden()`. Aber `erkundet()` sagt auf dem Titelbild immer 0. Warum? Und wie kommt die Zahl trotzdem dorthin? Tipp: Was der Dungeon weiß, muss in die Datei.
5. **Man sieht die Wut (leicht):** Ab der Hälfte ist die Krabbe wütend, aber man sieht es ihr nicht an. Färb sie dann etwas dunkler rot ein, und lass sie beim Zittern stärker wackeln. Aufpassen: `wecken()` setzt `modulate` zurück auf Weiß, und das Blinken bei Treffern auch. Und als Bonus: die Krone im Inventar oben anzeigen, sobald man sie hat. 👑

Fertig? Committen und Bescheid geben.


---

## Kapitel 12: Rätsel und Fallen

Der Kerker hat einen Boss, eine Krone und einen Abspann. Aber etwa zehn Räume sind noch fast leer: ein Schild, eine Tür, sonst nur Sand und ein paar Steinchen. Im Original sind genau das die Räume, an die man sich erinnert: ein Block, den man schieben muss, Fallen, die durch den Raum sausen, und Steingesichter, die aus der Wand spucken.

Davon bauen wir in diesem Kapitel vier Bausteine. Mit ihnen kannst du die leeren Räume füllen, ganz wie du willst:

- **Bodenschalter:** gedrückt, solange der Held oder etwas Schweres darauf steht.
- **Gitter:** geht auf und zu, wenn man es ihm sagt. Zum Beispiel ein Schalter.
- **Felsbrocken:** Der Held schiebt ihn, immer eine Kachel weit.
- **Wasserspeier:** ein Gesicht in der Wand, das Blasen nach dem Helden spuckt.
- **Klingenfalle:** ein Stahlstern, der losschießt, sobald der Held in seiner Reihe steht.

Das sind fünf. Die Klingenfalle gibt es als Zugabe. 😉

Neu sind **Signale, die du im Editor von einem Ding im Dungeon zu einem anderen verbindest**, **`test_move()`**: „Würde ich anstoßen, wenn ich mich so bewege?“, die Physik-Bildnummer **`Engine.get_physics_frames()`** und gemalte Formen mit **`draw_colored_polygon()`** und **`draw_set_transform()`**.

### 12.1 Noch zwei Dinge aus Kapitel 11

Bevor es mit den Rätseln losgeht, noch zwei Reste aus dem letzten Kapitel. Beide wirken sich auf das Verhalten aus.

1. **Der Lebensbalken bleibt kurz.** Wird die Krabbe geheilt, zum Beispiel weil der Held den Raum verlässt und wiederkommt, zeigt der Balken immer noch die alten Treffer. `queue_redraw()` steht nur im Treffer, nicht in `heilen()`. Die sauberste Lösung ist ein Setter, wie beim Leben im Spielstand. Dann kann man es nirgends mehr vergessen:

    ```gdscript
    var leben := MAX_LEBEN:
    	set(wert):
    		leben = wert
    		queue_redraw()   # Der Balken stimmt immer, egal wer leben ändert
    ```

    Das `queue_redraw()` in `_on_hurtbox_area_entered` darf dann weg.

    Im Spiel fällt der Fehler kaum auf: Solange die Bosssperre steht, kommst du aus dem Raum nicht heraus, und nach dem Laden ist der Balken wieder voll. Aber sobald irgendwo `leben` geändert wird, ohne dass `queue_redraw()` danebensteht, ist er wieder da. Mit dem Setter kann das nicht mehr passieren.

2. **Die wütende Krabbe blinkt bei Treffern nicht mehr.** `$Bild.modulate = Color(1.0, 0.5, 0.8)` steht in `_physics_process` und läuft damit 60-mal pro Sekunde. Der rote Treffer-Tween setzt `modulate` auf Rot, und ein Bild später ist es schon wieder rosa. Besser: Die Farbe nur dort setzen, wo sie sich ändern kann, also am Ende des Treffer-Tweens. Eine kleine Funktion sagt, welche Farbe gerade richtig ist:

    ```gdscript
    const WUT = Color(1.0, 0.5, 0.8)

    # Weiß, oder rosa vor Wut
    func farbe() -> Color:
    	return WUT if wuetend() else Color.WHITE
    ```

    Im Treffer dann `tween.tween_property($Bild, "modulate", farbe(), 0.2)` statt `Color.WHITE`, und die zwei Zeilen mit `if wuetend()` in `_physics_process` fallen weg. Beim Wecken setzt `wecken()` sie auf Weiß, und weil `heilen()` danach volle Lebenspunkte gibt, stimmt das auch.

### 12.2 Was kommt wohin, und welcher Raum bekommt was?

| Was | Wo |
|---|---|
| Gitter | neue Szene `gitter.tscn` mit `gitter.gd` |
| Bodenschalter | neue Szene `schalter.tscn` mit `schalter.gd` |
| Felsbrocken | neue Szene `felsbrocken.tscn` mit `felsbrocken.gd`, ein paar Zeilen in `held.gd` |
| Wasserspeier | neue Szene `wasserspeier.tscn` mit `wasserspeier.gd`, benutzt die Blase der Krabbe |
| Klingenfalle | neue Szene `klingenfalle.tscn` mit `klingenfalle.gd` |

Ich habe mir die fast leeren Räume angesehen. Hier sind meine Vorschläge. Die Zahlen sind die Räume, wie `raum_von()` sie nennt. Die linke obere Ecke eines Raums liegt bei `(x * 256, y * 176)`. Du entscheidest, was wohin kommt. Es ist dein Kerker.

| Raum | Jetzt | Idee |
|---|---|---|
| (1, -5) | ganz leer, Öffnungen rechts und unten | **Schieberätsel:** Ein Felsbrocken muss auf den Schalter, dann öffnet sich das Gitter rechts. Das bauen wir in 12.10 zusammen. |
| (3, -5) | ganz leer, Sackgasse links neben dem Bossraum | **Belohnungsraum:** zwei oder drei Wasserspeier oben in der Wand, und eine Truhe, die man sich unter Beschuss holen muss |
| (3, -4) | eine Tür, eine Truhe, eine Fledermaus | **Klingenfallen in allen vier Ecken**, wie im Original. Wer quer durch den Raum läuft, wird von zwei Seiten gejagt. |
| (4, -4), (4, -3) | Schild und Tür, dazu deine Schienen | Die Steingesichter, die schon in der Wand sind, werden **echte Wasserspeier** |
| (3, -2) | zwei Türen, eine Mimik, ein Schild | **Kampfraum:** Gitter gehen hinter dem Helden zu, bis alle Monster besiegt sind (Übung 1) |
| (-1, -2) | Geist, Mimik, Tür, Schild | **Dunkler Raum:** Man sieht nur, was um den Helden herum ist (Übung 4). Mit einem Geist darin wird das richtig unheimlich. 👻 |
| (2, -1) | nur die falsche Wand | **Felsbrocken-Irrgarten:** Mehrere Brocken versperren den Weg, und nur die richtige Reihenfolge führt durch |
| (3, -1), (4, -1) | je ein Schild | **Zwei Schalter für ein Gitter** (Übung 2), oder die **Ratten** aus Übung 3 |
| (2, 0), (3, 0) | eine Tür, eine Mimik | **Fallengang:** Klingenfallen oben und unten an der Wand, der Held muss in der Mitte durch |

Zehn Räume mit zehn verschiedenen Ideen wären zu viel auf einmal. Fang mit dem Schieberätsel an, dann siehst du, wie die Teile zusammenspielen.

### 12.3 Das Gitter

Das Gitter sieht aus wie ein kleiner Zaun und steht in einer Türöffnung. Geht es auf, versinken die Stäbe im Boden.

Neue Szene:

1. Wurzel **StaticBody2D**, Name `Gitter`. **Collision → Layer** `1` (Welt), **Mask** leer. Es soll nur im Weg stehen und selbst nichts bemerken.
2. Kind **Node2D**, Name `Bilder`, **Position** (0, 8). Das ist die Unterkante des Gitters. Darunter zwei **Sprite2D**, beide mit `tilemap_packed.png`, **Hframes** 12, **Vframes** 11:
   - `Links`: **Position** (-8, -8), **Frame** 76
   - `Rechts`: **Position** (8, -8), **Frame** 78
3. Kind **CollisionShape2D** (direkt unter `Gitter`, nicht unter `Bilder`) mit einem Rechteck 32 × 16.
4. Kind **AudioStreamPlayer**, Name `Ton`, mit `tuer_offen.wav`.
5. Speichern als `gitter.tscn`, Skript `gitter.gd`:

```gdscript
extends StaticBody2D

# Ein Gitter in einer Öffnung. Ein Schalter oder etwas anderes sagt ihm, wann es auf- und zugeht.

const ZEIT = 0.3   # so lange dauert Auf- oder Zugehen

@export var offen := false   # so steht es beim Start
@export var merken := true   # einmal offen, immer offen. Auch nach dem Laden.
@export var hinter_dem_helden := false   # steht offen, bis der Held im Raum ist. Dann geht es zu.

var tween: Tween


func _ready() -> void:
	if hinter_dem_helden:
		offen = true
		get_tree().get_first_node_in_group("held").angekommen.connect(held_angekommen)
	if merken and Spielstand.ist_erledigt(self):
		offen = true
	# Gleich richtig hinstellen, ohne Bewegung und ohne Ton
	$Bilder.scale.y = 0.0 if offen else 1.0
	$CollisionShape2D.disabled = offen


# Der Held ist nach einem Raumwechsel fertig hereingelaufen. In meinen Raum?
func held_angekommen() -> void:
	if %Camera2D.raum == %Camera2D.raum_von(global_position):
		schliessen()


func oeffnen() -> void:
	if merken:
		Spielstand.erledigen(self)
	stellen(true)


func schliessen() -> void:
	if merken and Spielstand.ist_erledigt(self):
		return   # Gemerkt ist gemerkt
	stellen(false)


# Auf- oder zugehen: Die Stäbe versinken im Boden oder kommen heraus
func stellen(auf: bool) -> void:
	if auf == offen:
		return
	offen = auf
	$CollisionShape2D.set_deferred("disabled", offen)
	$Ton.play()
	if tween:
		tween.kill()   # Ein Schalter kann schneller umschalten, als das Gitter fährt
	tween = create_tween()
	tween.tween_property($Bilder, "scale:y", 0.0 if offen else 1.0, ZEIT)
```

- **Warum `Bilder` als eigener Node?** So kann ein einziger Tween beide Hälften gleichzeitig schrumpfen lassen. Die CollisionShape steht bewusst daneben. Die soll nicht mitschrumpfen, sondern ganz aus sein.
- **`scale:y` auf 0:** Die Stäbe werden flacher und flacher, bis nichts mehr übrig ist. Mit dem Doppelpunkt sprichst du nur einen Teil einer Eigenschaft an. Das kennst du schon von `modulate:a`.
- **Warum `Bilder` auf (0, 8) und die Sprites auf -8?** Ein Node wächst und schrumpft immer um seinen eigenen Ursprung herum. Stünde `Bilder` in der Mitte, würden die Stäbe von oben und unten zur Mitte hin zusammenschrumpfen. So liegt der Ursprung an der Unterkante, die Stäbe schrumpfen nach unten und versinken im Boden. Die Sprites rücken um 8 nach oben, damit das Gitter trotzdem genau an seinem alten Platz steht. Das ist derselbe Trick wie beim atmenden Helden in Kapitel 2, nur mit einem Node statt mit **Offset**.
- **`hinter_dem_helden`:** Das Gitter steht offen, bis der Held hereingelaufen ist, und geht dann hinter ihm zu. Ohne diese Einstellung müsste ein Gitter, das den Raum versperren soll, von Anfang an geschlossen sein. Dann sieht man es schon beim Hereinkommen, und der Held läuft trotzdem hindurch. Seine 24 Pixel nach dem Raumwechsel sind ein Tween, und ein Tween setzt `position` einfach, ohne nach Wänden zu fragen. Damit das Gitter weiß, wann er fertig ist, sagt der Held es mit einem neuen Signal (siehe unten). Geht das Gitter zu, steht der Held schon ganz im Raum.
- **`merken`:** Ein Gitter mit `merken` schreibt sich wie eine Truhe in `erledigt` und ist nach dem Laden gleich offen. Ohne `merken` geht es wieder zu, wenn der Schalter losgelassen wird. Beides ist nützlich, darum ist es eine Einstellung im Inspector.
- **Senkrechte Öffnungen:** Das Gitter steht quer, passt also in eine Öffnung oben oder unten. Für links und rechts drehst du es im Inspector: **Rotation** 90° oder -90°. Das Bild dreht sich mit, die Kollisionsform auch. Die „Unterkante“ dreht sich aber ebenfalls: Bei 90° versinkt das Gitter nach links, bei -90° nach rechts. Probier aus, was dir besser gefällt.
- **Wohin genau?** In die Mitte der Öffnung. Eine Öffnung oben im Raum `(x, y)` hat ihre Mitte bei `(x * 256 + 128, y * 176 + 8)`. Eine Öffnung in der rechten Wand liegt bei `(x * 256 + 248, y * 176 + 80)`, eine in der linken bei `(x * 256 + 8, y * 176 + 80)`.

Und das neue Signal im Helden. In `held.gd` ganz oben unter `extends CharacterBody2D`:

```gdscript
signal angekommen   # nach einem Raumwechsel ganz im neuen Raum angekommen
```

In `_on_camera_2d_raumwechsel()` direkt nach `await tween.finished`:

```gdscript
	angekommen.emit()
```

### 12.4 Der Bodenschalter

Ein Schalter ist eine Platte im Boden. Er braucht kein Bild vom Kachelblatt. Wir malen ihn selbst, so wie die Blase.

Neue Szene:

1. Wurzel **Area2D**, Name `Schalter`. **Layer** leer, **Mask** `1` (Welt) und `2` (Held). Felsbrocken liegen auf Ebene 1, das kommt gleich.
2. **Ordering → Z Index** `-1`. Dann liegt die Platte auf dem Boden, und der Held läuft darüber statt darunter. Der Boden selbst hat -2, die Wände -1. Schau in deinem Dungeon nach, ob das bei dir auch so ist.
3. Kind **CollisionShape2D** mit einem Rechteck 8 × 8. Kleiner als die Platte: Der Held soll wirklich darauf stehen, nicht nur mit der Fußspitze an den Rand kommen.
4. Kind **AudioStreamPlayer**, Name `Klick`. Bis du ein eigenes Geräusch hast (Übung 5), nimm `schritt.wav` mit **Pitch Scale** 0,5. Das klingt tief und schwer.
5. Speichern als `schalter.tscn`, Skript `schalter.gd`:

```gdscript
extends Area2D

# Ein Bodenschalter. Unten, solange der Held oder etwas Schweres darauf steht.

signal gedrueckt
signal losgelassen

const GROESSE = 12.0
const RAND = Color(0.16, 0.12, 0.1)
const OBEN = Color(0.7, 0.62, 0.5)
const UNTEN = Color(0.45, 0.4, 0.32)
const KANTE = Color(0.35, 0.3, 0.24)

var unten := false


func _physics_process(_delta: float) -> void:
	var belastet := get_overlapping_bodies().any(func(ding: Node2D) -> bool: return ding.is_in_group("held") or ding.is_in_group("schwer"))
	if belastet == unten:
		return
	unten = belastet
	queue_redraw()
	if unten:
		$Klick.play()
		gedrueckt.emit()
	else:
		losgelassen.emit()


# Eine Platte im Boden. Oben hat sie unten eine dunkle Kante, gedrückt ist sie flach und dunkler.
func _draw() -> void:
	var platte := Rect2(-GROESSE / 2, -GROESSE / 2, GROESSE, GROESSE)
	draw_rect(platte, RAND)
	if unten:
		draw_rect(platte.grow(-1), UNTEN)
	else:
		draw_rect(platte.grow(-1), OBEN)
		draw_rect(Rect2(platte.position.x + 1, platte.end.y - 3, GROESSE - 2, 2), KANTE)
```

- **Zwei Signale, kein Ziel:** Der Schalter weiß nicht, was er schaltet. Er sagt nur „gedrückt“ und „losgelassen“. Wer zuhört, entscheidet, was passiert. Darum kann derselbe Schalter ein Gitter öffnen, eine Truhe erscheinen lassen oder Musik spielen.
- **`any()`** kennst du als Geschwister von `all()` aus der Belohnungstruhe: Ist **irgendeins** der Dinge auf mir der Held oder schwer?
- **Warum nicht `body_entered`?** Das kommt einmal beim Betreten. Stehen zwei Dinge auf der Platte und eins geht, kommt `body_exited`, obwohl die Platte noch belastet ist. Jedes Bild nachzuzählen ist einfacher und kann sich nicht verzählen. Die Dornen machen es genauso.
- **`platte.grow(-1)`:** ein Rechteck, das auf jeder Seite einen Pixel kleiner ist. So bleibt außen ein Rand stehen.
- **`platte.end`:** die rechte untere Ecke. Die dunkle Kante unten lässt die Platte etwas hervorstehen. Gedrückt fehlt sie, dann ist die Platte flach.
- **Wohin genau?** Auf die Mitte einer Bodenkachel: `(x * 256 + kx * 16 + 8, y * 176 + ky * 16 + 8)`. Dabei ist `kx` die Kachel von links (1 bis 14) und `ky` die Kachel von oben (1 bis 9).

### 12.5 Schalter und Gitter verbinden

Jetzt kommt etwas, das du noch nicht gemacht hast: zwei Dinge **im Dungeon** mit einem Signal verbinden. Bisher hast du Signale immer innerhalb einer Szene verbunden, zum Beispiel die Hurtbox mit ihrem Monster.

1. Zieh `gitter.tscn` und `schalter.tscn` in den Dungeon.
2. Klick im Dungeon auf den **Schalter**, dann rechts auf den Reiter **Node** (neben Inspector) → **Signals**.
3. Doppelklick auf `gedrueckt()`. Im Fenster das **Gitter** auswählen. Bei **Receiver Method** `oeffnen` eintragen → **Connect**.
4. Dasselbe für `losgelassen()` mit `schliessen`.

Fertig. Im Szenenbaum hat der Schalter jetzt ein kleines Signal-Symbol. Godot hat sich in `dungeon.tscn` gemerkt: „Wenn dieser Schalter `gedrueckt` sagt, ruf bei diesem Gitter `oeffnen()` auf.“ Kein Code, kein `get_node`, kein `%`.

- **Und wenn es die Funktion gar nicht gibt?** Dann legt Godot sie beim Verbinden an. Das ist praktisch bei `_on_..._entered`, hier aber ein Zeichen für einen Tippfehler. Steht nach dem Verbinden eine neue leere Funktion im Gitter, hast du dich vertippt.
- **Mehrere Zuhörer:** Ein Signal darf mit beliebig vielen Dingen verbunden sein. Ein Schalter kann also zwei Gitter gleichzeitig öffnen.

### 12.6 Der Felsbrocken

Neue Szene:

1. Wurzel **CharacterBody2D**, Name `Felsbrocken`, in die Gruppe `schwer`. **Motion Mode** auf **Floating**.
2. **Collision → Layer** `1` (Welt): Für alle anderen ist er ein Stück Wand. **Mask** `1` (Welt), `3` (Gegner) und `5` (Gegnersperre). Er darf weder in eine Wand noch in ein Monster rutschen, und auch nicht aus dem Raum hinaus.
3. Kind **Sprite2D**, Name `Bild`: `tilemap_packed.png`, **Hframes** 12, **Vframes** 11, **Frame** 56.
4. Kind **CollisionShape2D** mit einem Rechteck 14 × 14. Nicht 16 × 16! Warum, steht unten.
5. Kind **AudioStreamPlayer**, Name `Schieben`, vorerst mit `ruetteln.wav` und **Pitch Scale** 0,6.
6. Speichern als `felsbrocken.tscn`, Skript `felsbrocken.gd`:

```gdscript
extends CharacterBody2D

# Ein Felsbrocken, den der Held schieben kann. Immer genau eine Kachel weit.

const KACHEL = 16
const SCHUB_ZEIT = 0.4     # so lange muss der Held drücken, bis der Brocken nachgibt
const RUTSCH_ZEIT = 0.3    # so lange rutscht er eine Kachel weit

var schub_zeit := 0.0
var schub_richtung := Vector2.ZERO
var letzter_schub := 0     # in welchem Physik-Bild der Held zuletzt gedrückt hat
var rutscht := false

@onready var start_position := global_position


func _ready() -> void:
	%Camera2D.raumwechsel.connect(raum_gewechselt)


# Der Held läuft dagegen. Das kommt jedes Bild, solange er drückt.
func schieben(richtung: Vector2, delta: float) -> void:
	if rutscht:
		return
	var bild := Engine.get_physics_frames()
	# Andere Richtung oder eine Pause dazwischen? Dann fängt das Drücken von vorn an.
	if richtung != schub_richtung or bild - letzter_schub > 1:
		schub_zeit = 0.0
	schub_richtung = richtung
	letzter_schub = bild
	schub_zeit += delta
	# test_move: Würde ich auf dem Weg irgendwo anstoßen?
	if schub_zeit >= SCHUB_ZEIT and not test_move(global_transform, richtung * KACHEL):
		rutschen(richtung)


func rutschen(richtung: Vector2) -> void:
	rutscht = true
	schub_zeit = 0.0
	$Schieben.play()
	var tween := create_tween()
	tween.tween_property(self, "global_position", global_position + richtung * KACHEL, RUTSCH_ZEIT)
	await tween.finished
	rutscht = false


# Hat der Held meinen Raum verlassen? Dann zurück an den Anfang, damit sich niemand festschieben kann.
func raum_gewechselt(_richtung: Vector2i) -> void:
	if %Camera2D.raum != %Camera2D.raum_von(start_position):
		global_position = start_position
```

- **Erst drücken, dann rutschen:** Ohne `SCHUB_ZEIT` würde jeder Brocken sofort wegrutschen, sobald man ihn streift. Wer nur vorbeiläuft und an einer Ecke hängen bleibt, hätte das Rätsel kaputt gemacht. Im Original muss man sich auch kurz dagegenstemmen.
- **`Engine.get_physics_frames()`:** zählt die Physik-Bilder seit dem Start, 60 pro Sekunde. Der Brocken merkt sich, in welchem Bild zuletzt gedrückt wurde. Ist das mehr als ein Bild her, hat der Held zwischendurch losgelassen, und die Zeit fängt von vorn an. So braucht der Brocken kein eigenes `_physics_process`, um das Loslassen zu bemerken.
- **`test_move(global_transform, richtung * KACHEL)`:** Godot probiert die Bewegung nur aus, ohne den Brocken wirklich zu bewegen. Die Antwort ist `true`, wenn er dabei irgendwo anstoßen würde. Dann bleibt er stehen.
- **Darum 14 × 14:** Ein Brocken mit 16 × 16 würde nach einer Kachel genau an der Wand anliegen. Godot rechnet mit einem winzigen Sicherheitsabstand, und „genau anliegen“ zählt dann schon als Anstoßen. Mit einem Pixel Luft auf jeder Seite klappt es. Sichtbar ist das nicht, das Bild bleibt 16 × 16.
- **Warum ein Tween und kein `move_and_slide()`?** Der Brocken soll genau 16 Pixel weit rutschen, nicht 15,7. Der Tween landet genau da. Ob der Weg frei ist, hat `test_move` vorher schon geprüft.
- **Zurück an den Anfang:** Ein Brocken in einer Ecke ist für immer verloren, und das Rätsel ist nicht mehr lösbar. Darum springt er zurück, sobald der Held den Raum verlässt. Das kennst du vom Original. Und weil der Held den Raum gerade nicht sieht, merkt niemand das Springen.

### 12.7 Der Held schiebt

In `held.gd`, in `laufen()` direkt nach `ecke_umrunden(richtung, delta)`:

```gdscript
	# Gegen etwas gelaufen, das man schieben kann? Dann drücken.
	if richtung != Vector2.ZERO:
		for i in get_slide_collision_count():
			var ding := get_slide_collision(i).get_collider()
			if ding.has_method("schieben"):
				ding.schieben(richtung, delta)
```

- **`get_slide_collision(i).get_collider()`:** Bei jedem `move_and_slide()` merkt sich Godot, wogegen der Held gestoßen ist. Damit kommst du an das Ding selbst heran.
- **`has_method("schieben")`:** dieselbe Idee wie bei `benutzen()`. Der Held muss nicht wissen, was ein Felsbrocken ist. Alles, was `schieben()` kann, lässt sich schieben. Eine schiebbare Kiste später braucht hier also keine neue Zeile.
- **`richtung` statt `velocity`:** Steht der Held still, rutscht er vielleicht noch einen Hauch gegen den Brocken. Das soll nicht zählen. Gedrückt wird nur, solange eine Taste gedrückt ist.

### 12.8 Der Wasserspeier

Du hast schon Steingesichter in die Wände gemalt. Jetzt erwachen sie zum Leben. Frame 19 ist das Gesicht mit geschlossenem Mund, Frame 20 das gleiche mit grünem Sabber. Das passt perfekt zum Spucken.

Neue Szene:

1. Wurzel **Node2D**, Name `Wasserspeier`. Keine Kollision: Er sitzt in der Wand, und die Wand hat schon eine.
2. Kind **Sprite2D**, Name `Bild`: `tilemap_packed.png`, **Hframes** 12, **Vframes** 11, **Frame** 19.
3. Speichern als `wasserspeier.tscn`, Skript `wasserspeier.gd`:

```gdscript
extends Node2D

# Ein steinernes Gesicht in der Wand. Spuckt Blasen nach dem Helden, solange er in seinem Raum ist.

const BLASE = preload("res://blase.tscn")
const BILD_RUHE = 19
const BILD_SPUCKEN = 20
const ABSTAND = 14   # so weit vor dem Gesicht entsteht die Blase, damit sie nicht gleich in der Wand platzt

@export var blick := Vector2.DOWN   # dahin schaut das Gesicht aus der Wand heraus
@export var pause := 2.0            # so viele Sekunden zwischen zwei Blasen
@export var versatz := 0.0          # zusätzliche Wartezeit am Anfang, damit nicht alle gleichzeitig spucken

@onready var zeit := pause + versatz   # bis zur nächsten Blase
@onready var held: Node2D = get_tree().get_first_node_in_group("held")


func _physics_process(delta: float) -> void:
	if %Camera2D.raum != %Camera2D.raum_von(global_position):
		zeit = pause + versatz   # Kommt der Held herein, hat er erst einmal etwas Zeit
		return
	zeit -= delta
	if zeit <= 0:
		zeit = pause
		spucken()


func spucken() -> void:
	$Bild.frame = BILD_SPUCKEN
	var blase := BLASE.instantiate()
	blase.position = position + blick * ABSTAND
	blase.richtung = blase.position.direction_to(held.global_position)
	get_parent().add_child(blase)
	await get_tree().create_timer(0.3, false).timeout
	$Bild.frame = BILD_RUHE
```

- **Die Blase der Krabbe, noch einmal:** Sie fliegt geradeaus, platzt an Wänden, am Schwert und am Helden. Der Wasserspeier muss nur sagen, wo sie anfängt und wohin sie fliegt. So zahlt sich eine eigene Szene für die Blase aus.
- **`@onready var zeit := pause + versatz`:** Eine normale Variable oben im Skript bekommt ihren Wert, **bevor** Godot die Zahlen aus dem Inspector einträgt. Sie würde also immer mit 2 rechnen, auch wenn du im Inspector 3 einstellst. Mit `@onready` kommt die Rechnung erst in `_ready()`, und dann stehen die Inspector-Werte schon fest. Dasselbe Problem hatte `start_leben` im Glibber, weißt du noch?
- **`create_timer(0.3, false)`:** Das zweite `false` heißt: Der Timer läuft während einer Pause nicht weiter. Geht gerade ein Schild auf, sabbert der Wasserspeier eben etwas länger.
- **Wohin genau?** Genau auf eine Wandkachel, zum Beispiel auf eins deiner gemalten Steingesichter. In der oberen Wand: `(x * 256 + kx * 16 + 8, y * 176 + 8)` mit **Blick** (0, 1). In der linken Wand ist der Blick (1, 0), in der rechten (-1, 0).
- **Mehrere Wasserspeier in einem Raum:** Gib ihnen verschiedene **Versatz**-Werte, zum Beispiel 0, 0,7 und 1,4. Dann spucken sie nacheinander statt im Chor.

### 12.9 Die Klingenfalle

Die Klingenfalle wartet an ihrem Platz. Steht der Held mit ihr in einer Reihe oder Spalte, saust sie los, prallt an die Wand und kriecht langsam zurück. Man kann sie nicht besiegen, nur austricksen.

Neue Szene:

1. Wurzel **CharacterBody2D**, Name `Klingenfalle`. **Motion Mode** auf **Floating**.
2. **Collision → Layer** `3` (Gegner), **Mask** `1` (Welt) und `5` (Gegnersperre).
3. Kind **CollisionShape2D** mit einem Rechteck 12 × 12.
4. Speichern als `klingenfalle.tscn`, Skript `klingenfalle.gd`:

```gdscript
extends CharacterBody2D

# Eine Klingenfalle: wartet an ihrem Platz. Steht der Held mit ihr in einer Reihe oder Spalte, saust sie los.
# Sie liegt auf der Ebene Gegner. Darum merkt die Hurtbox des Helden sie ganz von selbst.

enum Zustand { WARTEN, ANGRIFF, ZURUECK }

const ANGRIFF_TEMPO = 160.0
const ZURUECK_TEMPO = 40.0
const BREITE = 7.0      # so nah muss der Held an ihrer Reihe oder Spalte sein
const STAHL = Color(0.78, 0.78, 0.84)
const RAND = Color(0.16, 0.12, 0.16)

@export var schaden := 2   # in halben Herzen

var zustand := Zustand.WARTEN
var richtung := Vector2.ZERO
var drehung := 0.0   # so weit ist der Stern gerade gedreht

@onready var start_position := global_position
@onready var held: Node2D = get_tree().get_first_node_in_group("held")


func _physics_process(delta: float) -> void:
	match zustand:
		Zustand.WARTEN:
			velocity = Vector2.ZERO
			if %Camera2D.raum == %Camera2D.raum_von(start_position):
				zielen()
		Zustand.ANGRIFF:
			velocity = richtung * ANGRIFF_TEMPO
			drehen(20 * delta)
			if get_slide_collision_count() > 0:   # angestoßen: zurück an den Platz
				zustand = Zustand.ZURUECK
		Zustand.ZURUECK:
			velocity = global_position.direction_to(start_position) * ZURUECK_TEMPO
			drehen(5 * delta)
			if global_position.distance_to(start_position) < 1:
				global_position = start_position
				zustand = Zustand.WARTEN
	move_and_slide()


# Steht der Held mit mir in einer Reihe oder Spalte? Dann los, auf ihn zu.
func zielen() -> void:
	var abstand := held.global_position - global_position
	if abs(abstand.y) < BREITE:
		richtung = Vector2(sign(abstand.x), 0)
	elif abs(abstand.x) < BREITE:
		richtung = Vector2(0, sign(abstand.y))
	else:
		return
	zustand = Zustand.ANGRIFF


func drehen(winkel: float) -> void:
	drehung += winkel
	queue_redraw()


# Ein Stern aus Stahl mit acht Zacken. draw_set_transform dreht alles, was danach gemalt wird.
func _draw() -> void:
	draw_set_transform(Vector2.ZERO, drehung)
	var zacken := PackedVector2Array()
	for i in 16:
		var laenge := 7.0 if i % 2 == 0 else 3.0   # abwechselnd Spitze und Kerbe
		zacken.append(Vector2.from_angle(i * TAU / 16) * laenge)
	draw_colored_polygon(zacken, STAHL)
	zacken.append(zacken[0])   # damit der Rand ringsherum geschlossen ist
	draw_polyline(zacken, RAND)
	draw_circle(Vector2.ZERO, 1.5, RAND)
```

- **Kein Monster, trotzdem gefährlich:** Die Falle ist nicht in der Gruppe `monster`. Die Kamera weckt sie also nicht, und eine Belohnungstruhe wartet nicht auf sie. Das ist richtig so, denn besiegen kann man sie ja nicht. Trotzdem tut sie weh: Die Hurtbox des Helden schaut auf Ebene 3 und findet dort die Falle. `getroffen()` fragt nur nach `schaden` und `global_position`, und beides hat sie.
- **Eine State Machine mit drei Zuständen**, wie in Kapitel 4. WARTEN schaut, ANGRIFF rast, ZURUECK kriecht.
- **`sign()`** macht aus jeder Zahl -1, 0 oder 1. Aus dem Abstand zum Helden wird so eine Richtung: links oder rechts, oben oder unten.
- **Ein Stern als Vieleck:** 16 Punkte im Kreis, abwechselnd weit draußen (7 Pixel, die Spitzen) und weiter innen (3 Pixel, die Kerben). `Vector2.from_angle(w)` ist ein Pfeil der Länge 1 in Richtung `w`. `draw_colored_polygon()` füllt die Form aus, `draw_polyline()` malt den Rand.
- **`draw_set_transform(Vector2.ZERO, drehung)`:** „Alles, was ich ab jetzt male, ist um `drehung` gedreht.“ So dreht sich nur das Bild. Die Kollisionsform bleibt, wie sie ist. Sie ist ja ein Quadrat, und ein Quadrat, das sich dreht, würde beim Anstoßen merkwürdig hängen bleiben.
- **Wohin?** In eine Ecke oder an eine Wand, dort wo sie ein Stück freie Bahn hat. Zwei Fallen, die aufeinander zurasen, stoßen übrigens nicht zusammen: Sie haben Ebene 3 nicht in der Mask und fliegen durcheinander hindurch. Das ist Absicht, sonst würden sie sich gegenseitig blockieren.

### 12.10 Ein Rätselraum

Jetzt alles zusammen, im leeren Raum (1, -5). Er hat Öffnungen rechts und unten.

1. **Gitter:** Zieh `gitter.tscn` in die rechte Öffnung, auf (504, -800), **Rotation** 90°.
2. **Schalter:** auf (344, -824).
3. **Felsbrocken:** zwei Kacheln darunter, auf (344, -792).
4. Schalter und Gitter verbinden wie in 12.5: `gedrueckt` → `oeffnen`, `losgelassen` → `schliessen`.

Der Held kommt von unten herein, stellt sich unter den Brocken und drückt zweimal nach oben. Der Brocken rutscht auf den Schalter, es klickt, das Gitter versinkt. Weil `merken` an ist, bleibt es offen, auch wenn der Brocken später weitergeschoben wird.

**Probier es auch einmal ohne Brocken:** Stell dich selbst auf den Schalter. Das Gitter geht auf. Steigst du herunter, geht es wieder zu. Dann musst du dich entscheiden: Soll `merken` aus sein, damit das Rätsel nur mit dem Brocken klappt? Oder ist es dir egal, wie der Spieler es löst? Beides ist in Ordnung. Im Original gibt es beides.

### 12.11 Ausprobieren

- [ ] Gegen den Felsbrocken laufen: Er bewegt sich erst nach einem kurzen Moment, dann genau eine Kachel weit.
- [ ] Kurz drücken, loslassen, wieder kurz drücken: Er bewegt sich nicht. Das Drücken fängt jedes Mal von vorn an.
- [ ] Den Brocken gegen die Wand schieben: Er bleibt davor stehen und rutscht nicht hinein.
- [ ] Brocken auf den Schalter: Klick, das Gitter versinkt, du kommst durch.
- [ ] Selbst auf den Schalter stellen: Das Gitter geht auf. Mit `merken` aus geht es beim Heruntersteigen wieder zu.
- [ ] Den Brocken in eine Ecke schieben, Raum verlassen, zurückkommen: Der Brocken steht wieder am Anfang.
- [ ] Gitter mit `merken` öffnen, sterben oder neu laden: Das Gitter ist sofort offen, ohne Geräusch.
- [ ] Wasserspeier: Im Raum spuckt er alle zwei Sekunden eine Blase nach dir. Die Blase platzt am Schwert, an der Wand und am Felsbrocken. In einem anderen Raum ist Ruhe.
- [ ] Klingenfalle: In ihre Reihe treten. Sie saust los, dreht sich schnell, trifft dich, prallt an die Wand und kriecht langsam zurück.
- [ ] Das Schwert tut der Klingenfalle nichts. Sie lässt sich nicht besiegen.
- [ ] Die Krabbe: Jeder Treffer macht den Balken kürzer. Wütend blinkt sie bei jedem Treffer rot.

### 12.12 Was beim Bauen schiefging

- **Der Wasserspeier spuckt sofort:** Zuerst stand oben `var zeit := 0.0`. Beim Betreten des Raums war die Zeit also schon abgelaufen, und die erste Blase flog, bevor der Held sich umsehen konnte. Jetzt beginnt `zeit` mit `pause + versatz`, und dafür braucht es `@onready` (12.8).
- **Eine Zahl, die sich nicht ändern will:** Zum Testen wollte ich die Blasen zählen und habe dem Dungeon eine kleine Funktion mitgegeben: `func(n): blasen += 1`. Der Zähler blieb bei 0, obwohl der Held getroffen wurde. Eine solche Funktion ohne Namen (ein **Lambda**) bekommt eine **Kopie** einfacher Werte wie Zahlen. Sie zählt ihre Kopie hoch, nicht das Original. Mit einem Array oder Dictionary klappt es, weil dann beide dasselbe Ding in der Hand haben. Das ist dieselbe Idee wie bei `assign` und den Dictionaries im Spielstand.
- **Der Held vor dem Brocken:** Steht der Held direkt unter dem Brocken, verdeckt sein Kopf den Brocken halb. Das ist richtig so. Wer weiter unten steht, ist näher an der Kamera und wird zuletzt gemalt. So sieht es auch bei den Säulen aus.

### Übungsaufgaben zu Kapitel 12

1. **Kampfraum (mittel):** Das Gitter kann mehr als nur Schalter. Gib ihm `@export var kampf := false`. Ein Kampfgitter steht beim Start offen, geht zu, sobald der Held seinen Raum betritt und dort noch Monster leben, und geht auf, wenn alle besiegt sind. Kommt dir das bekannt vor? Deine `Bosssperre` macht genau das. Bau das Gitter so, dass du die Bosssperre durch ein Kampfgitter ersetzen kannst. Denkfragen: Wann genau darf das Gitter zugehen? Was ist, wenn der Held noch mitten in der Öffnung steht? (Tipp: `hinter_dem_helden` aus 12.3 macht schon die Hälfte davon.)
2. **Zwei Schalter (mittel):** Ein Gitter, das erst aufgeht, wenn **beide** Schalter gedrückt sind. Beide Schalter sind mit `oeffnen` und `schliessen` verbunden. Das Gitter zählt mit: `@export var schalter_noetig := 1` und eine Variable, die bei `oeffnen()` eins hoch und bei `schliessen()` eins runter zählt. Erst wenn sie `schalter_noetig` erreicht, geht es wirklich auf. Ein Rätsel dazu: zwei Schalter, ein Felsbrocken. Wie kommt man durch? (Der Held kann ja auch auf einem stehen.)
3. **Die Ratte (mittel):** Frame 123 ist eine Ratte. Bau sie als neues Monster mit `extends Monster`. Sie läuft schnell an der Wand entlang und dreht an jeder Ecke ab, immer nach rechts. Den Helden beachtet sie nicht, aber wer ihr im Weg steht, wird gebissen. Tipp: `is_on_wall()` und `get_wall_normal()` hast du bei der Krabbe kennengelernt. Wenn die Wand vor ihr ist, dreht sie sich um 90°: `richtung = richtung.rotated(PI / 2)`. 🐀
4. **Dunkler Raum (knifflig):** In einem Raum ist es stockdunkel. Man sieht nur einen hellen Kreis um den Helden. Dafür gibt es zwei Nodes:
    - Ein **CanvasModulate** im Dungeon färbt alles dunkel, zum Beispiel mit der Farbe (0.05, 0.05, 0.1). Die Anzeige oben bleibt hell, weil sie auf einer eigenen **CanvasLayer** liegt.
    - Ein **PointLight2D** am Helden macht es um ihn herum wieder hell. Als **Texture** nimmst du eine **New GradientTexture2D**, stellst **Fill** auf **Radial**, **Fill From** auf (0.5, 0.5) und **Fill To** auf (1, 0.5). Im **Gradient** darunter tauschst du die beiden Farben, sodass er links weiß und rechts schwarz ist. Dann leuchtet die Mitte, und nach außen wird es dunkel.

    Das CanvasModulate darf nur in diesem einen Raum an sein. Wer schaltet es ein und aus? (Tipp: `raumwechsel` und `visible`.) Bonus: Fackeln an der Wand, die ihr eigenes kleines Licht haben.
5. **Kratz und Klick (leicht):** Mach mit 🆓 jsfxr ein schweres Schaben für den Felsbrocken und ein dumpfes Klacken für den Schalter. Und für den Wasserspeier ein feuchtes „Ptoo“. Wo muss der `AudioStreamPlayer` für das Spucken hin, damit er nicht abbricht? (Er muss den Wasserspeier nicht überleben, der bleibt ja da. Aber was ist mit einer Blase, die beim Platzen ein Geräusch macht?) 💦
6. **Nur einmal (leicht):** Im Original lassen sich viele Blöcke nur ein einziges Mal schieben, danach sitzen sie fest. Gib dem Felsbrocken `@export var nur_einmal := false`. Wo musst du ihn festhalten, und wo wieder lösen?

Fertig? Committen und Bescheid geben. Dann kommt Kapitel 13: Optionen und eine zweite Sprache.


---

## Kapitel 13: Optionen und eine zweite Sprache

Der Kerker ist voll. Jetzt bekommt das Spiel zwei Dinge, die jedes richtige Spiel hat: einen **Optionen-Bildschirm** und eine **zweite Sprache**. Für deinen DOOM-Klon wirst du beides wieder brauchen, und in Godot ist es erstaunlich bequem.

Die Optionen bekommen zwei Einstellungen:
- **Sprache:** Deutsch oder English.
- **Schräg laufen:** wie im Original nur in vier Richtungen, oder in acht.

Dazu kommt deine Beobachtung mit den doppelten Schritten beim Raumwechsel.

Neu sind **`tr()`**, der **TranslationServer**, eine Übersetzungstabelle als **CSV-Datei** und ein **zweiter Autoload** für Einstellungen, die zu keinem Spielstand gehören.

### 13.1 Was kommt wohin?

| Was | Wo |
|---|---|
| Schritte beim Hereinlaufen | `held.gd` |
| Alle Texte auf Deutsch und Englisch | `texte.csv` (liegt schon im Projekt), Projekteinstellungen |
| Übersetzen | `dialog.gd`, `titel.gd`, `abschluss.gd`, `angebot.gd`, `grabstein.gd`, `held.gd` |
| Einstellungen merken | neuer Autoload `optionen.gd` |
| Optionen-Bildschirm | neue Szene `optionen.tscn` mit `optionen_menue.gd`, ein Eintrag im Titelbild |
| Schräg laufen | `held.gd` |
| Prüfen, ob alles übersetzt ist | `texte.py` (liegt schon im Projekt) |

### 13.2 Der Held läuft herein

Beim Raumwechsel läuft der Held mit einem Tween 24 Pixel weiter, und der Tween ruft zweimal `schritt()` auf. Gleichzeitig läuft aber auch `_physics_process()` weiter. Hältst du eine Richtung gedrückt, spielt `laufen()` die Animation `laufen`, und die hat ihre eigenen zwei Schritte. Macht vier Schritte für zwei Füße.

Nimmst du die Schritte aus dem Tween heraus, läuft der Held ohne gedrückte Taste lautlos herein. Das Problem ist also nicht der Tween, sondern dass **zwei Dinge gleichzeitig** den Helden steuern: der Tween und die Tasten.

Die Lösung kennst du aus Kapitel 4: ein eigener Zustand. Solange der Held hereinläuft, ist er im Zustand `HEREIN`. Dann haben die Tasten Pause, der Tween bewegt ihn, und die Animation `laufen` macht die Schritte, genau wie beim normalen Laufen. Egal, ob eine Taste gedrückt ist oder nicht.

In `held.gd`:

```gdscript
enum Zustand { LAUFEN, ANGRIFF, GETROFFEN, HEREIN }
```

Im `match` in `_physics_process()` ein vierter Fall:

```gdscript
		Zustand.HEREIN:
			pass   # Der Tween aus dem Raumwechsel bewegt ihn. Die Tasten haben so lange Pause.
```

Und in `_on_camera_2d_raumwechsel()` wird der Tween kürzer. Die alten sechs Tween-Zeilen bis einschließlich `await tween.finished` ersetzt du durch:

```gdscript
	# Hereinlaufen: Der Tween bewegt, die Animation macht die Schritte, die Tasten haben Pause
	zustand = Zustand.HEREIN
	$AnimationPlayer.play("laufen")
	var tween := create_tween()
	tween.tween_property(self, "position", position + 24 * Vector2(wechselrichtung), 0.4)
	await tween.finished
	zustand = Zustand.LAUFEN
```

- **Ein Tween statt drei:** Die drei Abschnitte (6, 18 und 24 Pixel) waren nur nötig, um dazwischen die Schritte einzuhängen. Das macht jetzt die Animation. 0,4 Sekunden sind genau ein Durchlauf von `laufen`, also genau zwei Schritte.
- **`pass`:** „Hier passiert nichts.“ GDScript verlangt in jedem Fall mindestens eine Zeile, und `pass` ist die Zeile, die nichts tut.
- **Getroffen werden kann er trotzdem:** `treffer_pruefen()` steht unter dem `match` und läuft in jedem Zustand. Wer beim Hereinlaufen in eine Klingenfalle tappt, hat Pech.

Ich habe es ausprobiert: Mit und ohne gedrückte Taste sind es jetzt genau zwei Schritte.

### 13.3 Wie Godot übersetzt

Die Idee ist einfach. Es gibt eine Tabelle: links der deutsche Text, rechts daneben derselbe Text auf Englisch. Will das Spiel etwas anzeigen, fragt es: „Was steht in der Tabelle neben diesem Text, in der Sprache, die gerade eingestellt ist?“

Die Tabelle ist eine **CSV-Datei**. Das ist eine Textdatei, in der die Spalten durch Kommas getrennt sind. Du kannst sie mit jedem Texteditor öffnen, oder mit 🆓 LibreOffice Calc als richtige Tabelle. So fängt `texte.csv` an:

```
keys,de,en
KARTE,KARTE,MAP
INVENTAR,INVENTAR,INVENTORY
Weiter,Weiter,Continue
"Da weitermachen, wo du zuletzt einen Raum betreten hast.","Da weitermachen, wo du zuletzt einen Raum betreten hast.",Continue where you last entered a room.
```

- **Die erste Zeile** sagt Godot, welche Spalte was ist: `keys` sind die Schlüssel, danach kommt eine Spalte pro Sprache.
- **Der Schlüssel ist der deutsche Text selbst.** Das hat einen großen Vorteil: Im Code und im Inspector steht weiter normales Deutsch. Ein Schild mit „Willkommen im Kerker!“ bleibt ein Schild mit „Willkommen im Kerker!“. Und fehlt ein Text in der Tabelle, zeigt Godot einfach den Schlüssel, also Deutsch. Nichts geht kaputt, es ist nur noch nicht übersetzt.
- **Der Nachteil:** Änderst du einen deutschen Text, passt er nicht mehr zu seinem Schlüssel. Dafür gibt es `texte.py` (13.12).
- **Anführungszeichen:** Hat ein Text ein Komma, steht er in `"..."`, sonst hielte Godot das Komma für eine neue Spalte. Ein Anführungszeichen im Text wird zu zwei: `""`.

Und so kommt der Text ins Spiel:

- **Labels übersetzen sich selbst.** Steht in einem Label „KARTE“, und „KARTE“ ist ein Schlüssel, zeigt das Label auf Englisch „MAP“. Dafür musst du nichts tun. Das gilt für alle Controls, auch für Text, den der Code hineinschreibt.
- **Im Code gibt es `tr()`.** `tr("Willkommen im Kerker!")` liefert den Text in der eingestellten Sprache. Steht er nicht in der Tabelle, kommt er unverändert zurück.
- **Die Sprache stellt der TranslationServer ein:** `TranslationServer.set_locale("en")`. Ein Autoload, den Godot schon mitbringt. „Locale“ heißt so viel wie Sprache und Gegend: `de` ist Deutsch, `en` Englisch.

### 13.4 Die Tabelle einbinden

`texte.csv` liegt schon in deinem Projektordner. Ich habe alle Texte des Spiels gesammelt und übersetzt, 111 Stück, auch die für dieses Kapitel. Godot hat sie beim Öffnen des Projekts schon importiert. Daneben liegen jetzt `texte.de.translation` und `texte.en.translation`. Das sind die Übersetzungen, so wie Godot sie zum Spielen braucht.

1. **Project → Project Settings → Localization → Translations.**
2. **Add…** → `texte.de.translation` und `texte.en.translation` auswählen.

Das ist alles. Ab jetzt kennt das Spiel beide Sprachen.

**Zum Ausprobieren**, bevor es die Optionen gibt: Unter **Localization → Locale → Test** (vielleicht musst du oben rechts **Advanced Settings** einschalten) `en` eintragen und F5. Oben in der Anzeige steht jetzt MAP, INVENTORY und LIFE. Danach das Feld wieder leeren!

### 13.5 Sieben Tippfehler

Beim Übersetzen habe ich sieben Schildtexte gefunden, die nicht ganz stimmen. In `texte.csv` stehen sie schon richtig. Damit sie zum Schlüssel passen, korrigierst du sie im Inspector an den Schildern:

| Steht da | Richtig |
|---|---|
| … auf Steine **schägst**... | … auf Steine **schlägst**... |
| **Ein** bildliche Einleitung für Beginner. | **Eine** bildliche Einleitung für Beginner. |
| 1) **Drehe mit dem Rücken zu dem Geist** und bück dich ein wenig. | 1) **Dreh dich mit dem Rücken zum Geist** und bück dich ein wenig. |
| … jetzt bist **di** hinter ihm. | … jetzt bist **du** hinter ihm. |
| Aber sie sehen **genau so** aus... | Aber sie sehen **genauso** aus... |
| Das ist ein **magisches** Raum. | Das ist ein **magischer** Raum. |
| Da ist ein Schalter in der Mitte des Raums | … in der Mitte des Raums**.** |

Welches Schild welches ist, sagt dir `texte.py` (13.12). Solange ein Text noch falsch ist, zeigt das Spiel ihn auf Englisch einfach auf Deutsch an.

### 13.6 Der Dialog übersetzt

Fast alle Texte im Spiel gehen durch eine einzige Stelle: `Dialog.zeigen()`. Schilder, der alte Mann, der Händler, der Lotosstein, die Pausenfrage. Wenn der Dialog selbst übersetzt, ist das meiste mit drei Zeilen erledigt.

In `dialog.gd`, in `zeigen()`, statt `seiten = neue_seiten.duplicate()`:

```gdscript
	# Jede Seite übersetzen. Steht sie nicht in texte.csv, bleibt sie, wie sie ist.
	seiten.assign(neue_seiten.map(func(seite: String) -> String: return tr(seite)))
```

Ein paar Zeilen darunter wird auch der Name übersetzt:

```gdscript
	%Sprechername.text = tr(sprecher) + ":"
```

Und in `_process()` das Ja und Nein, statt der Zeile mit `"> Ja     Nein"`:

```gdscript
	var ja := tr("Ja")
	var nein := tr("Nein")
	$Rahmen/Auswahl.text = "> %s     %s" % [ja, nein] if antwort else "   %s  > %s" % [ja, nein]
```

- **`map()`** macht aus einem Array ein neues, in dem jedes Element durch die kleine Funktion gelaufen ist. Aus `["Willkommen im Kerker!", "Bitte nicht die Monster füttern."]` wird `["Welcome to the dungeon!", "Please don't feed the monsters."]`.
- **Warum `assign` und nicht `=`?** `map()` gibt ein ganz normales Array zurück. `seiten` ist aber ein `Array[String]`, und ein normales Array darf man ihm nicht einfach zuweisen. `assign` kopiert den Inhalt hinüber und prüft dabei, dass es wirklich Texte sind.
- **Warum nicht selbst Labels übersetzen lassen?** Das Label würde übersetzen, ja. Aber die Schreibmaschine zählt Buchstaben (`visible_characters`), und das soll sie an dem Text tun, der wirklich zu sehen ist.

### 13.7 Platzhalter: erst übersetzen, dann füllen

Ein paar Texte haben eine Lücke, in die eine Zahl kommt: „Hier ruhen %d Helden.“ Füllst du die Lücke zuerst, steht da „Hier ruhen 7 Helden.“, und das steht nicht in der Tabelle. Also immer **erst `tr()`, dann `%`**:

```gdscript
tr("Hier ruhen %d Helden. Alle sahen aus wie du...") % 7    # richtig: "Here lie 7 heroes. ..."
tr("Hier ruhen %d Helden. Alle sahen aus wie du..." % 7)    # falsch: findet nichts
```

Der Dialog übersetzt danach zwar noch einmal, aber „Here lie 7 heroes.“ ist kein Schlüssel, also bleibt es, wie es ist.

**`grabstein.gd`:**

```gdscript
		Dialog.zeigen([tr(seite) % Spielstand.gestorben], "Grabstein")
```

**`angebot.gd`:** Hier sind es zwei Lücken, und eine davon ist selbst ein Text.

```gdscript
		var ja: bool = await Dialog.frage(tr("%s für %d Münzen?") % [tr(Gegenstand.NAMEN[ware]), preis], NPC_Name)
```

**`held.gd`, in `pause_menue()`:** Der Stand und die Frage sind zwei Texte, die erst nach dem Übersetzen zusammenkommen.

```gdscript
	var stand := tr("Erkundet: %d %%   Zeit: %s") % [Spielstand.erkundet(), Spielstand.formatiere_spielzeit()]
	if not await Dialog.frage(stand + "\n" + tr("Zurück zum Titelbildschirm?")):
```

**`abschluss.gd`:** Dasselbe, nur öfter. Jede Zeile einzeln übersetzen, die Zeilenumbrüche kommen außen dazu. In der Tabelle steht dann kein einziges `\n`, und das macht das Leben leichter.

```gdscript
		text += tr("Ultimative Herausforderung geschafft!") + "\n"
		...
			text += tr("Platz %d in der Bestenliste!") % platzierung + "\n"
		else:
			text += tr("Aber die anderen waren schneller als du...") + "\n"
		text += "\n" + tr("Die Liste der schnellsten Helden:") + "\n"
		...
	else:
		text += tr("Zeit: %s") % Spielstand.formatiere_spielzeit() + "\n"
		text += tr("Erkundet: %d %%") % Spielstand.erkundet() + "\n"
		text += tr("Gestorben: %d-mal") % Spielstand.gestorben
		if Spielstand.erkundet() < 100:
			text += "\n\n" + tr("Da fehlt noch was ...") + "\n" + tr("Mit \"Weiter\" suchst du es.")
```

- **`%` zuerst, dann `+`:** In `tr("Zeit: %s") % zeit + "\n"` rechnet GDScript erst `%` und dann `+`, wie Punkt vor Strich. Es kommt also das Richtige heraus.
- **Und die anderen Dialoge?** Der Lotosstein, die Sterbe-Sätze, die Krone, die Iron-Man-Frage: Die geben ihren deutschen Text ohne Lücke an den Dialog weiter, und der übersetzt. Da musst du nichts ändern.

### 13.8 Das Titelbild

Im Titelbild sind die Einträge („Weiter“, „Neues Spiel“, …) zugleich die Namen, mit denen `starten()` entscheidet, was passiert. Die sollen deutsch bleiben, nur die **Anzeige** wird übersetzt. Dazu kommt der neue Eintrag „Optionen“.

In `titel.gd` oben:

```gdscript
const OPTIONEN = "res://optionen.tscn"

# Was unter dem Menü steht, je nachdem, was gerade ausgewählt ist. Jede Zeile wird einzeln übersetzt.
const ERKLAERUNG = {
	"Weiter": ["Da weitermachen, wo du zuletzt einen Raum betreten hast.", "Spielzeit: %s   Fortschritt: %d%%"],
	"Neues Spiel": ["Wie im Original: Wer stirbt, steht am Eingang wieder auf. Monster auch."],
	"Iron Man": ["Tot ist tot. Für Monster und für dich.", "Kein Speichern, kein Weiter."],
	"Optionen": ["Sprache und wie der Held läuft."],
}
```

In `_ready()`:

```gdscript
	eintraege.append_array(["Neues Spiel", "Iron Man", "Optionen"])
```

`anzeigen()` wird kürzer, weil alle Erklärungen gleich behandelt werden:

```gdscript
func anzeigen() -> void:
	var text := ""
	for i in eintraege.size():
		text += ("> " if i == auswahl else "  ") + tr(eintraege[i]) + "\n"
	$Menue.text = text
	# Jede Zeile der Erklärung einzeln übersetzen, dann zusammenkleben
	var zeilen: Array = ERKLAERUNG[eintraege[auswahl]].map(func(zeile: String) -> String: return tr(zeile))
	match eintraege[auswahl]:
		"Weiter":
			zeilen[1] = zeilen[1] % [zeit, erkundet]
		"Iron Man":
			if ironman_bestzeit:
				zeilen.append(tr("Schnellster eiserner Held: %s") % ironman_bestzeit)
	$Hinweis.text = "\n".join(zeilen)
```

Und ganz oben in `starten()`:

```gdscript
	if was == "Optionen":
		get_tree().change_scene_to_file(OPTIONEN)
		return
```

- **`"\n".join(zeilen)`:** klebt alle Zeilen zusammen, mit einem Zeilenumbruch dazwischen. Das ist das Gegenstück zu `split()`.
- **Die Leerzeichen am Zeilenanfang** aus deinen alten Erklärungen sind weg. Sie standen da, damit die zweite Zeile mittig aussieht, aber das Label zentriert sowieso jede Zeile für sich.

### 13.9 Die Optionen merken sich

Die Einstellungen gehören zu keinem Spielstand. Wer auf Englisch spielt, will auch nach „Neues Spiel“ noch Englisch, und im Iron-Man-Spiel auch. Darum bekommen sie einen eigenen Autoload mit einer eigenen Datei. Eine Prüfsumme braucht die nicht: Wer seine Sprache in der Datei umstellt, betrügt niemanden.

Neues Skript `optionen.gd` (ohne Szene):

```gdscript
extends Node

# Einstellungen, die zu keinem Spielstand gehören. Sie gelten für jedes Spiel, auch für Iron Man.

const DATEI = "user://optionen.cfg"
const SPRACHEN = ["de", "en"]
const SPRACHNAMEN = {"de": "Deutsch", "en": "English"}   # jede Sprache in ihrer eigenen Sprache

var sprache := "de"
var schraeg := false   # in acht Richtungen laufen statt in vier


func _ready() -> void:
	laden()


func laden() -> void:
	var datei := ConfigFile.new()
	datei.load(DATEI)   # Gibt es die Datei noch nicht, liefert get_value einfach die Ersatzwerte
	# Beim allerersten Start: die Sprache des Computers, wenn wir sie haben. Sonst Englisch.
	var vorschlag := OS.get_locale_language() if OS.get_locale_language() in SPRACHEN else "en"
	sprache = datei.get_value("optionen", "sprache", vorschlag)
	schraeg = datei.get_value("optionen", "schraeg", false)
	TranslationServer.set_locale(sprache)


func speichern() -> void:
	var datei := ConfigFile.new()
	datei.set_value("optionen", "sprache", sprache)
	datei.set_value("optionen", "schraeg", schraeg)
	datei.save(DATEI)
	TranslationServer.set_locale(sprache)
```

**Project Settings → Globals → Autoload:** `optionen.gd` mit dem Namen `Optionen` hinzufügen.

- **`OS.get_locale_language()`:** die Sprache, auf die der Computer eingestellt ist, zum Beispiel `de`. Ein Spieler aus Frankreich bekommt `fr`, das haben wir nicht, also Englisch. Danach entscheidet die Datei.
- **„Deutsch“ und „English“ werden nie übersetzt.** Wer aus Versehen auf eine Sprache umgestellt hat, die er nicht lesen kann, muss seine eigene Sprache trotzdem wiederfinden.
- **Warum `datei.load()` ohne `if`?** Klappt das Laden nicht, ist die ConfigFile einfach leer, und jedes `get_value` gibt seinen Ersatzwert zurück. Genau das wollen wir beim ersten Start.

### 13.10 Der Optionen-Bildschirm

Neue Szene, aufgebaut wie das Titelbild. Am schnellsten: `titel.tscn` im Dateisystem rechtsklicken → **Duplicate…** → `optionen.tscn`. Dann:

1. Wurzel umbenennen in `Optionen`. Das Skript abnehmen (Rechtsklick → **Detach Script**).
2. `Spielname` umbenennen in `Ueberschrift`, Text „OPTIONEN“. Den übersetzt das Label selbst.
3. `Menue`: **Offset Left** 56, **Offset Right** 240. „> Walk diagonally: off“ ist etwas breiter als „> Neues Spiel“.
4. `Hinweis` bleibt, wie er ist.
5. Neues Skript an die Wurzel, `optionen_menue.gd`:

```gdscript
extends Control

# Der Optionen-Bildschirm. Hoch und runter wählt, links und rechts ändert.

const TITEL = "res://titel.tscn"
const EINTRAEGE = ["Sprache", "Schräg laufen", "Zurück"]
const ERKLAERUNG = {
	"Sprache": "Links und rechts wechseln die Sprache.",
	"Schräg laufen": "Im Original läuft der Held nur in vier Richtungen. Mit „an“ geht es auch schräg.",
	"Zurück": "Zurück zum Titelbildschirm.",
}

var auswahl := 0


func _ready() -> void:
	anzeigen()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hoch"):
		auswahl = posmod(auswahl - 1, EINTRAEGE.size())
	elif Input.is_action_just_pressed("runter"):
		auswahl = posmod(auswahl + 1, EINTRAEGE.size())
	elif Input.is_action_just_pressed("links"):
		aendern(-1)
	elif Input.is_action_just_pressed("rechts") or Input.is_action_just_pressed("angriff"):
		aendern(1)
	else:
		return   # nichts gedrückt, nichts neu zu malen
	anzeigen()


# Die ausgewählte Einstellung eins weiter (oder eins zurück) schalten
func aendern(schritt: int) -> void:
	match EINTRAEGE[auswahl]:
		"Sprache":
			var nummer := Optionen.SPRACHEN.find(Optionen.sprache)
			Optionen.sprache = Optionen.SPRACHEN[posmod(nummer + schritt, Optionen.SPRACHEN.size())]
		"Schräg laufen":
			Optionen.schraeg = not Optionen.schraeg
		"Zurück":
			if Input.is_action_just_pressed("angriff"):
				get_tree().change_scene_to_file(TITEL)
			return
	Optionen.speichern()


func anzeigen() -> void:
	var werte := {
		"Sprache": Optionen.SPRACHNAMEN[Optionen.sprache],
		"Schräg laufen": tr("an") if Optionen.schraeg else tr("aus"),
	}
	var text := ""
	for i in EINTRAEGE.size():
		var eintrag: String = EINTRAEGE[i]
		text += ("> " if i == auswahl else "  ") + tr(eintrag)
		if eintrag in werte:
			text += ": " + werte[eintrag]
		text += "\n"
	$Menue.text = text
	$Hinweis.text = tr(ERKLAERUNG[EINTRAEGE[auswahl]])
```

- **Die Sprache wechselt sofort.** `Optionen.speichern()` stellt den TranslationServer um, und `anzeigen()` danach malt alles in der neuen Sprache. Die Überschrift merkt den Wechsel von selbst: Labels hören auf den TranslationServer.
- **`posmod(nummer + schritt, ...)`:** von der letzten Sprache wieder zur ersten, und mit links von der ersten zur letzten. Das kennst du vom Titelmenü. Kommt eine dritte Sprache dazu, musst du hier nichts ändern.
- **`else: return`:** Nur wenn wirklich etwas gedrückt wurde, wird neu gemalt. Das spart nichts, was man merkt, aber es zeigt, wie man so etwas macht.

### 13.11 Schräg laufen

In `held.gd`, in `laufen()`, statt der ersten Zeile:

```gdscript
	var eingabe := Input.get_vector("links", "rechts", "hoch", "runter")
	var richtung := eingabe if Optionen.schraeg else vier_richtungen(eingabe)
```

Und beim Schieben, damit kein Felsbrocken schräg rutscht:

```gdscript
				ding.schieben(vier_richtungen(richtung), delta)   # Felsbrocken rutschen nie schräg
```

- **Warum geht das so leicht?** `get_vector()` liefert schon eine fertige Richtung, auch schräg, und schräg nicht schneller als gerade. Das war die allererste Übung in Kapitel 1. Bisher hat `vier_richtungen()` daraus eine der vier gemacht. Jetzt nur noch, wenn die Option aus ist.
- **Was ist mit dem Blick und dem Schwert?** `blick = vier_richtungen(richtung)` steht schon in `laufen()`. Der Held läuft also schräg, schaut und sticht aber weiter in eine der vier Richtungen. Wie bei vielen Zelda-Spielen, die schräg laufen können.
- **Und die Ecken-Hilfe?** `ecke_umrunden()` hilft nur, wenn man fast gerade läuft. Schräg macht sie nichts, und das ist richtig so: Wer schräg läuft, rutscht sowieso an der Kante entlang.

### 13.12 Was fehlt noch?

Wenn du ab jetzt ein Schild aufstellst oder einen Text änderst, muss er auch in `texte.csv`. Damit du nichts vergisst, liegt `texte.py` im Projektordner:

```bash
python texte.py
```

Es sucht alle Texte im Spiel zusammen (Schilder, Namen, Labels und alles in `tr()`) und sagt dir:
- **Fehlt in texte.csv:** Dieser Text steht im Spiel, aber nicht in der Tabelle. Mit Datei, damit du ihn findest.
- **Kommt im Spiel nicht vor:** Dieser Text steht in der Tabelle, aber nirgends im Spiel.
- **Noch nicht übersetzt:** In einer Spalte fehlt etwas.

Bei einem Tippfehler taucht beides auf: der falsche Text als „fehlt“, der richtige als „kommt nicht vor“. Probier es gleich aus, bevor du die sieben Schilder aus 13.5 korrigierst. Bevor du dieses Kapitel gebaut hast, stehen außerdem die neuen Texte wie „Optionen“ unter „kommt nicht vor“. Die verschwinden, sobald es sie im Spiel gibt.

Neue Zeilen trägst du in `texte.csv` von Hand ein, mit einem Texteditor oder 🆓 LibreOffice Calc. In LibreOffice beim Speichern **Text CSV** wählen, **UTF-8** als Zeichensatz und Komma als Trenner, sonst gehen die Umlaute kaputt. Den englischen Text kannst du mir auch einfach schicken.

### 13.13 Ausprobieren

- [ ] Raumwechsel ohne gedrückte Taste: zwei Schritte. Mit gedrückter Taste: auch nur zwei.
- [ ] Während der Held hereinläuft, tut die Angriffstaste nichts.
- [ ] Titelbild: Unter „Iron Man“ steht „Optionen“, darunter die Erklärung.
- [ ] Optionen: Rechts bei „Sprache“, alles wird Englisch, auch die Überschrift. Noch einmal rechts, zurück zu Deutsch.
- [ ] Englisch einstellen, Spiel beenden, neu starten: Es ist immer noch Englisch.
- [ ] Im Spiel auf Englisch: MAP, INVENTORY, LIFE. Ein Schild auf Englisch, „Yes“ und „No“ in der Pausenfrage.
- [ ] Beim Händler: „A heart for 10 coins?“ Und der Name über der Box: „Merchant“.
- [ ] Ein Schild mit einem der sieben Tippfehler zeigt auf Englisch Deutsch. Nach dem Korrigieren: Englisch.
- [ ] Schräg laufen an: Der Held läuft schräg, das Schwert sticht trotzdem gerade. Ein Felsbrocken rutscht nur gerade.
- [ ] Abspann auf Englisch.
- [ ] `python texte.py` meldet keine fehlenden Texte mehr.

### 13.14 Was beim Bauen schiefging

- **Zeilenumbrüche in der Tabelle:** Zuerst wollte ich Texte wie `"Zeit: %s\nErkundet: %d %%\n"` als Ganzes übersetzen. Dann steckt der Zeilenumbruch im Schlüssel, und in einer CSV-Datei ist ein Zeilenumbruch mitten in einem Text eine Qual. Jede Zeile einzeln übersetzen und außen zusammenkleben ist viel einfacher (13.7).
- **Der Test, der nicht drücken wollte:** Zum Ausprobieren habe ich die Tasten per Code gedrückt, mit `Input.action_press("rechts")`. Laufen ging, aber im Optionen-Bildschirm passierte nichts. Laufen fragt `get_vector()`, also „ist die Taste gerade unten?“. Der Optionen-Bildschirm fragt `is_action_just_pressed()`, also „wurde sie **in diesem Bild** gedrückt?“. Und das Drücken per Code passierte in einem anderen Bild als die Frage. Mit `Input.parse_input_event()` geht der Druck den Weg einer echten Taste, und dann klappt es. Für dich als Spieler spielt das keine Rolle, aber wenn du einmal Tests schreibst, weißt du jetzt Bescheid.

### 13.15 Noch etwas aus Kapitel 12

Das wirkt sich im Moment nicht aus, aber vielleicht später:

**Das Kampfgitter zählt weiter.** In `_physics_process()` ruft das Kampfgitter `oeffnen()` auf, und zwar in jedem Bild, sobald alle Monster tot sind. Jedes Mal zählt `schalter_aktiv` eins hoch: 1, 2, 3, … Bei 1 geht das Gitter auf, danach ist es egal. Solange `merken` an ist (bei all deinen Kampfgittern), merkt man nichts, denn ein gemerktes Gitter geht nie wieder zu. Schaltest du aber einmal `merken` aus, kommt der Zähler nie wieder genau auf 1, und das Gitter bleibt beim nächsten Besuch für immer zu. Ein Kampfgitter ist kein Schalter, also soll es nicht mitzählen:

```gdscript
func _physics_process(_delta: float) -> void:
	if kampf and not offen and monster_im_raum.all(func(monster: Monster) -> bool: return monster.tot):
		if merken:
			Spielstand.erledigen(self)
		stellen(true)
```

### Übungsaufgaben zu Kapitel 13

1. **Gespeichert! (leicht):** Das „Gespeichert“ aus Kapitel 9 ist ein Bild (`speichern.png`), und Bilder übersetzt keine Tabelle. Mach daraus ein Label mit dem Text „Gespeichert“ und trag „Saved“ in `texte.csv` ein. Muss sich am Tween etwas ändern?
2. **Lautstärke (mittel):** Eine dritte Option: Lautstärke von 0 bis 10, mit links und rechts. Godot hat dafür den **Audio-Bus** „Master“: `AudioServer.set_bus_volume_db(0, linear_to_db(lautstaerke / 10.0))`. Warum `linear_to_db`? (Tipp: Lautstärke in Dezibel ist eine seltsame Skala. 0 dB ist volle Lautstärke, und bei -6 dB ist es ungefähr halb so laut.) Vergiss nicht, sie in `optionen.cfg` zu speichern und beim Start einzustellen. 🔊
3. **Vollbild (leicht):** Noch eine Option: Vollbild an oder aus. `DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)` und zurück mit `WINDOW_MODE_WINDOWED`.
4. **Einmal, zweimal (mittel):** Auf Englisch steht im Abspann „Died: 1 times“. Das ist falsch, es heißt „Died: once“. Im Deutschen geht es zufällig gut, weil „1-mal“ stimmt. Wie bekommst du die Einzahl richtig hin? Tipp: zwei Schlüssel, zum Beispiel „Gestorben: einmal“ und „Gestorben: %d-mal“, und der Code entscheidet, welcher es wird. Und was ist mit 0? „Kein einziges Mal gestorben!“ wäre doch schön. Für DOOM merk dir: Andere Sprachen haben mehr als zwei Formen. Im Russischen ist 2 anders als 5.
5. **Eine dritte Sprache (mittel):** Füg in `texte.csv` eine Spalte für eine weitere Sprache hinzu, zum Beispiel `fr` für Französisch. Eine Maschinenübersetzung reicht zum Ausprobieren völlig, zum Beispiel mit 🆓 DeepL. In `optionen.gd` kommt sie zu `SPRACHEN` und `SPRACHNAMEN`, und vergiss nicht, die neue `.translation`-Datei in den Projekteinstellungen hinzuzufügen. Dann schau genau hin: Kann die Kenney-Schrift „é“, „ç“ und „à“? Was würde mit Russisch oder Japanisch passieren? Für deinen DOOM-Klon ist das eine wichtige Frage: Die Schrift muss alle Sprachen können, die du anbieten willst. 🌍
6. **Optionen im Spiel (knifflig):** Bisher kommt man an die Optionen nur über das Titelbild. In der Pausenfrage wäre es praktisch, gleich die Sprache umzustellen, ohne das Spiel zu verlassen. Ein Szenenwechsel geht nicht, dann wäre der Dungeon weg. Wie kannst du den Optionen-Bildschirm stattdessen über das Spiel legen? (Tipp: `instantiate()` und eine `CanvasLayer`, so wie der Dialog. Und was muss dabei mit `get_tree().paused` passieren?)

Fertig? Committen und Bescheid geben. Dann kommt Kapitel 14: Musik und der Web-Export.


## Kapitel 14: Musik und Web-Export

Das letzte Kapitel. Bisher piept, klirrt und quiekt es im Kerker, aber Musik gibt es keine. Das ändert sich jetzt: Das Titelbild, der Kerker und der Boss bekommen jeder ein eigenes Stück, und beim Wechsel blendet das eine aus und das andere ein. In den Optionen kannst du die Musik leiser stellen, ohne dass die Geräusche leiser werden.

Danach kommt der Kerkerheld auf die Startseite, als Web-Spiel. Den Export kennst du schon von Flatterfisch und Hüpfheld. Diesmal gibt es aber ein paar Dinge, die es dort nicht gab: einen Spielstand, Musik und einen Vollbildmodus. Im Browser geht das alles etwas anders.

Neu sind **Audio-Busse**, ein **Autoload, der selbst ein AudioStreamPlayer ist**, **Schleifen in WAV-Dateien** und **`OS.has_feature()`**.

### 14.1 Was kommt wohin?

| Was | Wo |
|---|---|
| Drei Musikstücke | `musik.py` (liegt schon im Projekt) erzeugt `musik_titel.wav`, `musik_kerker.wav`, `musik_boss.wav` |
| Ein eigener Lautstärkeregler für die Musik | Audio-Bus `Musik` (unten im Editor) |
| Musik abspielen, ein- und ausblenden | neuer Autoload `musik.gd` |
| Welche Musik wann | `titel.gd`, `abschluss.gd`, `camera_2d.gd`, `krabbe.gd` |
| Option „Musik“, Lautstärke beim Start | `optionen.gd`, `optionen_menue.gd`, `titel.gd` |
| Kein Vollbild im Browser | `optionen.gd`, `optionen_menue.gd` |
| Web-Export | `web/`, Startseite `index.html` im Ordner `games` |

### 14.2 Ein Skript komponiert

Für die Fanfare aus der Truhe gibt es schon `fanfare.py`. Das neue `musik.py` macht dasselbe für vier ganze Stücke. Im Ordner `06-kerkerheld`:

```bash
python musik.py
```

```
musik_titel.wav: 8 Takte, 21.8 s, 939 KB
musik_kerker.wav: 8 Takte, 20.0 s, 861 KB
musik_boss.wav: 8 Takte, 12.6 s, 544 KB
musik_geheimnis.wav: 8 Takte, 16.0 s, 689 KB
```

Das vierte Stück, für den Geheimnisraum, brauchst du erst in Übung 3.

**Mach das als Erstes, noch vor allem anderen in diesem Kapitel.** Warum, steht in 14.10.

Die Stücke klingen wie auf einer alten Spielkonsole. Die hatten nur ein paar einfache Klangerzeuger, und genau die baut das Skript nach:
- **Melodie:** eine Rechteckwelle. Sie springt nur zwischen ganz oben und ganz unten hin und her. Das klingt hart und ein bisschen quäkig, genau richtig für eine Melodie.
- **Begleitung:** auch eine Rechteckwelle, aber dünner. Sie ist nur ein Viertel der Zeit oben und klingt dadurch heller und leiser.
- **Bass:** eine Dreieckwelle, weich und tief.
- **Trommel:** Rauschen. Kurz ist es ein Hi-Hat, etwas länger eine Snare, und der Kick ist ein Ton, der ganz schnell tiefer wird.

Die Noten stehen oben im Skript. So fängt der Kerker an:

```python
"melodie": "_:2 A4:2 D5:3 E5:1 | F5:4 E5:2 D5:2 | ...",
```

- **`A4:2`:** der Ton A in der vierten Oktave (das ist der Stimmton, 440 Hz), zwei Achtel lang. Ein Takt hat 8 Achtel.
- **`_:2`:** zwei Achtel Pause.
- **`|`:** ein Taktstrich. Er ist nur für dich da, damit du die Takte zählen kannst. Das Skript prüft trotzdem, ob jeder Takt genau 8 Achtel hat, und sagt dir sonst, welcher nicht stimmt.

**Und wie wiederholt sich das?** Ein Musikstück im Spiel soll endlos laufen, ohne Knacks an der Nahtstelle. Dafür braucht es zwei Dinge:
1. **Das Ende muss zum Anfang passen.** Ein Ton, der kurz vor Schluss angeschlagen wird, klingt eigentlich über das Ende hinaus. Das Skript rechnet diesen Rest einfach vorne wieder dazu. Wenn das Stück von vorn anfängt, klingt der letzte Ton also noch nach, genau wie er soll.
2. **Godot muss wissen, dass es wiederholen soll.** Eine WAV-Datei kann neben den Tönen noch andere Abschnitte enthalten. `musik.py` schreibt einen Abschnitt namens `smpl` hinein: „Schleife vom ersten bis zum letzten Sample“. Godot liest ihn beim Import. Schau nach: `musik_kerker.wav` im FileSystem anklicken, dann oben links den Tab **Import**. Bei **Loop Mode** steht `Detect From WAV`. Mehr musst du nicht tun.

Willst du später Musik aus einem anderen Programm benutzen, die keinen `smpl`-Abschnitt hat, stellst du dort **Loop Mode** auf `Forward` und klickst auf **Reimport**.

**Sind 3 MB Musik nicht zu viel fürs Web?** Im selben Import-Tab steht bei **Compress → Mode** `QOA`. Godot packt die Töne beim Import auf ungefähr ein Fünftel zusammen. Im fertigen Web-Export ist das ganze Spiel mit Musik gut 2 MB groß.

### 14.3 Ein eigener Bus für die Musik

Jeder Ton in Godot läuft durch einen **Audio-Bus**. Das ist wie ein Regler an einem Mischpult. Bisher gibt es nur einen, `Master`, und durch den läuft alles. Deine Lautstärke-Option aus Kapitel 13 dreht an diesem Regler.

Für die Musik kommt ein zweiter Regler dazu. Er läuft in den Master hinein. Dreht man ihn herunter, wird nur die Musik leiser. Dreht man den Master herunter, wird alles leiser, die Musik auch.

1. Unten im Editor auf **Audio** klicken (neben Output, Debugger, Animation …).
2. **Add Bus**. Rechts neben `Master` erscheint `New Bus`.
3. Doppelklick auf den Namen → **`Musik`**.
4. Ganz unten am neuen Bus steht, wohin er geht: `Master`. So soll es sein.

Godot speichert das von selbst in `default_bus_layout.tres` im Projektordner.

### 14.4 Der Musik-Autoload

Die Musik soll über Szenenwechsel hinweg weiterlaufen. Vom Titelbild in die Optionen und zurück soll sie nicht jedes Mal von vorn anfangen. Ein `AudioStreamPlayer` in `titel.tscn` würde beim Szenenwechsel mit der Szene verschwinden. Ein Autoload bleibt.

Neues Skript **`musik.gd`**. Ganz oben steht diesmal nicht `extends Node`, sondern `extends AudioStreamPlayer`:

```gdscript
extends AudioStreamPlayer

# Die Hintergrundmusik. Ein Autoload, darum spielt sie über jeden Szenenwechsel hinweg weiter.

const TITEL = preload("res://musik_titel.wav")
const KERKER = preload("res://musik_kerker.wav")
const BOSS = preload("res://musik_boss.wav")
const BLENDE = 0.6     # so lange dauert das Aus- und Einblenden, in Sekunden
const LEISE = -40.0    # in dB: so gut wie nichts mehr zu hören

var blende: Tween


func _ready() -> void:
	bus = &"Musik"
	# Dialoge und Raumwechsel pausieren das Spiel. Die Musik soll trotzdem weiterspielen.
	process_mode = Node.PROCESS_MODE_ALWAYS


# Ein Stück spielen. Läuft es schon, passiert nichts. Sonst wird das alte aus- und das neue eingeblendet.
func spielen(stueck: AudioStream) -> void:
	if stream == stueck and playing:
		return
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
	if blende:
		blende.kill()
	blende = create_tween()
	blende.tween_property(self, "volume_db", LEISE, BLENDE)
	blende.tween_callback(stop)
```

Eintragen: *Project Settings → Globals → Autoload*, Pfad `res://musik.gd`, Name **`Musik`**, **Add**. Er kommt unter `Optionen`.

- **`extends AudioStreamPlayer`:** Bisher waren deine Autoloads einfache `Node`s mit Variablen und Funktionen. Ein Autoload kann aber jeder Knotentyp sein. Dieser hier *ist* ein AudioStreamPlayer, deshalb gibt es `stream`, `play()`, `playing` und `volume_db` einfach so, ohne `$`.
- **`PROCESS_MODE_ALWAYS`:** Ohne diese Zeile hört die Musik bei jedem Dialog und bei jedem Raumwechsel auf. Ein pausierter AudioStreamPlayer pausiert nämlich auch seinen Ton. Das ist bei Geräuschen richtig: Ein Wasserspeier soll nicht weiterspucken, während ein Schild redet. Bei der Musik wäre es furchtbar.
- **`bus = &"Musik"`:** Das `&` vor dem Text macht daraus einen **StringName**. Das ist ein Text, den Godot nur einmal speichert und danach blitzschnell vergleicht. Bus-Namen, Aktionen und Gruppen sind in Godot StringNames. Ein normaler Text geht meistens auch, Godot wandelt ihn um.
- **Erst aus, dann ein:** Der Tween dreht die Lautstärke herunter, wechselt dann das Stück und dreht sie wieder hoch. `tween_callback()` kennst du von den Tweens bei Hüpfheld: An dieser Stelle im Ablauf wird eine Funktion aufgerufen.
- **`wechseln.bind(stueck)`:** `tween_callback()` will eine Funktion, die es später aufruft, und zwar ohne Argumente. `bind()` klebt das Argument schon jetzt an die Funktion. Später wird dann `wechseln(stueck)` aufgerufen.
- **`blende.kill()`:** Kommt ein neuer Wunsch, während noch geblendet wird, wird der alte Tween abgebrochen. Sonst würden zwei Tweens gleichzeitig an `volume_db` drehen.
- **Warum nicht einfach `volume_db` für die Option?** Mit `volume_db` blendet `musik.gd` ein und aus. Die Lautstärke aus den Optionen regelt der Bus. So kommen die beiden sich nicht in die Quere.

### 14.5 Wer bestellt welche Musik?

Jede Szene sagt dem Autoload, was sie hören will. Läuft das Stück schon, passiert nichts. Darum kann man `spielen()` ruhig öfter aufrufen.

**Titelbild:** In `titel.gd` als erste Zeile in `_ready()`:

```gdscript
	Musik.spielen(Musik.TITEL)
```

**Abspann:** In `abschluss.gd` dieselbe Zeile als erste in `_ready()`.

**Kerker und Boss:** Welcher Raum gerade zu sehen ist, weiß die Kamera. Also entscheidet sie. In `camera_2d.gd` eine neue Funktion:

```gdscript
# Im Bossraum läuft die Bossmusik, solange dort noch etwas lebt. Sonst die Kerkermusik.
func musik_waehlen() -> void:
	var lebt_noch := get_tree().get_nodes_in_group("monster").any(
			func(monster: Monster) -> bool: return raum_von(monster.start_position) == raum and not monster.tot)
	if raum_von(boss.global_position) == raum and lebt_noch:
		Musik.spielen(Musik.BOSS)
	else:
		Musik.spielen(Musik.KERKER)
```

Aufgerufen wird sie an zwei Stellen. Am Ende von `_ready()`:

```gdscript
	musik_waehlen.call_deferred()   # erst wenn alle Monster wissen, ob sie tot sind
```

Und in `schieben()`, gleich unter `%Karte.zeigen(raum)`:

```gdscript
	musik_waehlen()
```

- **`boss` ist der Raum, nicht die Krabbe:** In der Gruppe `boss` steckt der Marker2D aus `bossraum.tscn`. Er sagt, *wo* der Bossraum ist, aber nicht, ob die Krabbe noch lebt. Das fragt `any()` alle Monster: Lebt in diesem Raum noch eines?
- **`any()`** ist der kleine Bruder von `all()` aus Kapitel 11: „Stimmt das für mindestens eines?“
- **Die lange Zeile umbrechen:** Ist eine Zeile zu lang, darf sie nach einer offenen Klammer in der nächsten Zeile weitergehen. Zwei Tabs Einrückung zeigen: Das gehört noch zur Zeile darüber.
- **Wieso funktioniert das auch nach dem Sieg?** Die Krabbe bleibt nach ihrem Tod für immer `tot`, auch im normalen Spiel (Kapitel 11). Betrittst du den Bossraum danach noch einmal, lebt dort nichts mehr, und es läuft die Kerkermusik.
- **`call_deferred()` in `_ready()`:** Beim Start sind noch nicht alle Monster fertig. Steht die Krabbe im Szenenbaum weiter unten als die Kamera, hat sie ihr `_ready()` noch nicht gehabt und weiß noch gar nicht, dass sie schon besiegt ist. `call_deferred()` wartet, bis alle fertig sind. Genauso wird `monster_wecken` direkt darüber schon aufgerufen.
- **Warum nicht die Bosssperre?** Die wüsste auch, wann der Bosskampf losgeht. Aber du hast sie in Kapitel 12 durch ein Kampfgitter ersetzt. `bosssperre.gd` und `bosssperre.tscn` benutzt nichts mehr, die kannst du löschen (14.8). Die Kamera dagegen gibt es sicher.

**Der Boss stirbt:** Stille. Die Fanfare aus der Truhe soll gleich danach ganz für sich allein klingen. In `krabbe.gd`, in `sterben()`, gleich nach `Spielstand.erledigen(self)`:

```gdscript
	Musik.stoppen()   # Stille. Die Fanfare kommt gleich aus der Truhe.
```

### 14.6 Die Lautstärke für die Musik

Bei der Durchsicht ist mir aufgefallen: Die Lautstärke aus Kapitel 13 wird gespeichert und geladen, aber beim Start nicht eingestellt. Stell sie auf 3, starte das Spiel neu: In den Optionen steht 3, aber es ist laut wie 10. Erst wenn du einmal links oder rechts drückst, stimmt es wieder. Beim Vollbild hattest du dasselbe schon mit `vollbild_anwenden()` gelöst. Bei der Lautstärke machst du es genauso, und die Musik kommt gleich mit dazu.

In `optionen.gd`:

```gdscript
var lautstaerke := 10   # 0 bis 10: alles zusammen
var musik := 10         # 0 bis 10: nur die Musik
```

Eine neue Funktion, über `laden()`:

```gdscript
# Bus 0 heißt immer Master, da läuft alles durch. Die Musik hat ihren eigenen Bus.
# linear_to_db: Lautstärke hört man nicht gleichmäßig. 5 von 10 klingt so wirklich wie „halb so laut“.
func lautstaerke_anwenden() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(lautstaerke / 10.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musik"), linear_to_db(musik / 10.0))
```

In `laden()` unter der Zeile mit `lautstaerke` eine Zeile für `musik`, und ganz am Ende unter `vollbild_anwenden()` der Aufruf:

```gdscript
	musik = datei.get_value("optionen", "musik", 10)
	...
	lautstaerke_anwenden()
```

In `speichern()` unter der Zeile mit `lautstaerke`:

```gdscript
	datei.set_value("optionen", "musik", musik)
```

- **`get_bus_index("Musik")`:** Busse haben eine Nummer, `Master` ist immer 0. Die Musik ist bei dir 1, aber wer weiß, ob du später noch einen Bus davorschiebst. Mit dem Namen bist du sicher.

In `optionen_menue.gd` kommt „Musik“ unter „Lautstärke“ in `EINTRAEGE`, und in `ERKLAERUNG`:

```gdscript
	"Musik": "Nur die Musik. Die Geräusche bleiben, wie sie sind.",
```

In `aendern()` ersetzt du den Fall `"Lautstärke"` und hängst `"Musik"` dahinter:

```gdscript
		"Lautstärke":
			Optionen.lautstaerke = clampi(Optionen.lautstaerke + schritt, 0, 10)
			Optionen.lautstaerke_anwenden()
		"Musik":
			Optionen.musik = clampi(Optionen.musik + schritt, 0, 10)
			Optionen.lautstaerke_anwenden()
```

Und in `anzeigen()` bei den `werte`:

```gdscript
		"Musik": str(Optionen.musik),
```

- **`clampi` statt `clamp`:** `clamp()` nimmt alles Mögliche und gibt einen `Variant` zurück. `clampi()` ist nur für ganze Zahlen (`i` wie *integer*) und gibt auch eine zurück. Dann weiß Godot schon beim Schreiben, was herauskommt.

Zuletzt stimmt im Titelbild die Erklärung zu „Optionen“ nicht mehr. In `titel.gd`:

```gdscript
	"Optionen": ["Sprache, Lautstärke und wie der Held läuft."],
```

Die drei neuen Texte stehen schon in `texte.csv`, auf Englisch und Französisch. Bis du sie eingebaut hast, meldet `python texte.py` sie als „kommt im Spiel nicht vor“.

### 14.7 Kein Vollbild im Browser

Ein Browser lässt eine Seite nur dann ins Vollbild, wenn das **direkt** auf einen Klick oder Tastendruck passiert. So kann keine Webseite einfach von selbst den ganzen Bildschirm übernehmen. Godot liest die Tasten aber erst einen Moment später, in `_process()`. Für den Browser ist das schon „von selbst“. In meinem Test ist der Kerkerheld im Browser deshalb nie ins Vollbild gegangen, und beim Start, ganz ohne Tastendruck, geht es sowieso nicht.

Den Eintrag „Vollbild“ gibt es im Browser darum gar nicht erst. Dort hat jeder sowieso **F11**. Woher weiß das Spiel, ob es im Browser läuft?

In `optionen_menue.gd`, in `_ready()`, unter dem `if im_spiel:`-Block:

```gdscript
	if OS.has_feature("web"):
		eintraege = eintraege.filter(func(e: String) -> bool: return e != "Vollbild")   # im Browser gibt es dafür F11
```

Und in `optionen.gd` als erste Zeilen in `vollbild_anwenden()`:

```gdscript
	if OS.has_feature("web"):
		return
```

- **`OS.has_feature()`** fragt: „Auf was für einem Gerät laufe ich?“ Ein paar Antworten: `"web"`, `"windows"`, `"mobile"`, `"editor"`. Für DOOM wirst du das wieder brauchen, zum Beispiel für Grafikeinstellungen, die es nur auf dem PC gibt.
- **Warum auch in `vollbild_anwenden()`?** `laden()` ruft es beim Start auf. Stünde in der Datei `vollbild = true`, würde das Spiel im Browser ohne Tastendruck nach dem Vollbild fragen. Der Eintrag ist im Browser zwar weg, aber so kann es gar nicht erst passieren.

### 14.8 Ab ins Web

Den Export kennst du von Hüpfheld (Kapitel 8.5). Kurz:

1. In `06-kerkerheld` einen Ordner **`web`** mit einer leeren **`.gdignore`** darin.
2. *Project → Export → Add… → Web*: **Export Path** `web/index.html`, **Thread Support** aus.
3. **Export Project**, ohne **Export With Debug**.
4. Im Ordner `games`:

```bash
python -m http.server 8000
```

Dann `http://localhost:8000/06-kerkerheld/web/` öffnen.

Neu beim Kerkerheld:
- **Erst ein Tastendruck, dann Ton.** Browser spielen auf einer Seite keinen Ton ab, bevor man dort etwas angeklickt oder gedrückt hat. Sonst würden einen Webseiten ständig ungefragt anbrüllen. Godot wartet deshalb, und die Titelmusik setzt mit dem ersten Tastendruck ein. Das ist kein Fehler.
- **Der Spielstand wohnt im Browser.** Im Browser gibt es keinen Ordner `AppData`. `user://` landet im Speicher des Browsers, und zwar getrennt für jede Adresse. Was du auf `localhost` spielst, kennt die Startseite im Internet nicht, und umgekehrt. Ein privates Fenster vergisst alles, sobald es zu ist. Das gilt auch für die Bestenliste und die Optionen. Für deine Prüfsumme ändert sich nichts.
- **Die Größe:** `index.wasm` ist wie immer die ganze Engine, knapp 40 MB. Dein Spiel selbst, `index.pck`, ist mit allen Bildern, Tönen und der Musik gut 2 MB groß.
- **Die Lizenzen:** Godot (MIT) und die Kenney-Grafiken stehen schon in deiner `README.md`. Die Musik hat dein Skript gemacht, die gehört dir. Nur die Kenney-Schrift fehlt noch, die ist auch CC0.

**Auf die Startseite:** In `games/index.html` steht der Kerkerheld schon in der Liste, nur noch ohne Ordner. Aus `folder: null` wird:

```js
  { num: '06', name: 'Kerkerheld', folder: '06-kerkerheld/web', color: '#2ecc71', highscoreKey: null,
```

Und das „In Arbeit:“ in der Beschreibung darunter darf jetzt weg. Schreib hin, was den Kerkerheld ausmacht. In der Spieltabelle in `games/README.md` gehört er natürlich auch dazu.

Vorher aufräumen: Der Export nimmt **alles** mit, was Godot im Projekt kennt, auch Szenen, die nichts mehr benutzt. Lösch also `bosssperre.tscn` und `bosssperre.gd`. Die `.py`-Dateien, `texte.csv` und die Anleitung kommen übrigens nicht mit: Godot exportiert nur, was es selbst importiert hat. Aus `texte.csv` kommen nur die fertigen `.translation`-Dateien mit.

### 14.9 Ausprobieren

- [ ] Titelbild: Musik. In die Optionen und zurück: Sie läuft einfach weiter und fängt nicht von vorn an.
- [ ] Neues Spiel: Die Titelmusik blendet aus, die Kerkermusik ein.
- [ ] Ein Schild lesen: Die Musik spielt weiter, während das Spiel steht.
- [ ] Raumwechsel: Die Musik läuft ohne Unterbrechung weiter.
- [ ] Hör 20 Sekunden im selben Raum zu: Die Kerkermusik fängt ohne Knacks und ohne Pause von vorn an.
- [ ] In den Bossraum: Bossmusik. Die Krabbe besiegen: Stille, dann die Fanfare aus der Truhe.
- [ ] Nach dem Sieg noch einmal in den Bossraum: Kerkermusik.
- [ ] Im Bossraum sterben: Am Eingang läuft wieder die Kerkermusik.
- [ ] Abspann: Titelmusik.
- [ ] Optionen: Musik auf 0. Die Musik ist weg, das Schwert zischt weiter. Lautstärke auf 0: alles still.
- [ ] Musik auf 3, Spiel beenden, neu starten: Die Musik ist gleich leise, ohne dass du etwas drücken musst.
- [ ] Im Browser: Musik nach dem ersten Tastendruck. Kein „Vollbild“ in den Optionen.
- [ ] Im Browser einen Raum weit laufen, die Seite neu laden: „Weiter“ ist da.
- [ ] Die Startseite zeigt den Kerkerheld, und ein Klick startet ihn.

### 14.10 Was beim Bauen schiefging

- **Musik, die es noch nicht gab:** Zuerst habe ich `musik.gd` geschrieben und danach erst `musik.py` laufen lassen. Godot hat sofort gemeckert: `Preload file "res://musik_titel.wav" has no resource loaders`. `preload()` lädt schon beim Lesen des Skripts, und eine Datei, die es nicht gibt, kann es nicht laden. Das Schlimme daran: Ein Autoload mit einem Fehler wird einfach nicht angelegt, und dann gibt es danach in jedem Skript Fehler bei `Musik.spielen()`. Deshalb steht in 14.2: erst die Musik, dann der Rest.
- **Der Boss, der keiner war:** Meine erste `musik_waehlen()` hat gefragt, ob `boss` erledigt ist. Ergebnis: Bossmusik auch nach dem Sieg, für immer. `boss` ist ja der Marker2D des Raums, und ein Marker wird nie erledigt. Danach wollte ich die Bossmusik von der Bosssperre einschalten lassen, und es kam gar keine. Die Bosssperre steht nämlich in keiner Szene mehr. Am Ende hat die Kamera die Monster gefragt, und das geht immer.
- **Vollbild im Browser:** Das habe ich in meinem Browser nicht zum Laufen bekommen, siehe 14.7. Probier ruhig aus, ob es in deinem geht: Lass die beiden `OS.has_feature`-Zeilen einmal weg, exportiere neu und schalte Vollbild ein. Wenn es klappt, sag Bescheid.

### 14.11 Noch etwas aus Kapitel 13

**Die Schrift steckt jetzt in `schrift_settings.tres`.** Die Datei war ein paar hundert Bytes groß und ist jetzt fast 1 MB groß. Darin steckt eine komplette Kopie von `Kenney Pixel.ttf`, dazu ein Bild von jedem Buchstaben, den das Spiel schon einmal gebraucht hat. So etwas passiert, wenn man bei **Font** auf **Make Unique** klickt, wahrscheinlich bei der Übung mit „Gespeichert“. Im Spiel sieht man davon nichts. Aber jede kleine Änderung an den Label Settings schreibt dann wieder fast 1 MB in Git, und wenn du die Schrift einmal austauschst, bekommt die Kopie das nicht mit.

So machst du es rückgängig: `schrift_settings.tres` anklicken, im Inspector bei **Font** auf den Pfeil → **Load** → `Kenney/Kenney Pixel.ttf`. Danach ist die Datei wieder winzig.

### Übungsaufgaben zu Kapitel 14

1. **Gedämpft in der Pause (mittel):** Wenn das Pausenmenü offen ist, klingt die Musik wie aus dem Nebenraum. Ein Bus kann **Effekte** haben. Klick in der Audio-Leiste beim Bus `Musik` auf **Add Effect → LowPassFilter**. Der lässt nur die tiefen Töne durch. Schalte ihn im Bus aus und im Pausenmenü per Code ein und wieder aus: `AudioServer.set_bus_effect_enabled(bus, 0, true)`. Die `0` heißt: der erste Effekt in diesem Bus. Was passiert, wenn du im Bus mit **Cutoff Hz** spielst? 🔊
2. **Deine eigene Melodie (leicht):** Schreib in `musik.py` die Melodie vom Kerker um und lass das Skript noch einmal laufen. Godot importiert die neue Datei von selbst. Wenn dir ein Takt nicht gefällt, ändere nur diesen einen. Bonus: Mach den Kerker 16 Takte lang, die zweiten 8 mit einer anderen Melodie über demselben Bass. Was musst du am Bass und an der Trommel ändern?
3. **Ein Raum mit eigener Musik (mittel):** Der Geheimnisraum (1, -1) bekommt ein eigenes Stück. `musik.py` hat es schon erzeugt: `musik_geheimnis.wav`, fröhlich und in Dur. Bau es in `musik.gd` ein und lass `musik_waehlen()` es in diesem Raum spielen. Wie schreibst du das so, dass ein fünfter Raum mit eigener Musik nur noch eine einzige Zeile kostet? (Tipp: ein Dictionary von Raum zu Stück.)
4. **Herzklopfen (mittel):** Bei wenig Leben piept der Warnton aus Kapitel 6. Lass dazu die Musik etwas schneller laufen: `Musik.pitch_scale = 1.1`. Klingt das gut? Was passiert mit der Tonhöhe? Godot hat auch einen Effekt namens **PitchShift**. Kannst du damit die Musik schneller machen, ohne dass sie höher klingt? 🎵
5. **Für alle (leicht, freiwillig):** Lad den Kerkerheld auf 🆓 **itch.io** hoch. Dafür brauchst du ein Konto, das legst du selbst an. Pack den Inhalt von `web/` in eine ZIP-Datei, lade sie hoch und kreuz **This file will be played in the browser** an. Bei **SharedArrayBuffer support** machst du kein Kreuz, weil du ohne Threads exportiert hast. Und jetzt schick den Link jemandem, der gern Zelda spielt. 🎮

**Fast geschafft!** Ein Kapitel kommt noch: Wer den Link auf dem Handy öffnet, hat keine Tastatur. Committen und Bescheid geben.

---

## Kapitel 15: Touch-Knöpfe fürs Handy

Im Browser auf dem Handy läuft der Kerkerheld schon, man kann nur nichts drücken. In diesem Kapitel bekommt die Webseite ein Steuerkreuz, einen A-Knopf und einen Start-Knopf.

### 15.1 Warum nicht wie beim Hüpfheld?

Beim Hüpfheld liegen die Knöpfe **im Spielbild**: `touch.gd` legt `TouchScreenButton`s auf eine CanvasLayer. Das ging, weil dort mit „expand“ links und rechts noch Welt war.

Der Kerkerheld ist genau 256 × 224 Pixel groß, und ein Raum füllt das ganze Bild. Ein Steuerkreuz aus drei mal drei Feldern zu je 32 Pixeln würde unten links fast ein Viertel des Raums zudecken, genau da, wo Gegner und Truhen stehen. Mit „expand“ sähe man dagegen in die Nachbarräume, und das Schieben der Kamera ergäbe keinen Sinn mehr.

Dafür hat das Handy etwas, das der PC nicht hat: **schwarzen Rand**. Godot vergrößert das Bild nur in ganzen Schritten (Scale Mode `integer`) und lässt den Rest schwarz. Im Hochformat ist der Rand oben und unten, im Querformat links und rechts. Dort ist Platz.

Den Rand malt aber Godot selbst, im Canvas. Godot-Knöpfe kämen da nicht hin, **HTML-Knöpfe schon**: Sie liegen in der Webseite über dem Canvas. Und sie schicken dem Spiel ganz normale Tastendrücke: „Pfeil links“, „Leertaste“, „Esc“. Das ist dasselbe wie dein `pressKey` aus den JavaScript-Spielen. Godot merkt keinen Unterschied. Dialoge, Menüs und die Pause funktionieren deshalb sofort, ohne eine Zeile GDScript.

Der Nachteil: Das geht nur im Browser. Für eine echte Handy-App müsste man es später in Godot lösen.

### 15.2 touch.js

Neue Datei `web/touch.js`, direkt neben `index.html`. Der Export überschreibt nur die Dateien, die er selbst macht (`index.*`), deine Datei bleibt liegen. Und weil im Ordner die `.gdignore` liegt, schaut Godot sie gar nicht an.

```js
// Touch-Knöpfe für Handy und Tablet. Sie liegen im schwarzen Rand neben dem Spiel
// und schicken dem Spiel ganz normale Tastendrücke. Godot merkt keinen Unterschied.

// Mit Maus (PC) gibt es keine Knöpfe. "coarse" heißt: ein grober Zeiger, also ein Finger.
if (matchMedia('(pointer: coarse)').matches) {
  document.addEventListener('DOMContentLoaded', touchKnoepfe);
}

// Was Godot mit jeder Taste bekommt: code ist die Taste, key das Zeichen darauf
const ZEICHEN = { ArrowUp: 'ArrowUp', ArrowDown: 'ArrowDown', ArrowLeft: 'ArrowLeft',
                  ArrowRight: 'ArrowRight', Space: ' ', Escape: 'Escape' };

function taste(code, gedrueckt) {
  const art = gedrueckt ? 'keydown' : 'keyup';
  document.getElementById('canvas').dispatchEvent(
    new KeyboardEvent(art, { code: code, key: ZEICHEN[code], bubbles: true, cancelable: true }));
}

function touchKnoepfe() {
  const ebene = document.createElement('div');
  ebene.id = 'touch';
  ebene.innerHTML = `
    <div class="kreuz">
      <span data-code="ArrowUp">▲</span><span data-code="ArrowLeft">◀</span>
      <span data-code="ArrowRight">▶</span><span data-code="ArrowDown">▼</span>
    </div>
    <div class="knoepfe">
      <button class="a" data-code="Space">A</button>
      <button class="start" data-code="Escape">START</button>
    </div>`;
  document.body.appendChild(ebene);
  ebene.addEventListener('contextmenu', (e) => e.preventDefault());   // kein Menü bei langem Drücken

  // A und Start: drücken und loslassen, mehr nicht
  for (const knopf of ebene.querySelectorAll('button')) {
    knopf.addEventListener('pointerdown', (e) => {
      e.preventDefault();
      knopf.classList.add('an');
      taste(knopf.dataset.code, true);
    });
    for (const ende of ['pointerup', 'pointercancel', 'pointerleave']) {
      knopf.addEventListener(ende, () => {
        if (!knopf.classList.contains('an')) return;
        knopf.classList.remove('an');
        taste(knopf.dataset.code, false);
      });
    }
  }

  // Das Steuerkreuz ist eine Fläche: Wohin der Finger von der Mitte aus zeigt, so wird gelaufen.
  // Schräg drückt zwei Tasten auf einmal, wie auf der Tastatur. Der Finger darf rutschen.
  const kreuz = ebene.querySelector('.kreuz');
  let gedrueckt = new Set();

  function richtungen(e) {
    const r = kreuz.getBoundingClientRect();
    const x = (e.clientX - r.left) / r.width - 0.5;   // -0.5 links bis 0.5 rechts
    const y = (e.clientY - r.top) / r.height - 0.5;   // -0.5 oben bis 0.5 unten
    const neu = new Set();
    if (Math.hypot(x, y) < 0.1) return neu;           // genau in der Mitte: stehen bleiben
    const winkel = Math.atan2(y, x) * 180 / Math.PI;  // 0 = rechts, 90 = unten, -90 = oben
    // Acht Stücke zu je 45 Grad. Liegt der Winkel zwischen zwei Richtungen, gelten beide.
    if (winkel > -67.5 && winkel < 67.5) neu.add('ArrowRight');
    if (winkel > 22.5 && winkel < 157.5) neu.add('ArrowDown');
    if (winkel > 112.5 || winkel < -112.5) neu.add('ArrowLeft');
    if (winkel > -157.5 && winkel < -22.5) neu.add('ArrowUp');
    return neu;
  }

  // Nur melden, was sich geändert hat: Losgelassenes los, Neues drücken
  function setzen(neu) {
    for (const code of gedrueckt) if (!neu.has(code)) taste(code, false);
    for (const code of neu) if (!gedrueckt.has(code)) taste(code, true);
    gedrueckt = neu;
    for (const pfeil of kreuz.children) pfeil.classList.toggle('an', neu.has(pfeil.dataset.code));
  }

  kreuz.addEventListener('pointerdown', (e) => {
    e.preventDefault();
    kreuz.setPointerCapture(e.pointerId);   // auch melden, wenn der Finger aus dem Kreuz rutscht
    setzen(richtungen(e));
  });
  kreuz.addEventListener('pointermove', (e) => {
    if (kreuz.hasPointerCapture(e.pointerId)) setzen(richtungen(e));
  });
  for (const ende of ['pointerup', 'pointercancel']) {
    kreuz.addEventListener(ende, () => setzen(new Set()));
  }
}
```

Was darin passiert:
- **`matchMedia('(pointer: coarse)')`**: CSS kann fragen, womit gezeigt wird. `coarse` heißt grob, also ein Finger, `fine` wäre eine Maus. Am PC gibt es so gar keine Knöpfe.
- **`new KeyboardEvent(...)`**: ein nachgemachter Tastendruck. `code` ist die Taste auf der Tastatur, so wie Godot sie im Input Map als *Physical Key* kennt. Godot hört auf dem `<canvas>` zu, deshalb geht der Tastendruck genau dorthin.
- **Pointer-Events statt Touch-Events**: `pointerdown`, `pointermove` und `pointerup` gibt es für Finger, Maus und Stift gleichermaßen. So kannst du die Knöpfe am PC mit der Maus ausprobieren.
- **`setPointerCapture`**: Rutscht der Finger beim Laufen über den Rand des Steuerkreuzes hinaus, bekommt das Kreuz trotzdem weiter Bescheid. Sonst bliebe der Held einfach stehen, oder schlimmer: Die Taste bliebe gedrückt.
- **Das Steuerkreuz** ist nur eine runde Fläche. `Math.atan2` rechnet aus, in welche Richtung der Finger von der Mitte aus zeigt, als Winkel. Es gibt acht Stücke zu je 45 Grad, und in den schrägen Stücken sind zwei Pfeile gleichzeitig gedrückt. Ob der Held dann schräg läuft, entscheidet wie bei der Tastatur deine Option „Schräg laufen“.
- **`setzen`** meldet nur Änderungen. Bleibt der Finger rechts, kommt kein neues `keydown`. Sonst sähe Godot bei jeder kleinen Fingerbewegung einen neuen Tastendruck. Das ist dasselbe Problem wie neulich mit dem Stick im Dialog.

### 15.3 touch.css

Neue Datei `web/touch.css`:

```css
/* Die Ebene liegt über allem, lässt Berührungen aber durch, außer auf den Knöpfen */
#touch {
  position: fixed;
  inset: 0;
  pointer-events: none;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding: 24px;
  box-sizing: border-box;
  user-select: none;
  -webkit-user-select: none;
  -webkit-touch-callout: none;
  font-family: sans-serif;
}

/* Querformat: Der Rand ist links und rechts, die Knöpfe sitzen in der Mitte der Höhe */
@media (orientation: landscape) {
  #touch { align-items: center; padding: 12px; }
}

.kreuz, .knoepfe button { pointer-events: auto; touch-action: none; }

/* Steuerkreuz: ein Kreis mit vier Pfeilen */
.kreuz {
  position: relative;
  width: min(40vmin, 170px);
  aspect-ratio: 1;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.08);
  border: 2px solid rgba(255, 255, 255, 0.25);
}
.kreuz span {
  position: absolute;
  color: rgba(255, 255, 255, 0.5);
  font-size: min(8vmin, 32px);
  transform: translate(-50%, -50%);
}
.kreuz span[data-code="ArrowUp"]    { left: 50%; top: 18%; }
.kreuz span[data-code="ArrowDown"]  { left: 50%; top: 82%; }
.kreuz span[data-code="ArrowLeft"]  { left: 18%; top: 50%; }
.kreuz span[data-code="ArrowRight"] { left: 82%; top: 50%; }

.knoepfe {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}
.knoepfe button {
  border: 2px solid rgba(255, 255, 255, 0.25);
  background: rgba(255, 255, 255, 0.08);
  color: rgba(255, 255, 255, 0.6);
  font-weight: bold;
}
.knoepfe .a {
  width: min(22vmin, 90px);
  aspect-ratio: 1;
  border-radius: 50%;
  font-size: min(8vmin, 32px);
}
.knoepfe .start {
  padding: 6px 14px;
  border-radius: 999px;
  font-size: 12px;
  letter-spacing: 2px;
}

/* Gedrückt: smaragdgrün, wie die Münzen */
.kreuz span.an { color: #00f24d; }
.knoepfe button.an { background: rgba(0, 242, 77, 0.3); border-color: #00f24d; color: #fff; }
```

- **`pointer-events: none`** auf der ganzen Ebene: Sie liegt über dem Spiel, aber Berührungen gehen durch. Nur die Knöpfe selbst fangen sie auf.
- **`justify-content: space-between`** schiebt das Steuerkreuz an den linken und die Knöpfe an den rechten Rand. Im Hochformat sitzen beide unten. **`@media (orientation: landscape)`** setzt sie im Querformat auf halbe Höhe.
- **`vmin`** ist ein Hundertstel der kürzeren Bildschirmseite. Damit sind die Knöpfe auf kleinen Handys kleiner, und `min(..., 170px)` hält sie auf Tablets in Grenzen.
- **`-webkit-touch-callout`** und **`user-select`**: Ohne die zeigt das iPhone bei langem Drücken eine Lupe oder will Text markieren.

### 15.4 Die Webseite lädt die Dateien

Die `index.html` macht der Export jedes Mal neu. Was du dort hineinschreibst, ist beim nächsten Export wieder weg. Dafür gibt es im Export-Fenster ein eigenes Feld: *Project → Export → Web*, Abschnitt **HTML**, Feld **Head Include**:

```html
<link rel="stylesheet" href="touch.css">
<script src="touch.js"></script>
```

Was dort steht, kopiert Godot bei jedem Export in den `<head>` der `index.html`. Danach **Export Project**, wie immer ohne Debug.

### 15.5 Ausprobieren

**Am PC**, ohne Handy:
1. Im Ordner `games` den Server starten (`python -m http.server 8000`) und `http://localhost:8000/06-kerkerheld/web/` öffnen.
2. **F12** für die Entwicklerwerkzeuge, dann **Strg+Umschalt+M**: Der Browser tut so, als wäre er ein Handy. Oben kannst du ein Gerät aussuchen und mit dem Drehen-Knopf ins Querformat wechseln.
3. **F5** zum Neuladen. Erst dann fragt `touch.js` neu, ob ein Finger zeigt.

Die Knöpfe lassen sich dann mit der Maus drücken.

**Auf dem Handy:** Am einfachsten committen, pushen und über GitHub Pages öffnen. Ohne Push geht es, wenn Handy und PC im selben WLAN sind. Starte den Server dann mit `python -m http.server 8000 --bind 0.0.0.0` und öffne auf dem Handy `http://<IP vom PC>:8000/06-kerkerheld/web/`. Die IP zeigt `ipconfig` unter *IPv4-Adresse*. Windows fragt beim ersten Mal, ob Python ins Netz darf. Erlaube nur *Private Netzwerke*, nicht *Öffentliche*.

Checkliste:
- [ ] Am PC ohne Handy-Simulation: keine Knöpfe zu sehen
- [ ] Hochformat: Steuerkreuz unten links, A und Start unten rechts, nichts davon über dem Spiel
- [ ] Querformat: Steuerkreuz links, A und Start rechts
- [ ] Im Titelbild mit dem Kreuz auswählen, mit A starten
- [ ] Laufen, auch wenn der Finger über den Rand des Kreuzes hinausrutscht
- [ ] Start öffnet das Pausenmenü, das Kreuz wählt aus, A bestätigt
- [ ] Ein Dialog lässt sich mit A weiterblättern
- [ ] Die Musik setzt nach dem ersten Tippen ein
- [ ] In `README.md` bei **Steuerung** eine Zeile für Handy und Tablet ergänzt

### 15.6 Was ich getestet habe und was nicht

Ich habe das Kapitel in einer Testkopie gebaut und im Browser mit Handy-Simulation ausprobiert, im Hoch- und im Querformat. Die nachgemachten Tastendrücke kommen bei Godot an: Titelmenü, Spielstart, Laufen, schräg und Pausenmenü reagieren.

Auf einem **echten** Handy habe ich es nicht ausprobiert. Zwei Dinge musst du dort selbst prüfen:
- **Ton:** Browser spielen erst Ton ab, wenn man auf der Seite etwas angetippt hat. Ob ein Tippen auf einen HTML-Knopf dafür reicht, konnte ich nicht testen. Wenn es stumm bleibt, tipp einmal aufs Spielbild.
- **Mehrere Finger:** Laufen und gleichzeitig A drücken. Pointer-Events zählen jeden Finger einzeln, deshalb sollte das gehen. Sag Bescheid, wenn nicht.

### Übungsaufgaben zu Kapitel 15

1. **Brummen (leicht):** Lass das Handy beim Drücken von A kurz vibrieren: `navigator.vibrate(15)`. Die Zahl sind Millisekunden. Auf Android geht das, auf dem iPhone passiert einfach nichts. Warum ist das kein Fehler, und wie schreibst du die Zeile so, dass sie auf dem iPhone nicht abstürzt, falls es `navigator.vibrate` dort gar nicht gibt? 📳
2. **Für Linkshänder (leicht):** Tausch Steuerkreuz und Knöpfe: Kreuz rechts, A links. Das geht mit einer einzigen CSS-Zeile in `#touch`. (Tipp: `flex-direction`.)
3. **Weniger im Weg (mittel):** Auf einem Tablet im Querformat ist der Rand vielleicht schmaler als das Steuerkreuz, dann liegt es doch über dem Spiel. Mach die Knöpfe dort halb durchsichtig, solange sie nicht gedrückt sind. Woran erkennt CSS, dass der Bildschirm nicht viel breiter als hoch ist? (Tipp: `@media (max-aspect-ratio: ...)`)
4. **Titelbild (mittel):** Im Titelbild steht nirgends, welche Taste was macht. Auf dem Handy wäre „A drücken“ hilfreich, am PC „Leertaste“. Godot kann fragen, ob es einen Touchscreen gibt: `DisplayServer.is_touchscreen_available()`. Zeig damit im Titelbild den passenden Hinweis. Und was sagt die Funktion auf einem Laptop mit Touchscreen? ✋

**Der Kerkerheld ist fertig!** 🏰 Fünfzehn Kapitel: ein ganzer Dungeon mit Boss, Rätseln, Speichern, zwei Spielarten, drei Sprachen und Musik, spielbar auch auf dem Handy. Committen und Bescheid geben. Laut Roadmap ist das nächste Projekt **07 · Vampire Survivors (light)**: Hunderte Gegner auf einmal, und du lernst, wie man ein Spiel schnell hält, wenn sehr viel gleichzeitig passiert. Genau das braucht DOOM später auch.
