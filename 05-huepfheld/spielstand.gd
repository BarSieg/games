extends Node


const START_LEBEN = 3

var leben := START_LEBEN
var muenzen := 0
var meldung := ""   # was der Ende-Bildschirm zeigt


# Alles auf Anfang, für ein neues Spiel
func neues_spiel() -> void:
	leben = START_LEBEN
	muenzen = 0
