extends Node2D

# Ein steinernes Gesicht in der Wand. Spuckt Blasen nach dem Helden, solange er in seinem Raum ist.

const BLASE = preload("res://blase.tscn")
const BILD_RUHE = 19
const BILD_SPUCKEN = 20
const ABSTAND = 14   # so weit vor dem Gesicht entsteht die Blase, damit sie nicht gleich in der Wand platzt

@export var blick := Vector2.DOWN   # dahin schaut das Gesicht aus der Wand heraus
@export var pause := 2.0            # so viele Sekunden zwischen zwei Blasen
@export var versatz := 0.0          # zusätzliche Wartezeit am Anfang, damit nicht alle gleichzeitig spucken

@onready var zeit := pause + versatz   # bis zur nächsten Blase
@onready var held: Node2D = get_tree().get_first_node_in_group("held")


func _physics_process(delta: float) -> void:
	if %Camera2D.raum != %Camera2D.raum_von(global_position):
		zeit = pause + versatz   # Kommt der Held herein, hat er erst einmal etwas Zeit
		return
	zeit -= delta
	if zeit <= 0:
		zeit = pause
		spucken()


func spucken() -> void:
	$Bild.frame = BILD_SPUCKEN
	var blase := BLASE.instantiate()
	blase.position = position + blick * ABSTAND
	blase.richtung = blase.position.direction_to(held.global_position)
	get_parent().add_child(blase)
	await get_tree().create_timer(0.3, false).timeout
	$Bild.frame = BILD_RUHE
