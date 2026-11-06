extends CharacterBody2D

const SPEED = 40.0

var direction := 1.0   # läuft nach rechts aus dem Block


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = direction * SPEED
	move_and_slide()

	# An einer Wand umdrehen, wie der Gegner
	if is_on_wall() and get_wall_normal().x * direction < 0:
		direction = -direction


func _on_einsammeln_body_entered(body: Node2D) -> void:
	body.power_up()
	queue_free()
