# 04 · Flatterfisch

Mein erstes Spiel mit der Godot-Engine. Ein Fisch schwimmt zwischen Korallen hindurch. Jeder Flossenschlag treibt ihn nach oben, dazwischen sinkt er. Für jede Lücke gibt es einen Punkt.

Diesmal habe ich das Spiel selbst im Editor gebaut, Kapitel für Kapitel. Wie es entstanden ist, steht in der [ANLEITUNG.md](ANLEITUNG.md), mit allen Übungsaufgaben.

**Starten:**
- **Im Browser:** über die Startseite oder direkt `web/index.html`. Das braucht einen Webserver (z. B. `python -m http.server 8000` im `games`-Ordner), ein Doppelklick auf die Datei reicht nicht.
- **Im Editor:** Ordner in 🆓 Godot 4 öffnen und **F5** drücken.

**Steuerung:** Leertaste oder Mausklick: Flossenschlag · P: Pause · Nach Game Over: Leertaste für ein neues Spiel

## Was ich gelernt habe
- **Nodes und Szenen:** In Godot ist alles aus Nodes gebaut, und jede Node kann eine Sache gut: ein Bild zeigen, eine Kollisionsform haben, einen Ton abspielen. Mehrere Nodes ergeben eine Szene (Fisch, Korallen, Main). Eine Szene kann man beliebig oft in andere einsetzen.
- **Signale:** Objekte schicken Nachrichten, ohne zu wissen, wer zuhört. Die Koralle sagt „durchschwommen“, der Fisch sagt „gestorben“, und `main.gd` entscheidet, was daraus folgt. Verbinden kann man im Editor oder im Code (`connect`). Bei Objekten, die erst während des Spiels entstehen, geht es nur im Code.
- **Resources:** Manche Einstellungen sind eigene Objekte, die in einer Node stecken: die Form in der `CollisionShape2D`, die Bilder in den `SpriteFrames`, der Sound im `AudioStreamPlayer`. Ist das Feld leer, passiert einfach nichts, ohne Fehlermeldung.
- **Physik-Körper und Flächen:** Der Fisch ist ein `CharacterBody2D`, den ich selbst per Code bewege (`velocity`, `move_and_slide`). Korallen und Punktzone sind `Area2D`: Sie halten nichts auf, merken aber, wenn etwas sie berührt (`body_entered`).
- **Szenen zur Laufzeit erzeugen:** `preload` lädt den Bauplan, `instantiate()` baut eine Kopie, `add_child()` bringt sie ins Spiel, `queue_free()` räumt sie wieder weg. Ein `Timer` sorgt für Nachschub.
- **Gruppen:** Ein Etikett für viele Nodes. Mit `call_group` halte ich alle Korallen auf einmal an.
- **Process Mode und Pause:** `get_tree().paused` hält alles an, was auf *Pausable* steht. Was weiterlaufen soll (Main, die Pause-Anzeige), steht auf *Always*. `paused` gehört zum SceneTree und überlebt deshalb auch einen Szenen-Neustart.
- **Neustart ohne Aufräumen:** `reload_current_scene()` setzt alles auf den Anfang zurück. Ein `newGame()`, in dem man jede Variable einzeln zurücksetzt, braucht man nicht.
- **Speichern:** `ConfigFile` in `user://`. Im Browser landet das automatisch im Browser-Speicher.
- **Animation, Partikel, Parallax:** `AnimatedSprite2D` für den Flossenschlag, `CPUParticles2D` für Luftblasen, zwei `Parallax2D`-Ebenen für Sand und Steine, die verschieden schnell laufen.
- **Web-Export:** Export-Template *Web Single-Threaded*, damit das Spiel ohne besondere Server-Einstellungen läuft. Der Export liegt in `web/`, und eine leere `.gdignore` hält Godot davon ab, die exportierten Dateien selbst zu importieren.

## JavaScript im Vergleich zu Godot

| Weltraumsteine (JavaScript) | Flatterfisch (Godot) |
|---|---|
| eigener Game Loop mit `requestAnimationFrame` | `_process` und `_physics_process` ruft Godot selbst auf |
| Kollision selbst rechnen (`distance`) | Kollisionsformen und Signale, Godot rechnet |
| `alienSpawn -= dt` von Hand herunterzählen | `Timer`-Node und `await create_timer()` |
| Objekte in Arrays, `filter` zum Löschen | Nodes im Baum, `queue_free()` zum Löschen |
| alles im Code, auch Positionen und Farben | vieles im Editor, der Code steuert nur das Verhalten |
| `localStorage` | `ConfigFile` in `user://` |

## Notizen
_(Was war schwer? Was würde ich anders machen? Was war in Godot leichter, was hat mir gefehlt?)_

## Engine
Erstellt mit der [Godot Engine](https://godotengine.org) (MIT-Lizenz). Der Web-Export in `web/` enthält die Engine. Lizenz und Hinweise: https://godotengine.org/license

Für meinen eigenen Code, meine Grafiken und Sounds gilt die [LICENSE](../LICENSE) im Hauptordner.
