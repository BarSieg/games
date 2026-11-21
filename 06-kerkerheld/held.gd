extends CharacterBody2D

signal angekommen   # nach einem Raumwechsel ganz im neuen Raum angekommen

enum Zustand { LAUFEN, ANGRIFF, GETROFFEN, HEREIN }

const SPEED = 80.0
const BESCHLEUNIGUNG = 1200.0   # Pixel pro Sekunde², volle Geschwindigkeit nach 1/15 Sekunde
const ECKEN_HILFE = 6         # so viele Pixel neben einer Lücke hilft der Held noch nach
const ECKEN_TEMPO = 60.0      # so schnell rutscht er dabei zur Seite
const UNGEDULDIG_MIN = 10     # so viele Sekunden wartet der Held mindestens ruhig
const UNGEDULDIG_MAX = 30     # spätestens nach so vielen Sekunden wird der Held unruhig
const ANGRIFF_BUFFER = 0.1    # so lange wird ein zu früher Angriff gemerkt
const RUECKSTOSS = 160.0          # so schnell fliegt der Held nach einem Treffer zurück
const RUECKSTOSS_ZEIT = 0.2       # so lange fliegt er
const SCHONZEIT = 1.0             # so lange kann ihm danach nichts passieren
const IRONMAN_FRAME = 97
const OPTIONEN = preload("res://optionen.tscn")

var blick := Vector2.DOWN   # wohin der Held schaut, nur vier Richtungen
var steh_zeit := 0.0
var geduld_zeit := 0.0
var zustand := Zustand.LAUFEN
var angriff_buffer_timer := 0.0
var unverwundbar := 0.0
var rueckstoss_zeit := 0.0


func _ready() -> void:
	if Spielstand.iron_man:
		$Bild.frame = IRONMAN_FRAME
	Spielstand.gewonnen.connect(gewinnen)
	var dunkler_raum := pruefe_dunkelheit()
	schalte_taschenlampe(dunkler_raum)


# Nach dem Laden dort anfangen, wo zuletzt gespeichert wurde.
# _enter_tree statt _ready: Die Kamera fragt in ihrem _ready schon nach der Position des Helden.
func _enter_tree() -> void:
	if Spielstand.startpunkt != null:
		global_position = Spielstand.startpunkt
		unverwundbar = SCHONZEIT   # kurz Zeit zum Umschauen


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
	if Input.is_action_just_pressed("pause"):
		pause_menue()   # ohne await: läuft für sich, _physics_process ist sofort fertig
		return
	match zustand:
		Zustand.LAUFEN:
			laufen(delta)
			%Camera2D.offset = Vector2i.ZERO
			if Input.is_action_just_pressed("angriff") or angriff_buffer_timer > 0:
				angriff_buffer_timer = 0.0
				if not benutzen():
					angreifen()
		Zustand.ANGRIFF:
			if Input.is_action_just_pressed("angriff"):
				angriff_buffer_timer = ANGRIFF_BUFFER
			# Beim Zustechen abbremsen, nicht weiterlaufen
			velocity = velocity.move_toward(Vector2.ZERO, BESCHLEUNIGUNG * delta)
			move_and_slide()
		Zustand.GETROFFEN:
			velocity = velocity.move_toward(Vector2.ZERO, BESCHLEUNIGUNG * delta)
			%Camera2D.offset = Vector2i(randi_range(-2, 2), randi_range(-2, 2))
			move_and_slide()
			rueckstoss_zeit -= delta
			if rueckstoss_zeit <= 0:
				zustand = Zustand.LAUFEN
		Zustand.HEREIN:
			pass   # Der Tween aus dem Raumwechsel bewegt ihn. Die Tasten haben so lange Pause.
	angriff_buffer_timer -= delta
	treffer_pruefen(delta)


# Pause: zeigt den Stand und fragt, ob es zurück zum Titelbild geht
func pause_menue() -> void:
	var stand := tr("Erkundet: %d %%   Zeit: %s") % [Spielstand.erkundet(), Spielstand.formatiere_spielzeit()]
	match await Dialog.auswahlfrage(stand, [tr("Weiter"), tr("Optionen"), tr("Zum Titelbildschirm")]):
		0: # weiter
			pass
		1: # optionen
			var opt := OPTIONEN.instantiate()
			opt.im_spiel = true
			opt.process_mode = Node.PROCESS_MODE_ALWAYS   # läuft auch, wenn alles andere pausiert
			get_tree().paused = true
			get_tree().current_scene.get_node("%Anzeige").add_child(opt)
			await opt.tree_exited   # bis das Menü sich selbst wegräumt
			await get_tree().process_frame   # den Tastendruck vom Menü nicht an den Helden weitergeben
			get_tree().paused = false
		2: # zum Titelbildschirm
			if Spielstand.iron_man and not await Dialog.frage("Iron Man speichert den Zustand nicht. Der gesamte Fortschritt geht verloren. Der Held stirbt. Zurück zum Titelbildschirm?"):
				return
			get_tree().change_scene_to_file("res://titel.tscn")


