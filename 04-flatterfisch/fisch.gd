extends CharacterBody2D

const GRAVITY = 1200.0     # Pixel pro Sekunde², zieht nach unten
const FLAP_SPEED = -400.0  # Tempo direkt nach einem Flossenschlag (negativ = nach oben)

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("flap"):
		velocity.y = FLAP_SPEED
	move_and_slide()
