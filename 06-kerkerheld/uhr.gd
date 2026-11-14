extends Label

# Zählt die Spielzeit. Bei Dialogen und Raumwechseln ist das Spiel angehalten, dann steht auch die Uhr.


func _ready() -> void:
	visible = Spielstand.iron_man   # Nur der eiserne Held spielt gegen die Uhr


func _process(delta: float) -> void:
	Spielstand.spielzeit += delta
	text = Spielstand.zeit_text(Spielstand.spielzeit)
