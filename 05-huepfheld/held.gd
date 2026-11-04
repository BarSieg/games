extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -376.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Runtergefallen
	if position.y > 224:
		position.x = 44
		position.y = 135
		velocity = Vector2(0, 0)

	# Handle jump.
	if Input.is_action_just_pressed("springen") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("links", "rechts")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
