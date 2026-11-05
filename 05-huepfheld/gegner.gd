extends CharacterBody2D


const SPEED = 30.0

var direction := -1.0   # startet nach links, dem Held entgegen


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = direction * SPEED
	move_and_slide()

	# An einer Wand umdrehen
	if is_on_wall():
		direction = -direction
	$Bild.flip_h = direction > 0


func plattmachen() -> void:
	$Bild.play("platt")
	set_physics_process(false)                   # nicht mehr laufen
	$Treffer.set_deferred("monitoring", false)   # nicht noch einmal treffen
	await get_tree().create_timer(0.5).timeout
	queue_free()


func _on_treffer_body_entered(body: Node2D) -> void:
	# Von oben drauf: platt. Sonst hat der Held verloren.
	if body.velocity.y > 0 and body.global_position.y < global_position.y:
		plattmachen()
		body.abprallen()
	else:
		body.sterben()
