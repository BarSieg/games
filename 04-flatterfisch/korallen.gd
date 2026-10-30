extends Area2D

signal durchschwommen

const SPEED = 150.0  # Pixel pro Sekunde nach links

func _process(delta):
	position.x -= SPEED * delta
	# ganz links raus? Dann weg damit
	if position.x < -50:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("sterben"):
		body.sterben()


func _on_punktezone_body_entered(body: Node2D) -> void:
	durchschwommen.emit()
