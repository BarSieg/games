extends Control

# Das Titelbild, zugleich die Optionen. Hoch und runter wählt, links und rechts ändert, OK startet.

const WELT = "res://welt.tscn"
const ERKLAERUNG = {
	"Spielen": "Überlebe fünf Minuten. Deine Waffen feuern von selbst.",
	"Musik": "Links und rechts: leiser und lauter.",
	"Beben": "Das Bild wackelt, wenn Gegner dich beißen.",
	"Brummen": "Der Controller brummt, wenn Gegner dich beißen.",
	"Vollbild": "Im Fenster oder auf dem ganzen Bildschirm.",
}

var eintraege: Array[String] = ["Spielen", "Musik", "Beben", "Brummen", "Vollbild"]
var auswahl := 0


func _ready() -> void:
	Musik.spielen(Musik.TITEL)
	if OS.has_feature("web"):
		eintraege.erase("Vollbild")   # im Browser gibt es dafür F11
	anzeigen()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hoch"):
		auswahl = posmod(auswahl - 1, eintraege.size())
	elif Input.is_action_just_pressed("runter"):
		auswahl = posmod(auswahl + 1, eintraege.size())
	elif Input.is_action_just_pressed("links"):
		aendern(-1)
	elif Input.is_action_just_pressed("rechts") or Input.is_action_just_pressed("ok"):
		aendern(1)
	else:
		return   # nichts gedrückt, nichts neu zu schreiben
	anzeigen()


# Den ausgewählten Eintrag eins weiter (oder eins zurück) schalten
func aendern(schritt: int) -> void:
	match eintraege[auswahl]:
		"Spielen":
			if Input.is_action_just_pressed("ok"):
				get_tree().change_scene_to_file(WELT)
			return
		"Musik":
			Optionen.musik = clampi(Optionen.musik + schritt, 0, 10)
		"Beben":
			Optionen.beben = not Optionen.beben
		"Brummen":
			Optionen.brummen = not Optionen.brummen
			if Optionen.brummen:
				Input.start_joy_vibration(0, 0.5, 0.5, 0.2)   # kurz brummen, damit man merkt, wie es sich anfühlt
		"Vollbild":
			Optionen.vollbild = not Optionen.vollbild
	Optionen.speichern()


func anzeigen() -> void:
	var werte := {
		"Musik": str(Optionen.musik),
		"Beben": "an" if Optionen.beben else "aus",
		"Brummen": "an" if Optionen.brummen else "aus",
		"Vollbild": "an" if Optionen.vollbild else "aus",
	}
	var text := ""
	for i in eintraege.size():
		var eintrag := eintraege[i]
		text += ("> " if i == auswahl else "  ") + eintrag
		if eintrag in werte:
			text += ": " + werte[eintrag]
		text += "\n"
	$Menue.text = text
	$Hinweis.text = ERKLAERUNG[eintraege[auswahl]]
