extends Label

var held: Held


func _ready() -> void:
	held = get_tree().get_first_node_in_group("held")


func _process(_delta: float) -> void:
	var physik := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000
	text = "Level %d   Gegner: %d   FPS: %d   Physik: %.1f ms" % [held.level, get_tree().get_node_count_in_group("gegner"), Engine.get_frames_per_second(), physik]
	if held.testmodus:
		text += "   TESTMODUS"
