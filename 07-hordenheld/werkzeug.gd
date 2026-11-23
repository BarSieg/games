extends Node

# Werkzeuge zum Messen und Testen. Nur auf der Tastatur:
# F1 = 100 Gegner mehr, F2 = Held unverwundbar an/aus

const MONITORE = ["Gegner", "Messer", "Edelsteine"]
const GRUPPEN = ["gegner", "messer", "beute"]


func _ready() -> void:
	for i in MONITORE.size():
		Performance.add_custom_monitor("Hordenheld/" + MONITORE[i], get_tree().get_node_count_in_group.bind(GRUPPEN[i]))


func _exit_tree() -> void:
	for monitor in MONITORE:
		Performance.remove_custom_monitor("Hordenheld/" + monitor)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_F1:
			for i in 100:
				$"../Horde".neuer_gegner()
		KEY_F2:
			var held: Held = get_tree().get_first_node_in_group("held")
			held.testmodus = not held.testmodus
