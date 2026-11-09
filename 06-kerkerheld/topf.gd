extends StaticBody2D

@export var bewohnt := false


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	zerbrechen()


# Kurz plattdrücken, dann weg
func zerbrechen() -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.06, true, false, true).timeout
	Engine.time_scale = 1.0
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_property($Bild, "scale", Vector2(1.5, 0.2), 0.1)
	tween.tween_property($Bild, "visible", false, 0.0)
	tween.tween_property($Scherben, "emitting", true, 0.0)
	if bewohnt:
		tween.tween_property($Bild, "frame", 122, 0.0)
		tween.tween_property($Bild, "scale", Vector2(0.33, 0.33), 0.0)
		tween.tween_property($Bild, "visible", true, 0.0)
		tween.tween_callback($Bewohner.play).set_delay(0)
		tween.tween_property($Bild, "position:y", $Bild.position.y + 224, 1.0)
	else:
		tween.tween_property($Bild, "visible", false, 1.0)
	await tween.finished
	queue_free()
