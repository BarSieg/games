extends Node

# Einstellungen, die zu keinem Spielstand gehören. Sie gelten für jedes Spiel, auch für Iron Man.

const DATEI = "user://optionen.cfg"
const SPRACHEN = ["de", "en"]
const SPRACHNAMEN = {"de": "Deutsch", "en": "English"}   # jede Sprache in ihrer eigenen Sprache

var sprache := "de"
var schraeg := false   # in acht Richtungen laufen statt in vier


func _ready() -> void:
	laden()


func laden() -> void:
	var datei := ConfigFile.new()
	datei.load(DATEI)   # Gibt es die Datei noch nicht, liefert get_value einfach die Ersatzwerte
	# Beim allerersten Start: die Sprache des Computers, wenn wir sie haben. Sonst Englisch.
	var vorschlag := OS.get_locale_language() if OS.get_locale_language() in SPRACHEN else "en"
	sprache = datei.get_value("optionen", "sprache", vorschlag)
	schraeg = datei.get_value("optionen", "schraeg", false)
	TranslationServer.set_locale(sprache)


func speichern() -> void:
	var datei := ConfigFile.new()
	datei.set_value("optionen", "sprache", sprache)
	datei.set_value("optionen", "schraeg", schraeg)
	datei.save(DATEI)
	TranslationServer.set_locale(sprache)
