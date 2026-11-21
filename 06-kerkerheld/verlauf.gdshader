shader_type canvas_item;

uniform vec4 oben : source_color = vec4(0.0, 0.9, 0.3, 1.0);
uniform vec4 unten : source_color = vec4(0.0, 0.2, 0.1, 1.0);
uniform float von = 10.0;   // ab hier (in Pixeln von oben) beginnt der Verlauf
uniform float bis = 26.0;   // und hier ist er fertig

varying float y;

// Läuft für jede Ecke eines Buchstabens: Wir merken uns, wie weit unten sie im Label liegt
void vertex() {
	y = VERTEX.y;
	y = y + sin(TIME * 2.0) * 5.0;
}

// Läuft für jeden Pixel: Farbe je nach Höhe mischen, die Form (Alpha) vom Buchstaben behalten
void fragment() {
	vec4 farbe = mix(oben, unten, smoothstep(von, bis, y));
	COLOR = vec4(farbe.rgb, COLOR.a);
}