extends StaticBody2D

# Ein Gitter in einer Öffnung. Ein Schalter oder etwas anderes sagt ihm, wann es auf- und zugeht.

const ZEIT = 0.3   # so lange dauert Auf- oder Zugehen

@export var offen := false   # so steht es beim Start
@export var merken := true   # einmal offen, immer offen. Auch nach dem Laden.
@export var hinter_dem_helden := false # schliesst wenn der Held den Raum betritt

var tween: Tween


func _ready() -> void:
	if merken and Spielstand.ist_erledigt(self):
		offen = true
	if hinter_dem_helden:
		offen = true
		get_tree().get_first_node_in_group("held").angekommen.connect(held_angekommen)
	# Gleich richtig hinstellen, ohne Bewegung und ohne Ton
	$Bilder.scale.y = 0.0 if offen else 1.0
	$CollisionShape2D.disabled = offen


func oeffnen() -> void:
	if merken:
		Spielstand.erledigen(self)
	stellen(true)


func schliessen() -> void:
	if merken and Spielstand.ist_erledigt(self):
		return   # Gemerkt ist gemerkt
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
