# Inventur: Was liegt alles im Dungeon?
# Liest dungeon.tscn und zählt Gegenstände in Truhen, Fundstücken, Angeboten, Töpfen und Geschenken, dazu die Türen.
#
#   python inventur.py                  # Übersicht mit Zielen
#   python inventur.py herzcontainer    # nur ein Ding, dafür mit Raum und Position
#   python inventur.py tuer             # geht auch mit tuer und bosstuer

import re
import sys
from pathlib import Path

ORDNER = Path(__file__).parent
RAUM_GROESSE = (256, 176)   # wie in camera_2d.gd

# Welches Skript hat welchen Gegenstand in welcher Eigenschaft?
GEGENSTAND_IN = {
	"truhe.gd": "inhalt",
	"fundstueck.gd": "art",
	"angebot.gd": "ware",
	"figur.gd": "geschenk",
}

# Ziele: Name oder Liste von Namen, die gleich sein sollen, und die Zahl (None heißt: egal, nur gleich)
ZIELE = [
	(["HERZCONTAINER"], 7),
	(["SCHLUESSEL", "TUER"], None),
	(["KARTE", "KOMPASS", "MASTERSCHLUESSEL", "BOSSTUER"], 1),
]


def lies_eintraege(datei: Path) -> tuple[dict, list]:
	"""Zerlegt eine .tscn in ext_resources (id -> Pfad) und Knoten (Kopfzeile + Eigenschaften)."""
	resourcen = {}
	knoten = []
	aktuell = None
	for zeile in datei.read_text(encoding="utf-8").splitlines():
		if zeile.startswith("[ext_resource"):
			id_ = re.search(r' id="([^"]+)"', zeile).group(1)   # Leerzeichen davor, sonst passt auch uid="..."
			resourcen[id_] = re.search(r'path="res://([^"]+)"', zeile).group(1)
			aktuell = None
		elif zeile.startswith("[node"):
			aktuell = {"kopf": zeile, "werte": {}}
			knoten.append(aktuell)
		elif zeile.startswith("["):
			aktuell = None
		elif aktuell is not None and " = " in zeile:
			schluessel, wert = zeile.split(" = ", 1)
			aktuell["werte"][schluessel] = wert
	return resourcen, knoten


def kopf_wert(kopf: str, name: str) -> str | None:
	treffer = re.search(name + r'="([^"]*)"', kopf)
	return treffer.group(1) if treffer else None


def skript_standardwerte(skript: str) -> dict:
	"""Die Werte hinter @export var ... = ... im Skript, falls die Szene nichts anderes sagt."""
	werte = {}
	for zeile in (ORDNER / skript).read_text(encoding="utf-8").splitlines():
		treffer = re.match(r"@export var (\w+)\s*(?::[^=]*)?:?=\s*(.+?)\s*(#.*)?$", zeile)
		if treffer:
			werte[treffer.group(1)] = treffer.group(2)
	return werte


def wurzel_der_szene(szene: str) -> tuple[str | None, dict]:
	"""Skript und Werte der Wurzel einer Szene, auch bei geerbten Szenen (z. B. Händler erbt von Figur)."""
	resourcen, knoten = lies_eintraege(ORDNER / szene)
	wurzel = knoten[0]
	werte = {}
	skript = None
	instanz = re.search(r'instance=ExtResource\("([^"]+)"\)', wurzel["kopf"])
	if instanz:
		skript, werte = wurzel_der_szene(resourcen[instanz.group(1)])
	if "script" in wurzel["werte"]:
		skript = resourcen[re.search(r'ExtResource\("([^"]+)"\)', wurzel["werte"]["script"]).group(1)]
		werte = {**skript_standardwerte(skript), **werte}
	werte.update(wurzel["werte"])
	return skript, werte


def gegenstand_namen() -> list[str]:
	text = (ORDNER / "gegenstand.gd").read_text(encoding="utf-8")
	inhalt = re.search(r"enum Art\s*\{([^}]*)\}", text).group(1)
	return [n.strip() for n in inhalt.split(",") if n.strip()]


def als_art(wert: str, namen: list[str]) -> str:
	"""5 oder Gegenstand.Art.HERZCONTAINER -> HERZCONTAINER"""
	wert = wert.strip()
	if wert.isdigit():
		return namen[int(wert)]
	return wert.split(".")[-1]


def position(werte: dict) -> tuple[float, float]:
	treffer = re.search(r"Vector2\(([-\d.e]+), ([-\d.e]+)\)", werte.get("position", ""))
	return (float(treffer.group(1)), float(treffer.group(2))) if treffer else (0.0, 0.0)


