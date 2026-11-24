extends CanvasLayer

var held: Held
var uhr: Uhr


func _ready() -> void:
	hide()
	held = get_tree().get_first_node_in_group("held")
	uhr = get_tree().get_first_node_in_group("uhr")
	held.gestorben.connect(zeigen.bind("Game Over"))
	uhr.abgelaufen.connect(zeigen.bind("Gewonnen!"))


func zeigen(titel: String) -> void:
	$Kasten/Titel.text = titel
	$Kasten/Werte.text = "Überlebt: %s   Level: %d" % [uhr.als_text(uhr.zeit), held.level]
	show()
	get_tree().paused = true


func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ok"):
		get_tree().paused = false
		get_tree().reload_current_scene()
