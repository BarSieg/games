extends CharacterBody2D

const WACKELN = 12.0
const WACKEL_WINKEL = 0.15
const MAX_ABSTAND = 300.0        # ist ein Gegner so viele Pixel hinter dem Held,
const TELEPORT_ABSTAND = 250.0   # springt er so viele Pixel vor den Held
const FLUEGELSCHLAG = 20.0   # so schnell schlägt eine Fledermaus mit den Flügeln
const FLUEGEL_BREITE = 0.3   # so stark wird das Bild schmaler und breiter (0.3 = 70 % bis 130 %)
const BLITZ_DAUER = 0.1      # so lange leuchtet ein Gegner nach einem Treffer
const BLITZ_FARBE = Color(4, 4, 4)   # mehr als 1: heller als das Bild selbst, fast weiß
const STERBE_DAUER = 0.2     # so lange schrumpft ein Gegner, bevor er verschwindet
const EXPLOSIONSTEMPO = 150  # Pixel pro Sekunde

@export var flattern := false   # an: flattern statt wackeln
@export var tempo := 30.0   # Pixel pro Sekunde, langsamer als der Held
@export var leben := 2      # so viele Treffer hält er aus
@export var beute_szene: PackedScene   # das bleibt liegen, wenn er stirbt
@export var erfahrung := 1             # so viel ist die Beute wert
@export var rueckstoss := 1.0

var held: Node2D
var zahlen: Node2D
var blitz := 0.0   # wie lange er noch leuchtet
# Jeder Gegner fängt an einer anderen Stelle der Wackel-Welle an. Sonst wackeln alle im Gleichtakt.
var lauf_zeit := randf() * TAU


func _ready() -> void:
	held = get_tree().get_first_node_in_group("held")
	zahlen = get_tree().get_first_node_in_group("zahlen")


func _physics_process(delta: float) -> void:
	# Abstand zum Held messen und, falls zu weit, nach vorn springen
	var richtung := global_position.direction_to(held.global_position)
	if (global_position - held.global_position).length() > MAX_ABSTAND:
		global_position += richtung * (MAX_ABSTAND + TELEPORT_ABSTAND)
		richtung *= -1
	# stur zulaufen
	velocity = richtung * tempo
	position += velocity * delta

	$Bild.flip_h = richtung.x < 0
	lauf_zeit += delta
	if flattern:
		$Bild.scale.x = 1.0 + sin(lauf_zeit * FLUEGELSCHLAG) * FLUEGEL_BREITE
		$Bild.scale.y = 1.0 - sin(lauf_zeit * FLUEGELSCHLAG) * FLUEGEL_BREITE / 2
	else:
		$Bild.rotation = sin(lauf_zeit * WACKELN) * WACKEL_WINKEL

	if blitz > 0.0:
		blitz -= delta
		$Bild.modulate = BLITZ_FARBE if blitz > 0.0 else Color.WHITE


func treffer(schaden: int, stoss: Vector2 = Vector2.ZERO) -> void:
	if leben <= 0:
		return   # schon tot, wartet nur noch aufs Wegräumen
	var krit := randf() < 0.1
	if krit:
		schaden *= 2
	leben -= schaden
	zahlen.zeigen(global_position, schaden, krit)
	if leben <= 0:
		sterben()
	else:
		position += stoss * rueckstoss
		blitz = BLITZ_DAUER


func sterben() -> void:
	$"..".kills += 1
	var beute := beute_szene.instantiate()
	beute.wert = erfahrung
	beute.position = global_position
	# call_deferred: erst am Ende des Bildes einfügen, siehe unten
	get_tree().current_scene.add_child.call_deferred(beute)

	# Noch nicht weg: kurz aufleuchten und zusammenschrumpfen
	remove_from_group("gegner")   # die Waffen zielen nicht mehr auf ihn
	collision_layer = 0           # nichts trifft ihn mehr, er tut dem Held nicht mehr weh
	set_physics_process(false)    # er läuft nicht mehr und flattert nicht mehr
	$Bild.modulate = BLITZ_FARBE
	var tween := create_tween()
	tween.tween_property($Bild, "scale", Vector2.ZERO, STERBE_DAUER)
	tween.tween_callback(queue_free)


func platt() -> void:
	$Bild.modulate = BLITZ_FARBE
	var tween := create_tween()
	tween.tween_property($Bild, "scale:y", 0, STERBE_DAUER)
	tween.tween_callback(queue_free)

func explodieren() -> void:
	if not is_in_group("gegner"):
		return   # stirbt sowieso schon
	set_physics_process(false)   # stehen bleiben: kein Laufen, kein Teleportieren
	collision_layer = 0          # tut dem Held nichts mehr, keine Waffe trifft ihn mehr
	remove_from_group("gegner")  # kein Messer zielt mehr auf ihn
	$Bild.modulate = Color.WHITE
	get_tree().create_timer((held.global_position - global_position).length() / EXPLOSIONSTEMPO, false, false).timeout.connect(platt)
