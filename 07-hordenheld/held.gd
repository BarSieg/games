class_name Held
extends CharacterBody2D

signal erfahrung_geaendert(erfahrung: int, ziel: int)
signal level_auf(level: int)

const STARTTEMPO = 70.0        # Pixel pro Sekunde
const WACKELN = 15.0      # so schnell wackelt er beim Laufen hin und her
const WACKEL_WINKEL = 0.15   # so weit, in Radiant (0.15 sind etwa 9 Grad)
const MAX_LEBEN = 100.0
const SCHADEN = 10.0      # so viel Leben kostet ein Gegner pro Sekunde, solange er den Held berührt

var lauf_zeit := 0.0
var erfahrung := 0
var level := 1
var naechstes_level := 5   # so viel Erfahrung braucht das nächste Level
var tempo := STARTTEMPO
@export var upgrades: Array[Upgrade] = []

var leben := MAX_LEBEN:
	set(wert):
		leben = clampf(wert, 0, MAX_LEBEN)
		$Lebensbalken.value = leben
var stufen: Dictionary[Upgrade, int] = {}   # wie oft welches Upgrade schon gewählt wurde


func _ready() -> void:
	# prüfe upgrades, schritt 1 alle waffen anhängen
	var neue_waffen := []
	for upgrade in upgrades:
		if upgrade.neue_waffe != null:
			var waffe := upgrade.neue_waffe.instantiate()
			neue_waffen.append(waffe)
			add_child(waffe)
	# jetzt prüfe die knoten und eigenschaften
	for upgrade in upgrades:
		var finde_knoten := get_node_or_null(upgrade.knoten)
		if finde_knoten == null:
			push_error("Upgrade '" + upgrade.titel + "' braucht den Knoten '" + upgrade.knoten + "'")
		else:
			var finde_eigenschaft = finde_knoten.get_indexed(upgrade.eigenschaft)
			if finde_eigenschaft == null:
				push_error("Upgrade '" + upgrade.titel + "' Knoten '" + upgrade.knoten + "' braucht Eigenschaft '" + upgrade.eigenschaft + "'")
	# und lösche die zusätzlichen waffen wieder
	for waffe in neue_waffen:
		waffe.queue_free()

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

	# Wie viele Gegner berühren mich gerade?
	var treffer: int = $Trefferzone.get_overlapping_bodies().size()
	if treffer > 0:
		leben -= treffer * SCHADEN * delta
		if leben <= 0:
			get_tree().reload_current_scene()
	$Bild.modulate = Color(1, 0.4, 0.4) if treffer > 0 else Color.WHITE


func erfahrung_dazu(wert: int) -> void:
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
