extends CharacterBody2D

# Eine Blase der Kerkerkrabbe: fliegt geradeaus und platzt an der Wand, am Helden oder am Schwert

const TEMPO = 70.0
const RADIUS = 4.0

@export var schaden := 1   # in halben Herzen

var richtung := Vector2.DOWN


func _physics_process(delta: float) -> void:
	if move_and_collide(richtung * TEMPO * delta):
		platzen()


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(0.6, 0.85, 1.0, 0.5))
	draw_arc(Vector2.ZERO, RADIUS, 0, TAU, 16, Color(0.85, 0.95, 1.0))
	draw_rect(Rect2(-2, -2, 1, 1), Color.WHITE)   # ein Glanzpunkt


# Der Held meldet: getroffen
func hat_getroffen() -> void:
	platzen()


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	platzen()


func platzen() -> void:
	queue_free()
