extends CanvasLayer

const START_TIMER = 400

var time_left = START_TIMER

func _process(_delta: float) -> void:
	$Muenzen.text = "%02d" % Spielstand.muenzen
	$Leben.text = "%d" % Spielstand.leben
	if time_left > 0:
		time_left -= _delta
	else:
		get_tree().call_group("held", "sterben")
	$Timer.text = "%03d" % time_left
