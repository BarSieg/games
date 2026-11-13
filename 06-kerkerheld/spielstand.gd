extends Node

signal leben_geaendert
signal inventar_geaendert
signal gespeichert

const START_LEBEN = 6   # in halben Herzen: 6 sind drei ganze Herzen
const MAX_HERZEN = 10
const DATEI = "user://spielstand.cfg"
const SALZ = "Glibber essen keine Kekse"

var inventar := {}   # Gegenstand.Art -> Anzahl
var erledigt := {}   # Pfad im Dungeon -> true: offene Truhen und Türen, eingesammelte Dinge, ...
var besucht := {}    # Raum -> true, für die Karte
var startpunkt: Variant = null   # Hier steht der Held nach dem Laden. null heißt: wo er in der Szene steht.
var max_leben := START_LEBEN
var leben := START_LEBEN:
	set(wert):
		max_leben = mini(max_leben, MAX_HERZEN * 2)
		leben = clampi(wert, 0, mini(max_leben, MAX_HERZEN * 2))
		leben_geaendert.emit()
var gestorben := 0   # wie oft der Held schon gestorben ist, für den Grabstein


# _init statt _ready: Das läuft, sobald der Spielstand entsteht, noch bevor der Dungeon gebaut wird
func _init() -> void:
	laden()


# Alles auf Anfang, für ein neues Spiel
func neues_spiel() -> void:
	max_leben = START_LEBEN
	leben = max_leben
	inventar.clear()
	erledigt.clear()
	besucht.clear()
	startpunkt = null
	inventar_geaendert.emit()
	gestorben = 0


# Alles, was sich der Held und die Welt merken müssen, in eine Datei
func speichern(wo: Vector2) -> void:
	startpunkt = wo
	var datei := ConfigFile.new()
	datei.set_value("held", "startpunkt", startpunkt)
	datei.set_value("held", "max_leben", max_leben)
	datei.set_value("held", "inventar", inventar)
	datei.set_value("held", "gestorben", gestorben)
	datei.set_value("welt", "erledigt", erledigt)
	datei.set_value("welt", "besucht", besucht)
	datei.set_value("schutz", "pruefsumme", pruefsumme(datei))
	datei.save(DATEI)
	gespeichert.emit()


# Gibt es überhaupt schon einen Spielstand?
func spielstand_datei_vorhanden() -> bool:
	var datei := ConfigFile.new()
	return datei.load(DATEI) == OK


# Den letzten Stand zurückholen. Gibt es noch keinen, beginnt ein neues Spiel.
func laden() -> void:
	var datei := ConfigFile.new()
	if datei.load(DATEI) != OK:
		neues_spiel()
		return
	# Die Prüfsumme herausnehmen und neu ausrechnen. Passt sie nicht, hat jemand die Datei verändert.
	var gespeichert: String = datei.get_value("schutz", "pruefsumme", "")
	datei.erase_section("schutz")
	if gespeichert != pruefsumme(datei):
		push_warning("Spielstand wurde verändert. Selber schuld!")
		neues_spiel()
		return
	startpunkt = datei.get_value("held", "startpunkt", null)
	max_leben = datei.get_value("held", "max_leben", START_LEBEN)
	leben = mini(START_LEBEN, max_leben)   # wie im Original: weiter mit drei Herzen
	gestorben = datei.get_value("held", "gestorben", 0)
	# assign statt =: dieselben Dictionaries behalten, nur ihren Inhalt austauschen. Die Karte hält besucht fest.
	inventar.assign(datei.get_value("held", "inventar", {}))
	erledigt.assign(datei.get_value("welt", "erledigt", {}))
	besucht.assign(datei.get_value("welt", "besucht", {}))
	inventar_geaendert.emit()


# Ein Fingerabdruck der ganzen Datei. Ohne das Geheimnis kann ihn niemand passend neu ausrechnen.
func pruefsumme(datei: ConfigFile) -> String:
	return (datei.encode_to_text() + SALZ).sha256_text()


# Hat der Held dieses Ding schon geöffnet, eingesammelt, gekauft, ...?
func ist_erledigt(ding: Node) -> bool:
	return str(ding.get_path()) in erledigt


func erledigen(ding: Node) -> void:
	erledigt[str(ding.get_path())] = true


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
		inventar[art] = mini(anzahl(art) + 1, 99)
		inventar_geaendert.emit()


# Einen oder mehrere verbrauchen, falls der Held genug hat. Die Antwort sagt, ob es geklappt hat.
func verbrauchen(art: Gegenstand.Art, menge := 1) -> bool:
	if anzahl(art) < menge:
		return false
	inventar[art] -= menge
	inventar_geaendert.emit()
	return true
