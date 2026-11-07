extends CanvasLayer


func _process(delta: float) -> void:
	$Muenzen.text = "%02d" % Spielstand.muenzen
	$Leben.text = "%d" % Spielstand.leben
	if Spielstand.zeit > 0: 
		if not get_tree().get_first_node_in_group("held").im_ziel:
			Spielstand.zeit -= delta
	else:
		get_tree().call_group("held", "sterben")
	$Timer.text = "%03d" % Spielstand.zeit
