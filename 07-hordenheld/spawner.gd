extends Node2D

const ABSTAND = 240.0   # so weit vom Held entsteht ein Gegner, knapp außerhalb vom Bild
const START_TAKT = 1.0  # am Anfang eine Sekunde zwischen zwei Gegnern
const MIN_TAKT = 0.1    # schneller wird es nicht: zehn Gegner pro Sekunde
const SCHNELLER = 0.97  # nach jedem Gegner wird der Takt 3 % kürzer

@export var gegner_szene: PackedScene

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
	var gegner := gegner_szene.instantiate()
	# Ein zufälliger Punkt auf einem Kreis um den Held
	gegner.position = held.global_position + Vector2.from_angle(randf() * TAU) * ABSTAND
	add_child(gegner)
