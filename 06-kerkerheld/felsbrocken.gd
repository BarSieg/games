extends CharacterBody2D

# Ein Felsbrocken, den der Held schieben kann. Immer genau eine Kachel weit.

@export var nur_einmal := false # lässt sich nur ein mal schieben

const KACHEL = 16
const SCHUB_ZEIT = 0.4     # so lange muss der Held drücken, bis der Brocken nachgibt
const RUTSCH_ZEIT = 0.3    # so lange rutscht er eine Kachel weit

var schub_zeit := 0.0
var schub_richtung := Vector2.ZERO
var letzter_schub := 0     # in welchem Physik-Bild der Held zuletzt gedrückt hat
var rutscht := false
var geschoben := false

@onready var start_position := global_position


func _ready() -> void:
	%Camera2D.raumwechsel.connect(raum_gewechselt)


# Der Held läuft dagegen. Das kommt jedes Bild, solange er drückt.
func schieben(richtung: Vector2, delta: float) -> void:
	if rutscht or (nur_einmal and geschoben):
		return
	var bild := Engine.get_physics_frames()
	# Andere Richtung oder eine Pause dazwischen? Dann fängt das Drücken von vorn an.
	if richtung != schub_richtung or bild - letzter_schub > 1:
		schub_zeit = 0.0
	schub_richtung = richtung
	letzter_schub = bild
	schub_zeit += delta
	# test_move: Würde ich auf dem Weg irgendwo anstoßen?
	if schub_zeit >= SCHUB_ZEIT and not test_move(global_transform, richtung * KACHEL):
		rutschen(richtung)


func rutschen(richtung: Vector2) -> void:
	rutscht = true
	geschoben = true
	schub_zeit = 0.0
	$Schieben.play()
	var tween := create_tween()
	tween.tween_property(self, "global_position", global_position + richtung * KACHEL, RUTSCH_ZEIT)
	await tween.finished
	rutscht = false


# Hat der Held meinen Raum verlassen? Dann zurück an den Anfang, damit sich niemand festschieben kann.
func raum_gewechselt(_richtung: Vector2i) -> void:
	if %Camera2D.raum != %Camera2D.raum_von(start_position):
		global_position = start_position
		geschoben = false 
