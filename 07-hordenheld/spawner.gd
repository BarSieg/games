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
	var held := get_tree().get_first_node_in_group("held") as Node2D
	var gegner := gegner_szenen[randi() % gegner_szenen.size()].instantiate()
	
	# Ein zufälliger Punkt auf einem Kreis um den Held
	var alpha := Vector2.from_angle(randf() * TAU).normalized()
	
	var bx := get_viewport_rect().size.x / 2 # halbe Bildschirm Breite
	var by := get_viewport_rect().size.y / 2 # halbe Bildschirm Höhe
	
	var tx := 100500.0 # Abstand zum Snittpunkt
	var ty := 100500.0 # Abstand zum Snittpunkt

	# wo wird der Richtungsvector den Bildschirmrand horisontal schneiden?
	if alpha.x > 0:
		tx = (bx ) / alpha.x # rechts
	elif alpha.x < 0:
		tx = (-bx  ) / alpha.x #links

	# wo wird der Richtungsvector den Bildschirmrand vertical schneiden?
	if alpha.y > 0:
		ty = (by ) / alpha.y # unten
	elif alpha.y < 0:
		ty = (-by ) / alpha.y # oben

	# nehme den nächsten Schnittpunkt + Abstand hinter dem Bildschirmrand
	gegner.position = held.global_position + (min(tx, ty) + ABSTAND) * alpha
	#prints(alpha, held.global_position, get_viewport_rect().size, tx, ty, gegner.position, versatz.length())
	add_child(gegner)
