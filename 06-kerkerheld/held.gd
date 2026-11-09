extends CharacterBody2D

enum Zustand { LAUFEN, ANGRIFF }

const SPEED = 80.0
const BESCHLEUNIGUNG = 1200.0   # Pixel pro Sekunde², volle Geschwindigkeit nach 1/15 Sekunde
const ECKEN_HILFE = 6         # so viele Pixel neben einer Lücke hilft der Held noch nach
const ECKEN_TEMPO = 60.0      # so schnell rutscht er dabei zur Seite
const UNGEDULDIG_MIN = 10     # so viele Sekunden wartet der Held mindestens ruhig
const UNGEDULDIG_MAX = 30     # spätestens nach so vielen Sekunden wird der Held unruhig
const ANGRIFF_BUFFER = 0.1    # so lange wird ein zu früher Angriff gemerkt

var blick := Vector2.DOWN   # wohin der Held schaut, nur vier Richtungen
var steh_zeit := 0.0
var geduld_zeit := 0.0
var zustand := Zustand.LAUFEN
var angriff_buffer_timer := 0.0


# Stößt der Held gerade gegen eine Kante, und daneben ist frei: zur Seite rutschen
func ecke_umrunden(richtung: Vector2, delta: float) -> void:
	# Nur wenn er gegen etwas läuft, und nur fast gerade (nicht schräg)
	if get_slide_collision_count() == 0 or min(abs(richtung.x), abs(richtung.y)) > 0.2:
		return
	var vor := vier_richtungen(richtung) * 2   # zwei Pixel nach vorn
	var seite := Vector2(vor.y, vor.x).normalized()   # quer zur Laufrichtung
	for abstand in range(1, ECKEN_HILFE + 1):
		for s: Vector2 in [seite, -seite]:
			# Wäre der Held hier, um abstand zur Seite versetzt: Käme er dann nach vorn?
			if not test_move(global_transform.translated(s * abstand), vor):
				position += s * ECKEN_TEMPO * delta
				return


# Aus einer beliebigen Richtung wird eine der vier: die stärkere Achse gewinnt
func vier_richtungen(v: Vector2) -> Vector2:
	if abs(v.x) > abs(v.y):
		return Vector2(sign(v.x), 0)
	return Vector2(0, sign(v.y))


func schritt() -> void:
	$Schritt.pitch_scale = randf_range(0.9, 1.1)
	$Schritt.play()


func _physics_process(delta: float) -> void:
	match zustand:
		Zustand.LAUFEN:
			laufen(delta)
			if Input.is_action_just_pressed("angriff") or angriff_buffer_timer > 0:
				angreifen()
		Zustand.ANGRIFF:
			if Input.is_action_just_pressed("angriff"):
				angriff_buffer_timer = ANGRIFF_BUFFER
			# Beim Zustechen abbremsen, nicht weiterlaufen
			velocity = velocity.move_toward(Vector2.ZERO, BESCHLEUNIGUNG * delta)
			move_and_slide()
	angriff_buffer_timer -= delta


# Zustechen in Blickrichtung, danach wieder laufen
func angreifen() -> void:
	zustand = Zustand.ANGRIFF
	$Schwert.rotation = blick.angle() + PI / 2
	$AnimationPlayer.play("angriff")
	await $AnimationPlayer.animation_finished
	zustand = Zustand.LAUFEN


func laufen(delta: float) -> void:
	var richtung := vier_richtungen(Input.get_vector("links", "rechts", "hoch", "runter"))
	velocity = velocity.move_toward(richtung * SPEED, BESCHLEUNIGUNG * delta)
	move_and_slide()
	ecke_umrunden(richtung, delta)

	if richtung != Vector2.ZERO:
		steh_zeit = 0.0
		geduld_zeit = 0.0
		blick = vier_richtungen(richtung)
		$AnimationPlayer.play("laufen")
	else:
		steh_zeit += delta
		if geduld_zeit == 0:
			geduld_zeit = randf_range(UNGEDULDIG_MIN, UNGEDULDIG_MAX)
		if steh_zeit > geduld_zeit:
			$AnimationPlayer.play("ungeduldig")
		else:
			$AnimationPlayer.play("stehen")

	# Nach links und rechts schauen
	if richtung.x != 0:
		$Bild.flip_h = richtung.x < 0


func _on_camera_2d_raumwechsel(wechselrichtung: Variant) -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(18 * wechselrichtung.x, 18 * wechselrichtung.y), 0.2)
	await tween.finished
