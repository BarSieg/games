extends AudioStreamPlayer

# Die Hintergrundmusik. Ein Autoload, darum spielt sie über jeden Szenenwechsel hinweg weiter.

const TITEL = preload("res://musik_titel.wav")
const KAMPF = preload("res://musik_kampf.wav")
const ENDSPURT = preload("res://musik_endspurt.wav")
const BLENDE = 0.6     # so lange dauert das Aus- und Einblenden, in Sekunden
const LEISE = -40.0    # in dB: so gut wie nichts mehr zu hören

var blende: Tween
var ziel: AudioStream   # was gerade laufen soll, null = Ruhe


func _ready() -> void:
	bus = &"Musik"
	# Level-Up und Ende-Bildschirm pausieren das Spiel. Die Musik soll trotzdem weiterspielen.
	process_mode = Node.PROCESS_MODE_ALWAYS


# Ein Stück spielen. Soll es schon laufen, passiert nichts. Sonst wird das alte aus- und das neue eingeblendet.
func spielen(stueck: AudioStream) -> void:
	if ziel == stueck:
		return
	ziel = stueck
	if blende:
		blende.kill()
	blende = create_tween()
	if playing:
		blende.tween_property(self, "volume_db", LEISE, BLENDE)
	else:
		volume_db = LEISE
	blende.tween_callback(wechseln.bind(stueck))
	blende.tween_property(self, "volume_db", 0.0, BLENDE)


func wechseln(stueck: AudioStream) -> void:
	stream = stueck
	play()


# Ausblenden und Ruhe
func stoppen() -> void:
	ziel = null
	if blende:
		blende.kill()
	blende = create_tween()
	blende.tween_property(self, "volume_db", LEISE, BLENDE)
	blende.tween_callback(stop)
