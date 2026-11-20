"""Prüft, ob jeder Text im Spiel in texte.csv steht.

Gesucht wird:
- in allen .tscn: Schildtexte (seiten, danach), Namen (NPC_Name) und Label-Texte (text)
- in allen .gd: Texte, die wie ein Satz oder ein Wort für den Spieler aussehen
  (mit Leerzeichen oder großem Anfangsbuchstaben)

Ausgegeben wird, was in texte.csv fehlt, und was in texte.csv steht, aber nirgends mehr vorkommt.
Bei einem Tippfehler im Spiel taucht beides auf: der falsche Text als „fehlt“, der richtige als „unbenutzt“.

Aufruf im Ordner 06-kerkerheld:
    python texte.py

Für ein Übersetzungsprogramm wie DeepL gibt es noch zwei Befehle:

    python texte.py export de          schreibt alle deutschen Texte nach texte_de.txt, einen pro Zeile
    python texte.py export de fr       nur die, die auf Französisch noch fehlen (texte_de_fuer_fr.txt)
    python texte.py import fr datei    schreibt die Zeilen aus der Datei als Spalte "fr" in texte.csv

Beim Import zählt nur die Reihenfolge: Zeile 1 der Datei gehört zu Zeile 1 des Exports.
Hat die Datei so viele Zeilen, wie in "fr" noch fehlen, werden genau die Lücken gefüllt.
Hat sie so viele Zeilen, wie es Texte gibt, wird die ganze Spalte ersetzt.
"""

import csv
import glob
import re
import sys

CSV = "texte.csv"

# Texte, die zwar im Spiel stehen, aber nicht übersetzt werden: Platzhalter, die der Code
# sowieso überschreibt, Namen von Animationen, Formatierungen, ...
NICHT_UEBERSETZEN = {
    "lorem...", "> Ja     Nein", "x keys", "x coins", "0:00:00", "<Status>", "Händler:", "RESET",
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
    "Glibber essen keine Kekse",                    # das Salz für die Prüfsumme
    "Spielstand wurde verändert. Selber schuld!",   # sieht nur, wer Godot offen hat
    "Deutsch", "English", "Français",                # Sprachnamen bleiben immer gleich
}


def texte_aus_szenen():
    gefunden = {}
    for datei in glob.glob("*.tscn"):
        inhalt = open(datei, encoding="utf-8").read()
        for zeile in re.findall(r"^(?:seiten|danach|NPC_Name|text) = (.*)$", inhalt, re.M):
            # Array[String](["a", "b"]) oder einfach "a": alle Texte in Anführungszeichen
            for text in re.findall(r'"((?:[^"\\]|\\.)*)"', zeile):
                gefunden.setdefault(text.replace('\\"', '"'), datei)
    return gefunden


def texte_aus_skripten():
    gefunden = {}
    for datei in glob.glob("*.gd"):
        for nummer, zeile in enumerate(open(datei, encoding="utf-8"), 1):
            if zeile.strip().startswith("#"):
                continue
            for text in re.findall(r'"((?:[^"\\]|\\.)*)"', zeile):
                text = text.replace('\\"', '"')
                if text.startswith(("res://", "user://", "[")):
                    continue
                if not re.search(r"[A-Za-zÄÖÜäöüß]{2}", text):
                    continue   # kein einziges Wort, nur Zeichen wie "> %s"
                if " " in text or re.match(r"[A-ZÄÖÜ][a-zäöüß]", text):
                    gefunden.setdefault(text, f"{datei}:{nummer}")
            # Was in tr() steht, ist auf jeden Fall ein Text für den Spieler, auch ein kleines "an"
            for text in re.findall(r'tr\("((?:[^"\\]|\\.)*)"\)', zeile):
                gefunden.setdefault(text.replace('\\"', '"'), f"{datei}:{nummer}")
    return gefunden


def csv_laden():
    with open(CSV, encoding="utf-8", newline="") as f:
        return [z for z in csv.reader(f) if z]


def csv_speichern(zeilen):
    # So, wie Godot die Datei selbst schreiben würde: \n am Zeilenende, Anführungszeichen nur wo nötig
    with open(CSV, "w", encoding="utf-8", newline="") as f:
        csv.writer(f, lineterminator="\n").writerows(zeilen)


def spalte(kopf, sprache):
    if sprache not in kopf[1:]:
        sys.exit(f"Sprache „{sprache}“ gibt es in {CSV} nicht. Da sind: {', '.join(kopf[1:])}")
    return kopf.index(sprache)


