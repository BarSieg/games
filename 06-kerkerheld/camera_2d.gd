extends Camera2D

const RAUM_GROESSE = Vector2(256, 176)   # 16 × 11 Kacheln
const ANZEIGE_HOEHE = 48                 # Platz für die Anzeige oben
const SCHIEBE_ZEIT = 0.6                 # so lange dauert ein Raumwechsel

var raum := Vector2i.ZERO   # welchen Raum die Kamera gerade zeigt

@onready var held: Node2D = get_tree().get_first_node_in_group("held")


func _ready() -> void:
	# Beim Start ohne Schieben gleich zum Raum des Helden
	raum = raum_von(held.global_position)
	position = kamera_position(raum)


func _process(_delta: float) -> void:
	var neu := raum_von(held.global_position)
	if neu != raum:
		schieben(neu)


# In welchem Raum liegt dieser Punkt?
func raum_von(punkt: Vector2) -> Vector2i:
	return Vector2i((punkt / RAUM_GROESSE).floor())


# Wo muss die Kamera stehen, damit sie diesen Raum zeigt?
func kamera_position(r: Vector2i) -> Vector2:
	return Vector2(r) * RAUM_GROESSE - Vector2(0, ANZEIGE_HOEHE)


# Zum neuen Raum schieben. Solange steht das ganze Spiel still.
func schieben(neu: Vector2i) -> void:
	raum = neu
	get_tree().paused = true
	var tween := create_tween()
	tween.tween_property(self, "position", kamera_position(neu), SCHIEBE_ZEIT)
	await tween.finished
	get_tree().paused = false