# Jedes Bild: Berührt der Held gerade ein Monster?
func treffer_pruefen(delta: float) -> void:
	if unverwundbar > 0:
		unverwundbar -= delta
		$Bild.visible = fmod(unverwundbar, 0.1) < 0.05   # blinken, zehnmal pro Sekunde
		return
	$Bild.visible = true
	for monster in $Hurtbox.get_overlapping_bodies():
		getroffen(monster)
		return   # ein Treffer pro Bild reicht


func tuer_offen() -> void:
	$Tuer.play()


func getroffen(monster: Node2D) -> void:
	Spielstand.leben -= monster.schaden
	$Autsch.play()
	if monster.has_method("hat_getroffen"):
		monster.hat_getroffen()
	if Spielstand.leben <= 0:
		sterben()
		return
	unverwundbar = SCHONZEIT
	zustand = Zustand.GETROFFEN
	rueckstoss_zeit = RUECKSTOSS_ZEIT
	velocity = monster.global_position.direction_to(global_position) * RUECKSTOSS   # weg vom Monster


# Ein letztes Mal drehen, dann alles von vorn
func sterben() -> void:
	set_physics_process(false)
	$Bild.visible = true
	var tween := create_tween()
	tween.tween_property($Bild, "rotation", TAU * 3, 1.0)
	tween.tween_property($Bild, "modulate:a", 0.0, 0.3)
	await tween.finished
	if Spielstand.iron_man:
		await Dialog.zeigen(["Tot ist tot.", "Hier endet die Geschichte des eisernen Helden."])
		get_tree().change_scene_to_file("res://titel.tscn")
		return
	var zeit := Spielstand.spielzeit   # Die Uhr läuft weiter, auch wenn der Held von vorn anfängt
	Spielstand.laden()
	Spielstand.spielzeit = zeit
	Spielstand.gestorben += 1
	Spielstand.speichern(Spielstand.startpunkt)
	get_tree().reload_current_scene()


# Zustechen in Blickrichtung, danach wieder laufen
func angreifen() -> void:
	zustand = Zustand.ANGRIFF
	$AnimationPlayer.play("angriff")
	await $AnimationPlayer.animation_finished
	if zustand == Zustand.ANGRIFF:   # nur, wenn nicht inzwischen etwas anderes passiert ist
		zustand = Zustand.LAUFEN


func laufen(delta: float) -> void:
	var eingabe := Input.get_vector("links", "rechts", "hoch", "runter")
	var richtung := eingabe if Optionen.schraeg else vier_richtungen(eingabe)
	velocity = velocity.move_toward(richtung * SPEED, BESCHLEUNIGUNG * delta)
	move_and_slide()
	ecke_umrunden(richtung, delta)

	# Gegen etwas gelaufen, das man schieben kann? Dann drücken.
	if richtung != Vector2.ZERO:
		for i in get_slide_collision_count():
			var ding := get_slide_collision(i).get_collider()
			if ding.has_method("schieben"):
				ding.schieben(vier_richtungen(richtung), delta)

	if richtung != Vector2.ZERO:
		steh_zeit = 0.0
		geduld_zeit = 0.0
		blick = vier_richtungen(richtung)
		$Schwert.rotation = blick.angle() + PI / 2
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


# Steht vor dem Helden etwas, das man benutzen kann? Dann benutzen statt zustechen.
func benutzen() -> bool:
	for ding in $Schwert/Hand.get_overlapping_bodies():
		if ding.has_method("benutzen"):
			ding.benutzen()
			return true
	return false


func pruefe_dunkelheit() -> bool:
	var ist_dunkel: bool = %Camera2D.ist_dunkel(%Camera2D.raum_von(global_position))
	%Dunkelheit.visible = ist_dunkel
	return ist_dunkel


func schalte_taschenlampe(ein: bool) -> void:
	await get_tree().create_timer(0.5).timeout
	$Taschenlampe.visible = ein


func _on_camera_2d_raumwechsel(wechselrichtung: Variant) -> void:
	# Die Dunkelheit schaltet der Held
	var dunkler_raum := pruefe_dunkelheit()
	# Hereinlaufen: Der Tween bewegt, die Animation macht die Schritte, die Tasten haben Pause
	zustand = Zustand.HEREIN
	$AnimationPlayer.play("laufen")
	var tween := create_tween()
	tween.tween_property(self, "position", position + 24 * Vector2(wechselrichtung), 0.4)
	await tween.finished
	zustand = Zustand.LAUFEN
	angekommen.emit()
	schalte_taschenlampe(dunkler_raum)
	if %Camera2D.raum_von(get_tree().get_first_node_in_group("boss").global_position) != %Camera2D.raum_von(global_position):
		Spielstand.speichern(global_position)   # ganz im neuen Raum angekommen: speichern
	else:
		Spielstand.speichern(Spielstand.startpunkt)   # vor dem Bossraum: der alte Startpunkt bleibt


# Die Krone ist da: stehen bleiben, staunen, ab zum Abspann
func gewinnen() -> void:
	set_physics_process(false)
	$AnimationPlayer.play("stehen")
	await get_tree().create_timer(2.0).timeout
	await Dialog.zeigen(["Die Kerkerkrone! Der Kerker ist befreit."])
	Spielstand.speichern(Spielstand.startpunkt)   # Krabbe und Krone merken. Im Iron-Man-Spiel passiert hier nichts.
	get_tree().change_scene_to_file("res://abschluss.tscn")
