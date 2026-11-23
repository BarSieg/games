extends Area2D

const TEMPO = 200.0        # Pixel pro Sekunde
const LEBENSDAUER = 1.5    # Sekunden, dann ist das Messer weg, auch wenn es nichts getroffen hat
const SCHUB = 3.0          # schubst den Gegner so viele Pixel weg

var richtung := Vector2.RIGHT   # setzt die Waffe, bevor das Messer in die Welt kommt
var schaden := 1                # das auch
var zeit := LEBENSDAUER
var durchschlag := 1            # so viele Gegner trifft ein Messer höchstens


func _ready() -> void:
	# Das Bild zeigt nach oben, der Winkel 0 aber nach rechts. Darum eine Vierteldrehung dazu.
	rotation = richtung.angle() + PI / 2


func _physics_process(delta: float) -> void:
	position += richtung * TEMPO * delta
	zeit -= delta
	if zeit <= 0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Trifft das Messer zwei Gegner im selben Bild, zählt nur der erste
	if is_queued_for_deletion():
		return
	body.treffer(schaden, richtung * SCHUB)
	durchschlag -= 1
	if durchschlag <= 0:
		queue_free()
