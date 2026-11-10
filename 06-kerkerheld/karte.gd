extends Node2D

const MAP_VERSATZ_X = 2
const MAP_VERSATZ_Y = 4
const MAP_SPACE_X = 3
const MAP_SPACE_Y = 18
const MAP_RAUM_BREITE = 6
const MAP_RAUM_HOEHE = 4
const MAP_RAUM_ABSTAND = 2

var besucht := {}             # jeder besuchte Raum ist ein Schlüssel
var aktuell := Vector2i.ZERO
var alle_raeume := {}         # jeder Raum, in dem eine Wandkachel liegt


func _ready() -> void:
	# Welche Räume gibt es? Jede Wandkachel verrät ihren Raum.
	for zelle in %Waende.get_used_cells():
		alle_raeume[Vector2i((Vector2(zelle) / Vector2(16, 11)).floor())] = true
	Spielstand.inventar_geaendert.connect(queue_redraw)


# Die Kamera meldet einen Raum: merken und neu malen lassen
func zeigen(raum: Vector2i) -> void:
	aktuell = raum
	besucht[raum] = true
	queue_redraw()
	# $KarteLabel.text = str(raum)


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


# Wo auf der Karte liegt das Kästchen für diesen Raum?
func kasten(raum: Vector2i) -> Rect2:
	var ecke := Vector2(
		MAP_SPACE_X + (MAP_RAUM_BREITE + MAP_RAUM_ABSTAND) * (raum.x + MAP_VERSATZ_X),
		MAP_SPACE_Y + (MAP_RAUM_HOEHE + MAP_RAUM_ABSTAND) * (raum.y + MAP_VERSATZ_Y))
	return Rect2(ecke, Vector2(MAP_RAUM_BREITE, MAP_RAUM_HOEHE))
