extends Node2D


const ZEIT_ZUM_SAMMELN = 15.0
const ZEIT_VERSCHWINDEN = 5.0

var drop := false   # Aus Gegner ausgeschlagen statt im Level liegend
var zeit := 0.0


func _ready() -> void:
	if drop:
		zeit = ZEIT_ZUM_SAMMELN
	queue_redraw()


func _physics_process(delta: float) -> void:
	if drop:
		zeit -= delta
		queue_redraw()
		if zeit < 0:
			queue_free()


func _on_bild_body_entered(_body: Node2D) -> void:
	Spielstand.leben += 2
	queue_free()


func _draw() -> void:
	# Ein volles Herz, beim Verschwinden immer durchsichtiger
	var ecke = $Bild.position
	var alpha := 1.0 if (zeit > ZEIT_VERSCHWINDEN or not drop) else zeit / ZEIT_VERSCHWINDEN
	for y in Spielstand.HERZ.size():
		for x in Spielstand.HERZ[y].length():
			var farbe: Color
			match Spielstand.HERZ[y][x]:
				"o":
					farbe = Color(Spielstand.RAND, alpha)
				"#":
					farbe = Color(Spielstand.VOLL, alpha)
				"+":
					farbe = Color(Spielstand.GLANZ, alpha)
				_:
					continue   # durchsichtig: nichts malen
			draw_rect(Rect2(ecke + Vector2(x, y), Vector2(1, 1)), farbe)
