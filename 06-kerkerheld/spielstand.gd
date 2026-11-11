extends Node

signal leben_geaendert
signal inventar_geaendert

const START_LEBEN = 6   # in halben Herzen: 6 sind drei ganze Herzen
const MAX_HERZEN = 10

const RAND = Color(0.16, 0.04, 0.06)
const VOLL = Color(0.85, 0.1, 0.15)
const GLANZ = Color(1.0, 0.67, 0.67)
const GOLD = Color(1, 0.8, 0.3)
const LEER = Color(0.3, 0.3, 0.3)
const LEER_GLANZ = Color(0.47, 0.47, 0.47)

var inventar := {}   # Gegenstand.Art -> Anzahl



var max_leben := START_LEBEN
var leben := START_LEBEN:
	set(wert):
		max_leben = min(max_leben, MAX_HERZEN * 2)
		leben = clampi(wert, 0, min(max_leben, MAX_HERZEN * 2))
		leben_geaendert.emit()


# Alles auf Anfang, für ein neues Spiel
func neues_spiel() -> void:
	max_leben = START_LEBEN
	leben = max_leben
	inventar.clear()
	inventar_geaendert.emit()


# Wie viele davon hat der Held?
func anzahl(art: Gegenstand.Art) -> int:
	return inventar.get(art, 0)


func hinzufuegen(art: Gegenstand.Art) -> void:
	if art == Gegenstand.Art.HERZCONTAINER:
		Spielstand.max_leben += 2
		Spielstand.leben += 20   # alle Herzen auffüllen, der Setter schneidet ab
	elif art == Gegenstand.Art.HERZ:
		Spielstand.leben += 2
	else:
		inventar[art] = anzahl(art) + 1
		inventar_geaendert.emit()


# Einen verbrauchen, falls der Held einen hat. Die Antwort sagt, ob es geklappt hat.
func verbrauchen(art: Gegenstand.Art) -> bool:
	if anzahl(art) == 0:
		return false
	inventar[art] -= 1
	inventar_geaendert.emit()
	return true
