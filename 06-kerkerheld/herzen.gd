extends Node2D

const HERZ = [
	".##.##.",
	"#######",
	"#######",
	".#####.",
	"..###..",
	"...#...",
]
const ABSTAND = 8                        # 7 Pixel Herz, 1 Pixel Luft
const HERZEN_SPACE_Y = 16
const VOLL = Color(0.85, 0.1, 0.15)
const LEER = Color(0.3, 0.3, 0.3)


func _ready() -> void:
	Spielstand.leben_geaendert.connect(queue_redraw)


func _draw() -> void:
	for herz in range(int(Spielstand.max_leben / 2.0)):
		# Wie viele Hälften dieses Herzens sind noch voll: 2, 1 oder 0 (oder weniger)?
		var haelften := Spielstand.leben - herz * 2
		for y in HERZ.size():
			for x in HERZ[y].length():
				if HERZ[y][x] == "#":
					# Ein halbes Herz: nur die linke Hälfte (Spalten 0 bis 3) ist rot
					var voll: bool = haelften >= 2 or (haelften == 1 and x <= 3)
					draw_rect(Rect2(herz * ABSTAND + x, y + HERZEN_SPACE_Y, 1, 1), VOLL if voll else LEER)
