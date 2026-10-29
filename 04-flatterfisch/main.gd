extends Node2D

const KORALLEN = preload("res://korallen.tscn")
const GAP_MIN_Y = 150.0  # höchste Lage der Lücke
const GAP_MAX_Y = 490.0  # tiefste Lage der Lücke

func _on_korallen_timer_timeout():
	var korallen = KORALLEN.instantiate()
	korallen.position = Vector2(400, randf_range(GAP_MIN_Y, GAP_MAX_Y))
	add_child(korallen)
