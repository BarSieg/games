extends Node2D

const MAP_VERSATZ_X = 3
const MAP_VERSATZ_Y = 3
const MAP_SPACE_X = 3
const MAP_SPACE_Y = 17
const MAP_RAUM_BREITE = 6
const MAP_RAUM_HOEHE = 4
const MAP_RAUM_ABSTAND = 2

var besucht := {}             # jeder besuchte Raum ist ein Schlüssel
var aktuell := Vector2i.ZERO


# Die Kamera meldet einen Raum: merken und neu malen lassen
func zeigen(raum: Vector2i) -> void:
	aktuell = raum
	besucht[raum] = true
	queue_redraw()
	# $KarteLabel.text = str(raum)


func _draw() -> void:
	for raum in besucht:
		draw_rect(kasten(raum), Color.DARK_GRAY)
	draw_rect(kasten(aktuell), Color.WHITE)


# Wo auf der Karte liegt das Kästchen für diesen Raum?
func kasten(raum: Vector2i) -> Rect2:
	var ecke := Vector2(
		MAP_SPACE_X + (MAP_RAUM_BREITE + MAP_RAUM_ABSTAND) * (raum.x + MAP_VERSATZ_X),
		MAP_SPACE_Y + (MAP_RAUM_HOEHE + MAP_RAUM_ABSTAND) * (raum.y + MAP_VERSATZ_Y))
	return Rect2(ecke, Vector2(MAP_RAUM_BREITE, MAP_RAUM_HOEHE))
