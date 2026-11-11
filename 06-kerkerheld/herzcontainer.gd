extends Node2D




func _ready() -> void:
	queue_redraw()


func _physics_process(_delta: float) -> void:
	pass   # evtl. Animation


func _on_bild_body_entered(_body: Node2D) -> void:
	Spielstand.hinzufuegen(Gegenstand.Art.HERZCONTAINER)
	queue_free()


func _draw() -> void:
	# Ein goldgerahmtes Herz
	Gegenstand.malen(self, Gegenstand.Art.HERZCONTAINER, $Bild.position)
