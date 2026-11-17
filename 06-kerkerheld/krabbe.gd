extends Monster

# Die Kerkerkrabbe: läuft seitwärts hin und her, spuckt Blasen, und wenn sie wütend ist, rennt sie los

enum Zustand { SEITWAERTS, ZIELEN, ANLAUF, STURM }

const BLASE = preload("res://blase.tscn")
const MAX_LEBEN = 4
const SEIT_TEMPO = 50.0
const STURM_TEMPO = 150.0
const FAECHER = [-0.35, 0.0, 0.35]   # drei Blasen, leicht gefächert (Winkel im Bogenmaß)
const SCHONZEIT = 1.0                # so lange nach einem Treffer unverwundbar
const LEBENSBALKENBREITE = 42.0

@export var schaden := 2   # in halben Herzen

var leben := MAX_LEBEN
var zustand := Zustand.SEITWAERTS
var zustand_zeit := 0.0
var richtung := Vector2.LEFT
var schonzeit := 0.0

@onready var held: Node2D = get_tree().get_first_node_in_group("held")


func _ready() -> void:
	super()
	# Schon besiegt? Dann tot bleiben. Nicht löschen, sonst wüsste die Truhe nicht, dass sie erscheinen darf.
	if Spielstand.ist_erledigt(self):
		tot = true
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
		$Hurtbox.set_deferred("monitoring", false)
		set_physics_process(false)
		return
	heilen()


# Ein Boss kommt nie wieder, auch nicht im normalen Spiel
func wecken() -> void:
	if Spielstand.ist_erledigt(self):
		return
	super()


func heilen() -> void:
	leben = MAX_LEBEN
	schonzeit = 0.0
	wechseln(Zustand.SEITWAERTS)


# Wütend ist sie ab der Hälfte
func wuetend() -> bool:
	return leben <= MAX_LEBEN / 2.0


func _physics_process(delta: float) -> void:
	zustand_zeit -= delta
	schonzeit -= delta
	if schonzeit > 0:
		$Bild.visible = fmod(schonzeit, 0.1) < 0.05
	$Bild.position.x = 0

	match zustand:
		Zustand.SEITWAERTS:
			# Nur umdrehen, wenn die Wand vor ihr ist. Eine Wand über oder unter ihr ist egal.
			if is_on_wall() and get_wall_normal().dot(richtung) < 0:
				richtung = -richtung   # umdrehen, ohne den Kopf zu drehen: Krabben eben
			velocity = richtung * SEIT_TEMPO * (1.5 if wuetend() else 1.0)
			if zustand_zeit <= 0:
				wechseln(Zustand.ANLAUF if wuetend() and randf() < 0.5 else Zustand.ZIELEN)
		Zustand.ZIELEN, Zustand.ANLAUF:
			velocity = Vector2.ZERO
			$Bild.position.x = randi_range(-1, 1)   # zittern: Gleich passiert was!
			if zustand_zeit <= 0:
				if zustand == Zustand.ZIELEN:
					spucken()
					wechseln(Zustand.SEITWAERTS)
				else:
					wechseln(Zustand.STURM)
		Zustand.STURM:
			velocity = richtung * STURM_TEMPO
			if get_slide_collision_count() > 0:   # gegen die Wand gerannt
				global_position += get_wall_normal()
				wechseln(Zustand.SEITWAERTS)
	if wuetend():
		$Bild.modulate = Color(1.0, 0.5, 0.8)
	move_and_slide()


func wechseln(neu: Zustand) -> void:
	zustand = neu
	match neu:
		Zustand.SEITWAERTS:
			richtung = [Vector2.LEFT, Vector2.RIGHT].pick_random()
			zustand_zeit = randf_range(1.5, 2.5)
		Zustand.ZIELEN:
			zustand_zeit = 0.3 if wuetend() else 0.4
		Zustand.ANLAUF:
			zustand_zeit = 0.5
		Zustand.STURM:
			# Die Richtung wird beim Losrennen festgelegt. Wer jetzt ausweicht, wird verfehlt.
			richtung = global_position.direction_to(held.global_position)


# Drei Blasen auf den Helden zu, wütend fünf
func spucken() -> void:
	var winkel: Array = FAECHER
	if wuetend():
		winkel = [-0.7] + FAECHER + [0.7]
	for w: float in winkel:
		var blase := BLASE.instantiate()
		blase.position = position + Vector2(0, 8)
		blase.richtung = global_position.direction_to(held.global_position).rotated(w)
		get_parent().add_child(blase)


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	if schonzeit > 0:
		return
	schonzeit = SCHONZEIT
	leben -= 1
	$Treffer.play()
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.06, true, false, true).timeout
	Engine.time_scale = 1.0
	var tween := create_tween()
	tween.tween_property($Bild, "modulate", Color.RED, 0.05)
	tween.tween_property($Bild, "modulate", Color.WHITE, 0.2)
	if leben <= 0:
		sterben()
	queue_redraw()


func _draw() -> void:
	# Lebensbalken
	draw_rect(Rect2(Vector2(-LEBENSBALKENBREITE / 2.0,-30), Vector2(LEBENSBALKENBREITE,2)), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(Vector2(-LEBENSBALKENBREITE / 2.0,-30), Vector2(leben * LEBENSBALKENBREITE / MAX_LEBEN, 2)), Color.RED)


# Erst lange blinken, dann wie jedes Monster verschwinden
func sterben() -> void:
	Spielstand.erledigen(self)
	set_physics_process(false)
	$Bild.visible = true
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitoring", false)
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for i in 8:
		tween.tween_property($Bild, "modulate", Color.RED, 0.1)
		tween.tween_property($Bild, "modulate", Color.WHITE, 0.1)
	await tween.finished
	super()
