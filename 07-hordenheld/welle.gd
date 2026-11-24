class_name Welle
extends Resource

@export var start := 0                        # ab dieser Sekunde gilt die Welle
@export var gegner: Array[PackedScene] = []   # aus diesen wird zufällig gewählt
@export var takt := 1.0                       # so viele Sekunden zwischen zwei Gegnern
@export var leben_mal := 1.0
@export var elite: PackedScene                # kommt einmal am Anfang der Welle, darf leer bleiben
