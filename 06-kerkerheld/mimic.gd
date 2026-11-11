extends StaticBody2D


var offen := false
@export var schaden := 2

# Der Held steht davor und drückt den Knopf
func benutzen() -> void:
	if offen:
		return
	offen = true
	$Bild.animation = "angriff"
	var held = get_tree().get_first_node_in_group("held")
	if held.unverwundbar <= 0:
		held.getroffen(self)
