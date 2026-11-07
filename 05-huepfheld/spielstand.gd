extends Node


const EXTRA_LEBEN_TON = preload("res://extraLive.wav")
const START_LEBEN = 3
const START_ZEIT = 400.0

var leben := START_LEBEN
var muenzen := 0
var meldung := ""   # was der Ende-Bildschirm zeigt
var ton := AudioStreamPlayer.new()
var zeit := START_ZEIT
var stark := false
var rueckkehr := Vector2.ZERO   # wo der Held nach einer Röhre auftaucht, ZERO heißt: am Levelanfang


# Den Ton für das Extraleben einrichten und anhängen
func _ready() -> void:
	ton.stream = EXTRA_LEBEN_TON
	add_child(ton)


# Alles auf Anfang, für ein neues Spiel
func neues_spiel() -> void:
	leben = START_LEBEN
	muenzen = 0
	neuer_versuch()


# Nach einem Tod: Zeit und Kraft zurück, Start am Levelanfang
func neuer_versuch() -> void:
	zeit = START_ZEIT
	stark = false
	rueckkehr = Vector2.ZERO

# Münzen zählen, bei 100 gibt es ein Leben dazu
func muenze_sammeln(amount := 1) -> void:
	muenzen += amount
	while muenzen > 99:
		muenzen -= 100
		leben += 1
		ton.play()
