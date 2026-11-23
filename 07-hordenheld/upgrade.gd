class_name Upgrade
extends Resource

@export var titel := ""
@export var beschreibung := ""
@export var max_stufe := 5   # so oft kann man es wählen, 0 heißt: beliebig oft

@export_group("Wirkung")
@export var knoten := "."      # welcher Node, vom Held aus gesehen
@export var eigenschaft := ""  # welche Variable von diesem Node
@export var mal := 1.0         # erst malnehmen ...
@export var plus := 0.0        # ... dann dazuzählen
@export var neue_waffe: PackedScene   # gibt es eine, kommt sie beim ersten Mal an den Held
@export var braucht: Upgrade


func anwenden(held: Node, stufe: int) -> void:
	if neue_waffe != null and stufe == 0:
		held.add_child(neue_waffe.instantiate())
		return
	var ziel := held.get_node(knoten)
	var alt = ziel.get_indexed(eigenschaft)
	ziel.set_indexed(eigenschaft, alt * mal + plus)
