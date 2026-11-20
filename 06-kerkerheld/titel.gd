extends Control

const DUNGEON = "res://dungeon.tscn"
const OPTIONEN = "res://optionen.tscn"

# Was unter dem Menü steht, je nachdem, was gerade ausgewählt ist. Jede Zeile wird einzeln übersetzt.
const ERKLAERUNG = {
	"Weiter": ["Da weitermachen, wo du zuletzt einen Raum betreten hast.", "Spielzeit: %s   Fortschritt: %d%%"],
	"Neues Spiel": ["Wie im Original: Wer stirbt, steht am Eingang wieder auf. Monster auch."],
	"Iron Man": ["Tot ist tot. Für Monster und für dich.", "Kein Speichern, kein Weiter."],
	"Optionen": ["Sprache und wie der Held läuft."],
}

var eintraege: Array[String] = []
var auswahl := 0
var zeit := ""
var erkundet := 0
var ironman_bestzeit := ""


func _ready() -> void:
	if Spielstand.spielstand_datei_vorhanden():
		eintraege.append("Weiter")
		var stats := Spielstand.load_stats_fuer_titel()
		zeit = Spielstand.formatiere_spielzeit(stats[0] / 1000.0)
		erkundet = stats[1]
	eintraege.append_array(["Neues Spiel", "Iron Man", "Optionen"])
	var ironman := Spielstand.rekorde_laden()
	if ironman.size() > 0:
		ironman_bestzeit = Spielstand.formatiere_spielzeit(ironman[0] / 1000.0)
	anzeigen()


# Input statt _unhandled_input: just_pressed meldet sich nur einmal, auch wenn der Stick länger gedrückt bleibt
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hoch"):
		auswahl = posmod(auswahl - 1, eintraege.size())
		anzeigen()
	elif Input.is_action_just_pressed("runter"):
		auswahl = posmod(auswahl + 1, eintraege.size())
		anzeigen()
	elif Input.is_action_just_pressed("angriff"):
		starten(eintraege[auswahl])


func anzeigen() -> void:
	var text := ""
	for i in eintraege.size():
		text += ("> " if i == auswahl else "  ") + tr(eintraege[i]) + "\n"
	$Menue.text = text
	# Jede Zeile der Erklärung einzeln übersetzen, dann zusammenkleben
	var zeilen: Array = ERKLAERUNG[eintraege[auswahl]].map(func(zeile: String) -> String: return tr(zeile))
	match eintraege[auswahl]:
		"Weiter":
			zeilen[1] = zeilen[1] % [zeit, erkundet]
		"Iron Man":
			if ironman_bestzeit:
				zeilen.append(tr("Schnellster eiserner Held: %s") % ironman_bestzeit)
	$Hinweis.text = "\n".join(zeilen)


func starten(was: String) -> void:
	if was == "Optionen":
		get_tree().change_scene_to_file(OPTIONEN)
		return
	Spielstand.iron_man = was == "Iron Man"
	match was:
		"Weiter":
			Spielstand.laden()
		"Neues Spiel":
			if Spielstand.spielstand_datei_vorhanden():
				if not await Dialog.frage("Dein altes Spiel wird gelöscht. Wirklich?"):
					return
			Spielstand.loeschen()
			Spielstand.neues_spiel()
		"Iron Man":
			Spielstand.neues_spiel()   # der normale Spielstand bleibt, wie er ist
		
	get_tree().change_scene_to_file(DUNGEON)
