extends Node2D

const ABSTAND = 20.0   # so weit vom Bildrand spawnen die Gegner
const START_TAKT = 1.0  # am Anfang eine Sekunde zwischen zwei Gegnern
const MIN_TAKT = 0.1    # schneller wird es nicht: zehn Gegner pro Sekunde
const SCHNELLER = 0.97  # nach jedem Gegner wird der Takt 3 % kürzer
const PLATZ = 12.0       # so viel Abstand will jeder Gegner zu jedem anderen
const KAESTCHEN = 12.0   # so groß ist ein Kästchen im Raster, nie kleiner als PLATZ
const SCHIEBEN = 0.15    # so viel von der Überlappung wird pro Schritt weggeschoben
# das eigene Kästchen, rechts daneben und die drei darunter
const HALBE_NACHBARN = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)]

@export var gegner_szenen: Array[PackedScene]

var takt := START_TAKT
var warten := START_TAKT
var schritt := 0   # für halbe Arbeit


func _process(delta: float) -> void:
	warten -= delta
	# while statt if: Ist der Takt kürzer als ein Bild, kommen mehrere Gegner im selben Bild
	while warten <= 0:
		neuer_gegner()
		takt = maxf(MIN_TAKT, takt * SCHNELLER)
		warten += takt


func _physics_process(_delta: float) -> void:
	platz_machen()


func platz_machen() -> void:
	var gegner := get_children()

	# 1. Jeden Gegner nur einmal nach seiner Position fragen
	var orte := PackedVector2Array()
	for einer: Node2D in gegner:
		orte.append(einer.position)

	# 2. Das Raster: zu jedem Kästchen die Nummern der Gegner darin
	var raster: Dictionary[Vector2i, PackedInt32Array] = {}
	for i in orte.size():
		var kaestchen := Vector2i((orte[i] / KAESTCHEN).floor())
		if not raster.has(kaestchen):
			raster[kaestchen] = PackedInt32Array()
		raster[kaestchen].append(i)

	# 3. Jedes Paar nur einmal: Jedes Kästchen schaut in sich selbst und in vier Nachbarn
	schritt += 1
	var schub := PackedVector2Array()
	schub.resize(orte.size())
	for kaestchen in raster:
		if (kaestchen.x + kaestchen.y + schritt) % 2 == 0:
			var hier := raster[kaestchen]
			for richtung in HALBE_NACHBARN:
				if not raster.has(kaestchen + richtung):
					continue
				var dort := raster[kaestchen + richtung]
				for a in hier.size():
					var i := hier[a]
					# im eigenen Kästchen nur mit denen, die nach mir in der Liste stehen
					var anfang := a + 1 if richtung == Vector2i.ZERO else 0
					for b in range(anfang, dort.size()):
						var j := dort[b]
						var weg := orte[i] - orte[j]
						var abstand := weg.length()
						if abstand < PLATZ:
							if abstand < 0.01:
								# genau aufeinander: irgendeine Richtung
								weg = Vector2.from_angle(randf() * TAU)
								abstand = 1.0
							var stoss := weg / abstand * (PLATZ - abstand) * SCHIEBEN * 2
							schub[i] += stoss   # i wird weggeschoben,
							schub[j] -= stoss   # j genauso weit in die andere Richtung

	# 4. Alle auf einmal verschieben
	for i in gegner.size():
		gegner[i].position += schub[i]


func neuer_gegner() -> void:
	var gegner := gegner_szenen[randi() % gegner_szenen.size()].instantiate()

	# Eine zufällige Richtung von der Bildmitte aus
	var alpha := Vector2.from_angle(randf() * TAU)

	var bx := get_viewport_rect().size.x / 2   # halbe Bildschirmbreite
	var by := get_viewport_rect().size.y / 2   # halbe Bildschirmhöhe

	var tx := INF   # Abstand zum Schnittpunkt
	var ty := INF   # Abstand zum Schnittpunkt

	# Wo schneidet die Richtung den linken oder rechten Bildschirmrand?
	if alpha.x > 0:
		tx = bx / alpha.x    # rechts
	elif alpha.x < 0:
		tx = -bx / alpha.x   # links

	# Wo schneidet die Richtung den oberen oder unteren Bildschirmrand?
	if alpha.y > 0:
		ty = by / alpha.y    # unten
	elif alpha.y < 0:
		ty = -by / alpha.y   # oben

	# Den näheren Schnittpunkt nehmen, plus ABSTAND hinter den Bildschirmrand
	gegner.position = get_viewport().get_camera_2d().get_screen_center_position() + (minf(tx, ty) + ABSTAND) * alpha
	add_child(gegner)
