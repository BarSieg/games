extends Area2D

const BESCHLEUNIGUNG = 500.0   # so schnell wird er schneller, wenn er zum Held fliegt

# Das Bild, Zeichen für Zeichen. Was nicht in den FARBEN steht, bleibt durchsichtig.
const BILD = [
	"...o...",
	"..o+o..",
	".o+##o.",
	"o+####o",
	".o###o.",
	"..o#o..",
	"...o...",
]
const FARBEN_1 = {   # blau, für normale Steine
	"o": Color(0.05, 0.1, 0.3),   # dunkler Rand
	"#": Color(0.2, 0.5, 1.0),    # blau
	"+": Color(0.75, 0.9, 1.0),   # Glanz
}

const FARBEN_2 = {   # grün, für Steine ab wert 3
	"o": Color(0.1, 0.3, 0.05),   # dunkler Rand
	"#": Color(0.5, 1.0, 0.2),   # grün
	"+": Color(0.9, 1.0, 0.75),   # Glanz
}

const FARBEN_3 = {   # rot, für Steine ab wert 10
	"o": Color(0.3, 0.05, 0.1),   # dunkler Rand
	"#": Color(1.0, 0.2, 0.5),   # rot
	"+": Color(1.0, 0.75, 0.9),   # Glanz
}

var wert := 1             # so viel Erfahrung bringt er, setzt der Gegner
var ziel: Node2D = null   # wohin er fliegt, setzt der Magnet
var tempo := -60.0        # negativ: erst ein kleiner Hüpfer weg vom Held, dann hin


func _draw() -> void:
	# Die Mitte vom Bild soll auf der Position vom Stein liegen
	var mitte := Vector2i(BILD[0].length(), BILD.size()) / 2
	var farben: Dictionary = FARBEN_1 if wert < 3 else (FARBEN_2 if wert < 10 else FARBEN_3)
	for y in BILD.size():
		for x in BILD[y].length():
			var zeichen: String = BILD[y][x]
			if zeichen in farben:
				draw_rect(Rect2(Vector2i(x, y) - mitte, Vector2.ONE), farben[zeichen])


func anziehen(held: Node2D) -> void:
	ziel = held


func _physics_process(delta: float) -> void:
	if ziel == null:
		return   # liegt einfach da
	tempo += BESCHLEUNIGUNG * delta
	global_position = global_position.move_toward(ziel.global_position, tempo * delta)
	if global_position.distance_squared_to(ziel.global_position) < 4 * 4:
		ziel.erfahrung_dazu(wert)
		queue_free()
