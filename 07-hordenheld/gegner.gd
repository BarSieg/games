extends CharacterBody2D

const WACKELN = 12.0
const WACKEL_WINKEL = 0.15
const MAX_ABSTAND = 300.0        # ist ein Gegner so viele Pixel hinter dem Held,
const TELEPORT_ABSTAND = 250.0   # springt er so viele Pixel vor den Held

@export var tempo := 30.0   # Pixel pro Sekunde, langsamer als der Held
@export var leben := 2      # so viele Treffer hält er aus
@export var beute_szene: PackedScene   # das bleibt liegen, wenn er stirbt
@export var erfahrung := 1             # so viel ist die Beute wert

var held: Node2D
# Jeder Gegner fängt an einer anderen Stelle der Wackel-Welle an. Sonst wackeln alle im Gleichtakt.
var lauf_zeit := randf() * TAU


func _ready() -> void:
	held = get_tree().get_first_node_in_group("held")


func _physics_process(delta: float) -> void:
	# Abstand zum Held messen und, falls zu weit, nach vorn springen
	var richtung := global_position.direction_to(held.global_position)
	if (global_position - held.global_position).length() > MAX_ABSTAND:
		global_position += richtung * (MAX_ABSTAND + TELEPORT_ABSTAND)
		richtung *= -1
	# stur zulaufen
	velocity = richtung * tempo
	move_and_slide()

	$Bild.flip_h = richtung.x < 0
	lauf_zeit += delta
	$Bild.rotation = sin(lauf_zeit * WACKELN) * WACKEL_WINKEL


func treffer(schaden: int, stoss: Vector2 = Vector2.ZERO) -> void:
	if leben <= 0:
		return   # schon tot, wartet nur noch aufs Wegräumen
	leben -= schaden
	if leben <= 0:
		sterben()
	else:
		position += stoss


func sterben() -> void:
	var beute := beute_szene.instantiate()
	beute.wert = erfahrung
	beute.position = global_position
	# call_deferred: erst am Ende des Bildes einfügen, siehe unten
	get_tree().current_scene.add_child.call_deferred(beute)
	queue_free()
