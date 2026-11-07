# Kerkerheld – Schritt-für-Schritt-Anleitung

Ein Dungeon von oben, nach dem Vorbild des ersten Dungeons aus The Legend of Zelda. Wie bei Hüpfheld baust du selbst im Godot-Editor, Kapitel für Kapitel. Nach jedem Kapitel meldest du dich, ich schaue deine Dateien durch, dann kommt das nächste.

Vieles kennst du schon: TileMapLayer, Kollisionsebenen, Tweens, Autoload, HUD, Szenenwechsel, Web-Export. Dafür geht es in den ersten Kapiteln schneller. Neu sind vor allem **State Machines**, **Räume**, ein **Inventar** und **Speichern in eine Datei**.

**Geplante Kapitel:**
1. Projekt, Grafiken und der erste Raum ← *du bist hier*
2. Laufen in vier Richtungen, mit Animation
3. Das Schwert: Angriff, Hitbox und Hurtbox
4. Gegner mit State Machine: umherlaufen, verfolgen, angreifen
5. Mehrere Räume: Die Kamera schaltet um wie im Original
6. Herzen, Schaden und die Anzeige oben
7. Schlüssel, Truhen und verschlossene Türen (Inventar)
8. Dialoge: Schilder und ein alter Mann
9. Die Welt merkt sich alles: Speichern und Laden
10. Boss, Titelbild, Musik und Web-Export

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

Der Held sollte an den Wänden stoppen und schräg an ihnen entlanggleiten. Lauf an die Wand oben: Sein Kopf verschwindet halb in der Wand, die Füße bleiben davor. Durch die Lücke oben kommt er hinaus ins Leere. Darum kümmern wir uns in Kapitel 5.

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
