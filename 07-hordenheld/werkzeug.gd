extends Node

# Werkzeuge zum Messen und Testen. Nur auf der Tastatur:
# F1 = 100 Gegner mehr, F2 = Testmodus an/aus, F3 = Grenze suchen, F4 = Uhr 30 Sekunden vor

const MONITORE = ["Gegner", "Messer", "Edelsteine"]
const GRUPPEN = ["gegner", "messer", "beute"]

var max_spawn := false
var spawn_takt := 1.0
var last_spawn := 0.0
var physik_limit := 16.7
var max_gegner := 1


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()   # im fertigen Spiel gibt es kein Werkzeug
		return
	for i in MONITORE.size():
		Performance.add_custom_monitor("Hordenheld/" + MONITORE[i], get_tree().get_node_count_in_group.bind(GRUPPEN[i]))


func _physics_process(delta: float) -> void:
	if max_spawn:
		last_spawn -= delta
		if last_spawn <= 0.0:
			last_spawn += spawn_takt
			if Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000 > physik_limit:
				max_gegner = get_tree().get_node_count_in_group("gegner")
				push_warning("Limit erreicht bei " + str(max_gegner) + " Gegner")
				max_spawn = false
			else:
				for i in 50:
					$"../Horde".neuer_gegner()


func _exit_tree() -> void:
	for monitor in MONITORE:
		if Performance.has_custom_monitor("Hordenheld/" + monitor):
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
		KEY_F3:
			max_spawn = true
		KEY_F4:
			var uhr: Uhr = get_tree().get_first_node_in_group("uhr")
			uhr.zeit += 30.0
