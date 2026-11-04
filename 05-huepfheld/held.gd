extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -376.0
const JUMP_CUT = 0.5   # Taste früh losgelassen: restlichen Schwung halbieren
const FALL_GRAVITY_FACTOR = 1.6   # beim Fallen stärker nach unten ziehen
const MAX_FALL_SPEED = 300.0
const FALL_LIMIT = 224   # tiefer als das: runtergefallen

var start_position: Vector2

func _ready() -> void:
	start_position = position

func _physics_process(delta: float) -> void:
	# Schwerkraft, beim Fallen stärker
	if not is_on_floor():
		var gravity := get_gravity()
		if velocity.y > 0:
			gravity *= FALL_GRAVITY_FACTOR
		velocity += gravity * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	# Runtergefallen
	if position.y > FALL_LIMIT:
		position = start_position
		velocity = Vector2.ZERO

	# Handle jump.
	if Input.is_action_just_pressed("springen") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("springen") and velocity.y < 0:
		velocity.y *= JUMP_CUT

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("links", "rechts")
	if direction:
		velocity.x = direction * SPEED
		$Bild.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
