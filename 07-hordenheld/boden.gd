extends Sprite2D

# Der Boden: ein Bild, das ein Muster aus 2×2 Kacheln immer wieder wiederholt.
# Es ist so groß wie der Bildschirm plus ein Muster und springt mit der Kamera mit,
# immer um ein ganzes Muster. Weil alle Muster gleich aussehen, merkt man das Springen nicht.

const KACHEL = 16

@export var kachelblatt: Texture2D
# Welche Kacheln vom Blatt ins 2×2-Muster kommen, gezählt in Kacheln (Spalte, Zeile)
@export var kachel_lo := Vector2i(0, 0)   # links oben
@export var kachel_ro := Vector2i(0, 0)   # rechts oben
@export var kachel_lu := Vector2i(0, 0)   # links unten
@export var kachel_ru := Vector2i(0, 0)   # rechts unten


func _ready() -> void:
	var blatt := kachelblatt.get_image()
	var muster := Image.create_empty(KACHEL * 2, KACHEL * 2, false, blatt.get_format())
	muster.blit_rect(blatt, Rect2i(kachel_lo * KACHEL, Vector2i(KACHEL, KACHEL)), Vector2i(0, 0))
	muster.blit_rect(blatt, Rect2i(kachel_ro * KACHEL, Vector2i(KACHEL, KACHEL)), Vector2i(KACHEL, 0))
	muster.blit_rect(blatt, Rect2i(kachel_lu * KACHEL, Vector2i(KACHEL, KACHEL)), Vector2i(0, KACHEL))
	muster.blit_rect(blatt, Rect2i(kachel_ru * KACHEL, Vector2i(KACHEL, KACHEL)), Vector2i(KACHEL, KACHEL))
	texture = ImageTexture.create_from_image(muster)
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	centered = false
	# region größer als das Bild selbst: Dann wird es wiederholt, bis die Fläche voll ist
	region_enabled = true
	region_rect = Rect2(Vector2.ZERO, get_viewport_rect().size + 2 * Vector2(KACHEL, KACHEL))


func _process(_delta: float) -> void:
	# Die linke obere Ecke vom Bildschirm, in der Welt
	var ecke := get_viewport().get_camera_2d().get_screen_center_position() - get_viewport_rect().size / 2
	# Auf ganze Muster abrunden: Der Boden fängt immer links oberhalb vom Bildschirm an
	global_position = (ecke / (2 * KACHEL)).floor() * (2 * KACHEL)
