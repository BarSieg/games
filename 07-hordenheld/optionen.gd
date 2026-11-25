extends Node

# Einstellungen, die für jedes Spiel gelten. Sie stehen in einer eigenen Datei.

const DATEI = "user://optionen.cfg"

var musik := 7          # 0 bis 10
var beben := true       # wackelt das Bild, wenn Gegner beißen?
var brummen := true     # brummt der Controller, wenn Gegner beißen?
var vollbild := false


func _ready() -> void:
	laden()


func laden() -> void:
	var datei := ConfigFile.new()
	datei.load(DATEI)   # Gibt es die Datei noch nicht, liefert get_value einfach die Ersatzwerte
	musik = datei.get_value("optionen", "musik", 7)
	beben = datei.get_value("optionen", "beben", true)
	brummen = datei.get_value("optionen", "brummen", true)
	vollbild = datei.get_value("optionen", "vollbild", false)
	anwenden()


func speichern() -> void:
	var datei := ConfigFile.new()
	datei.set_value("optionen", "musik", musik)
	datei.set_value("optionen", "beben", beben)
	datei.set_value("optionen", "brummen", brummen)
	datei.set_value("optionen", "vollbild", vollbild)
	datei.save(DATEI)
	anwenden()


# Was sich nicht von selbst einstellt, wird hier eingestellt. Beben und Brummen fragt der Held selbst.
func anwenden() -> void:
	# linear_to_db: 5 von 10 klingt so wirklich wie „halb so laut“
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musik"), linear_to_db(musik / 10.0))
	if OS.has_feature("web"):
		return   # im Browser gibt es dafür F11
	if vollbild:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Den Controller brummen lassen, wenn es eingeschaltet ist. schwach und stark: 0 bis 1, dauer in Sekunden.
func brummen_lassen(schwach: float, stark: float, dauer: float) -> void:
	if not brummen:
		return
	if not OS.has_feature("web"):
		Input.start_joy_vibration(0, schwach, stark, dauer)
		return
	# Im Browser kann Godot das nicht. Darum fragen wir den Browser selbst, in seiner Sprache: JavaScript.
	JavaScriptBridge.eval("""
		for (const pad of navigator.getGamepads()) {
			if (pad && pad.vibrationActuator) {
				pad.vibrationActuator.playEffect("dual-rumble",
					{duration: %d, weakMagnitude: %f, strongMagnitude: %f});
			}
		}
	""" % [dauer * 1000, schwach, stark])
