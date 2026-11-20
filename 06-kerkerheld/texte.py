"""Prüft, ob jeder Text im Spiel in texte.csv steht.

Gesucht wird:
- in allen .tscn: Schildtexte (seiten, danach), Namen (NPC_Name) und Label-Texte (text)
- in allen .gd: Texte, die wie ein Satz oder ein Wort für den Spieler aussehen
  (mit Leerzeichen oder großem Anfangsbuchstaben)

Ausgegeben wird, was in texte.csv fehlt, und was in texte.csv steht, aber nirgends mehr vorkommt.
Bei einem Tippfehler im Spiel taucht beides auf: der falsche Text als „fehlt“, der richtige als „unbenutzt“.

Aufruf im Ordner 06-kerkerheld:
    python texte.py
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
    "Deutsch", "English",                            # Sprachnamen bleiben immer gleich
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


def main():
    sys.stdout.reconfigure(encoding="utf-8")   # Umlaute auch in der Git-Bash
    with open(CSV, encoding="utf-8", newline="") as f:
        zeilen = list(csv.reader(f))
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