def fundliste() -> list[dict]:
	"""Alles Zählbare im Dungeon: je ein Eintrag mit Art, Anzahl, Quelle, Knotenname und Position."""
	namen = gegenstand_namen()
	resourcen, knoten = lies_eintraege(ORDNER / "dungeon.tscn")
	positionen = {".": (0.0, 0.0)}   # Knotenpfad -> Position im Dungeon, für verschachtelte Knoten
	funde = []
	for k in knoten[1:]:
		name = kopf_wert(k["kopf"], "name")
		eltern = kopf_wert(k["kopf"], "parent")
		pfad = name if eltern == "." else eltern + "/" + name
		ex, ey = positionen.get(eltern, (0.0, 0.0))
		x, y = position(k["werte"])
		pos = (ex + x, ey + y)
		positionen[pfad] = pos

		instanz = re.search(r'instance=ExtResource\("([^"]+)"\)', k["kopf"])
		if not instanz:
			continue
		szene = resourcen[instanz.group(1)]
		skript, werte = wurzel_der_szene(szene)
		werte = {**werte, **k["werte"]}
		quelle = Path(szene).stem.capitalize()
		skript = Path(skript).name if skript else ""

		if skript == "tuer.gd":
			art = "BOSSTUER" if werte.get("master") == "true" else "TUER"
			funde.append({"art": art, "anzahl": 1, "quelle": quelle, "name": pfad, "pos": pos, "extra": ""})
		elif skript == "topf.gd" and int(werte.get("muenzen", "0")) > 0:
			funde.append({"art": "MUENZE", "anzahl": int(werte["muenzen"]), "quelle": quelle, "name": pfad, "pos": pos, "extra": ""})
		elif skript in GEGENSTAND_IN:
			art = als_art(werte[GEGENSTAND_IN[skript]], namen)
			anzahl = 1
			extra = ""
			if skript == "figur.gd":
				anzahl = int(werte.get("geschenk_anzahl", "0"))
				if anzahl == 0:
					continue
				extra = "nimmt" if anzahl < 0 else "schenkt"
			elif skript == "angebot.gd":
				extra = werte.get("preis", "?") + " Münzen" + (", einmalig" if werte.get("einmalig") == "true" else "")
			elif skript == "truhe.gd" and werte.get("belohnung") == "true":
				extra = "Belohnung"
			funde.append({"art": art, "anzahl": anzahl, "quelle": quelle, "name": pfad, "pos": pos, "extra": extra})
	return funde


def raum_von(pos: tuple[float, float]) -> tuple[int, int]:
	return (int(pos[0] // RAUM_GROESSE[0]), int(pos[1] // RAUM_GROESSE[1]))


def uebersicht(funde: list[dict]) -> None:
	summe = {}
	for f in funde:
		if f["anzahl"] > 0:   # was jemand wegnimmt, liegt ja nicht im Dungeon
			summe[f["art"]] = summe.get(f["art"], 0) + f["anzahl"]
	alle = gegenstand_namen() + ["TUER", "BOSSTUER"]
	print("Was liegt im Dungeon:")
	for art in alle:
		print(f"  {art:18}{summe.get(art, 0):5}")
	print()
	print("Ziele:")
	for gruppe, ziel in ZIELE:
		werte = [summe.get(art, 0) for art in gruppe]
		ok = len(set(werte)) == 1 and (ziel is None or werte[0] == ziel)
		text = " = ".join(f"{art} {w}" for art, w in zip(gruppe, werte))
		soll = "alle gleich" if ziel is None else f"Ziel {ziel}"
		print(f"  {'✔' if ok else '✘'}  {text}   ({soll})")


def einzeln(funde: list[dict], art: str) -> None:
	treffer = [f for f in funde if f["art"] == art]
	if not treffer:
		print(f"Kein {art} im Dungeon. Möglich sind: {', '.join(gegenstand_namen() + ['TUER', 'BOSSTUER'])}")
		return
	plus = sum(f["anzahl"] for f in treffer if f["anzahl"] > 0)
	minus = sum(f["anzahl"] for f in treffer if f["anzahl"] < 0)
	print(f"{art}: {plus}" + (f"   (und {minus} weg)" if minus else ""))
	for f in sorted(treffer, key=lambda f: (raum_von(f["pos"])[1], raum_von(f["pos"])[0])):
		rx, ry = raum_von(f["pos"])
		anzahl = f"{f['anzahl']:+} " if f["anzahl"] != 1 else ""
		extra = f"  ({f['extra']})" if f["extra"] else ""
		print(f"  Raum ({rx:2}, {ry:2})  bei {f['pos'][0]:6.0f}, {f['pos'][1]:6.0f}   {anzahl}{f['quelle']:12} {f['name']}{extra}")


if __name__ == "__main__":
	sys.stdout.reconfigure(encoding="utf-8")
	funde = fundliste()
	if len(sys.argv) > 1:
		einzeln(funde, sys.argv[1].upper())
	else:
		uebersicht(funde)
