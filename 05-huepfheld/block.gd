extends StaticBody2D

const POWER_UP = preload("res://power_up.tscn")
const MUENZE = preload("res://muenze.tscn")
const FRAME_LEER = 29   # hier die Nummer deines leeren Blocks eintragen
const FRAME_ZIEGEL = 6
const FRAME_MUENZE = 9

enum Typ { MUENZE, POWER_UP, ZIEGEL }

@export var typ := Typ.MUENZE
@export var muenzen := 1        # zählt nur bei Typ MUENZE

var leer := false


func _ready() -> void:
	if typ == Typ.ZIEGEL:
		$Bild.frame = FRAME_ZIEGEL


func _on_unterseite_body_entered(body: Node2D) -> void:
	# Nur wenn der Held von unten kommt, also gerade steigt
	if body.velocity.y >= 0 or leer:
		return
	match typ:
		Typ.MUENZE:
			muenzen -= 1
			body.muenze_einsammeln()
			var muenze := MUENZE.instantiate()
			muenze.aus_block = true
			muenze.position = position # + Vector2(0, -18)
			get_parent().add_child.call_deferred(muenze)
			if muenzen == 0:
				leer_machen()
		Typ.POWER_UP:
			var power_up := POWER_UP.instantiate()
			power_up.position = position + Vector2(0, -18)
			get_parent().add_child.call_deferred(power_up)
			leer_machen()
		Typ.ZIEGEL:
			if body.stark:
				oben_treffen(body)
				body.ziegel_brechen()
				queue_free()
				return
	anstossen(body)


func leer_machen() -> void:
	leer = true
	$Bild.frame = FRAME_LEER


# Wer oben auf dem Block steht, wird mit erwischt
func oben_treffen(body: Node2D) -> void:
	var gegner_liste: Array[Node2D] = $Oberseite.get_overlapping_bodies()
	for gegner in gegner_liste:
		gegner.plattmachen()
	if gegner_liste.size() > 0:
		body.plopp(0.8)


# Kurz hochhüpfen und zurück
func anstossen(body: Node2D) -> void:
	var tween := create_tween()
	tween.tween_property($Bild, "position:y", -4.0, 0.08)
	tween.tween_property($Bild, "position:y", 0.0, 0.08)
	oben_treffen(body)
