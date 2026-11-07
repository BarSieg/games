extends CharacterBody2D


const SPEED = 30.0
const FALL_LIMIT = 224          # tiefer als das: in ein Loch gefallen
const LEFT_MAX_DISTANZ = 180    # 10 Kacheln hinter dem linken Bildrand
const JUMP_VELOCITY = -190.0    # beim Sterben hochspringen

var direction := -1.0   # startet nach links, dem Held entgegen
@export var kantenerkennung := false


func _ready() -> void:
	set_physics_process(false)   # warten, bis der Gegner ins Bild kommt


func umdrehen() -> void:
	direction = -direction
	$Kante.position.x = 12 * sign(direction)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = direction * SPEED
	move_and_slide()

	# An einer Wand umdrehen, aber nur, wenn sie vorne ist
	if is_on_wall() and get_wall_normal().x * direction < 0:
		umdrehen()
	$Bild.flip_h = direction > 0

	if kantenerkennung and is_on_floor() and not $Kante.is_colliding():
		umdrehen()

	# Runtergefallen...
	if position.y > FALL_LIMIT:
		queue_free()

	# Weit links hinter dem Bild: weg für immer
	var camera := get_viewport().get_camera_2d()
	if global_position.x + (get_viewport_rect().size.x / 2) + LEFT_MAX_DISTANZ < camera.get_screen_center_position().x:
		queue_free()

	# Steckt der Held in mir? Jedes Bild pruefen, nicht nur beim ersten Kontakt
	if $Treffer.monitoring:
		for body in $Treffer.get_overlapping_bodies():
			treffer(body)


func plattmachen() -> void:
	$Bild.play("platt")
	$Treffer.set_deferred("monitoring", false)   # nicht noch einmal treffen
	# Fliegt weg, wird vom FALL_LIMIT aufgeräumt
	velocity.x = SPEED
	velocity.y = JUMP_VELOCITY
	collision_mask = 0
	collision_layer = 0


func treffer(body: Node2D) -> void:
	# Von oben drauf: platt. Sonst hat der Held verloren.
	if body.velocity.y > 0 and body.global_position.y < global_position.y:
		plattmachen()
		body.abprallen()
	else:
		body.getroffen()


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	set_physics_process(true)    # ab jetzt läuft er, auch außerhalb des Bildes
