class_name Held
extends CharacterBody2D

signal erfahrung_geaendert(erfahrung: int, ziel: int)
signal level_auf(level: int)

const STARTTEMPO = 70.0        # Pixel pro Sekunde
const WACKELN = 15.0      # so schnell wackelt er beim Laufen hin und her
const WACKEL_WINKEL = 0.15   # so weit, in Radiant (0.15 sind etwa 9 Grad)
const MAX_LEBEN = 100.0
const SCHADEN = 10.0      # so viel Leben kostet ein Gegner pro Sekunde, solange er den Held berührt
const UPGRADES = ["Noch ein Messer", "Schneller werfen", "Schärfere Messer", "Großer Magnet", "Heiltrank", "Flinke Füße"]

var lauf_zeit := 0.0
var leben := MAX_LEBEN
var erfahrung := 0
var level := 1
var naechstes_level := 5   # so viel Erfahrung braucht das nächste Level
var tempo := STARTTEMPO


func _physics_process(delta: float) -> void:
	var richtung := Input.get_vector("links", "rechts", "hoch", "runter")
	velocity = richtung * tempo
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

	# Wie viele Gegner berühren mich gerade?
	var treffer: int = $Trefferzone.get_overlapping_bodies().size()
	if treffer > 0:
		leben -= treffer * SCHADEN * delta
		$Lebensbalken.value = leben
		if leben <= 0:
			get_tree().reload_current_scene()
	$Bild.modulate = Color(1, 0.4, 0.4) if treffer > 0 else Color.WHITE


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
		"Flinke Füße":
			tempo *= 1.1
