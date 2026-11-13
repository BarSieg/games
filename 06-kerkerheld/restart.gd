extends StaticBody2D

var seite: String = "Willst du deinen gesamten Fortschritt zurücksetzen und von vorne anfangen?"


func _ready() -> void:
	init()
	Spielstand.gespeichert.connect(init)   # sobald es eine Datei gibt, auftauchen


# Nur sichtbar, wenn es einen Spielstand gibt
func init() -> void:
	var activ := Spielstand.spielstand_datei_vorhanden()
	$Bild.visible = activ
	$CollisionShape2D.disabled = not activ


# Lesen statt zustechen
func benutzen() -> void:
	if Spielstand.spielstand_datei_vorhanden():
		var ja: bool = await Dialog.frage(seite, "Lotosstein")
		if ja:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(Spielstand.DATEI))
			Spielstand.neues_spiel()
			get_tree().reload_current_scene()   # Dungeon neu bauen, jetzt mit leerem Spielstand
