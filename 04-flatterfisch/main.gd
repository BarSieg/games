extends Node2D

const KORALLEN = preload("res://korallen.tscn")
const GAP_MIN_Y = 150.0  # höchste Lage der Lücke
const GAP_MAX_Y = 490.0  # tiefste Lage der Lücke
var lastHeight = (GAP_MIN_Y + GAP_MAX_Y) / 2

var kann_neustarten = false

func _on_korallen_timer_timeout():
	var korallen = KORALLEN.instantiate()
	var newHeight = clamp(randf_range(GAP_MIN_Y, GAP_MAX_Y), lastHeight - 150, lastHeight + 150)
	korallen.position = Vector2(400, newHeight)
	lastHeight = newHeight
	add_child(korallen)


func _on_fisch_gestorben() -> void:
	$KorallenTimer.stop()
	get_tree().call_group("korallen", "set_process", false)
	$CanvasLayer/GameOverLabel.show()
	# kurz warten, damit ein hektischer Tastendruck nicht sofort neu startet
	await get_tree().create_timer(0.8).timeout
	kann_neustarten = true

func _process(_delta):
	if kann_neustarten and Input.is_action_just_pressed("flap"):
		get_tree().reload_current_scene()
