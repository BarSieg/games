extends Area2D


@export_file("*.tscn") var ziel_szene: String
@export var ausgang := Vector2.ZERO   # wo der Held in der Ziel-Szene herauskommt, ZERO: wo er dort steht


func _physics_process(_delta: float) -> void:
	if not Input.is_action_pressed("runter"):
		return
	for body in get_overlapping_bodies():
		if body.is_on_floor():
			Spielstand.rueckkehr = ausgang
			body.roehre_betreten(ziel_szene)
