extends Node

# Einstellungen, die zu keinem Spielstand gehören. Sie gelten für jedes Spiel, auch für Iron Man.

const DATEI = "user://optionen.cfg"
const SPRACHEN = ["de", "en", "fr"]
const SPRACHNAMEN = {"de": "Deutsch", "en": "English", "fr": "Français"}   # jede Sprache in ihrer eigenen Sprache

var sprache := "de"
var schraeg := false   # in acht Richtungen laufen statt in vier
var lautstaerke := 10   # in acht Richtungen laufen statt in vier
var vollbild := false


func _ready() -> void:
	laden()


func vollbild_anwenden() -> void:
	var modus := DisplayServer.WINDOW_MODE_FULLSCREEN if vollbild else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(modus)


func laden() -> void:
	var datei := ConfigFile.new()
	datei.load(DATEI)   # Gibt es die Datei noch nicht, liefert get_value einfach die Ersatzwerte
	# Beim allerersten Start: die Sprache des Computers, wenn wir sie haben. Sonst Englisch.
	var vorschlag := OS.get_locale_language() if OS.get_locale_language() in SPRACHEN else "en"
	sprache = datei.get_value("optionen", "sprache", vorschlag)
	schraeg = datei.get_value("optionen", "schraeg", false)
	vollbild = datei.get_value("optionen", "vollbild", false)
	lautstaerke = datei.get_value("optionen", "lautstaerke", 10)
	TranslationServer.set_locale(sprache)
	vollbild_anwenden()


func speichern() -> void:
	var datei := ConfigFile.new()
	datei.set_value("optionen", "sprache", sprache)
	datei.set_value("optionen", "schraeg", schraeg)
	datei.set_value("optionen", "vollbild", vollbild)
	datei.set_value("optionen", "lautstaerke", lautstaerke)
	datei.save(DATEI)
	TranslationServer.set_locale(sprache)
