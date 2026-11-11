class_name Schatz
extends Node2D

var art := Gegenstand.Art.SCHLUESSEL


func _draw() -> void:
	Gegenstand.malen(self, art, Vector2.ZERO)


# Über wo einen Schatz aufsteigen lassen, kurz zeigen, verblassen.
# Der Tween kommt zurück, falls noch jemand etwas anhängen will.
static func zeigen(wo: Node2D, was: Gegenstand.Art) -> Tween:
	var schatz: Schatz = load("res://schatz.tscn").instantiate()
	schatz.art = was
	schatz.position = Vector2(0, -4)
	wo.add_child(schatz)
	var tween := schatz.create_tween()
	tween.tween_property(schatz, "position:y", -18.0, 0.5)
	tween.tween_interval(0.6)
	tween.tween_property(schatz, "modulate:a", 0.0, 0.3)
	tween.tween_callback(schatz.queue_free)
	return tween
