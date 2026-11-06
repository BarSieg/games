extends Area2D


func _on_body_entered(body: Node2D) -> void:
	body.ziel_erreicht()
	for hoehe in [1.0, 1.26, 1.5, 2.0]:   # Dur-Akkord nach oben
		$ZielTon.pitch_scale = hoehe
		$ZielTon.play()
		await get_tree().create_timer(0.15).timeout
