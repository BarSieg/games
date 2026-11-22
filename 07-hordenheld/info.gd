extends Label


func _process(_delta: float) -> void:
	text = "Gegner: %d   FPS: %d" % [get_tree().get_node_count_in_group("gegner"), Engine.get_frames_per_second()]
