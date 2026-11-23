extends Node2D

@export var geschoss_szene: PackedScene
@export var abklingzeit := 0.6    # Sekunden zwischen zwei Würfen
@export var schaden := 1
@export var reichweite := 150.0   # auf Gegner, die weiter weg sind, wird nicht geworfen
@export var anzahl := 1

var warten := 0.0
var seite := 1


func _physics_process(delta: float) -> void:
	warten -= delta
	if warten > 0:
		return
	var ziel := naechster_gegner()
	if ziel == null:
		return   # niemand da: warten bleibt unter 0, beim nächsten Gegner wird sofort geworfen

	for g in anzahl:
		var geschoss := geschoss_szene.instantiate()
		var winkel := ceili(g / 2.0) * 15.0
		if g % 2 == 0:
			winkel = -winkel
		if anzahl % 2 == 0:
			winkel *= seite
		geschoss.richtung = global_position.direction_to(ziel.global_position).rotated(deg_to_rad(winkel))
		geschoss.schaden = schaden
		# In die Welt, nicht an den Held: Sonst liefe das Messer mit, wenn der Held läuft
		get_tree().current_scene.add_child(geschoss)
		geschoss.global_position = global_position
	warten = abklingzeit
	seite = -seite


func naechster_gegner() -> Node2D:
	var bester: Node2D = null
	var bester_abstand := reichweite * reichweite
	for gegner: Node2D in get_tree().get_nodes_in_group("gegner"):
		var abstand := global_position.distance_squared_to(gegner.global_position)
		if abstand < bester_abstand:
			bester = gegner
			bester_abstand = abstand
	return bester
