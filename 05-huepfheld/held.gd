extends CharacterBody2D


const SPEED = 100.0
const RUN_SPEED = 160.0
const JUMP_VELOCITY = -376.0      # 4 Kacheln
const BOUNCE_VELOCITY = -420.0    # 5 Kacheln
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
const BRAKE_SHOW_TIME = 0.15      # so lange bleibt das Bremsbild mindestens stehen
const STOMP_BOUNCE = -220.0       # so hoch prallt der Held vom Gegner ab
const INVINCIBLE_TIME = 1.5       # so lange ist der Held nach einem Treffer unverwundbar

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var camera_target_x := CAMERA_OFFSET_X
var prev_is_on_floor := true
var brake_timer := 0.0
var tot := false
var stark := false
var unverwundbar := 0.0
var im_ziel := false


func _ready() -> void:
	$Camera2D.reset_smoothing()


# Welche Animation passt gerade?
func update_animation(direction: float) -> void:
	if not is_on_floor():
		if velocity.y < 0:
			$Bild.play("springen")
		else:
			$Bild.play("fallen")
	elif direction * velocity.x < 0 and abs(velocity.x) > 60:
		brake_timer = BRAKE_SHOW_TIME
		$Bild.play("bremsen")
	elif brake_timer > 0:
		$Bild.play("bremsen")
	elif abs(velocity.x) > 5:
		$Bild.play("laufen")
	else:
		$Bild.play("stehen")


# Ein Gegner ist erledigt
func plopp(hoehe := 1.0) -> void:
	$GegnerPlopp.pitch_scale = hoehe
	$GegnerPlopp.play()


# Auf einen Gegner gesprungen: hochfedern
func abprallen() -> void:
	if Input.is_action_pressed("springen"):
		velocity.y = BOUNCE_VELOCITY
	else:
		velocity.y = STOMP_BOUNCE
	plopp()


# Power-up eingesammelt
func power_up() -> void:
	stark = true
	$Bild.modulate = Color(1, 0.8, 0.3)   # golden
	$PowerUp.play()


# Von einem Gegner erwischt
func getroffen() -> void:
	if unverwundbar > 0 or im_ziel:
		return
	$Schaden.play()
	if stark:
		stark = false
		$Bild.modulate = Color.WHITE
		unverwundbar = INVINCIBLE_TIME
	else:
		sterben()


# Erwischt: Level von vorn
func sterben() -> void:
	if not tot:
		tot = true
		velocity.x = 0
		velocity.y = JUMP_VELOCITY
		collision_mask = 0
		collision_layer = 0
		await get_tree().create_timer(1.5).timeout
		Spielstand.leben -= 1
		if Spielstand.leben > 0:
			get_tree().reload_current_scene()
		else:
			Spielstand.meldung = "GAME OVER"
			get_tree().change_scene_to_file("res://ende.tscn")


func _physics_process(delta: float) -> void:
	var gravity := get_gravity()
	if im_ziel or tot:
		velocity += gravity * delta
		move_and_slide()
		return

	# Coyote Time: Am Boden wird der Zähler voll, in der Luft läuft er ab
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	brake_timer -= delta

	# Nach einem Treffer kurz unverwundbar, und blinken
	if unverwundbar > 0:
		unverwundbar -= delta
		$Bild.visible = int(unverwundbar * 10) % 2 == 0
	else:
		$Bild.visible = true

	# Schwerkraft, beim Fallen stärker
	if not is_on_floor():
		if velocity.y > 0:
			gravity *= FALL_GRAVITY_FACTOR
		velocity += gravity * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)

	# Staub beim Landen
	if not prev_is_on_floor and is_on_floor():
		$Staub.restart()
	prev_is_on_floor = is_on_floor()

	# Runtergefallen
	if position.y > FALL_LIMIT:
		sterben()

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
	$Bild.speed_scale = abs(velocity.x) / SPEED

	# Kein Zurück für die Kamera
	var halbe_breite := get_viewport_rect().size.x / 2
	$Camera2D.limit_left = max($Camera2D.limit_left, $Camera2D.get_screen_center_position().x - halbe_breite)
	# Kamera schwenkt langsam in Laufrichtung
	$Camera2D.position.x = move_toward($Camera2D.position.x, camera_target_x, CAMERA_TURN_SPEED * delta)

	move_and_slide()
	update_animation(direction)

	# Kein Zurück für den Helden
	if position.x < $Camera2D.limit_left + 9:
		position.x = $Camera2D.limit_left + 9
		velocity.x = 0


# Eine Muenze eingesammelt
func muenze_einsammeln() -> void:
	Spielstand.muenze_sammeln()
	$MuenzeTon.pitch_scale = randf_range(0.9, 1.1)
	$MuenzeTon.play()


# Ziegel zerschlagen: Scherben fliegen
func ziegel_brechen() -> void:
	$Scherben.restart()


# Die Fahne erreicht: kurz feiern, dann der Ende-Bildschirm
func ziel_erreicht() -> void:
	if im_ziel or tot:
		return
	im_ziel = true
	velocity.x = 0
	$Bild.play("stehen")
	await get_tree().create_timer(3.0).timeout
	Spielstand.meldung = "GESCHAFFT!"
	get_tree().change_scene_to_file("res://ende.tscn")
