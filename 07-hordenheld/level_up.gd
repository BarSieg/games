extends CanvasLayer

var held: Held
var angebot: Array[String] = []   # die drei Upgrades, die gerade zur Wahl stehen
var auswahl := 0                  # welches davon markiert ist

@onready var zeilen: Array[Label] = [$Kasten/Wahl1, $Kasten/Wahl2, $Kasten/Wahl3]


func _ready() -> void:
	hide()
	held = get_tree().get_first_node_in_group("held")
	held.level_auf.connect(zeigen)


func zeigen(level: int) -> void:
	$Kasten/Titel.text = "Level %d!" % level
	# Alle Upgrades mischen und die ersten drei nehmen: drei verschiedene, zufällig
	angebot.assign(Held.UPGRADES)
	angebot.shuffle()
	angebot.resize(3)
	for i in 3:
		zeilen[i].text = angebot[i]
	auswahl = 0
	markieren()
	show()
	get_tree().paused = true


func _process(_delta: float) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("runter"):
		auswahl = wrapi(auswahl + 1, 0, 3)
		markieren()
	elif Input.is_action_just_pressed("hoch"):
		auswahl = wrapi(auswahl - 1, 0, 3)
		markieren()
	elif Input.is_action_just_pressed("ok"):
		waehlen()


func markieren() -> void:
	for i in 3:
		zeilen[i].modulate = Color.YELLOW if i == auswahl else Color(1, 1, 1, 0.5)


func waehlen() -> void:
	hide()
	get_tree().paused = false
	held.upgrade(angebot[auswahl])
	# Hat der Held genug Erfahrung für noch ein Level, kommt das Menü gleich noch einmal
	held.level_pruefen()