def platzhalter(text):
    # %s, %d, %5.1f, %% ... müssen in der Übersetzung genauso vorkommen, sonst stürzt tr() % ... ab
    return sorted(re.findall(r"%[-+0-9.]*[sdifxXc%]", text))


def exportieren(quelle, ziel=None):
    zeilen = csv_laden()
    kopf = zeilen[0]
    q = spalte(kopf, quelle)
    texte = zeilen[1:]
    datei = f"texte_{quelle}.txt"
    if ziel:
        datei = f"texte_{quelle}_fuer_{ziel}.txt"
        if ziel in kopf:
            z = kopf.index(ziel)
            texte = [t for t in texte if len(t) <= z or not t[z].strip()]
    if not texte:
        print(f"Auf „{ziel}“ ist schon alles übersetzt.")
        return
    with open(datei, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(t[q] for t in texte) + "\n")
    print(f"{len(texte)} Texte nach {datei} geschrieben.")


def importieren(ziel, datei):
    zeilen = csv_laden()
    kopf = zeilen[0]
    # utf-8-sig: falls ein Programm ein unsichtbares BOM an den Anfang setzt
    with open(datei, encoding="utf-8-sig") as f:
        neu = f.read().rstrip("\n").split("\n")
    neu = [t.strip() for t in neu]

    if ziel not in kopf:
        kopf.append(ziel)
    z = kopf.index(ziel)
    for t in zeilen[1:]:
        t.extend([""] * (len(kopf) - len(t)))   # neue Spalte: überall erst mal leer

    alle = zeilen[1:]
    luecken = [t for t in alle if not t[z].strip()]
    if len(neu) == len(luecken):
        betroffen = luecken
    elif len(neu) == len(alle):
        betroffen = alle
    else:
        sys.exit(f"{datei} hat {len(neu)} Zeilen. Erwartet: {len(luecken)} (die Lücken in „{ziel}“) "
                 f"oder {len(alle)} (alle Texte). Nichts geändert.")

    probleme = 0
    for t, uebersetzung in zip(betroffen, neu):
        if platzhalter(t[0]) != platzhalter(uebersetzung):
            print(f"  Platzhalter passen nicht:\n    {t[0]}\n    {uebersetzung}")
            probleme += 1
        t[z] = uebersetzung
    csv_speichern(zeilen)
    print(f"{len(betroffen)} Texte in Spalte „{ziel}“ geschrieben.")
    if probleme:
        print(f"{probleme} davon bitte in {CSV} von Hand korrigieren.")


def main():
    sys.stdout.reconfigure(encoding="utf-8")   # Umlaute auch in der Git-Bash
    sys.stderr.reconfigure(encoding="utf-8")
    befehl = sys.argv[1:]
    if befehl[:1] == ["export"] and len(befehl) in (2, 3):
        return exportieren(*befehl[1:])
    if befehl[:1] == ["import"] and len(befehl) == 3:
        return importieren(*befehl[1:])
    if befehl:
        sys.exit(__doc__)

    zeilen = csv_laden()
    sprachen = zeilen[0][1:]
    schluessel = {z[0]: z for z in zeilen[1:] if z}

    im_spiel = texte_aus_szenen() | texte_aus_skripten()
    fehlt = {t: wo for t, wo in im_spiel.items() if t not in schluessel and t not in NICHT_UEBERSETZEN}
    unbenutzt = [k for k in schluessel if k not in im_spiel]
    leer = [k for k, z in schluessel.items() if any(not z[i + 1].strip() for i in range(len(sprachen)))]

    print(f"{len(schluessel)} Texte in {CSV}, Sprachen: {', '.join(sprachen)}")
    if fehlt:
        print(f"\nFehlt in {CSV} ({len(fehlt)}):")
        for text, wo in sorted(fehlt.items(), key=lambda e: e[1]):
            print(f"  {wo}: {text}")
    if unbenutzt:
        print(f"\nSteht in {CSV}, kommt aber im Spiel nicht vor ({len(unbenutzt)}):")
        for text in unbenutzt:
            print(f"  {text}")
    if leer:
        print(f"\nNoch nicht in jede Sprache übersetzt ({len(leer)}):")
        for text in leer:
            print(f"  {text}")
    if not (fehlt or unbenutzt or leer):
        print("Alles übersetzt. 🎉")


if __name__ == "__main__":
    main()
