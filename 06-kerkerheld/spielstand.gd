extends Node

signal leben_geaendert
signal inventar_geaendert

const START_LEBEN = 6   # in halben Herzen: 6 sind drei ganze Herzen
const MAX_HERZEN = 10

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
		max_leben += 2
		leben += 20   # alle Herzen auffüllen, der Setter schneidet ab
	elif art == Gegenstand.Art.HERZ:
		leben += 2
	else:
		inventar[art] = min(anzahl(art) + 1, 99)
		inventar_geaendert.emit()


# Einen oder mehrere verbrauchen, falls der Held genug hat. Die Antwort sagt, ob es geklappt hat.
func verbrauchen(art: Gegenstand.Art, menge := 1) -> bool:
	if anzahl(art) < menge:
		return false
	inventar[art] -= menge
	inventar_geaendert.emit()
	return true
