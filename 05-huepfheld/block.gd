extends StaticBody2D

const POWER_UP = preload("res://power_up.tscn")
const FRAME_LEER = 29   # hier die Nummer deines leeren Blocks eintragen

@export var hat_power_up := false

var leer := false


func _on_unterseite_body_entered(body: Node2D) -> void:
	# Nur wenn der Held von unten kommt, also gerade steigt
	if body.velocity.y < 0 and not leer:
		leer = true
		$Bild.frame = FRAME_LEER
		if hat_power_up:
			var power_up := POWER_UP.instantiate()
			power_up.position = position + Vector2(0, -18)   # eine Kachel über dem Block
			get_parent().add_child.call_deferred(power_up)
		else:
			body.muenze_einsammeln()
		anstossen()


# Kurz hochhüpfen und zurück
func anstossen() -> void:
	var tween := create_tween()
	tween.tween_property($Bild, "position:y", -4.0, 0.08)
	tween.tween_property($Bild, "position:y", 0.0, 0.08)
