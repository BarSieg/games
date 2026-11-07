extends CanvasLayer

# Knöpfe für Handy und Tablet: links das Steuerkreuz, rechts A und B.
# Auf dem PC sind sie unsichtbar (TOUCHSCREEN_ONLY). Spielstand hängt diese Ebene an,
# deshalb gibt es sie in jeder Szene, auch auf dem Start- und Ende-Bildschirm.

const GROESSE = 32   # wie die Bilder in touch/
const RAND = 6       # Abstand zum Bildschirmrand

# Name des Bildes, Aktion und Platz in Knopfgrößen.
# Steuerkreuz: gezählt von links unten, A und B: von rechts unten.
const STEUERKREUZ = [
	["pfeil_hoch", "", Vector2(1, 0)],   # macht nichts, wie beim echten Controller
	["pfeil_links", "links", Vector2(0, 1)],
	["pfeil_rechts", "rechts", Vector2(2, 1)],
	["pfeil_runter", "runter", Vector2(1, 2)],
]
const AKTIONEN = [
	["knopf_b", "rennen", Vector2(0, 0.8)],
	["knopf_a", "springen", Vector2(1.2, 0)],
]

var knoepfe := {}   # Knopf -> [Platz, rechts oder links]


func _ready() -> void:
	layer = 10   # über der Anzeige
	for eintrag in STEUERKREUZ:
		knopf_anlegen(eintrag, false)
	for eintrag in AKTIONEN:
		knopf_anlegen(eintrag, true)
	get_viewport().size_changed.connect(anordnen)
	anordnen()


func knopf_anlegen(eintrag: Array, rechts: bool) -> void:
	var knopf := TouchScreenButton.new()
	knopf.texture_normal = load("res://touch/%s.png" % eintrag[0])
	knopf.texture_pressed = load("res://touch/%s_gedrueckt.png" % eintrag[0])
	knopf.action = eintrag[1]
	knopf.passby_press = true   # Finger rutscht auf den Nachbarknopf: der wird gedrückt
	knopf.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
	add_child(knopf)
	knoepfe[knopf] = [eintrag[2], rechts]


# Bei Stretch Aspect "expand" ändert sich die Bildbreite, also neu verteilen
func anordnen() -> void:
	var bild := get_viewport().get_visible_rect().size
	for knopf in knoepfe:
		var platz: Vector2 = knoepfe[knopf][0] * GROESSE
		if knoepfe[knopf][1]:
			knopf.position = Vector2(bild.x - RAND - 2.2 * GROESSE + platz.x, bild.y - RAND - 1.8 * GROESSE + platz.y)
		else:
			knopf.position = Vector2(RAND + platz.x, bild.y - RAND - 3 * GROESSE + platz.y)
