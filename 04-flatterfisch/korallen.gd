extends Area2D

const SPEED = 150.0  # Pixel pro Sekunde nach links

func _process(delta):
	position.x -= SPEED * delta
	# ganz links raus? Dann weg damit
	if position.x < -50:
		queue_free()
