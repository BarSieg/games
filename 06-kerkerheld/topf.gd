extends StaticBody2D

const FUNDSTUECK = preload("res://fundstueck.tscn")

var ganz := true
var tween: Tween   # das Zerbrechen. Gemerkt, damit reparieren() es abbrechen kann.

@onready var start_frame: int = $Bild.frame
@onready var start_bild_position: Vector2 = $Bild.position

@export var bewohnt := false
@export var muenzen := 0


func _ready() -> void:
	if muenzen > 0:
		if Spielstand.ist_erledigt(self):
			muenzen = 0


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	zerbrechen()


# Kurz plattdrücken, dann weg
# Kurz plattdrücken, dann weg
func zerbrechen() -> void:
	ganz = false
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.06, true, false, true).timeout
	Engine.time_scale = 1.0
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	tween = create_tween()
	tween.tween_property($Bild, "scale", Vector2(1.5, 0.2), 0.1)
	tween.tween_property($Bild, "visible", false, 0.0)
	tween.tween_property($Scherben, "emitting", true, 0.0)
	if bewohnt:
		tween.tween_property($Bild, "frame", 122, 0.0)
		tween.tween_property($Bild, "scale", Vector2(0.33, 0.33), 0.0)
		tween.tween_property($Bild, "visible", true, 0.0)
		tween.tween_callback($Bewohner.play).set_delay(0)
		tween.tween_property($Bild, "position:y", $Bild.position.y + 224, 1.0)
	else:
		tween.tween_property($Bild, "visible", false, 1.0)
	beute()


# Wieder ganz wie am Anfang. Im Iron-Man-Spiel bleibt kaputt kaputt.
func reparieren() -> void:
	if ganz or Spielstand.iron_man:
		return
	ganz = true
	if tween:
		tween.kill()   # falls es noch nicht fertig ist, zum Beispiel nach einer Pause
	$Bild.frame = start_frame
	$Bild.position = start_bild_position
	$Bild.scale = Vector2.ONE
	$Bild.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	$Hurtbox.set_deferred("monitoring", true)


# Die Münzen aus dem Topf leicht verstreut fallen lassen
func beute() -> void:
	if muenzen > 0:
		Spielstand.erledigen(self)
	for i in muenzen:
		var ding = FUNDSTUECK.instantiate()
		ding.art = Gegenstand.Art.MUENZE
		ding.drop = true
		ding.position = position + Vector2(randf_range(-6, 6), randf_range(-6, 6))
		get_parent().add_child.call_deferred(ding)
	muenzen = 0   # Ein reparierter Topf ist leer
