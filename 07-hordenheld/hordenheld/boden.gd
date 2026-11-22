extends Sprite2D

# Der Boden: ein Bild, das eine Kachel immer wieder wiederholt.
# Es ist so groß wie der Bildschirm plus eine Kachel an jedem Rand und springt mit der Kamera mit,
# immer um eine ganze Kachel. Weil alle Kacheln gleich aussehen, merkt man das Springen nicht.

const KACHEL = 16

@export var kachelblatt: Texture2D
@export var kachel := Vector2i(0, 0)   # welche Kachel vom Blatt, gezählt in Kacheln (Spalte, Zeile)


func _ready() -> void:
	# Die eine Kachel aus dem Blatt ausschneiden. Wiederholen kann Godot nur ein ganzes Bild.
	var bild := kachelblatt.get_image().get_region(Rect2i(kachel * KACHEL, Vector2i(KACHEL, KACHEL)))
	texture = ImageTexture.create_from_image(bild)
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	centered = false
	# region größer als das Bild selbst: Dann wird es wiederholt, bis die Fläche voll ist
	region_enabled = true
	region_rect = Rect2(Vector2.ZERO, get_viewport_rect().size + Vector2(KACHEL, KACHEL) * 2)


func _process(_delta: float) -> void:
	# Die linke obere Ecke vom Bildschirm, in der Welt
	var ecke := get_viewport().get_camera_2d().get_screen_center_position() - get_viewport_rect().size / 2
	# Auf ganze Kacheln abrunden, und eine Kachel Vorsprung, damit am Rand nie etwas fehlt
	global_position = (ecke / KACHEL).floor() * KACHEL - Vector2(KACHEL, KACHEL)
