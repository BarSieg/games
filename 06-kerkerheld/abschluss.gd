extends Control

# Der Abspann: wie lange, wie gründlich, wie oft gestorben


func _ready() -> void:
	var text := "Zeit: %s\nErkundet: %d %%\n" % [Spielstand.zeit_text(Spielstand.spielzeit), Spielstand.erkundet()]
	if Spielstand.iron_man:
		text += "Kein einziges Mal gestorben!"
	else:
		text += "Gestorben: %d-mal" % Spielstand.gestorben
		if Spielstand.erkundet() < 100:
			text += "\n\nDa fehlt noch was ...\nMit \"Weiter\" suchst du es."
	$Ergebnis.text = text


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("angriff"):
		get_tree().change_scene_to_file("res://titel.tscn")
