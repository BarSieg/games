extends StaticBody2D

var seite: String = "Hier ruhen %d Helden. Alle sahen aus wie du..."


# Lesen statt zustechen
func benutzen() -> void:
	if Spielstand.gestorben > 1:
		Dialog.zeigen([seite % Spielstand.gestorben], "Grabstein")
