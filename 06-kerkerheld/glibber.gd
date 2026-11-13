extends Monster

enum Zustand { WANDERN, JAGEN, ANLAUF, SPRUNG, RUHE, GETROFFEN }

const WANDER_TEMPO = 25.0
const JAGD_TEMPO = 40.0
const SPRUNG_TEMPO = 160.0
const RUECKSTOSS = 180.0      # so schnell fliegt er nach einem Treffer zurück
const BREMSE = 600.0          # so schnell kommt er danach zum Stehen
const SEHWEITE = 64.0         # so nah muss der Held kommen, damit der Glibber ihn bemerkt
const VERGESSWEITE = 96.0     # so weit weg muss der Held sein, damit er ihn wieder vergisst
const SPRUNGWEITE = 28.0      # aus dieser Nähe springt er an
const HERZ_DROPRATE = 0.2
const MUENZ_DROPRATE = 0.3
const MUENZ_DROP_MAX = 2

@export var leben := 2
@export var schaden := 1   # in halben Herzen
@export var zeige_zustand := false

var zustand := Zustand.WANDERN
var zustand_zeit := 0.0       # wie lange der aktuelle Zustand noch dauert
var richtung := Vector2.ZERO
var start_leben := 0          # wird in _ready() gesetzt

@onready var held: Node2D = get_tree().get_first_node_in_group("held")


func _ready() -> void:
	super()
	start_leben = leben
	wechseln(Zustand.WANDERN)
	$Anzeige.visible = zeige_zustand
	herzdroprate = HERZ_DROPRATE
	muenzdroprate = MUENZ_DROPRATE
	muenzdropmax = MUENZ_DROP_MAX


func _physics_process(delta: float) -> void:
	zustand_zeit -= delta
	var abstand := global_position.distance_to(held.global_position)

	match zustand:
		Zustand.WANDERN:
			velocity = richtung * WANDER_TEMPO
			if abstand < SEHWEITE:
				$RayCast2D.target_position = held.global_position - global_position
				$RayCast2D.force_raycast_update()
				if not $RayCast2D.is_colliding():
					wechseln(Zustand.JAGEN)
			elif zustand_zeit <= 0 or is_on_wall():
				wechseln(Zustand.WANDERN)   # neue Richtung würfeln
		Zustand.JAGEN:
			velocity = global_position.direction_to(held.global_position) * JAGD_TEMPO
			if abstand > VERGESSWEITE:
				wechseln(Zustand.WANDERN)
			elif abstand < SPRUNGWEITE:
				wechseln(Zustand.ANLAUF)
		Zustand.ANLAUF:
			velocity = Vector2.ZERO
			$Bild.position.x = randi_range(-1, 1)   # zittern: Gleich passiert was!
			if zustand_zeit <= 0:
				wechseln(Zustand.SPRUNG)
		Zustand.SPRUNG:
			velocity = richtung * SPRUNG_TEMPO
			if zustand_zeit <= 0:
				wechseln(Zustand.RUHE)
		Zustand.RUHE, Zustand.GETROFFEN:
			velocity = velocity.move_toward(Vector2.ZERO, BREMSE * delta)
			if zustand_zeit <= 0:
				$RayCast2D.target_position = held.global_position - global_position
				$RayCast2D.force_raycast_update()
				if not $RayCast2D.is_colliding():
					wechseln(Zustand.JAGEN)
				else:
					wechseln(Zustand.WANDERN)

	move_and_slide()
	$Anzeige.text = Zustand.keys()[zustand]


# Einen Zustand betreten: alles einstellen, was zu ihm gehört
func wechseln(neu: Zustand) -> void:
	zustand = neu
	$Bild.position.x = 0
	match neu:
		Zustand.WANDERN:
			# Stehen bleiben gehört auch zum Herumlaufen
			richtung = [Vector2.ZERO, Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].pick_random()
			zustand_zeit = randf_range(0.5, 1.5)
			$AnimationPlayer.play("wabbeln")
		Zustand.ANLAUF:
			zustand_zeit = 0.4
			$AnimationPlayer.play("springen")
		Zustand.SPRUNG:
			# Die Richtung wird beim Absprung festgelegt. Wer jetzt ausweicht, wird verfehlt.
			richtung = global_position.direction_to(held.global_position)
			zustand_zeit = 0.25
			$AnimationPlayer.play("RESET")
		Zustand.RUHE:
			zustand_zeit = 0.6
			$AnimationPlayer.play("RESET")
		Zustand.GETROFFEN:
			zustand_zeit = 0.3
			$AnimationPlayer.play("RESET")
		Zustand.JAGEN:
			$AnimationPlayer.play("wabbeln")


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	if zustand == Zustand.GETROFFEN:
		return
	leben -= 1
	velocity = held.global_position.direction_to(global_position) * RUECKSTOSS   # weg vom Helden
	wechseln(Zustand.GETROFFEN)
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.06, true, false, true).timeout
	Engine.time_scale = 1.0
	var tween := create_tween()
	tween.tween_property($Bild, "modulate", Color.RED, 0.05)
	tween.tween_property($Bild, "modulate", Color.WHITE, 0.2)
	if leben <= 0:
		sterben()


func hat_getroffen() -> void:
	wechseln(Zustand.RUHE)


func heilen() -> void:
	leben = start_leben
	wechseln(Zustand.WANDERN)
	$Anzeige.visible = zeige_zustand

# Wie jedes Monster sterben, aber vorher noch die Anzeige weg
func sterben() -> void:
	$Anzeige.hide()
	super()
