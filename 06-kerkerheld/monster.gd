class_name Monster
extends CharacterBody2D

# Was alle Monster gemeinsam haben: Sie sterben, und im normalen Spiel kommen sie wieder.

var tot := false
var start_position := Vector2.ZERO   # hier stand das Monster beim Start, hierhin kommt es zurück


func _ready() -> void:
	start_position = global_position


# Der Held betritt meinen Raum: alles wie neu. Nur wer im Iron-Man-Spiel tot ist, bleibt tot.
func wecken() -> void:
	if tot and Spielstand.iron_man:
		return
	tot = false
	show()
	global_position = start_position
	velocity = Vector2.ZERO
	$Bild.scale = Vector2.ONE
	$Bild.modulate = Color.WHITE
	$CollisionShape2D.disabled = false
	$Hurtbox.monitoring = true
	set_physics_process(true)
	heilen()


# Volle Lebenspunkte. Monster, die mehr als einen Treffer aushalten, schreiben ihr eigenes heilen().
func heilen() -> void:
	pass


# Nicht mehr bewegen, nicht mehr treffen, zusammenschrumpfen
func sterben() -> void:
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	# PAUSE_PROCESS: Der Tween läuft auch weiter, wenn der Held schnell den Raum verlässt und das Monster einschläft
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Bild, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(verschwinden)


# Unsichtbar statt gelöscht, damit wecken() mich zurückholen kann
func verschwinden() -> void:
	tot = true
	hide()
