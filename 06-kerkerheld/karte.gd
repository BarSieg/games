extends Node2D

const MAP_VERSATZ_X = 2
const MAP_VERSATZ_Y = 4
const MAP_SPACE_X = 3
const MAP_SPACE_Y = 18
const MAP_RAUM_BREITE = 6
const MAP_RAUM_HOEHE = 4
const MAP_RAUM_ABSTAND = 2
const DOOR_PIXELS = 2

var besucht := Spielstand.besucht   # dasselbe Dictionary wie im Spielstand, keine Kopie
var aktuell := Vector2i.ZERO
var alle_raeume := {}         # jeder Raum, in dem eine Wandkachel liegt
var geheime_raeume := {}      # diese Räume erscheinen erst auf der Karte, wenn man sie betreten hat


func _ready() -> void:
	# Welche Räume gibt es? Jede Wandkachel verrät ihren Raum.
	for zelle in %Waende.get_used_cells():
		alle_raeume[Vector2i((Vector2(zelle) / Vector2(16, 11)).floor())] = true
	Spielstand.inventar_geaendert.connect(queue_redraw)
	# Geheime Räume merken: In jedem liegt ein Marker aus der Gruppe secrets
	for geheimnis in get_tree().get_nodes_in_group("secrets"):
		geheime_raeume[%Camera2D.raum_von(geheimnis.global_position)] = true


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
			# aber die geheimen nicht!
			if not raum in geheime_raeume:
				draw_rect(kasten(raum), Color(0.25, 0.25, 0.25))
				pruefe_tueren(raum)
	for raum in besucht:
		draw_rect(kasten(raum), Color.DARK_GRAY)
		pruefe_tueren(raum)
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


# Für jeden Raum reicht es, zwei Richtungen zu prüfen: Süden und Osten
func pruefe_tueren(raum: Vector2i) -> void:
	var nachbarraum := raum + Vector2i(0, 1)
	var doorfarbe := Color.DARK_GRAY if nachbarraum in besucht and raum in besucht else Color(0.25, 0.25, 0.25)
	if (nachbarraum in besucht) or ((Spielstand.anzahl(Gegenstand.Art.KARTE) > 0) and (raum in alle_raeume) and (not raum in geheime_raeume)):
		if (
			(
			   %Waende.get_cell_source_id(Vector2i(nachbarraum.x * 16 + 7, nachbarraum.y * 11)) == -1
			   and %Waende.get_cell_source_id(Vector2i(nachbarraum.x * 16 + 7, nachbarraum.y * 11 - 1)) == -1
			)
			or
			(
			   %Waende.get_cell_source_id(Vector2i(nachbarraum.x * 16 + 2, nachbarraum.y * 11)) == -1
			   and %Waende.get_cell_source_id(Vector2i(nachbarraum.x * 16 + 2, nachbarraum.y * 11 - 1)) == -1
			)
			):
			draw_rect(tuer_kasten(raum, true), doorfarbe)
	nachbarraum = raum + Vector2i(1, 0)
	doorfarbe = Color.DARK_GRAY if nachbarraum in besucht and raum in besucht else Color(0.25, 0.25, 0.25)
	if (nachbarraum in besucht) or ((Spielstand.anzahl(Gegenstand.Art.KARTE) > 0) and (raum in alle_raeume) and (not raum in geheime_raeume)):
		if (
			(
			   %Waende.get_cell_source_id(Vector2i(nachbarraum.x * 16, nachbarraum.y * 11 + 4)) == -1
			   and %Waende.get_cell_source_id(Vector2i(nachbarraum.x * 16 - 1, nachbarraum.y * 11 + 4)) == -1
			)
			or
			(
			   %Waende.get_cell_source_id(Vector2i(nachbarraum.x * 16, nachbarraum.y * 11 + 8)) == -1
			   and %Waende.get_cell_source_id(Vector2i(nachbarraum.x * 16 - 1, nachbarraum.y * 11 + 8)) == -1
			)
			):
			draw_rect(tuer_kasten(raum, false), doorfarbe)


# Wo auf der Karte liegt das Kästchen für die Tür nach Süden oder Osten?
func tuer_kasten(raum: Vector2i, vertical: bool) -> Rect2:
	var ecke := Vector2.ZERO
	if vertical:
		ecke = Vector2(
			MAP_SPACE_X + (MAP_RAUM_BREITE + MAP_RAUM_ABSTAND) * (raum.x + MAP_VERSATZ_X) + int((MAP_RAUM_BREITE - DOOR_PIXELS) / 2.0),
			MAP_SPACE_Y + (MAP_RAUM_HOEHE + MAP_RAUM_ABSTAND) * (raum.y + MAP_VERSATZ_Y) + MAP_RAUM_HOEHE)
	else:
		ecke = Vector2(
			MAP_SPACE_X + (MAP_RAUM_BREITE + MAP_RAUM_ABSTAND) * (raum.x + MAP_VERSATZ_X) + MAP_RAUM_BREITE,
			MAP_SPACE_Y + (MAP_RAUM_HOEHE + MAP_RAUM_ABSTAND) * (raum.y + MAP_VERSATZ_Y) + int((MAP_RAUM_HOEHE - DOOR_PIXELS) / 2.0))
	return Rect2(ecke, Vector2(DOOR_PIXELS, DOOR_PIXELS))
