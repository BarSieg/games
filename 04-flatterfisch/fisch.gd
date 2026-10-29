extends CharacterBody2D

signal gestorben  # Nachricht an alle, die zuhören
signal gestartet

var tot = false
var los = false

@export var gravity = 1400.0  # Pixel pro Sekunde², zieht nach unten
const FLAP_SPEED = -400.0  # Tempo direkt nach einem Flossenschlag (negativ = nach oben)
const TOP_BORDER = 42

func _physics_process(delta):
	velocity.y += gravity * delta
	if tot:
		rotation = move_toward(rotation, PI / 2, 5 * delta)
		move_and_slide()
		return
	if position.y > 660:
		sterben()
	if (position.y < TOP_BORDER):
		position.y = TOP_BORDER
		velocity.y = 0
	if (velocity.y > 0 && los):
		rotation = clamp(rotation + PI / 36, -PI / 12, PI / 12)
	if (!los):
		if Input.is_action_just_pressed("flap"):
			los = true
			gestartet.emit()
		else:
			velocity.y = 0
	if Input.is_action_just_pressed("flap"):
		velocity.y = FLAP_SPEED
		rotation = -PI / 12
	move_and_slide()

func sterben():
	if tot:
		return  # wer schon tot ist, stirbt nicht noch mal
	tot = true
	los = false
	gestorben.emit()
