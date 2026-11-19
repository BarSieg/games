extends Area2D

# Ein Bodenschalter. Unten, solange der Held oder etwas Schweres darauf steht.

signal gedrueckt
signal losgelassen

const GROESSE = 12.0
const RAND = Color(0.16, 0.12, 0.1)
const OBEN = Color(0.7, 0.62, 0.5)
const UNTEN = Color(0.45, 0.4, 0.32)
const KANTE = Color(0.35, 0.3, 0.24)

var unten := false


func _physics_process(_delta: float) -> void:
	var belastet := get_overlapping_bodies().any(func(ding: Node2D) -> bool: return ding.is_in_group("held") or ding.is_in_group("schwer"))
	if belastet == unten:
		return
	unten = belastet
	queue_redraw()
	if unten:
		$Klick.play()
		gedrueckt.emit()
	else:
		losgelassen.emit()


# Eine Platte im Boden. Oben hat sie unten eine dunkle Kante, gedrückt ist sie flach und dunkler.
func _draw() -> void:
	var platte := Rect2(-GROESSE / 2, -GROESSE / 2, GROESSE, GROESSE)
	draw_rect(platte, RAND)
	if unten:
		draw_rect(platte.grow(-1), UNTEN)
	else:
		draw_rect(platte.grow(-1), OBEN)
		draw_rect(Rect2(platte.position.x + 1, platte.end.y - 3, GROESSE - 2, 2), KANTE)
