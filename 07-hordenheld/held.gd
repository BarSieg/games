class_name Held
extends CharacterBody2D

signal erfahrung_geaendert(erfahrung: int, ziel: int)
signal level_auf(level: int)

const STARTTEMPO = 70.0        # Pixel pro Sekunde
const WACKELN = 15.0      # so schnell wackelt er beim Laufen hin und her
const WACKEL_WINKEL = 0.15   # so weit, in Radiant (0.15 sind etwa 9 Grad)
const MAX_LEBEN = 100.0
const SCHADEN = 10.0      # so viel Leben kostet ein Gegner pro Sekunde, solange er den Held berührt
const BEBEN_PRO_GEGNER = 0.25   # so viel Beben bringt jeder Gegner, der den Held berührt
const BEBEN_TEMPO = 3.0         # so schnell steigt und fällt das Beben, pro Sekunde
const BEBEN_PIXEL = 4.0         # so weit wackelt das Bild bei vollem Beben
const KAMERA_VORAUSSCHAU = 64   # so viel weiter sieht man in die Richtung, in die der Held läuft

@export var upgrades: Array[Upgrade] = []

var lauf_zeit := 0.0
var erfahrung := 0
var level := 1
var naechstes_level := 5   # so viel Erfahrung braucht das nächste Level
var tempo := STARTTEMPO
var leben := MAX_LEBEN:
	set(wert):
		leben = clampf(wert, 0, MAX_LEBEN)
		$Lebensbalken.value = leben
var stufen: Dictionary[Upgrade, int] = {}   # wie oft welches Upgrade schon gewählt wurde
var beben := 0.0   # 0 = ruhig, 1 = volles Beben

# zum Testen
var testmodus := false   # schaltet das Werkzeug um

func _ready() -> void:
	# Upgrades prüfen. Schritt 1: alle neuen Waffen kurz anhängen, sonst gibt es ihre Knoten nicht
	var neue_waffen := []
	for upgrade in upgrades:
		if upgrade.neue_waffe != null:
			var waffe := upgrade.neue_waffe.instantiate()
			neue_waffen.append(waffe)
			add_child(waffe)
	# Schritt 2: Knoten und Eigenschaften prüfen
	for upgrade in upgrades:
		var finde_knoten := get_node_or_null(upgrade.knoten)
		if finde_knoten == null:
			push_error("Upgrade '" + upgrade.titel + "' braucht den Knoten '" + upgrade.knoten + "'")
		else:
			var finde_eigenschaft = finde_knoten.get_indexed(upgrade.eigenschaft)
			if finde_eigenschaft == null:
				push_error("Upgrade '" + upgrade.titel + "' Knoten '" + upgrade.knoten + "' braucht Eigenschaft '" + upgrade.eigenschaft + "'")
	# Schritt 3: die Waffen wieder wegräumen
	for waffe in neue_waffen:
		waffe.free()


func _physics_process(delta: float) -> void:
	var richtung := Input.get_vector("links", "rechts", "hoch", "runter")
	velocity = richtung * tempo
	move_and_slide()

	if richtung.x != 0:
		$Bild.flip_h = richtung.x < 0
	# Ein Bild pro Figur reicht: Beim Laufen wackelt sie hin und her
	if richtung != Vector2.ZERO:
		lauf_zeit += delta
		$Bild.rotation = sin(lauf_zeit * WACKELN) * WACKEL_WINKEL
	else:
		lauf_zeit = 0.0
		$Bild.rotation = 0.0
	$Camera2D.position = richtung * KAMERA_VORAUSSCHAU

	# Wie viele Gegner berühren mich gerade?
	var treffer: int = $Trefferzone.get_overlapping_bodies().size()
	if treffer > 0 and not testmodus:
		leben -= treffer * SCHADEN * delta
		if leben <= 0:
			get_tree().reload_current_scene()
	$Bild.modulate = Color(1, 0.4, 0.4) if treffer > 0 else Color.WHITE

	# Je mehr Gegner beißen, desto mehr bebt es
	var ziel := 0.0 if testmodus else minf(treffer * BEBEN_PRO_GEGNER, 1.0)
	beben = move_toward(beben, ziel, BEBEN_TEMPO * delta)
	var staerke := beben * beben   # zum Quadrat: wenig Beben bleibt fast ruhig, viel Beben wird heftig
	$Camera2D.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * staerke * BEBEN_PIXEL
	if staerke > 0.0:
		Input.start_joy_vibration(0, staerke, staerke * staerke, 0.1)


func erfahrung_dazu(wert: int) -> void:
	if testmodus:
		return
	erfahrung += wert
	erfahrung_geaendert.emit(erfahrung, naechstes_level)
	level_pruefen()


func level_pruefen() -> void:
	if erfahrung < naechstes_level:
		return
	erfahrung -= naechstes_level   # was zu viel war, bleibt fürs nächste Level
	level += 1
	naechstes_level += 5           # jedes Level braucht 5 mehr als das davor
	erfahrung_geaendert.emit(erfahrung, naechstes_level)
	level_auf.emit(level)


func _on_magnet_area_entered(area: Area2D) -> void:
	area.anziehen(self)


func stufe(upgrade: Upgrade) -> int:
	return stufen.get(upgrade, 0)


func moegliche_upgrades() -> Array[Upgrade]:
	var liste: Array[Upgrade] = []
	for upgrade in upgrades:
		if upgrade.max_stufe == 0 or stufe(upgrade) < upgrade.max_stufe:
			if upgrade.braucht == null or stufe(upgrade.braucht) > 0:
				liste.append(upgrade)
	return liste


func upgrade_waehlen(upgrade: Upgrade) -> void:
	upgrade.anwenden(self, stufe(upgrade))
	stufen[upgrade] = stufe(upgrade) + 1
