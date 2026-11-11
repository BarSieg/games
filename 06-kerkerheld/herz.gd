extends Node2D


const ZEIT_ZUM_SAMMELN = 15.0
const ZEIT_VERSCHWINDEN = 5.0

var drop := false   # Aus Gegner ausgeschlagen statt im Level liegend
var zeit := 0.0


func _ready() -> void:
	if drop:
		zeit = ZEIT_ZUM_SAMMELN
	queue_redraw()


func _physics_process(delta: float) -> void:
	if drop:
		zeit -= delta
		queue_redraw()
		if zeit < 0:
			queue_free()


func _on_bild_body_entered(_body: Node2D) -> void:
	Spielstand.hinzufuegen(Gegenstand.Art.HERZ)
	queue_free()


func _draw() -> void:
	var alpha := 1.0 if (zeit > ZEIT_VERSCHWINDEN or not drop) else zeit / ZEIT_VERSCHWINDEN
	Gegenstand.malen(self, Gegenstand.Art.HERZ, $Bild.position, alpha)
