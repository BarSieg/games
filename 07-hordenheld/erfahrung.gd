extends ProgressBar


func _ready() -> void:
	var held: Held = get_tree().get_first_node_in_group("held")
	held.erfahrung_geaendert.connect(_on_erfahrung_geaendert)
	max_value = held.naechstes_level
	value = 0


func _on_erfahrung_geaendert(erfahrung: int, ziel: int) -> void:
	max_value = ziel
	value = erfahrung
