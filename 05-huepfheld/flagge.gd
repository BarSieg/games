extends AnimatedSprite2D


const TOP_Y = 45
const BOTTOM_Y = 171


func _on_held_flagge_hochziehen(hoehe: float) -> void:
	position.y = clamp(BOTTOM_Y - hoehe, TOP_Y, BOTTOM_Y)
	if position.y == TOP_Y:
		$Salut.emitting = true
