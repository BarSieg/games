extends CanvasLayer

const GEWONNEN = "Gewonnen!"
const VERLOREN = "Game Over"
const DATEI = "user://hordenheld.cfg"
const TITEL = "res://titel.tscn"

var held: Held
var uhr: Uhr
var rekord := 0


func _ready() -> void:
	hide()
	held = get_tree().get_first_node_in_group("held")
	uhr = get_tree().get_first_node_in_group("uhr")
	held.gestorben.connect(zeigen.bind(VERLOREN))
	uhr.abgelaufen.connect(zeigen.bind(GEWONNEN))
	laden()


func speichern() -> void:
	var datei := ConfigFile.new()
	datei.set_value("hordenheld", "kills", rekord)
	datei.save(DATEI)


func laden() -> void:
	var datei := ConfigFile.new()
	if datei.load(DATEI) != OK:
		return
	rekord = datei.get_value("hordenheld", "kills", 0)


func zeigen(titel: String) -> void:
	Musik.stoppen()
	var kills: int = $"../Horde".kills
	if titel == GEWONNEN:
		if kills > rekord:
			rekord = kills
			speichern()
		await get_tree().create_timer(2.0, false).timeout   # Explosion abwarten
	$Kasten/Titel.text = titel
	$Kasten/Werte.text = "Überlebt: %s\nLevel: %d\nMonster getötet: %d\nRekord: %d Monster" % [uhr.als_text(uhr.zeit), held.level, kills, rekord]
	show()
	get_tree().paused = true


func _process(_delta: float) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("ok"):
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("pause"):
		get_tree().paused = false
		get_tree().change_scene_to_file(TITEL)
