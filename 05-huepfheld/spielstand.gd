extends Node


const EXTRA_LEBEN_TON = preload("res://extraLive.wav")
const START_LEBEN = 3

var leben := START_LEBEN
var muenzen := 0
var meldung := ""   # was der Ende-Bildschirm zeigt
var ton := AudioStreamPlayer.new()


# Den Ton für das Extraleben einrichten und anhängen
func _ready() -> void:
	ton.stream = EXTRA_LEBEN_TON
	add_child(ton)


# Alles auf Anfang, für ein neues Spiel
func neues_spiel() -> void:
	leben = START_LEBEN
	muenzen = 0


# Münzen zählen, bei 100 gibt es ein Leben dazu
func muenze_sammeln(amount := 1) -> void:
	muenzen += amount
	while muenzen > 99:
		muenzen -= 100
		leben += 1
		ton.play()
