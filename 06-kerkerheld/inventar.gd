extends Node2D


func _ready() -> void:
	Spielstand.inventar_geaendert.connect(aktualisieren)
	aktualisieren()


func aktualisieren() -> void:
	$Anzahl.text = "x%d" % Spielstand.anzahl(Gegenstand.Art.SCHLUESSEL)
	queue_redraw()


func _draw() -> void:
	Gegenstand.malen(self, Gegenstand.Art.SCHLUESSEL, Vector2(4, 30))
	if Spielstand.anzahl(Gegenstand.Art.MASTERSCHLUESSEL) > 0:
		Gegenstand.malen(self, Gegenstand.Art.MASTERSCHLUESSEL, Vector2(28, 30))
	if Spielstand.anzahl(Gegenstand.Art.KARTE) > 0:
		Gegenstand.malen(self, Gegenstand.Art.KARTE, Vector2(46, 21))
	if Spielstand.anzahl(Gegenstand.Art.KOMPASS) > 0:
		Gegenstand.malen(self, Gegenstand.Art.KOMPASS, Vector2(46, 34))
