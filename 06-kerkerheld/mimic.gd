extends StaticBody2D

@export var schaden := 2   # in halben Herzen

var offen := false


# Der Held steht davor und drückt den Knopf
func benutzen() -> void:
	if offen:
		return
	offen = true
	$Bild.animation = "angriff"
	var held = get_tree().get_first_node_in_group("held")
	if held.unverwundbar <= 0:
		held.getroffen(self)
