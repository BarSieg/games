extends StaticBody2D


const FRAME_LEER = 29   # hier die Nummer deines leeren Blocks eintragen

var leer := false


func _on_unterseite_body_entered(body: Node2D) -> void:
	# Nur wenn der Held von unten kommt, also gerade steigt
	if body.velocity.y < 0 and not leer:
		leer = true
		$Bild.frame = FRAME_LEER
		body.muenze_einsammeln()
		anstossen()


# Kurz hochhüpfen und zurück
func anstossen() -> void:
	var tween := create_tween()
	tween.tween_property($Bild, "position:y", -4.0, 0.08)
	tween.tween_property($Bild, "position:y", 0.0, 0.08)
