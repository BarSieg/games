extends StaticBody2D

@export var ware: Gegenstand.Art = Gegenstand.Art.HERZ
@export var preis := 10
@export var einmalig := false   # nur einmal zu haben, zum Beispiel der Herzcontainer


func _ready() -> void:
	$Preis.text = str(preis)


func _draw() -> void:
	Gegenstand.malen(self, ware, Vector2(0, 7))


# Fragen, bezahlen, einpacken
func benutzen() -> void:
	var ja: bool = await Dialog.frage("%s für %d Münzen?" % [Gegenstand.NAMEN[ware], preis])
	if not ja:
		Dialog.zeigen(["Gucken kostet nichts. Noch nicht."])
	elif not Spielstand.verbrauchen(Gegenstand.Art.MUENZE, preis):
		Dialog.zeigen(["Das reicht nicht. Komm wieder, wenn du flüssig bist."])
	else:
		Spielstand.hinzufuegen(ware)
		Schatz.zeigen(get_tree().get_first_node_in_group("held"), ware)
		if einmalig:
			queue_free()
		Dialog.zeigen(["Gute Wahl! Umtausch ausgeschlossen."])
