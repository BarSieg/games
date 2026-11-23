extends Node2D

var drehtempo := PI / 2
var schaden := 1


func _physics_process(delta: float) -> void:
	rotation += drehtempo * delta
	$Axt/Bild.rotation = rotation
	$Axt2/Bild.rotation = rotation + PI


func treffer(body: Node2D) -> void:
	body.treffer(schaden)


func _on_axt_2_body_entered(body: Node2D) -> void:
	treffer(body)


func _on_axt_body_entered(body: Node2D) -> void:
	treffer(body)
