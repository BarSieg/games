extends CharacterBody2D


const SPEED = 80.0
const BESCHLEUNIGUNG = 20.0


func _physics_process(_delta: float) -> void:
	var richtung := Input.get_vector("links", "rechts", "hoch", "runter")
	velocity = velocity.move_toward(richtung * SPEED, BESCHLEUNIGUNG)
	move_and_slide()

	# Nach links und rechts schauen
	if richtung.x != 0:
		$Bild.flip_h = richtung.x < 0
