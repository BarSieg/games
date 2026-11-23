extends CanvasLayer

var held: Held
var angebot: Array[Upgrade] = []   # die Upgrades, die gerade zur Wahl stehen
var auswahl := 0                   # welches davon markiert ist

@onready var zeilen: Array[Label] = [$Kasten/Wahl1, $Kasten/Wahl2, $Kasten/Wahl3]


func _ready() -> void:
	hide()
	held = get_tree().get_first_node_in_group("held")
	held.level_auf.connect(zeigen)


func zeigen(level: int) -> void:
	angebot = held.moegliche_upgrades()
	if angebot.is_empty():
		return   # alles ausgereizt, dann gibt es eben nichts
	angebot.shuffle()
	angebot.resize(mini(angebot.size(), 3))

	$Kasten/Titel.text = "Level %d!" % level
	for i in 3:
		zeilen[i].visible = i < angebot.size()
		if zeilen[i].visible:
			zeilen[i].text = beschriftung(angebot[i])
	auswahl = 0
	markieren()
	show()
	get_tree().paused = true


func beschriftung(upgrade: Upgrade) -> String:
	var stufe := held.stufe(upgrade)
	if upgrade.neue_waffe != null and stufe == 0:
		return upgrade.titel + "  NEU!"
	if upgrade.max_stufe == 0:
		return upgrade.titel
	return "%s  %d/%d" % [upgrade.titel, stufe + 1, upgrade.max_stufe]


func _process(_delta: float) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("runter"):
		auswahl = wrapi(auswahl + 1, 0, angebot.size())
		markieren()
	elif Input.is_action_just_pressed("hoch"):
		auswahl = wrapi(auswahl - 1, 0, angebot.size())
		markieren()
	elif Input.is_action_just_pressed("ok"):
		waehlen()


func markieren() -> void:
	for i in angebot.size():
		zeilen[i].modulate = Color.YELLOW if i == auswahl else Color(1, 1, 1, 0.5)
	$Kasten/Beschreibung.text = angebot[auswahl].beschreibung


func waehlen() -> void:
	hide()
	get_tree().paused = false
	held.upgrade_waehlen(angebot[auswahl])
	held.level_pruefen()
