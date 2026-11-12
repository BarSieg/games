extends StaticBody2D

const OFFEN_LINKS = 22
const OFFEN_RECHTS = 23

@export var master := false   # braucht den Masterschlüssel statt eines normalen


func _ready() -> void:
	if Spielstand.ist_erledigt(self):
		queue_free()
		return
	if master:
		$Bilder.modulate = Color(1.0, 0.85, 0.4)   # golden: Hier geht es zum Boss


# Der Held steht davor und drückt den Knopf
func benutzen() -> void:
	var schluessel := Gegenstand.Art.MASTERSCHLUESSEL if master else Gegenstand.Art.SCHLUESSEL
	if not Spielstand.verbrauchen(schluessel):
		wackeln()
		return
	Spielstand.erledigen(self)
	$CollisionShape2D.set_deferred("disabled", true)
	$Bilder/Links.frame = OFFEN_LINKS
	$Bilder/Rechts.frame = OFFEN_RECHTS
	get_tree().get_first_node_in_group("held").tuer_offen()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)


# Kein Schlüssel: Die Tür rüttelt nur
func wackeln() -> void:
	$Ruetteln.play()
	var tween := create_tween()
	for i in 3:
		tween.tween_property($Bilder, "position:x", 1.0, 0.04)
		tween.tween_property($Bilder, "position:x", -1.0, 0.04)
	tween.tween_property($Bilder, "position:x", 0.0, 0.04)
