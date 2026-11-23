extends Node2D

const ABSTAND = 20.0   # so weit vom Bildrand spawnen die Gegner
const START_TAKT = 1.0  # am Anfang eine Sekunde zwischen zwei Gegnern
const MIN_TAKT = 0.1    # schneller wird es nicht: zehn Gegner pro Sekunde
const SCHNELLER = 0.97  # nach jedem Gegner wird der Takt 3 % kürzer

@export var gegner_szenen: Array[PackedScene]

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
	var gegner := gegner_szenen[randi() % gegner_szenen.size()].instantiate()

	# Eine zufällige Richtung von der Bildmitte aus
	var alpha := Vector2.from_angle(randf() * TAU)

	var bx := get_viewport_rect().size.x / 2   # halbe Bildschirmbreite
	var by := get_viewport_rect().size.y / 2   # halbe Bildschirmhöhe

	var tx := INF   # Abstand zum Schnittpunkt
	var ty := INF   # Abstand zum Schnittpunkt

	# Wo schneidet die Richtung den linken oder rechten Bildschirmrand?
	if alpha.x > 0:
		tx = bx / alpha.x    # rechts
	elif alpha.x < 0:
		tx = -bx / alpha.x   # links

	# Wo schneidet die Richtung den oberen oder unteren Bildschirmrand?
	if alpha.y > 0:
		ty = by / alpha.y    # unten
	elif alpha.y < 0:
		ty = -by / alpha.y   # oben

	# Den näheren Schnittpunkt nehmen, plus ABSTAND hinter den Bildschirmrand
	gegner.position = get_viewport().get_camera_2d().get_screen_center_position() + (minf(tx, ty) + ABSTAND) * alpha
	add_child(gegner)
