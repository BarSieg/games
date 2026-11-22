extends Label

# Zählt die Spielzeit. Bei Dialogen und Raumwechseln ist das Spiel angehalten, dann steht auch die Uhr.


func _ready() -> void:
	visible = Spielstand.iron_man   # Nur der eiserne Held spielt gegen die Uhr
	Spielstand.gewonnen.connect(stop_uhr)


func _process(delta: float) -> void:
	Spielstand.spielzeit += delta
	text = Spielstand.formatiere_spielzeit()


func stop_uhr() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
