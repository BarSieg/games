extends CharacterBody2D

const TEMPO = 70.0        # Pixel pro Sekunde
const WACKELN = 15.0      # so schnell wackelt er beim Laufen hin und her
const WACKEL_WINKEL = 0.15   # so weit, in Radiant (0.15 sind etwa 9 Grad)
const MAX_LEBEN = 100.0
const SCHADEN = 10.0      # so viel Leben kostet ein Gegner pro Sekunde, solange er den Held berührt

var lauf_zeit := 0.0
var leben := MAX_LEBEN


func _physics_process(delta: float) -> void:
	var richtung := Input.get_vector("links", "rechts", "hoch", "runter")
	velocity = richtung * TEMPO
	move_and_slide()

	if richtung.x != 0:
		$Bild.flip_h = richtung.x < 0
	# Ein Bild pro Figur reicht: Beim Laufen wackelt sie hin und her
	if richtung != Vector2.ZERO:
		lauf_zeit += delta
		$Bild.rotation = sin(lauf_zeit * WACKELN) * WACKEL_WINKEL
	else:
		lauf_zeit = 0.0
		$Bild.rotation = 0.0

	# Wie viele Gegner berühren mich gerade?
	var treffer: int = $Trefferzone.get_overlapping_bodies().size()
	if treffer > 0:
		leben -= treffer * SCHADEN * delta
		$Lebensbalken.value = leben
		if leben <= 0:
			get_tree().reload_current_scene()
	$Bild.modulate = Color(1, 0.4, 0.4) if treffer > 0 else Color.WHITE
