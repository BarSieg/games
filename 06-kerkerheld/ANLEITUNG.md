# Kerkerheld – Schritt-für-Schritt-Anleitung

Ein Dungeon von oben, nach dem Vorbild des ersten Dungeons aus The Legend of Zelda. Wie bei Hüpfheld baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Vieles kennst du schon: TileMapLayer, Kollisionsebenen, Tweens, Autoload, HUD, Szenenwechsel, Web-Export. Dafür geht es in den ersten Kapiteln schneller. Neu sind vor allem **State Machines**, **Räume**, ein **Inventar** und **Speichern in eine Datei**.

**Geplante Kapitel:**
1. Projekt, Grafiken und der erste Raum ✔
2. Laufen in vier Richtungen, mit Animation ✔
3. Das Schwert: Angriff, Hitbox und Hurtbox ← *du bist hier*
4. Gegner mit State Machine: umherlaufen, verfolgen, angreifen
5. Mehrere Räume: Die Kamera schaltet um wie im Original
6. Herzen, Schaden und die Anzeige oben
7. Schlüssel, Truhen und verschlossene Türen (Inventar)
8. Dialoge: Schilder und ein alter Mann
9. Die Welt merkt sich alles: Speichern und Laden
10. Boss, Titelbild mit Optionen (z. B. schräg laufen ja/nein), Musik und Web-Export

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
