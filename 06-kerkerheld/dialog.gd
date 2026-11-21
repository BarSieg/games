extends CanvasLayer

signal fertig

const TEMPO = 30.0   # Buchstaben pro Sekunde

var seiten: Array[String] = []   # was noch kommt
var buchstaben := 0.0            # wie viele Buchstaben schon zu sehen sind, mit Komma
var fragend := false             # wartet die letzte Seite auf Ja oder Nein?
var antwort := true
var auswahlfragend := false      # wartet die letzte Seite auf eine Auswahl aus einer Liste?
var auswahlantwort := 0          # die wievielte Antwort gerade markiert ist
var auswahloptionen: Array[String] = []
var buchstaben_anzeige := 0.0    # bis hierhin wurde schon geplappert

@onready var text: Label = $Rahmen/Text


func _ready() -> void:
	hide()


# Eine oder mehrere Seiten nacheinander zeigen. Solange steht das Spiel still.
func zeigen(neue_seiten: Array[String], sprecher: String = "") -> void:
	# Jede Seite übersetzen. Steht sie nicht in texte.csv, bleibt sie, wie sie ist.
	seiten.assign(neue_seiten.map(func(seite: String) -> String: return tr(seite)))
	get_tree().paused = true
	show()
	%Sprechername.text = tr(sprecher) + ":"
	$Sprecherrahmen.visible = (sprecher != "")
	# Der Rahmen wächst und schrumpft mit dem Namen: Textbreite plus 3 Pixel Luft links und rechts
	var breite: float = %Sprechername.get_minimum_size().x + 6
	$Sprecherrahmen/Sprecherinnen.size.x = breite
	$Sprecherrahmen.size.x = breite + 2
	umblaettern()
	await fertig


# Eine Frage stellen. Die Antwort ist true für Ja und false für Nein.
func frage(seite: String, sprecher: String = "") -> bool:
	fragend = true
	antwort = true
	await zeigen([seite], sprecher)
	fragend = false
	return antwort


# Eine Frage mit mehreren Antworten untereinander. Zurück kommt die Nummer der gewählten Antwort.
func auswahlfrage(seite: String, antworten: Array[String], sprecher: String = "") -> int:
	auswahloptionen.assign(antworten.map(func(option: String) -> String: return tr(option)))
	auswahlfragend = true
	auswahlantwort = 0
	await zeigen([seite], sprecher)
	auswahlfragend = false
	return auswahlantwort


func umblaettern() -> void:
	text.text = seiten.pop_front()
	text.visible_characters = 0
	buchstaben = 0.0
	buchstaben_anzeige = 0.0


func _process(delta: float) -> void:
	var chat_teil := ""
	if not visible:
		return
	# Input statt _unhandled_input: Der Stick schickt bei jedem Zittern ein neues Ereignis,
	# just_pressed meldet sich dagegen nur einmal pro Druck
	if $Rahmen/Auswahl.visible and (Input.is_action_just_pressed("links") or Input.is_action_just_pressed("rechts")):
		antwort = not antwort
	elif $Rahmen/Mehrfachauswahl.visible and Input.is_action_just_pressed("runter"):
		auswahlantwort = posmod(auswahlantwort + 1, auswahloptionen.size())
	elif $Rahmen/Mehrfachauswahl.visible and Input.is_action_just_pressed("hoch"):
		auswahlantwort = posmod(auswahlantwort - 1, auswahloptionen.size())
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
	$Rahmen/Weiter.visible = alles_da() and not (letzte and (fragend or auswahlfragend)) and Time.get_ticks_msec() % 600 < 300
	$Rahmen/Auswahl.visible = alles_da() and letzte and fragend
	var ja := tr("Ja")
	var nein := tr("Nein")
	$Rahmen/Auswahl.text = "> %s     %s" % [ja, nein] if antwort else "   %s  > %s" % [ja, nein]
	$Rahmen/Mehrfachauswahl.visible = alles_da() and letzte and auswahlfragend
	$Rahmen/Mehrfachauswahl.text = ""
	for t in auswahloptionen.size():
		if auswahlantwort == t:
			$Rahmen/Mehrfachauswahl.text += "> "
		else:
			$Rahmen/Mehrfachauswahl.text += "   "
		$Rahmen/Mehrfachauswahl.text += auswahloptionen[t] + "\n"


func alles_da() -> bool:
	return buchstaben >= text.get_total_character_count()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("angriff"):
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
