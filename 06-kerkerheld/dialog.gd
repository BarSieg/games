extends CanvasLayer

signal fertig

const TEMPO = 30.0   # Buchstaben pro Sekunde

var seiten: Array[String] = []   # was noch kommt
var buchstaben := 0.0            # wie viele Buchstaben schon zu sehen sind, mit Komma
var fragend := false             # wartet die letzte Seite auf Ja oder Nein?
var antwort := true
var buchstaben_anzeige := 0.0

@onready var text: Label = $Rahmen/Text


func _ready() -> void:
	hide()


# Eine oder mehrere Seiten nacheinander zeigen. Solange steht das Spiel still.
func zeigen(neue_seiten: Array[String], sprecher: String = "") -> void:
	seiten = neue_seiten.duplicate()
	get_tree().paused = true
	show()
	%Sprechername.text = sprecher + ":"
	$Sprecherrahmen.visible = (sprecher != "")
	umblaettern()
	await fertig


# Eine Frage stellen. Die Antwort ist true für Ja und false für Nein.
func frage(seite: String, sprecher: String = "") -> bool:
	fragend = true
	antwort = true
	await zeigen([seite], sprecher)
	fragend = false
	return antwort


func umblaettern() -> void:
	text.text = seiten.pop_front()
	text.visible_characters = 0
	buchstaben = 0.0
	buchstaben_anzeige = 0.0


func _process(delta: float) -> void:
	var chat_teil := ""
	if not visible:
		return
	if not alles_da():
		buchstaben += TEMPO * delta
	if buchstaben > buchstaben_anzeige:
		chat_teil = text.text.substr(int(buchstaben_anzeige), int(buchstaben - buchstaben_anzeige))
		if chat_teil.replace(" ", "").length() > 1:
			$Chat.pitch_scale = randf_range(0.8, 1.2)
			$Chat.play()
			buchstaben_anzeige = buchstaben
	text.visible_characters = int(buchstaben)
	var letzte := seiten.is_empty()
	# Blinkender Pfeil: Es geht weiter
	$Rahmen/Weiter.visible = alles_da() and not (letzte and fragend) and Time.get_ticks_msec() % 600 < 300
	$Rahmen/Auswahl.visible = alles_da() and letzte and fragend
	$Rahmen/Auswahl.text = "> Ja     Nein" if antwort else "   Ja  > Nein"


func alles_da() -> bool:
	return buchstaben >= text.get_total_character_count()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if $Rahmen/Auswahl.visible and (event.is_action_pressed("links") or event.is_action_pressed("rechts")):
		antwort = not antwort
	elif event.is_action_pressed("angriff"):
		if not alles_da():
			buchstaben = text.get_total_character_count()   # Ungeduldig? Dann alles auf einmal.
		elif not seiten.is_empty():
			umblaettern()
		else:
			schliessen()


func schliessen() -> void:
	hide()
	# Erst weiterspielen, wenn die Taste losgelassen ist. Sonst sticht der Held mit demselben Druck gleich zu.
	while Input.is_action_pressed("angriff"):
		await get_tree().process_frame
	get_tree().paused = false
	fertig.emit()
