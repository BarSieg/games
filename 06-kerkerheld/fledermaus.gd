extends Monster

enum Zustand { FLATTERN, SITZEN }

const FLATTERN_TEMPO = 55.0
const MUENZ_DROPRATE = 0.5
const MUENZ_DROP_MAX = 1

var zustand := Zustand.FLATTERN
var zustand_zeit := 0.0         # wie lange der aktuelle Zustand noch dauert
var richtung := Vector2.ZERO

@export var schaden := 1   # in halben Herzen

func _ready() -> void:
	super()
	wechseln(Zustand.FLATTERN)
	muenzdroprate = MUENZ_DROPRATE
	muenzdropmax = MUENZ_DROP_MAX


func _physics_process(delta: float) -> void:
	zustand_zeit -= delta

	match zustand:
		Zustand.FLATTERN:
			velocity = richtung * FLATTERN_TEMPO
			if is_on_wall():
				wechseln(Zustand.FLATTERN)   # neue Richtung würfeln
		Zustand.SITZEN:
			velocity = Vector2.ZERO
	if zustand_zeit <= 0:
		if randf() < 0.1:
			wechseln(Zustand.SITZEN)
		else:
			wechseln(Zustand.FLATTERN)
	move_and_slide()


# Einen Zustand betreten: alles einstellen, was zu ihm gehört
func wechseln(neu: Zustand) -> void:
	zustand = neu
	match neu:
		Zustand.FLATTERN:
			# Neue zufällige Richtung, auch schräg
			richtung = Vector2(randf() - 0.5, randf() - 0.5).normalized()
			zustand_zeit = randf_range(0.5, 1.5)
			$AnimationPlayer.play("flattern")
		Zustand.SITZEN:
			zustand_zeit = 0.7
			$AnimationPlayer.play("sitzen")


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.06, true, false, true).timeout
	Engine.time_scale = 1.0
	var tween := create_tween()
	tween.tween_property($Bild, "modulate", Color.RED, 0.05)
	tween.tween_property($Bild, "modulate", Color.WHITE, 0.2)
	sterben()
