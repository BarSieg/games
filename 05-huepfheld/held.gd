extends CharacterBody2D


const SPEED = 100.0
const RUN_SPEED = 160.0
const JUMP_VELOCITY = -376.0
const MIN_JUMP_VELOCITY = -188.0  # kürzester Sprung, etwa 1 Kachel
const JUMP_CUT = 0.4              # Taste früh losgelassen: restlichen Schwung kürzen
const FALL_GRAVITY_FACTOR = 1.7   # beim Fallen stärker nach unten ziehen
const MAX_FALL_SPEED = 300.0
const FALL_LIMIT = 224            # tiefer als das: runtergefallen
const ACCELERATION = 600.0        # am Boden loslaufen
const FRICTION = 800.0            # am Boden abbremsen
const AIR_ACCELERATION = 400.0    # in der Luft lenken
const AIR_FRICTION = 150.0        # in der Luft fast keine Bremse: der Schwung bleibt
const COYOTE_TIME = 0.1           # so lange nach der Kante darf man noch springen
const JUMP_BUFFER = 0.1           # so lange wird ein zu früher Sprung gemerkt
const TURN_ACCELERATION = 1200.0  # beim Umdrehen am Boden stärker bremsen
const CAMERA_OFFSET_X = 54.0      # so weit schaut die Kamera voraus
const CAMERA_TURN_SPEED = 60.0    # Pixel pro Sekunde, die die Kamera umschwenkt

var start_position: Vector2
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var camera_target_x := CAMERA_OFFSET_X


func _ready() -> void:
	start_position = position
	$Camera2D.reset_smoothing()


# Welche Animation passt gerade?
func update_animation() -> void:
	if not is_on_floor():
		if velocity.y < 0:
			$Bild.play("springen")
		else:
			$Bild.play("fallen")
	elif abs(velocity.x) > 5:
		$Bild.play("laufen")
	else:
		$Bild.play("stehen")

func _physics_process(delta: float) -> void:
	# Coyote Time: Am Boden wird der Zähler voll, in der Luft läuft er ab
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

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
		$Camera2D.limit_left = 0
		$Camera2D.reset_smoothing()
		$Camera2D.align()

	# Jump Buffering: Ein Tastendruck gilt noch kurze Zeit
	if Input.is_action_just_pressed("springen"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer -= delta

	# Springen, wenn beides passt: Taste gerade gedrückt, Boden gerade unter den Füßen
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		if not Input.is_action_pressed("springen"):
			velocity.y = MIN_JUMP_VELOCITY   # losgelassen noch vor der Landung
		jump_buffer_timer = 0
		coyote_timer = 0
		$SprungTon.play()
	if Input.is_action_just_released("springen") and velocity.y < 0:
		velocity.y *= JUMP_CUT

	# Laufen: Die Geschwindigkeit nähert sich dem Ziel, statt zu springen
	var direction := Input.get_axis("links", "rechts")
	var max_speed := RUN_SPEED if Input.is_action_pressed("rennen") else SPEED
	var accel: float
	if direction:
		accel = TURN_ACCELERATION if is_on_floor() and direction * velocity.x < 0 else ACCELERATION if is_on_floor() else AIR_ACCELERATION
		$Bild.flip_h = direction < 0
		camera_target_x = CAMERA_OFFSET_X * sign(direction)
	else:
		accel = FRICTION if is_on_floor() else AIR_FRICTION
	velocity.x = move_toward(velocity.x, direction * max_speed, accel * delta)

	# Kein Zurück für die Kamera
	$Camera2D.limit_left = max($Camera2D.limit_left, $Camera2D.get_screen_center_position().x - 192)


	$Camera2D.position.x = move_toward($Camera2D.position.x, camera_target_x, CAMERA_TURN_SPEED * delta)

	move_and_slide()
	update_animation()
	
	# Kein Zurück für den Helden
	if position.x < $Camera2D.limit_left + 9:
		position.x = $Camera2D.limit_left + 9
		velocity.x = 0
	
	$Debug.text = "%d %d" % [velocity.x, velocity.y]
