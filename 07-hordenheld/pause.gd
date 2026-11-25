extends CanvasLayer

# Das Pausenmenü. Start öffnet und schließt es, darin lassen sich die Optionen ändern.

const TITEL = "res://titel.tscn"

var eintraege: Array[String] = ["Weiter", "Musik", "Beben", "Brummen", "Zum Titelbild"]
var auswahl := 0
var dauer := 0.0


func _ready() -> void:
	hide()
	var held: Held = get_tree().get_first_node_in_group("held")
	held.pause.connect(zeigen)


func _process(delta: float) -> void:
	dauer += delta
	$Titel.modulate.a = cos(dauer * 10)
	if not visible:
		return
	if Input.is_action_just_pressed("hoch"):
		auswahl = posmod(auswahl - 1, eintraege.size())
	elif Input.is_action_just_pressed("runter"):
		auswahl = posmod(auswahl + 1, eintraege.size())
	elif Input.is_action_just_pressed("links"):
		aendern(-1)
	elif Input.is_action_just_pressed("rechts") or Input.is_action_just_pressed("ok"):
		aendern(1)
	elif Input.is_action_just_pressed("pause"):
		hide()
		get_tree().paused = false
	else:
		return   # nichts gedrückt, nichts neu zu schreiben
	anzeigen()


# Den ausgewählten Eintrag eins weiter (oder eins zurück) schalten
func aendern(schritt: int) -> void:
	match eintraege[auswahl]:
		"Weiter":
			if Input.is_action_just_pressed("ok"):
				hide()
				get_tree().paused = false
			return
		"Musik":
			Optionen.musik = clampi(Optionen.musik + schritt, 0, 10)
		"Beben":
			Optionen.beben = not Optionen.beben
		"Brummen":
			Optionen.brummen = not Optionen.brummen
			if Optionen.brummen:
				Optionen.brummen_lassen(0.5, 0.5, 0.2)   # kurz brummen, damit man merkt, wie es sich anfühlt
		"Zum Titelbild":
			if Input.is_action_just_pressed("ok"):
				get_tree().paused = false
				get_tree().change_scene_to_file(TITEL)
			return
	Optionen.speichern()


func anzeigen() -> void:
	var werte := {
		"Musik": str(Optionen.musik),
		"Beben": "an" if Optionen.beben else "aus",
		"Brummen": "an" if Optionen.brummen else "aus",
	}
	var text := ""
	for i in eintraege.size():
		var eintrag := eintraege[i]
		text += ("> " if i == auswahl else "  ") + eintrag
		if eintrag in werte:
			text += ": " + werte[eintrag]
		text += "\n"
	$Kasten/Menue.text = text


func zeigen() -> void:
	get_tree().paused = true
	await get_tree().create_timer(0.01).timeout
	show()
	anzeigen()
