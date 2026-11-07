extends Control


const WELT = "1-1"


func _ready() -> void:
	$VBoxContainer/Welt.text = "Welt " + WELT
	$VBoxContainer/Leben.text = "     x  %d" % Spielstand.leben
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://level.tscn")
