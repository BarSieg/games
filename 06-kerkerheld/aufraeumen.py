"""Räumt dungeon.tscn auf.

1. Sortieren: Alle Dinge derselben Art (alle Truhen, alle Töpfe, ...) stehen im Szenenbaum
   hintereinander, innerhalb einer Art nach Namen: Topf, Topf2, Topf3, ..., Topf10.
   Die Arten kommen in der Reihenfolge, in der sie zum ersten Mal in der Datei auftauchen.
   Nodes ohne eigene Szene (Boden, Waende, Camera2D, Anzeige, ...) bleiben ganz oben.
2. Ausrichten: Kleine Dinge (eine Kachel groß) bekommen eine Position in der Mitte einer Kachel,
   also (16 * x + 8, 16 * y + 8). Türen, Gitter, Raumgrenzen, Marker und der Boss nicht.

Vorher in Godot die Szene schließen (oder Godot ganz) und committen!
Sonst speichert der Editor beim nächsten Strg+S seinen alten Stand darüber.

Aufruf im Ordner 06-kerkerheld:
    python aufraeumen.py              # zeigt nur, was passieren würde
    python aufraeumen.py --schreiben  # ändert dungeon.tscn wirklich
"""

import math
import re
import sys

DATEI = "dungeon.tscn"
KACHEL = 16

# Diese Szenen werden auf die Kachelmitte gesetzt. Alles andere bleibt, wo es ist.
AUSRICHTEN = {
    "saeule.tscn", "topf.tscn", "glibber.tscn", "fledermaus.tscn", "geist.tscn", "ratte.tscn",
    "truhe.tscn", "mimic.tscn", "schild.tscn", "fundstueck.tscn", "figur.tscn", "haendler.tscn",
    "tuerbesitzer.tscn", "dornen.tscn", "restart.tscn", "grabstein.tscn", "falschewand.tscn",
    "schalter.tscn", "felsbrocken.tscn", "wasserspeier.tscn", "klingenfalle.tscn", "fackel.tscn",
}

# In diesen Räumen bleibt alles, wie es ist (Raum wie raum_von() ihn nennt)
NICHT_AUSRICHTEN_IN = {(1, -1)}

RAUM_BREITE = 256
RAUM_HOEHE = 176


def raum_von(x, y):
    return (math.floor(x / RAUM_BREITE), math.floor(y / RAUM_HOEHE))


# Die nächste Kachelmitte. Genau auf der Grenze zwischen zwei Kacheln geht es nach rechts bzw. unten.
def kachelmitte(wert):
    return math.floor((wert - KACHEL / 2) / KACHEL + 0.5) * KACHEL + KACHEL // 2


# Topf2 vor Topf10: Zahlen im Namen als Zahlen vergleichen, nicht Zeichen für Zeichen
def natuerlich(name):
    return [int(teil) if teil.isdigit() else teil.lower() for teil in re.split(r"(\d+)", name)]


def zahl(text):
    wert = float(text)
    return str(int(wert)) if wert == int(wert) else text


def main():
    schreiben = "--schreiben" in sys.argv
    text = open(DATEI, encoding="utf-8").read()

    # Die Datei besteht aus Blöcken, die jeweils mit [ am Zeilenanfang beginnen
    bloecke = re.split(r"\n(?=\[)", text.rstrip("\n"))
    kopf = []      # alles vor dem ersten Node: gd_scene, ext_resource, sub_resource
    wurzel = None  # der Node Dungeon selbst
    gruppen = []   # jeder Node direkt unter Dungeon, zusammen mit allen seinen Kindern
    ende = []      # connection, editable, ...
    for block in bloecke:
        if block.startswith("[node"):
            parent = re.search(r'parent="([^"]*)"', block.split("\n")[0])
            if parent is None:
                wurzel = block
            elif parent.group(1) == ".":
                gruppen.append([block])
            else:
                gruppen[-1].append(block)   # Kinder stehen immer direkt hinter ihrem Node
        elif wurzel is None:
            kopf.append(block)
        else:
            ende.append(block)

    if any('index="' in g[0].split("\n")[0] for g in gruppen):
        sys.exit("Abbruch: Ein Node hat ein index=. Damit kommt dieses Skript nicht zurecht.")

    # Welche Szene steckt hinter welcher ExtResource-ID?
    szenen = {
        m.group(2): m.group(1)
        for m in re.finditer(r'\[ext_resource type="PackedScene"[^\]]*path="res://([^"]+)" id="([^"]+)"', text)
    }

    def art(gruppe):
        m = re.search(r'instance=ExtResource\("([^"]+)"\)', gruppe[0].split("\n")[0])
        return szenen[m.group(1)] if m else None

    def name(gruppe):
        return re.search(r'name="([^"]+)"', gruppe[0]).group(1)

    # 1. Sortieren
    ohne_szene = [g for g in gruppen if art(g) is None]
    arten = []
    for g in gruppen:
        if art(g) is not None and art(g) not in arten:
            arten.append(art(g))
    sortiert = list(ohne_szene)
    for a in arten:
        sortiert += sorted((g for g in gruppen if art(g) == a), key=lambda g: natuerlich(name(g)))
    umsortiert = sum(1 for alt, neu in zip(gruppen, sortiert) if alt is not neu)

    # 2. Ausrichten
    verschoben = []
    for g in sortiert:
        if art(g) not in AUSRICHTEN:
            continue
        m = re.search(r"\nposition = Vector2\(([-\d.e]+), ([-\d.e]+)\)", g[0])
        if m is None:
            continue   # keine Position heißt (0, 0), da lassen wir die Finger davon
        x, y = float(m.group(1)), float(m.group(2))
        if raum_von(x, y) in NICHT_AUSRICHTEN_IN:
            continue
        nx, ny = kachelmitte(x), kachelmitte(y)
        if (nx, ny) != (x, y):
            g[0] = g[0][:m.start()] + f"\nposition = Vector2({nx}, {ny})" + g[0][m.end():]
            # Lag es genau auf der Grenze zwischen zwei Kacheln? Dann hat das Skript geraten.
            geraten = abs(nx - x) == KACHEL / 2 or abs(ny - y) == KACHEL / 2
            verschoben.append((name(g), zahl(m.group(1)), zahl(m.group(2)), nx, ny, geraten))

    print(f"{len(gruppen)} Nodes direkt unter Dungeon, {umsortiert} davon stehen jetzt an einer anderen Stelle.")
    print("Reihenfolge der Arten:", ", ".join(a.removesuffix(".tscn") for a in arten))
    print(f"{len(verschoben)} Dinge auf die Kachelmitte gesetzt.")
    geraten = [v for v in verschoben if v[5]]
    if geraten:
        print(f"Diese {len(geraten)} lagen genau zwischen zwei Kacheln. Schau nach, ob die Seite stimmt:")
        for n, x, y, nx, ny, _ in sorted(geraten, key=lambda v: natuerlich(v[0])):
            print(f"  {n}: ({x}, {y}) -> ({nx}, {ny})")

    if not schreiben:
        print("\nNichts geändert. Mit --schreiben wird dungeon.tscn wirklich umgebaut.")
        return

    # Jeder Node-Block endet mit einer Leerzeile, auch der, der vorher ganz am Ende der Datei stand
    nodes = [block.rstrip("\n") + "\n" for g in sortiert for block in g]
    neu = kopf + [wurzel] + nodes + ende
    open(DATEI, "w", encoding="utf-8", newline="\n").write("\n".join(neu) + "\n")
    print("\ndungeon.tscn geschrieben. In Godot die Szene neu öffnen.")


if __name__ == "__main__":
    main()
