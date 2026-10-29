extends Node2D

const KORALLEN = preload("res://korallen.tscn")
const GAP_MIN_Y = 150.0  # höchste Lage der Lücke
const GAP_MAX_Y = 490.0  # tiefste Lage der Lücke
const PAUSE_BLINKS_PER_SECOND = 5
var lastHeight = (GAP_MIN_Y + GAP_MAX_Y) / 2

var kann_neustarten = false

func _on_korallen_timer_timeout():
	var korallen = KORALLEN.instantiate()
	var newHeight = clamp(randf_range(GAP_MIN_Y, GAP_MAX_Y), lastHeight - 150, lastHeight + 150)
	korallen.position = Vector2(400, newHeight)
	lastHeight = newHeight
	add_child(korallen)

func _ready():
	$Fisch.gestorben.connect(_on_fisch_gestorben)

func _on_fisch_gestorben() -> void:
	$KorallenTimer.stop()
	get_tree().call_group("korallen", "set_process", false)
	$CanvasLayer/GameOverLabel.show()
	# kurz warten, damit ein hektischer Tastendruck nicht sofort neu startet
	await get_tree().create_timer(0.8).timeout
	kann_neustarten = true

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
	if (get_tree().paused):
		$CanvasLayer/PauseLabel.visible = (Time.get_ticks_msec() * PAUSE_BLINKS_PER_SECOND / 1000 % 2 == 0)
	else:
		$CanvasLayer/PauseLabel.visible = false
	if kann_neustarten and Input.is_action_just_pressed("flap"):
		get_tree().reload_current_scene()


func _on_fisch_gestartet() -> void:
	$KorallenTimer.start()
