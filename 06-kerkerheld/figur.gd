extends StaticBody2D

@export var NPC_Name := "Alter Mann"   # 0 heißt: kein Geschenk
@export_multiline var seiten: Array[String] = ["Es ist gefährlich, allein zu gehen!", "Nimm das hier."]
@export_multiline var danach: Array[String] = ["Was denn noch? Mehr hab ich nicht."]
@export var geschenk: Gegenstand.Art = Gegenstand.Art.MUENZE
@export var geschenk_anzahl := 0   # 0 heißt: kein Geschenk
@export var beim_betreten := false   # spricht den Helden von selbst an, sobald er den Raum betritt

var schon_geredet := false


func _ready() -> void:
	if beim_betreten:
		%Camera2D.raumwechsel.connect(raum_betreten)


# Die Kamera ist in einem neuen Raum angekommen. Ist es meiner, und kennen wir uns noch nicht?
func raum_betreten(_richtung: Vector2i) -> void:
	if not schon_geredet and %Camera2D.raum == %Camera2D.raum_von(global_position):
		benutzen()


# Beim ersten Mal reden und vielleicht etwas schenken, danach nur noch reden
func benutzen() -> void:
	if schon_geredet:
		Dialog.zeigen(danach, NPC_Name)
		return
	schon_geredet = true
	await Dialog.zeigen(seiten, NPC_Name)
	if geschenk_anzahl > 0:
		for i in geschenk_anzahl:
			Spielstand.hinzufuegen(geschenk)
		Schatz.zeigen(get_tree().get_first_node_in_group("held"), geschenk)
	# Weggenommen werden nur die Münzen
	if geschenk_anzahl < 0 and Spielstand.anzahl(Gegenstand.Art.MUENZE) > 0:
		Spielstand.verbrauchen(Gegenstand.Art.MUENZE, mini(Spielstand.anzahl(Gegenstand.Art.MUENZE), abs(geschenk_anzahl)))
