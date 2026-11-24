extends Node2D

var drehtempo := PI 
var schaden := 2
const SCHUB = 3.0  # schubst den Gegner so viele Pixel weg


func _physics_process(delta: float) -> void:
	rotation += drehtempo * delta
	$Axt/Bild.rotation = rotation * 2
	$Axt2/Bild.rotation = rotation * 2


func treffer(body: Node2D, richtung : Vector2) -> void:
	body.treffer(schaden, richtung.normalized() * SCHUB)


func _on_axt_2_body_entered(body: Node2D) -> void:
	treffer(body, -$Axt2/Bild.position)


func _on_axt_body_entered(body: Node2D) -> void:
	treffer(body,-$Axt/Bild.position)
