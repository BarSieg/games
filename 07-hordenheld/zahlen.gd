extends Node2D

# Alle Schadenszahlen auf einmal, gezeichnet von einem einzigen Knoten.
# Jede Zahl ist nur ein Eintrag in vier Listen: wo, welcher Wert, wann entstanden, ob kritisch.

const DAUER = 0.6        # so lange ist eine Zahl zu sehen
const STEIGEN = 20.0     # so viele Pixel steigt sie in der Zeit nach oben
const HOECHSTENS = 300   # mehr Zahlen gleichzeitig nicht, sonst sieht man nichts mehr
const GROESSE = 16       # Schriftgröße
const GROESSE_KRIT = 24  # Schriftgröße bei kritischen Treffern
const BREITE = 40.0      # in so einem breiten Kasten wird die Zahl mittig geschrieben

var orte := PackedVector2Array()
var werte := PackedInt32Array()
var geburt := PackedFloat32Array()
var kritisch := PackedByteArray()
var zeit := 0.0
var schrift: Font


func _ready() -> void:
	schrift = load("res://schrift.tres").font


func zeigen(ort: Vector2, wert: int, krit: bool) -> void:
	if orte.size() >= HOECHSTENS:
		weg_mit_der_aeltesten()
	orte.append(ort + Vector2(randf_range(-4, 4), -8))
	werte.append(wert)
	geburt.append(zeit)
	kritisch.append(int(krit))


func weg_mit_der_aeltesten() -> void:
	orte.remove_at(0)
	werte.remove_at(0)
	geburt.remove_at(0)
	kritisch.remove_at(0)


func _process(delta: float) -> void:
	zeit += delta
	# Neue Zahlen kommen hinten dazu, also stehen die ältesten immer vorne
	while geburt.size() > 0 and zeit - geburt[0] > DAUER:
		weg_mit_der_aeltesten()
	queue_redraw()


func _draw() -> void:
	for i in orte.size():
		var alter := (zeit - geburt[i]) / DAUER   # 0 = neu, 1 = gleich weg
		var ort := orte[i] + Vector2(-BREITE / 2, -STEIGEN * alter)
		var krit := bool(kritisch[i])
		var farbe := Color(1, 1, 0 if krit else 1, 1.0 - alter * alter)
		var rand := Color(0, 0, 0, farbe.a)
		draw_string_outline(schrift, ort, str(werte[i]), HORIZONTAL_ALIGNMENT_CENTER, BREITE, GROESSE_KRIT if krit else GROESSE, 4, rand)
		draw_string(schrift, ort, str(werte[i]), HORIZONTAL_ALIGNMENT_CENTER, BREITE, GROESSE_KRIT if krit else GROESSE, farbe)
