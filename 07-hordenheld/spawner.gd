extends Node2D

const ABSTAND = 20.0   # so weit vom Bildrand spawnen die Gegner
const PLATZ = 12.0       # so viel Abstand will jeder Gegner zu jedem anderen
const KAESTCHEN = 12.0   # so groß ist ein Kästchen im Raster, nie kleiner als PLATZ
const SCHIEBEN = 0.15    # so viel von der Überlappung wird pro Schritt weggeschoben
const SCHUBBEGRENZUNG = 6.0   # nicht mehr als das, sonst schieben sich die Gegner durcheinander
# das eigene Kästchen, rechts daneben und die drei darunter
const HALBE_NACHBARN = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)]

@export var wellen: Array[Welle] = []

var uhr: Uhr
var welle_nr := 0   # die wievielte Welle gerade läuft, von 0 an gezählt
var warten := 0.0
var schritt := 0   # für halbe Arbeit
var leben_mal := 1.0
var tempo_mal := 1.0
var kills := 0


func _ready() -> void:
	uhr = get_tree().get_first_node_in_group("uhr")
	uhr.abgelaufen.connect(explosion)
	Musik.spielen(Musik.KAMPF)


func _process(delta: float) -> void:
	# Ist die nächste Welle dran?
	if welle_nr + 1 < wellen.size() and uhr.zeit >= wellen[welle_nr + 1].start:
		welle_nr += 1
		leben_mal = wellen[welle_nr].leben_mal
		tempo_mal = wellen[welle_nr].tempo_mal
		if welle_nr == wellen.size() - 1:
			Musik.spielen(Musik.ENDSPURT)   # die letzte Welle: Endspurt
		if wellen[welle_nr].elite != null:
			einsetzen(wellen[welle_nr].elite.instantiate())
		einkesseln(wellen[welle_nr].kessel)

	warten -= delta
	# while statt if: Ist der Takt kürzer als ein Bild, kommen mehrere Gegner im selben Bild
	while warten <= 0:
		neuer_gegner()
		warten += wellen[welle_nr].takt


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
		gegner[i].position += schub[i].limit_length(SCHUBBEGRENZUNG)


func neuer_gegner() -> void:
	var szenen := wellen[welle_nr].gegner
	einsetzen(szenen[randi() % szenen.size()].instantiate())


# Setzt einen Gegner an eine zufällige Stelle knapp hinter dem Bildrand
func einsetzen(gegner: Node2D) -> void:
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
	aufstellen(gegner, get_viewport().get_camera_2d().get_screen_center_position() + (minf(tx, ty) + ABSTAND) * alpha)



# Ein Ring aus Gegnern rund um den Held, überall knapp hinter dem Bildrand
func einkesseln(anzahl: int) -> void:
	var held: Node2D = get_tree().get_first_node_in_group("held")
	var radius := get_viewport_rect().size.length() / 2 + ABSTAND   # die halbe Bildschirmdiagonale reicht bis in jede Ecke
	# nur die erste Sorte der Welle: Fledermäuse wären viel früher da, und der Ring hätte Lücken
	var szene := wellen[welle_nr].gegner[0]
	for i in anzahl:
		aufstellen(szene.instantiate(), held.global_position + Vector2.from_angle(TAU * i / anzahl) * radius)


# Der Gegner kommt an seinen Platz, mit den Werten der Welle
func aufstellen(gegner: Node2D, ort: Vector2) -> void:
	gegner.position = ort
	gegner.leben = ceili(gegner.leben * leben_mal)
	gegner.tempo *= tempo_mal
	add_child(gegner)


# Explodiere alle Gegner am Ende der Runde
func explosion() -> void:
	set_process(false)
	set_physics_process(false)
	for monster in get_children():
		monster.explodieren()
