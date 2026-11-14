extends Node2D


func _ready() -> void:
	Spielstand.inventar_geaendert.connect(aktualisieren)
	Spielstand.gespeichert.connect(gespeichert_animation)
	aktualisieren()


func gespeichert_animation() -> void:
	var tween := create_tween()
	tween.tween_property($Speichern, "visible", true, 0.2)
	tween.tween_property($Speichern, "visible", false, 0.2)
	tween.tween_property($Speichern, "visible", true, 0.2)
	tween.tween_property($Speichern, "visible", false, 0.2)
	tween.tween_property($Speichern, "visible", true, 0.2)
	tween.tween_property($Speichern, "modulate:a", 0, 1.0)
	await tween.finished
	$Speichern.visible = false
	$Speichern.modulate.a = 1.0


func aktualisieren() -> void:
	$Anzahl.text = " x %d" % Spielstand.anzahl(Gegenstand.Art.SCHLUESSEL)
	$Muenzen.text = " x %d" % Spielstand.anzahl(Gegenstand.Art.MUENZE)
	queue_redraw()


func _draw() -> void:
	Gegenstand.malen(self, Gegenstand.Art.MUENZE, Vector2(14, 47))
	Gegenstand.malen(self, Gegenstand.Art.SCHLUESSEL, Vector2(14, 30))
	if Spielstand.anzahl(Gegenstand.Art.MASTERSCHLUESSEL) > 0:
		Gegenstand.malen(self, Gegenstand.Art.MASTERSCHLUESSEL, Vector2(52, 30))
	if Spielstand.anzahl(Gegenstand.Art.KARTE) > 0:
		Gegenstand.malen(self, Gegenstand.Art.KARTE, Vector2(70, 28))
	if Spielstand.anzahl(Gegenstand.Art.KOMPASS) > 0:
		Gegenstand.malen(self, Gegenstand.Art.KOMPASS, Vector2(88, 28))
