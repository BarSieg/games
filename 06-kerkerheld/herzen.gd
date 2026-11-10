extends Node2D

const ABSTAND = 16                       # 14 Pixel Herz, 2 Pixel Luft
const PRO_REIHE = 5
const HERZEN_SPACE_Y = 16
const WARNUNG_FREQUENZ = 0.9

var warnung := 0.0


func _ready() -> void:
	Spielstand.leben_geaendert.connect(queue_redraw)


func _draw() -> void:
	for herz in range(int(Spielstand.max_leben / 2.0)):
		# Fünf Herzen pro Reihe: Der Rest ist die Spalte, das Ergebnis der Division die Reihe
		var ecke := Vector2(herz % PRO_REIHE, int(herz / float(PRO_REIHE))) * ABSTAND + Vector2(0, HERZEN_SPACE_Y)
		# Wie viele Hälften dieses Herzens sind noch voll: 2, 1 oder 0 (oder weniger)?
		var haelften := Spielstand.leben - herz * 2
		for y in Spielstand.HERZ.size():
			for x in Spielstand.HERZ[y].length():
				# Ein halbes Herz: nur die linke Hälfte (Spalten 0 bis 6) ist rot
				var voll: bool = haelften >= 2 or (haelften == 1 and x <= 6)
				var farbe: Color
				match Spielstand.HERZ[y][x]:
					"o":
						farbe = Spielstand.RAND
					"#":
						farbe = Spielstand.VOLL if voll else Spielstand.LEER
					"+":
						farbe = Spielstand.GLANZ if voll else Spielstand.LEER_GLANZ
					_:
						continue   # durchsichtig: nichts malen
				draw_rect(Rect2(ecke + Vector2(x, y), Vector2(1, 1)), farbe)


func _physics_process(delta: float) -> void:
	if Spielstand.leben <= 2 and Spielstand.leben > 0:
		warnung -= delta
		if warnung < 0:
			warnung = WARNUNG_FREQUENZ
			$Warnton.play()
