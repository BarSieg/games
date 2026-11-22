extends AudioStreamPlayer

# Die Hintergrundmusik. Ein Autoload, darum spielt sie über jeden Szenenwechsel hinweg weiter.

const TITEL = preload("res://musik_titel.wav")
const KERKER = preload("res://musik_kerker.wav")
const BOSS = preload("res://musik_boss.wav")
const GEHEIMNIS = preload("res://musik_geheimnis.wav")
const BLENDE = 0.6     # so lange dauert das Aus- und Einblenden, in Sekunden
const LEISE = -40.0    # in dB: so gut wie nichts mehr zu hören
const NORMAL = -10.0    # in dB: so gut wie nichts mehr zu hören


var blende: Tween


func _ready() -> void:
	bus = &"Musik"
	# Dialoge und Raumwechsel pausieren das Spiel. Die Musik soll trotzdem weiterspielen.
	process_mode = Node.PROCESS_MODE_ALWAYS


# Ein Stück spielen. Läuft es schon, passiert nichts. Sonst wird das alte aus- und das neue eingeblendet.
func spielen(stueck: AudioStream) -> void:
	if stream == stueck and playing:
		return
	if blende:
		blende.kill()
	blende = create_tween()
	if playing:
		blende.tween_property(self, "volume_db", LEISE, BLENDE)
	else:
		volume_db = LEISE
	blende.tween_callback(wechseln.bind(stueck))
	blende.tween_property(self, "volume_db", NORMAL, BLENDE)


func wechseln(stueck: AudioStream) -> void:
	stream = stueck
	play()


# Ausblenden und Ruhe
func stoppen() -> void:
	if blende:
		blende.kill()
	blende = create_tween()
	blende.tween_property(self, "volume_db", LEISE, BLENDE)
	blende.tween_callback(stop)
