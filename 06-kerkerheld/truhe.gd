extends StaticBody2D

const BILD_OEFFNEN = 90
const BILD_OFFEN = 91

@export var inhalt: Gegenstand.Art = Gegenstand.Art.SCHLUESSEL
@export var belohnung := false   # erscheint wenn alle monster im raum besiegt sind

var offen := false
var monster_im_raum := []
var versteckt := false


func _ready() -> void:
	if Spielstand.ist_erledigt(self):
		offen = true
		$Bild.frame = BILD_OFFEN
		return
	if belohnung:
		var alle_monster := get_tree().get_nodes_in_group("monster")
		for monster in alle_monster:
			if %Camera2D.raum_von(monster.position) == %Camera2D.raum_von(self.position):
				monster_im_raum.append(monster)
		versteckt = true
		$Bild.visible = false
		$CollisionShape2D.disabled = true


# Der Held steht davor und drückt den Knopf
func benutzen() -> void:
	if offen or versteckt:
		return
	offen = true
	Spielstand.erledigen(self)
	$Bild.frame = BILD_OEFFNEN
	$Fanfare.play()
	Spielstand.hinzufuegen(inhalt)
	zeigen()


# Der Schatz steigt aus der Truhe auf, bleibt kurz stehen und verblasst
func zeigen() -> void:
	var tween := Schatz.zeigen(self, inhalt)
	tween.tween_property($Bild, "frame", BILD_OFFEN, 0.0)


func erscheinen() -> void:
	versteckt = false
	$Bild.visible = true
	$CollisionShape2D.disabled = false
	$Erscheinen.play()


func _physics_process(_delta: float) -> void:
	if versteckt:
		monster_im_raum = monster_im_raum.filter(is_instance_valid)
		if monster_im_raum.size() == 0:
			erscheinen()
