extends Node

signal leben_geaendert
signal inventar_geaendert
signal gespeichert
signal gewonnen

const START_LEBEN = 6   # in halben Herzen: 6 sind drei ganze Herzen
const MAX_HERZEN = 10
const MONSTER_RAUMWECHSEL = 3   # Monster bleiben tot, bis der Held so viele andere Räume betreten hat
const DATEI = "user://spielstand.cfg"
const REKORDE = "user://ironman.cfg"
const REKORDE_ANZAHL = 5
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
var iron_man := false   # Tot ist tot: kein Speichern, kein Laden
# Wie die Dictionaries: immer dasselbe Ding, nur der Inhalt wechselt. Die Kamera hält es fest.
var letzte_raeume := LetzteRaeume.new(MONSTER_RAUMWECHSEL)
var spielzeit := 0.0      # in Sekunden. Läuft nur, wenn das Spiel nicht angehalten ist.
var zu_erkunden := {}    # Pfad im Dungeon -> true: alles, was für 100 % zählt. Füllt sich beim Bauen des Dungeons.
var ironman_platzierung := 0


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
	letzte_raeume.leeren()
	spielzeit = 0.0


# Alles, was sich der Held und die Welt merken müssen, in eine Datei
func speichern(wo: Variant) -> void:
	if iron_man:
		return   # Ein eiserner Held hat keinen Kontrollpunkt
	startpunkt = wo
	var datei := ConfigFile.new()
	datei.set_value("held", "startpunkt", startpunkt)
	datei.set_value("held", "max_leben", max_leben)
	datei.set_value("held", "inventar", inventar)
	datei.set_value("held", "spielzeit", int(spielzeit * 1000.0))   # ganze Millisekunden: Kommazahlen kommen nicht immer genau so zurück, und die Prüfsumme passt nicht mehr
	datei.set_value("held", "gestorben", gestorben)
	datei.set_value("welt", "erledigt", erledigt)
	datei.set_value("welt", "besucht", besucht)
	datei.set_value("welt", "erkundet", erkundet())
	datei.set_value("welt", "letzte_raeume", letzte_raeume.raeume)   # nur die Liste, ein Objekt kann ConfigFile nicht speichern
	datei.set_value("schutz", "pruefsumme", pruefsumme(datei))
	datei.save(DATEI)
	gespeichert.emit()


# Gibt es überhaupt schon einen Spielstand?
func spielstand_datei_vorhanden() -> bool:
	return FileAccess.file_exists(DATEI)


# Den letzten Stand zurückholen. Gibt es noch keinen, beginnt ein neues Spiel.
func laden() -> void:
	var datei := ConfigFile.new()
	if datei.load(DATEI) != OK:
		neues_spiel()
		return
	# Die Prüfsumme herausnehmen und neu ausrechnen. Passt sie nicht, hat jemand die Datei verändert.
	var hashwert: String = datei.get_value("schutz", "pruefsumme", "")
	datei.erase_section("schutz")
	if hashwert != pruefsumme(datei):
		push_warning("Spielstand wurde verändert. Selber schuld!")
		neues_spiel()
		return
	# Fehlt, wenn vor dem ersten Raumwechsel gespeichert wurde. null als Ersatzwert zählt für Godot nicht.
	startpunkt = datei.get_value("held", "startpunkt") if datei.has_section_key("held", "startpunkt") else null
	max_leben = datei.get_value("held", "max_leben", START_LEBEN)
	leben = mini(START_LEBEN, max_leben)   # wie im Original: weiter mit drei Herzen
	gestorben = datei.get_value("held", "gestorben", 0)
	# assign statt =: dieselben Dictionaries behalten, nur ihren Inhalt austauschen. Die Karte hält besucht fest.
	inventar.assign(datei.get_value("held", "inventar", {}))
	spielzeit = datei.get_value("held", "spielzeit", 0.0) / 1000.0
	erledigt.assign(datei.get_value("welt", "erledigt", {}))
	letzte_raeume.uebernehmen(datei.get_value("welt", "letzte_raeume", []))
	besucht.assign(datei.get_value("welt", "besucht", {}))
	inventar_geaendert.emit()


func load_stats_fuer_titel() -> Array[int]:
	var titel_erkundet := 0
	var titel_spielzeit := 0
	var datei := ConfigFile.new()
	if datei.load(Spielstand.DATEI) == OK:
		# Die Prüfsumme herausnehmen und neu ausrechnen. Passt sie nicht, hat jemand die Datei verändert.
		var hashwert: String = datei.get_value("schutz", "pruefsumme", "")
		datei.erase_section("schutz")
		if hashwert == pruefsumme(datei):
			titel_spielzeit = datei.get_value("held", "spielzeit", 0.0)
			titel_erkundet = datei.get_value("welt", "erkundet", 0)
	return [titel_spielzeit, titel_erkundet]


