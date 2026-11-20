extends StaticBody2D

# Ein Gitter in einer Öffnung. Ein Schalter oder etwas anderes sagt ihm, wann es auf- und zugeht.

const ZEIT = 0.3   # so lange dauert Auf- oder Zugehen

@export var offen := false   # so steht es beim Start
@export var merken := true   # einmal offen, immer offen. Auch nach dem Laden.
@export var hinter_dem_helden := false   # steht offen, bis der Held im Raum ist. Dann geht es zu.
@export var kampf := false   # lässt den Helden herein, aber erst wieder hinaus, wenn alle Monster im Raum besiegt sind
@export var schalter_noetig := 1   # so viele Schalter müssen gleichzeitig gedrückt sein

var tween: Tween
var monster_im_raum := []
var schalter_aktiv := 0   # so viele sind es gerade


func _ready() -> void:
	if merken and Spielstand.ist_erledigt(self):
		offen = true
	if hinter_dem_helden or kampf:
		offen = true
		get_tree().get_first_node_in_group("held").angekommen.connect(held_angekommen)
	if kampf:
		merken = true # Kampfgitter muss gemerkt werden
		var alle_monster := get_tree().get_nodes_in_group("monster")
		for monster in alle_monster:
			if %Camera2D.raum_von(monster.position) == %Camera2D.raum_von(self.position):
				monster_im_raum.append(monster)
	# Gleich richtig hinstellen, ohne Bewegung und ohne Ton
	$Bilder.scale.y = 0.0 if offen else 1.0
	$CollisionShape2D.disabled = offen


func _physics_process(_delta: float) -> void:
	if kampf:
		if monster_im_raum.all(func(monster: Monster) -> bool: return monster.tot):
			oeffnen()


func oeffnen() -> void:
	schalter_aktiv += 1
	if schalter_aktiv == schalter_noetig:
		if merken:
			Spielstand.erledigen(self)
		stellen(true)


func schliessen() -> void:
	if merken and Spielstand.ist_erledigt(self):
		return   # Gemerkt ist gemerkt
	schalter_aktiv = max(schalter_aktiv - 1, 0)
	stellen(false)


# Auf- oder zugehen: Die Stäbe versinken im Boden oder kommen heraus
func stellen(auf: bool) -> void:
	if auf == offen:
		return
	offen = auf
	$CollisionShape2D.set_deferred("disabled", offen)
	$Ton.play()
	if tween:
		tween.kill()   # Ein Schalter kann schneller umschalten, als das Gitter fährt
	tween = create_tween()
	tween.tween_property($Bilder, "scale:y", 0.0 if offen else 1.0, ZEIT)


# Der Held ist nach einem Raumwechsel fertig hereingelaufen. In meinen Raum?
func held_angekommen() -> void:
	if %Camera2D.raum == %Camera2D.raum_von(global_position):
		schliessen()
