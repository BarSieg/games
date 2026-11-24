class_name Uhr
extends Label

signal abgelaufen

const SPIELZEIT = 300.0   # so viele Sekunden muss der Held überleben

var zeit := 0.0
var vorbei := false


func _process(delta: float) -> void:
	if vorbei:
		return
	zeit += delta
	if zeit >= SPIELZEIT:
		zeit = SPIELZEIT
		vorbei = true
		abgelaufen.emit()
	text = als_text(SPIELZEIT - zeit)


func als_text(sekunden: float) -> String:
	var ganz := ceili(sekunden)
	return "%d:%02d" % [floori(ganz / 60.0), ganz % 60]
