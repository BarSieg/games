extends CanvasLayer


func _process(_delta: float) -> void:
	$Muenzen.text = "%02d" % Spielstand.muenzen
	$Leben.text = "%d" % Spielstand.leben
