extends Control

const DUNGEON = "res://dungeon.tscn"

# Was unter dem Menü steht, je nachdem, was gerade ausgewählt ist
const ERKLAERUNG = {
	"Weiter": "Da weitermachen, wo du zuletzt einen Raum betreten hast.",
	"Neues Spiel": "Wie im Original: Wer stirbt, steht am Eingang wieder auf. Monster auch.",
	"Iron Man": "Tot ist tot. Für Monster und für dich. Kein Speichern, kein Weiter.",
}

var eintraege: Array[String] = []
var auswahl := 0


func _ready() -> void:
	if Spielstand.spielstand_datei_vorhanden():
		eintraege.append("Weiter")
	eintraege.append_array(["Neues Spiel", "Iron Man"])
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
		text += ("> " if i == auswahl else "  ") + eintraege[i] + "\n"
	$Menue.text = text
	$Hinweis.text = ERKLAERUNG[eintraege[auswahl]]


func starten(was: String) -> void:
	Spielstand.iron_man = was == "Iron Man"
	match was:
		"Weiter":
			Spielstand.laden()
		"Neues Spiel":
			Spielstand.loeschen()
			Spielstand.neues_spiel()
		"Iron Man":
			Spielstand.neues_spiel()   # der normale Spielstand bleibt, wie er ist
	get_tree().change_scene_to_file(DUNGEON)
