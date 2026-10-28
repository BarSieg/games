extends CharacterBody2D

@export var gravity = 1400.0     # Pixel pro Sekunde², zieht nach unten
const FLAP_SPEED = -400.0  # Tempo direkt nach einem Flossenschlag (negativ = nach oben)
const TOP_BORDER = 42

func _physics_process(delta):
	velocity.y += gravity * delta
	if (position.y < TOP_BORDER): 
		position.y = TOP_BORDER
		velocity.y = 0
	if (velocity.y > 0):
		rotation = clamp(rotation + PI / 36, -PI / 12, PI / 12)
	
	if Input.is_action_just_pressed("flap"):
		velocity.y = FLAP_SPEED
		rotation = -PI / 12
	move_and_slide()
