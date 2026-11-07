extends Area2D

@export var eingangsrichtung := Spielstand.RoehrenRichtung.UNTEN
@export_file("*.tscn") var ziel_szene: String
@export var ausgang := Vector2.ZERO   # wo der Held in der Ziel-Szene herauskommt, ZERO: wo er dort steht
@export var nur_ein_mal_betreten := false

func _physics_process(_delta: float) -> void:
	if eingangsrichtung == Spielstand.RoehrenRichtung.UNTEN and not Input.is_action_pressed("runter"):
		return
	if eingangsrichtung == Spielstand.RoehrenRichtung.RECHTS and not Input.is_action_pressed("rechts"):
		return
	if nur_ein_mal_betreten and Spielstand.bonus:
		return
	for body in get_overlapping_bodies():
		if body.is_on_floor():
			Spielstand.bonus = true
			Spielstand.rueckkehr = ausgang
			body.roehre_betreten(ziel_szene, eingangsrichtung)
