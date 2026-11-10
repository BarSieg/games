extends Node2D

const HERZCONTAINER = [
	"...ooo....ooo...",
	"..o$$$o..o$$$o..",
	".o$###$oo$###$o.",
	"o$#++##$$#####$o",
	"o$#+##########$o",
	"o$####$##$####$o",
	"o$###$$$$$$###$o",
	"o$###$$$$$$###$o",
	".o$###$$$$###$o.",
	"..o$###$$###$o..",
	"...o$######$o...",
	"....o$####$o....",
	".....o$##$o.....",
	"......o$$o......",
	".......oo.......",
]


func _ready() -> void:
	queue_redraw()


func _physics_process(_delta: float) -> void:
	pass   # evtl. Animation


func _on_bild_body_entered(_body: Node2D) -> void:
	Spielstand.max_leben += 2
	Spielstand.leben += 20   # alle Herzen auffüllen, der Setter schneidet ab
	queue_free()


func _draw() -> void:
	# Ein goldgerahmtes Herz
	var ecke = $Bild.position
	for y in HERZCONTAINER.size():
		for x in HERZCONTAINER[y].length():
			var farbe: Color
			match HERZCONTAINER[y][x]:
				"o":
					farbe = Spielstand.RAND
				"#":
					farbe = Spielstand.VOLL
				"+":
					farbe = Spielstand.GLANZ
				"$":
					farbe = Spielstand.GOLD
				_:
					continue   # durchsichtig: nichts malen
			draw_rect(Rect2(ecke + Vector2(x, y), Vector2(1, 1)), farbe)
