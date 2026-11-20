extends Monster

const SPEED = 130.0

var schaden := 1   # in halben Herzen
@export var richtung := Vector2(1.0, 0.0)


func _ready() -> void:
	super()
	richtung = richtung.normalized()
	$Bild.rotation = richtung.angle()


func _physics_process(_delta: float) -> void:
	if is_on_wall() and get_wall_normal().dot(richtung) < 0:
		richtung = richtung.rotated(PI / 2)
		$Bild.rotation = richtung.angle()
	velocity = richtung * SPEED
	move_and_slide()


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.06, true, false, true).timeout
	Engine.time_scale = 1.0
	var tween := create_tween()
	tween.tween_property($Bild, "modulate", Color.RED, 0.05)
	tween.tween_property($Bild, "modulate", Color.WHITE, 0.2)
	sterben()
