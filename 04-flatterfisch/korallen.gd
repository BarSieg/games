extends Area2D

signal durchschwommen

var speed = 150.0 # Pixel pro Sekunde nach links

func _process(delta):
	position.x -= speed * delta
	# ganz links raus? Dann weg damit
	if position.x < -50:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("sterben"):
		body.sterben()


func _on_punktezone_body_entered(_body: Node2D) -> void:
	durchschwommen.emit()
