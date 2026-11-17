extends StaticBody2D

# Soll im Bossraum platziert werden

func _ready() -> void:
	visible = false
	$CollisionShape2D.disabled = true
	%Camera2D.bossraum_betreten.connect(raum_sperren)
	Spielstand.gewonnen.connect(raum_entsperren)


func raum_sperren() -> void:
	var monster_im_raum := []
	var alle_monster := get_tree().get_nodes_in_group("monster")
	for monster in alle_monster:
		if %Camera2D.raum_von(monster.position) == %Camera2D.raum_von(self.position):
			monster_im_raum.append(monster)
	if not monster_im_raum.all(func(monster: Monster) -> bool: return monster.tot):
		$CollisionShape2D.disabled = false
		visible = true


func raum_entsperren() -> void:
	visible = false
	$CollisionShape2D.disabled = true
