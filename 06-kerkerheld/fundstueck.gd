extends Area2D

const ZEIT_ZUM_SAMMELN = 15.0
const ZEIT_VERSCHWINDEN = 5.0

@export var art: Gegenstand.Art = Gegenstand.Art.MUENZE

var drop := false   # von einem Monster fallen gelassen: verschwindet nach einer Weile
var zeit := ZEIT_ZUM_SAMMELN


func _physics_process(delta: float) -> void:
	if drop:
		zeit -= delta
		queue_redraw()
		if zeit < 0:
			queue_free()


func _draw() -> void:
	# In den letzten Sekunden verblassen. Liegt es fest im Level, bleibt zeit immer voll.
	var alpha := clampf(zeit / ZEIT_VERSCHWINDEN, 0.0, 1.0)
	var hoehe: float = Gegenstand.BILDER[art][0].size()
	Gegenstand.malen(self, art, Vector2(0, hoehe / 2), alpha)


func _on_body_entered(_body: Node2D) -> void:
	Spielstand.hinzufuegen(art)
	# Unsichtbar werden, klimpern, erst danach weg. Sonst wäre der Ton gleich mit weg.
	set_deferred("monitoring", false)
	drop = false
	hide()
	if art == Gegenstand.Art.MUENZE:
		$Klimper.play()
		await $Klimper.finished
	else:
		$Sammeln.play()
		await $Sammeln.finished
	queue_free()
