extends Node2D

const KORALLEN = preload("res://korallen.tscn")
const GAP_MIN_Y = 150.0  # höchste Lage der Lücke
const GAP_MAX_Y = 490.0  # tiefste Lage der Lücke
const PAUSE_BLINKS_PER_SECOND = 5
const SAVE_PATH = "user://highscore.cfg"
const KORALLEN_SPEED = 150.0
const KORALLEN_SPEED_DELTA = 5.0
const KORALLEN_SPEED_MAX = 210.0

var lastHeight = (GAP_MIN_Y + GAP_MAX_Y) / 2

var kann_neustarten = false
var punkte = 0
var highscore = 0

func _on_korallen_timer_timeout():
	var korallen = KORALLEN.instantiate()
	korallen.speed = clamp(KORALLEN_SPEED + (punkte / 10) * KORALLEN_SPEED_DELTA, 0, KORALLEN_SPEED_MAX)
	var newHeight = clamp(randf_range(GAP_MIN_Y, GAP_MAX_Y), lastHeight - 150, lastHeight + 150)
	korallen.position = Vector2(400, newHeight)
	lastHeight = newHeight
	add_child(korallen)
	korallen.durchschwommen.connect(_on_durchschwommen)

func _ready():
	$Fisch.gestorben.connect(_on_fisch_gestorben)
	highscore = lade_highscore()

func getMedal():
	var medal = ""
	match punkte:
		var s when s >= 40:
			medal = "🥇"
		var s when s >= 20:
			medal = "🥈"
		var s when s >= 10:
			medal = "🥉"
	return medal

func _on_fisch_gestorben() -> void:
	$KorallenTimer.stop()
	get_tree().call_group("korallen", "set_process", false)
	if punkte > highscore:
		highscore = punkte
		speichere_highscore()
		$CanvasLayer/GameOverLabel.text = "GAME OVER\n%s\nPunkte: %d\nNeuer Rekord!\n\nLeertaste: nochmal" % [getMedal(), punkte]
	else:
		$CanvasLayer/GameOverLabel.text = "GAME OVER\n%s\nPunkte: %d\nRekord: %d\n\nLeertaste: nochmal" % [getMedal(), punkte, highscore]
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

func _on_durchschwommen():
	if $Fisch.tot:
		return  # ein toter Fisch, der durch die Zone fällt, bekommt keine Punkte
	punkte += 1
	$CanvasLayer/PunkteLabel.text = str(punkte)

func lade_highscore():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		return config.get_value("spiel", "highscore", 0)
	return 0  # noch keine Datei (erster Start) oder nicht lesbar

func speichere_highscore():
	var config = ConfigFile.new()
	config.set_value("spiel", "highscore", highscore)
	config.save(SAVE_PATH)
