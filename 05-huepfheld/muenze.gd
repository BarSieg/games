extends Area2D


var aus_block := false   # vom Block ausgeschlagen statt im Level liegend


func _ready() -> void:
	if aus_block:
		monitoring = false   # kann nicht noch einmal eingesammelt werden
		hochspringen(40)


func _on_body_entered(body: Node2D) -> void:
	body.muenze_einsammeln()
	set_deferred("monitoring", false)
	hochspringen(16)


# Hochfliegen, ein Stück zurückfallen, verschwinden
func hochspringen(hoehe: float) -> void:
	var start := position.y
	var tween := create_tween()
	tween.tween_property(self, "position:y", start - hoehe, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", start - hoehe / 2, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(queue_free)