# Den Spielstand wegwerfen. Sonst holt der erste Tod ihn zurück.
func loeschen() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(DATEI))


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
	if art == Gegenstand.Art.KRONE:
		gewonnen.emit()
		if iron_man:
			rekord_eintragen()


# Rekordzeiten werden in Millisekunden gespeichert
func rekorde_laden() -> Array[int]:
	var ironman := ConfigFile.new()
	var beste_zeiten: Array[int] = []
	if ironman.load(REKORDE) == OK:
		# Die Prüfsumme herausnehmen und neu ausrechnen. Passt sie nicht, hat jemand die Datei verändert.
		var hashwert: String = ironman.get_value("schutz", "pruefsumme", "")
		ironman.erase_section("schutz")
		if hashwert == pruefsumme(ironman):
			beste_zeiten.assign(ironman.get_value("ironman", "bestezeiten", []))
	return beste_zeiten


func rekorde_speichern(beste_zeiten: Array[int]) -> void:
	var ironman := ConfigFile.new()
	ironman.set_value("ironman", "bestezeiten", beste_zeiten)
	ironman.set_value("schutz", "pruefsumme", pruefsumme(ironman))
	ironman.save(REKORDE)


func rekord_eintragen() -> void:
	var beste_zeiten: Array[int] = rekorde_laden()
	var neuer_rekord := int(spielzeit * 1000.0)   # in Millisekunden
	ironman_platzierung = beste_zeiten.bsearch(neuer_rekord)
	if ironman_platzierung < REKORDE_ANZAHL:
		beste_zeiten.insert(ironman_platzierung, neuer_rekord)
		if beste_zeiten.size() > REKORDE_ANZAHL:
			beste_zeiten.resize(REKORDE_ANZAHL)
		rekorde_speichern(beste_zeiten)


# Einen oder mehrere verbrauchen, falls der Held genug hat. Die Antwort sagt, ob es geklappt hat.
func verbrauchen(art: Gegenstand.Art, menge := 1) -> bool:
	if anzahl(art) < menge:
		return false
	inventar[art] -= menge
	inventar_geaendert.emit()
	return true


# Sekunden als Uhrzeit, auf die Millisekunde: 125 wird zu "02:05.000", 3725 zu "01:02:05.000"
func formatiere_spielzeit(zeit_in_sekunden: float = spielzeit) -> String:
	var stunden: int = int(zeit_in_sekunden / 60.0 / 60.0)
	var minuten: int = int(zeit_in_sekunden / 60.0) % 60
	var sekunden: int = int(zeit_in_sekunden) % 60
	var millisekunden: int = int(zeit_in_sekunden * 1000.0) % 1000
	if stunden > 0:
		return "%02d:%02d:%02d.%03d" % [stunden, minuten, sekunden, millisekunden]
	return "%02d:%02d.%03d" % [minuten, sekunden, millisekunden]


# Dieses Ding zählt für die Erkundung. Gehört in _ready(), noch vor ein mögliches queue_free().
func zaehlt_mit(ding: Node) -> void:
	zu_erkunden[str(ding.get_path())] = true


# Wie viel Prozent davon schon erledigt ist. floori: 100 % gibt es erst, wenn wirklich alles gefunden ist.
func erkundet() -> int:
	if zu_erkunden.is_empty():
		return 0
	var gefunden := zu_erkunden.keys().filter(func(pfad: String) -> bool: return pfad in erledigt).size()
	return floori(100.0 * gefunden / zu_erkunden.size())


# Merkt sich die letzten paar Räume, jeden nur einmal. Ist sie voll, fällt der älteste heraus.
# Ein Raum, der schon drin ist, rückt nicht wieder nach hinten. Das wäre genauer, merkt aber kein Spieler.
class LetzteRaeume:
	var platz: int                   # so viele Räume passen hinein
	var raeume: Array[Vector2i] = []   # vorn der älteste, hinten der neueste


	func _init(anzahl: int) -> void:
		platz = anzahl


	func hinzufuegen(neu: Vector2i) -> void:
		if neu in raeume:
			return
		raeume.append(neu)
		if raeume.size() > platz:
			raeume.pop_front()


	func enthaelt(gesucht: Vector2i) -> bool:
		return gesucht in raeume


	func leeren() -> void:
		raeume.clear()


	# Wie assign bei den Dictionaries: den Inhalt austauschen, das Ding selbst bleibt dasselbe
	func uebernehmen(liste: Array) -> void:
		raeume.assign(liste)
		while raeume.size() > platz:   # falls MONSTER_RAUMWECHSEL inzwischen kleiner ist als beim Speichern
			raeume.pop_front()
