extends Control

# Der Optionen-Bildschirm. Hoch und runter wählt, links und rechts ändert.

const TITEL = "res://titel.tscn"
const EINTRAEGE = ["Sprache", "Schräg laufen", "Vollbild", "Lautstärke", "Zurück"]
const ERKLAERUNG = {
	"Sprache": "Links und rechts wechseln die Sprache.",
	"Schräg laufen": "Im Original läuft der Held nur in vier Richtungen. Mit „an“ geht es auch schräg.",
	"Vollbild": "Vollbild oder Fenstermodus",
	"Lautstärke": "Mehr ist lauter, weniger ist leiser",
	"Zurück": "Zurück zum Titelbildschirm.",
}

var eintraege := EINTRAEGE
var erklaerung := ERKLAERUNG.duplicate()
var auswahl := 0
var im_spiel := false


func _ready() -> void:
	if im_spiel:
		eintraege = EINTRAEGE.filter(func(e: String) -> bool: return e != "Schräg laufen")
		erklaerung["Zurück"] = "Zurück zum Spiel."
	anzeigen()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hoch"):
		auswahl = posmod(auswahl - 1, eintraege.size())
	elif Input.is_action_just_pressed("runter"):
		auswahl = posmod(auswahl + 1, eintraege.size())
	elif Input.is_action_just_pressed("links"):
		aendern(-1)
	elif Input.is_action_just_pressed("rechts") or Input.is_action_just_pressed("angriff"):
		aendern(1)
	else:
		return   # nichts gedrückt, nichts neu zu malen
	anzeigen()


# Die ausgewählte Einstellung eins weiter (oder eins zurück) schalten
func aendern(schritt: int) -> void:
	match eintraege[auswahl]:
		"Sprache":
			var nummer := Optionen.SPRACHEN.find(Optionen.sprache)
			Optionen.sprache = Optionen.SPRACHEN[posmod(nummer + schritt, Optionen.SPRACHEN.size())]
		"Schräg laufen":
			Optionen.schraeg = not Optionen.schraeg
		"Vollbild":
			Optionen.vollbild = not Optionen.vollbild
			Optionen.vollbild_anwenden()
		"Lautstärke":
			Optionen.lautstaerke = clamp(Optionen.lautstaerke + schritt, 0, 10)
			AudioServer.set_bus_volume_db(0, linear_to_db(Optionen.lautstaerke / 10.0))
		"Zurück":
			if Input.is_action_just_pressed("angriff"):
				if im_spiel:
					queue_free()
				else:
					get_tree().change_scene_to_file(TITEL)
			return
	Optionen.speichern()


func anzeigen() -> void:
	var werte := {
		"Sprache": Optionen.SPRACHNAMEN[Optionen.sprache],
		"Schräg laufen": tr("an") if Optionen.schraeg else tr("aus"),
		"Vollbild": tr("an") if Optionen.vollbild else tr("aus"),
		"Lautstärke": str(Optionen.lautstaerke),
	}
	var text := ""
	for i in eintraege.size():
		var eintrag: String = eintraege[i]
		text += ("> " if i == auswahl else "  ") + tr(eintrag)
		if eintrag in werte:
			text += ": " + werte[eintrag]
		text += "\n"
	$Menue.text = text
	$Hinweis.text = tr(erklaerung[eintraege[auswahl]])
