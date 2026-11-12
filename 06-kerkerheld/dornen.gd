extends Area2D

var schaden := 1   # in halben Herzen


# Jedes Bild nachsehen, nicht nur beim Betreten: Wer stehen bleibt, wird nach der Schonzeit wieder gepikst
func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("held") and body.unverwundbar <= 0:
			body.getroffen(self)
