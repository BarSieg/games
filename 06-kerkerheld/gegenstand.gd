class_name Gegenstand

# Alles, was in einer Truhe liegen und ins Inventar wandern kann
enum Art { SCHLUESSEL, MASTERSCHLUESSEL, KARTE, KOMPASS }

# Zu jeder Art ein Bild aus Text und welche Farbe welches Zeichen hat. Andere Zeichen bleiben durchsichtig.
const BILDER = {
	Art.SCHLUESSEL: [
		[
			"..ooo..",
			".o###o.",
			"o##o##o",
			"o##o##o",
			".o###o.",
			"..o#o..",
			"..o#oo.",
			"..o##o.",
			"..o#oo.",
			"..o##o.",
			"..o#o..",
			"...o...",
		],
		{"o": Color(0.16, 0.12, 0.08), "#": Color(0.78, 0.78, 0.84)},
	],
	Art.MASTERSCHLUESSEL: [
		[
			"...ooo...",
			"..o###o..",
			".o##+##o.",
			"o##+++##o",
			".o##+##o.",
			"..o###o..",
			"...o#o...",
			"...o#oo..",
			"...o###o.",
			"...o#oo..",
			"...o##o..",
			"...o#oo..",
			"...o#o...",
			"....o....",
		],
		{"o": Color(0.24, 0.14, 0.04), "#": Color(1.0, 0.8, 0.3), "+": Color(0.86, 0.12, 0.16)},
	],
	Art.KARTE: [
		[
			"oooooooooo",
			"o##-##-##o",
			"o##-##-##o",
			"o--------o",
			"o##-##-##o",
			"o##-##-xxo",
			"o--------o",
			"o##-##-##o",
			"oooooooooo",
		],
		{"o": Color(0.31, 0.2, 0.1), "#": Color(0.92, 0.84, 0.63), "-": Color(0.63, 0.43, 0.24), "x": Color(0.82, 0.12, 0.12)},
	],
	Art.KOMPASS: [
		[
			"..ooooo..",
			".o#####o.",
			"o###r###o",
			"o##rrr##o",
			"o###o###o",
			"o##sss##o",
			"o###s###o",
			".o#####o.",
			"..ooooo..",
		],
		{"o": Color(0.24, 0.14, 0.04), "#": Color(0.94, 0.94, 0.9), "r": Color(0.82, 0.12, 0.12), "s": Color(0.47, 0.47, 0.55)},
	],
}


# Einen Gegenstand malen. Die Stelle ist die Mitte seiner Unterkante, also da, wo er "steht".
static func malen(leinwand: CanvasItem, art: Art, mitte_unten: Vector2) -> void:
	var bild: Array = BILDER[art][0]
	var ecke := mitte_unten - Vector2(bild[0].length() / 2.0, bild.size()).floor()
	bild_malen(leinwand, bild, ecke, BILDER[art][1])


# Ein Bild aus Text malen, Pixel für Pixel. Geht nur aus dem _draw() der Leinwand heraus.
static func bild_malen(leinwand: CanvasItem, bild: Array, ecke: Vector2, farben: Dictionary) -> void:
	for y in bild.size():
		for x in bild[y].length():
			var zeichen: String = bild[y][x]
			if zeichen in farben:
				leinwand.draw_rect(Rect2(ecke + Vector2(x, y), Vector2.ONE), farben[zeichen])
