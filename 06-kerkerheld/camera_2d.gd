extends Camera2D

signal raumwechsel(richtung)
signal bossraum_betreten

const RAUM_GROESSE = Vector2(256, 176)   # 16 × 11 Kacheln
const ANZEIGE_HOEHE = 48                 # Platz für die Anzeige oben
const SCHIEBE_ZEIT = 0.6                 # so lange dauert ein Raumwechsel

var raum := Vector2i.ZERO   # welchen Raum die Kamera gerade zeigt
var letzte_raeume := Spielstand.letzte_raeume   # in welchen Räumen die Monster noch tot bleiben

@onready var held: Node2D = get_tree().get_first_node_in_group("held")
@onready var boss: Node2D = get_tree().get_first_node_in_group("boss")


func _ready() -> void:
	# Beim Start ohne Schieben gleich zum Raum des Helden
	raum = raum_von(held.global_position)
	position = kamera_position(raum)
	monster_wecken.call_deferred(true)
	%Karte.zeigen(raum)
	musik_waehlen.call_deferred()   # erst wenn alle Monster wissen, ob sie tot sind


# Im Bossraum läuft die Bossmusik, solange dort noch etwas lebt. Sonst die Kerkermusik.
func musik_waehlen() -> void:
	var geheimnis := get_tree().get_nodes_in_group("secrets").any(
			func(marker: Marker2D) -> bool: return raum_von(marker.global_position) == raum
	)
	var lebt_noch := get_tree().get_nodes_in_group("monster").any(
			func(monster: Monster) -> bool: return raum_von(monster.start_position) == raum and not monster.tot)
	if geheimnis:
		Musik.spielen(Musik.GEHEIMNIS)
	elif raum_von(boss.global_position) == raum and lebt_noch:
		Musik.spielen(Musik.BOSS)
	else:
		Musik.spielen(Musik.KERKER)


func _process(_delta: float) -> void:
	var neu := raum_von(held.global_position)
	if neu != raum:
		schieben(neu)


# In welchem Raum liegt dieser Punkt?
func raum_von(punkt: Vector2) -> Vector2i:
	return Vector2i((punkt / RAUM_GROESSE).floor())


# Wo muss die Kamera stehen, damit sie diesen Raum zeigt?
func kamera_position(r: Vector2i) -> Vector2:
	return Vector2(r) * RAUM_GROESSE - Vector2(0, ANZEIGE_HOEHE)


# Ist dieser Raum dunkel? Das steht an den Dunkelheitmarkern.
func ist_dunkel(r: Vector2i) -> bool:
	return get_tree().get_nodes_in_group("dunkel").any(
			func(marker: Marker2D) -> bool: return raum_von(marker.global_position) == r)


# Zum neuen Raum schieben. Solange steht das ganze Spiel still.
func schieben(neu: Vector2i) -> void:
	var richtung := neu - raum
	raum = neu
	get_tree().paused = true
	# Dunkel gewinnt: Sonst sieht man beim Hineinschieben, was im dunklen Raum lauert.
	# Hell wird es erst wieder, wenn der Held angekommen ist (pruefe_dunkelheit im Held).
	if ist_dunkel(neu):
		%Dunkelheit.visible = true
	var tween := create_tween()
	tween.tween_property(self, "position", kamera_position(neu), SCHIEBE_ZEIT)
	await tween.finished
	monster_wecken(letzte_raeume.enthaelt(neu))
	if not letzte_raeume.enthaelt(neu):
		toepfe_reparieren()
	letzte_raeume.hinzufuegen(neu)
	get_tree().paused = false
	raumwechsel.emit(richtung)
	%Karte.zeigen(raum)
	musik_waehlen()
	if raum_von(boss.global_position) == raum:
		bossraum_betreten.emit()


# Nur die Monster im aktuellen Raum sind wach, alle anderen schlafen
func monster_wecken(nur_heilen: bool) -> void:
	for monster: Monster in get_tree().get_nodes_in_group("monster"):
		if raum_von(monster.start_position) == raum:
			monster.process_mode = Node.PROCESS_MODE_INHERIT
			if nur_heilen:
				monster.heilen()
			else:
				monster.wecken()
		else:
			monster.process_mode = Node.PROCESS_MODE_DISABLED


# Zerbrochene Töpfe im aktuellen Raum wieder ganz machen
func toepfe_reparieren() -> void:
	for topf in get_tree().get_nodes_in_group("topf"):
		if raum_von(topf.global_position) == raum:
			topf.reparieren()
