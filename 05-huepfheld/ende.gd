extends Control


var bereit := false   # erst nach einer Sekunde, sonst springt man versehentlich weiter


func _ready() -> void:
	$VBoxContainer/Meldung.text = Spielstand.meldung
	$VBoxContainer/Muenzen.text = "MUENZEN  %02d" % Spielstand.muenzen
	$VBoxContainer/Hinweis.modulate.a = 0.0   # unsichtbar, nimmt aber schon Platz ein
	await get_tree().create_timer(1.0).timeout
	bereit = true
	$VBoxContainer/Hinweis.modulate.a = 1.0


func _unhandled_input(event: InputEvent) -> void:
	if bereit and event.is_action_pressed("springen"):
		Spielstand.neues_spiel()
		get_tree().change_scene_to_file("res://level.tscn")
