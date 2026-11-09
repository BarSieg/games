# Kerkerheld – Schritt-für-Schritt-Anleitung

Ein Dungeon von oben, nach dem Vorbild des ersten Dungeons aus The Legend of Zelda. Wie bei Hüpfheld baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Vieles kennst du schon: TileMapLayer, Kollisionsebenen, Tweens, Autoload, HUD, Szenenwechsel, Web-Export. Dafür geht es in den ersten Kapiteln schneller. Neu sind vor allem **State Machines**, **Räume**, ein **Inventar** und **Speichern in eine Datei**.

**Geplante Kapitel:**
1. Projekt, Grafiken und der erste Raum ✔
2. Laufen in vier Richtungen, mit Animation ✔
3. Das Schwert: Angriff, Hitbox und Hurtbox ✔
4. Gegner mit State Machine: umherlaufen, verfolgen, angreifen ✔
5. Mehrere Räume: Die Kamera schaltet um wie im Original, Monster bleiben in ihrem Raum ✔
6. Herzen, Schaden und die Anzeige oben ← *du bist hier*
7. Schlüssel, Truhen und verschlossene Türen (Inventar), dazu Karte und Kompass: Türen und Bossraum auf der Karte
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
