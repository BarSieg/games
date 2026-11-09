extends Node

signal leben_geaendert

const START_LEBEN = 6   # in halben Herzen: 6 sind drei ganze Herzen

var max_leben := START_LEBEN
var leben := START_LEBEN:
	set(wert):
		leben = clampi(wert, 0, max_leben)
		leben_geaendert.emit()


# Alles auf Anfang, für ein neues Spiel
func neues_spiel() -> void:
	max_leben = START_LEBEN
	leben = max_leben
