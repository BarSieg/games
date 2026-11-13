extends Monster

enum Zustand { SCHWEBEN }

const SCHWEBEN_TEMPO = 20.0
const ALPHA_MIN = 0.2
const ALPHA_MAX = 0.5

var zustand := Zustand.SCHWEBEN
var zustand_zeit := 0.0         # wie lange der aktuelle Zustand noch dauert
var richtung := Vector2.ZERO
var alpha_ziel := 0.25

@export var schaden := 2   # in halben Herzen

@onready var held: Node2D = get_tree().get_first_node_in_group("held")


func _ready() -> void:
	super()
	wechseln(Zustand.SCHWEBEN)


func _physics_process(delta: float) -> void:
	zustand_zeit -= delta

	match zustand:
		Zustand.SCHWEBEN:
			velocity = richtung * SCHWEBEN_TEMPO
			modulate.a = move_toward(modulate.a, alpha_ziel, 0.01)
	if zustand_zeit <= 0:
		wechseln(Zustand.SCHWEBEN)
	move_and_slide()


# Einen Zustand betreten: alles einstellen, was zu ihm gehört
func wechseln(neu: Zustand) -> void:
	zustand = neu
	match neu:
		Zustand.SCHWEBEN:
			# Auf den Helden zu
			richtung = global_position.direction_to(held.global_position)
			zustand_zeit = randf_range(0.5, 1.5)
			alpha_ziel = randf_range(ALPHA_MIN, ALPHA_MAX)
			$AnimationPlayer.play("schweben")


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	# Je durchsichtiger der Geist, desto öfter geht die Klinge durch ihn hindurch
	if randf() > modulate.a:
		return
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.06, true, false, true).timeout
	Engine.time_scale = 1.0
	set_physics_process(false)
	var tween := create_tween()
	tween.tween_property($Bild, "modulate", Color.RED, 0.05)
	tween.tween_property($Bild, "modulate", Color.WHITE, 0.2)
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	tween.tween_property($Bild, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)
