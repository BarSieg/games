extends Label

var held: Held


func _ready() -> void:
	held = get_tree().get_first_node_in_group("held")


func _process(_delta: float) -> void:
	text = "Level %d   Gegner: %d   FPS: %d" % [held.level, get_tree().get_node_count_in_group("gegner"), Engine.get_frames_per_second()]
