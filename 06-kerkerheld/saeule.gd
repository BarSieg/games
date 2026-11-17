extends StaticBody2D

@export var map_frame: int = 7

func _ready() -> void:
	$Bild.frame = map_frame
