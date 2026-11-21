extends Node

# Einstellungen, die zu keinem Spielstand gehören. Sie gelten für jedes Spiel, auch für Iron Man.

const DATEI = "user://optionen.cfg"
const SPRACHEN = ["de", "en", "fr"]
const SPRACHNAMEN = {"de": "Deutsch", "en": "English", "fr": "Français"}   # jede Sprache in ihrer eigenen Sprache

var sprache := "de"
var schraeg := false   # in acht Richtungen laufen statt in vier
var lautstaerke := 10   # 0 bis 10: alles zusammen
var musik := 10         # 0 bis 10: nur die Musik
var vollbild := false


func _ready() -> void:
	laden()


func vollbild_anwenden() -> void:
	if OS.has_feature("web"):
		return
	var modus := DisplayServer.WINDOW_MODE_FULLSCREEN if vollbild else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(modus)


# Bus 0 heißt immer Master, da läuft alles durch. Die Musik hat ihren eigenen Bus.
# linear_to_db: Lautstärke hört man nicht gleichmäßig. 5 von 10 klingt so wirklich wie „halb so laut“.
func lautstaerke_anwenden() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(lautstaerke / 10.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musik"), linear_to_db(musik / 10.0))
func laden() -> void:
	var datei := ConfigFile.new()
	datei.load(DATEI)   # Gibt es die Datei noch nicht, liefert get_value einfach die Ersatzwerte
	# Beim allerersten Start: die Sprache des Computers, wenn wir sie haben. Sonst Englisch.
	var vorschlag := OS.get_locale_language() if OS.get_locale_language() in SPRACHEN else "en"
	sprache = datei.get_value("optionen", "sprache", vorschlag)
	schraeg = datei.get_value("optionen", "schraeg", false)
	vollbild = datei.get_value("optionen", "vollbild", false)
	lautstaerke = datei.get_value("optionen", "lautstaerke", 10)
	musik = datei.get_value("optionen", "musik", 10)
	TranslationServer.set_locale(sprache)
	vollbild_anwenden()
	lautstaerke_anwenden()


func speichern() -> void:
	var datei := ConfigFile.new()
	datei.set_value("optionen", "sprache", sprache)
	datei.set_value("optionen", "schraeg", schraeg)
	datei.set_value("optionen", "vollbild", vollbild)
	datei.set_value("optionen", "lautstaerke", lautstaerke)
	datei.set_value("optionen", "musik", musik)
	datei.save(DATEI)
	TranslationServer.set_locale(sprache)
