extends Area2D

@export var schaden := 1
@export var takt := 0.5   # alle so viele Sekunden brennt er

var warten := 0.0
var zeit := 0.0


func _physics_process(delta: float) -> void:
	warten -= delta
	if warten > 0:
		return
	warten = takt
	for gegner: Node2D in get_overlapping_bodies():
		gegner.treffer(schaden)


func _process(delta: float) -> void:
	zeit += delta
	queue_redraw()


func _draw() -> void:
	var radius: float = $CollisionShape2D.shape.radius
	var flackern := 0.8 + 0.2 * sin(zeit * 8.0)
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.3, 0.0, 0.3 * flackern))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1.0, 0.8, 0.2, flackern))
