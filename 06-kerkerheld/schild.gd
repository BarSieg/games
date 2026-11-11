extends StaticBody2D

@export_multiline var seiten: Array[String] = ["Hier könnte Ihre Werbung stehen."]


# Lesen statt zustechen
func benutzen() -> void:
	Dialog.zeigen(seiten)
