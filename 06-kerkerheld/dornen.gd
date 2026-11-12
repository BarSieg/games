extends Area2D

var schaden := 1   # in halben Herzen

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("treffer_pruefen"):
		if body.unverwundbar <= 0:
			body.getroffen(self)
