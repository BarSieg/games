extends CharacterBody2D


const SPEED = 30.0

var direction := -1.0   # startet nach links, dem Held entgegen
@export var kantenerkennung = false


func umdrehen() -> void:
	direction = -direction
	$Kante.position.x = 12 * sign(direction)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = direction * SPEED
	move_and_slide()

	# An einer Wand umdrehen
	if is_on_wall():
		umdrehen()
	$Bild.flip_h = direction > 0
	
	if kantenerkennung and not $Kante.is_colliding():
		umdrehen()


func plattmachen() -> void:
	$Bild.play("platt")
	set_physics_process(false)                   # nicht mehr laufen
	$Treffer.set_deferred("monitoring", false)   # nicht noch einmal treffen
	await get_tree().create_timer(0.5).timeout
	queue_free()


func _on_treffer_body_entered(body: Node2D) -> void:
	# Auf einen anderen Gegner getroffen
	if body.has_node("Kante"):
		pass #umdrehen()
	# Vom Helden getroffen. Von oben drauf: platt. Sonst hat der Held verloren.
	elif body.velocity.y > 0 and body.global_position.y < global_position.y:
		plattmachen()
		body.abprallen()
	else:
		body.sterben()
