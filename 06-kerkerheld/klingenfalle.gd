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
