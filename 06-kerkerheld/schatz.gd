class_name Schatz
extends Node2D

var art := Gegenstand.Art.SCHLUESSEL


func _draw() -> void:
	Gegenstand.malen(self, art, Vector2.ZERO)
