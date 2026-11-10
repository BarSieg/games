extends StaticBody2D

const SCHATZ = preload("res://schatz.tscn")
const BILD_OEFFNEN = 90
const BILD_OFFEN = 91

@export var inhalt: Gegenstand.Art = Gegenstand.Art.SCHLUESSEL

var offen := false


# Der Held steht davor und drückt den Knopf
func benutzen() -> void:
	if offen:
		return
	offen = true
	$Bild.frame = BILD_OEFFNEN
	$Fanfare.play()
	Spielstand.hinzufuegen(inhalt)
	zeigen()


# Der Schatz steigt aus der Truhe auf, bleibt kurz stehen und verblasst
func zeigen() -> void:
	var schatz: Schatz = SCHATZ.instantiate()
	schatz.art = inhalt
	schatz.position = Vector2(0, -4)
	add_child(schatz)
	var tween := schatz.create_tween()
	tween.tween_property(schatz, "position:y", -18.0, 0.5)
	tween.tween_interval(0.6)
	tween.tween_property(schatz, "modulate:a", 0.0, 0.3)
	tween.tween_callback(schatz.queue_free)
	tween.tween_property($Bild, "frame", BILD_OFFEN, 0.0)
