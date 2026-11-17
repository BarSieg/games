extends Control

# Der Abspann: wie lange, wie gründlich, wie oft gestorben


func _ready() -> void:
	var text := ""
	if Spielstand.iron_man:
		text += "Ultimative Herausforderung geschafft!\n" 
		var platzierung := Spielstand.ironman_platzierung + 1
		if platzierung <= Spielstand.REKORDE_ANZAHL:
			text += "Platz %d in der Bestenliste!\n" % platzierung
		else:
			text += "Aber die anderen waren schneller als du...\n"
		text += "\nDie Liste der schnellsten Helden:\n"
		var rekorde := Spielstand.rekorde_laden()
		var rekorde_sekunden: Array = rekorde.map(func(x): return x / 1000.0)
		for i in rekorde.size():
			if i == Spielstand.ironman_platzierung:
				text += "[pulse freq=4.0 color=#b89800]%d. %s[/pulse]\n" % [i+1, Spielstand.formatiere_spielzeit(rekorde_sekunden[i])]
			else:
				text += "%d. %s\n" % [i+1, Spielstand.formatiere_spielzeit(rekorde_sekunden[i])]
	else:
		text += "Zeit: %s\nErkundet: %d %%\n" % [Spielstand.formatiere_spielzeit(), Spielstand.erkundet()]
		text += "Gestorben: %d-mal" % Spielstand.gestorben
		if Spielstand.erkundet() < 100:
			text += "\n\nDa fehlt noch was ...\nMit \"Weiter\" suchst du es."
	$Ergebnis.text = text


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("angriff"):
		get_tree().change_scene_to_file("res://titel.tscn")
