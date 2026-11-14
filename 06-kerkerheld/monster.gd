class_name Monster
extends CharacterBody2D

# Was alle Monster gemeinsam haben: Sie sterben, und im normalen Spiel kommen sie wieder.

const FUNDSTUECK = preload("res://fundstueck.tscn")

var tot := false
var start_position := Vector2.ZERO   # hier stand das Monster beim Start, hierhin kommt es zurück
var herzdroprate := 0.0    # die Monster stellen das in ihrem _ready() ein
var muenzdroprate := 0.0
var muenzdropmax := 0      # so viele Münzen fallen höchstens auf einmal
var start_groesse := Vector2.ONE     # so groß war das Bild beim Start. Der Boss ist größer als die anderen.

func _ready() -> void:
	start_position = global_position
	start_groesse = $Bild.scale


# Der Held betritt meinen Raum: alles wie neu. Nur wer im Iron-Man-Spiel tot ist, bleibt tot.
func wecken() -> void:
	if tot and Spielstand.iron_man:
		return
	tot = false
	show()
	global_position = start_position
	velocity = Vector2.ZERO
	$Bild.scale = start_groesse
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
	beute()


func drop_herz() -> void:
	var herz := FUNDSTUECK.instantiate()
	herz.art = Gegenstand.Art.HERZ
	herz.drop = true
	herz.position = position
	get_parent().add_child.call_deferred(herz)


func drop_muenzen() -> void:
	var anzahl := randi_range(1, muenzdropmax)
	for _a in anzahl:
		var muenze := FUNDSTUECK.instantiate()
		muenze.drop = true
		muenze.position = position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		get_parent().add_child.call_deferred(muenze)


# Ein Herz oder mehrere Münzen fallen lassen. Oder nichts.
func beute() -> void:
	var los := randf()
	if los < herzdroprate + muenzdroprate:
		if los < herzdroprate:
			drop_herz()
		else:
			drop_muenzen()


# Unsichtbar statt gelöscht, damit wecken() mich zurückholen kann
func verschwinden() -> void:
	tot = true
	hide()
