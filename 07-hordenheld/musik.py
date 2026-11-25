"""Drei Musikstücke im Stil alter Spielkonsolen als WAV schreiben. Nur die Standardbibliothek.

    python musik.py

erzeugt musik_titel.wav, musik_kampf.wav und musik_endspurt.wav. Jedes Stück ist eine Schleife:
Das Ende passt genau an den Anfang. Die Schleife steht in der Datei selbst (im "smpl"-Abschnitt),
Godot liest sie beim Import und spielt das Stück dann endlos.

Die Stimmen klingen wie bei einer alten Konsole:
- melodie: Rechteckwelle, die Hauptstimme
- begleitung: dünnere Rechteckwelle, leise
- bass: Dreieckwelle, weich und tief
- trommel: Rauschen. k = Kick (tief), s = Snare, h = Hi-Hat, . = nichts

Noten schreibt man als "Name+Oktave:Länge", zum Beispiel "A4:2". Die Länge zählt in Achteln,
ein Takt hat 8 Achtel. "_:2" ist eine Pause. Kreuz: "C#5", B statt H: "Bb4".
Jede Stimme muss genau so lang sein wie das ganze Stück, sonst bricht das Skript ab und sagt,
welcher Takt nicht stimmt. "|" trennt die Takte und wird sonst ignoriert.
"""

import math
import random
import struct
from pathlib import Path

RATE = 22050          # Abtastrate. Für Konsolenklang reicht die Hälfte von CD-Qualität, und die Dateien sind kleiner.
ORDNER = Path(__file__).parent


def acht(*akkorde: str) -> str:
    """Ein Takt Bass in Achteln: tief, hoch, tief, hoch ... "E2" -> "E2:1 E3:1 E2:1 E3:1 ..." """
    takte = []
    for akkord in akkorde:
        ton, oktave = akkord[:-1], int(akkord[-1])
        takte.append(" ".join(f"{ton}{oktave}:1 {ton}{oktave + 1}:1" for _ in range(4)))
    return " | ".join(takte)


STUECKE = {
    # Mutig, aber noch ruhig: das Titelbild
    "musik_titel.wav": {
        "tempo": 100,   # Viertel pro Minute
        "melodie": "A4:2 C5:2 E5:3 D5:1 | C5:2 B4:2 A4:4 | F4:2 A4:2 C5:3 B4:1 | A4:2 G4:2 E4:4 |"
                   "A4:2 C5:2 E5:3 G5:1 | F5:2 E5:2 D5:4 | C5:2 D5:2 E5:2 B4:2 | A4:6 _:2",
        "begleitung": "A3:1 C4:1 E4:1 C4:1 A3:1 C4:1 E4:1 C4:1 | A3:1 C4:1 E4:1 C4:1 A3:1 C4:1 E4:1 C4:1 |"
                      "F3:1 A3:1 C4:1 A3:1 F3:1 A3:1 C4:1 A3:1 | C4:1 E4:1 G4:1 E4:1 C4:1 E4:1 G4:1 E4:1 |"
                      "A3:1 C4:1 E4:1 C4:1 A3:1 C4:1 E4:1 C4:1 | D4:1 F4:1 A4:1 F4:1 D4:1 F4:1 A4:1 F4:1 |"
                      "C4:1 E4:1 G4:1 E4:1 E4:1 G#4:1 B4:1 G#4:1 | A3:1 C4:1 E4:1 C4:1 A3:1 C4:1 E4:1 C4:1",
        "bass": "A2:4 E3:4 | A2:4 E3:4 | F2:4 C3:4 | C2:4 G2:4 | A2:4 E3:4 | D2:4 A2:4 | C2:4 E2:4 | A2:4 E3:4",
        "trommel": "k...h... " * 8,
    },
    # Treibend: die ersten vier Minuten
    "musik_kampf.wav": {
        "tempo": 132,
        "melodie": "E5:2 _:1 E5:1 G5:2 E5:2 | D5:2 B4:2 G4:2 A4:2 | B4:2 _:1 B4:1 D5:2 B4:2 | A4:2 G4:2 F#4:4 |"
                   "E5:2 _:1 E5:1 G5:2 B5:2 | A5:2 G5:2 F#5:2 D5:2 | E5:2 D5:2 B4:2 D5:2 | E5:6 _:2",
        "begleitung": "",
        "bass": acht("E2", "G2", "B1", "D2", "E2", "D2", "C2", "E2"),
        "trommel": "k.h.s.hk " * 7 + "k.s.s.ss",
    },
    # Schneller und lauter: die letzte Minute
    "musik_endspurt.wav": {
        "tempo": 160,
        "melodie": "A5:1 A5:1 _:1 A5:1 G5:2 E5:2 | F5:2 E5:2 D5:2 E5:2 | C5:1 C5:1 _:1 C5:1 D5:2 E5:2 | B4:4 E5:4 |"
                   "A5:1 A5:1 _:1 A5:1 B5:2 C6:2 | B5:2 A5:2 G5:2 E5:2 | F5:2 E5:2 D5:2 B4:2 | A4:4 E5:2 A5:2",
        "begleitung": "",
        "bass": acht("A1", "D2", "A1", "E2", "A1", "E2", "D2", "A1"),
        "trommel": "khshkhsh " * 7 + "khshksss",
    },
}

LAUTSTAERKE = {"melodie": 0.22, "begleitung": 0.08, "bass": 0.32}
WELLE = {"melodie": "puls50", "begleitung": "puls25", "bass": "dreieck"}

HALBTOENE = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2, "H": 2}


def frequenz(name: str) -> float:
    """'A4' -> 440 Hz, 'C#5' -> 554 Hz, 'Bb1' -> 58 Hz"""
    ton, oktave = name[:-1], int(name[-1])
    schritte = HALBTOENE[ton[0].upper()] + (oktave - 4) * 12
    if ton[1:] == "#":
        schritte += 1
    elif ton[1:] == "b":
        schritte -= 1
    return 440.0 * 2 ** (schritte / 12)


def noten_lesen(text: str, takte: int, stimme: str, datei: str) -> list[tuple[str, int]]:
    noten = []
    for nummer, takt in enumerate(text.split("|"), 1):
        laenge = 0
        for wort in takt.split():
            name, achtel = wort.split(":")
            noten.append((name, int(achtel)))
            laenge += int(achtel)
        if laenge != 8:
            raise SystemExit(f"{datei}, {stimme}, Takt {nummer}: {laenge} Achtel statt 8")
    if len(text.split("|")) != takte:
        raise SystemExit(f"{datei}, {stimme}: {len(text.split('|'))} Takte statt {takte}")
    return noten


def welle(art: str, phase: float) -> float:
    p = phase % 1.0
    if art == "puls50":
        return 1.0 if p < 0.5 else -1.0
    if art == "puls25":
        return 1.0 if p < 0.25 else -1.0
    # Dreieck mit 16 Stufen, wie bei den alten Konsolen
    return round((4 * abs(p - 0.5) - 1) * 8) / 8


def huellkurve(t: float, dauer: float) -> float:
    """Kurz anschlagen, etwas abfallen, am Ende sauber ausklingen (sonst knackt es)"""
    if t < 0.005:
        return t / 0.005
    wert = 1.0 - 0.35 * min((t - 0.005) / 0.12, 1.0)
    rest = dauer - t
    if rest < 0.02:
        wert *= max(rest, 0.0) / 0.02
    return wert


def mischen(puffer: list[float], anfang: int, werte: list[float]) -> None:
    # Was über das Ende hinausragt, kommt vorne wieder dazu: So passt die Schleife ohne Knacks
    n = len(puffer)
    for i, w in enumerate(werte):
        puffer[(anfang + i) % n] += w


def stimme_spielen(puffer, noten, art, staerke, achtel_sek):
    zeit = 0.0
    for name, achtel in noten:
        dauer = achtel * achtel_sek
        if name != "_":
            f = frequenz(name)
            klingt = dauer * 0.9   # kleine Lücke, damit gleiche Töne hintereinander getrennt klingen
            werte = [welle(art, f * i / RATE) * huellkurve(i / RATE, klingt) * staerke
                     for i in range(int(klingt * RATE))]
            mischen(puffer, int(zeit * RATE), werte)
        zeit += dauer


def trommel_spielen(puffer, muster, achtel_sek):
    zufall = random.Random(7)   # immer dasselbe Rauschen, damit die Datei bei jedem Lauf gleich ist
    for nummer, schlag in enumerate(muster.replace(" ", "")):
        start = int(nummer * achtel_sek * RATE)
        if schlag == "k":   # Kick: ein Sinus, der schnell tiefer wird
            werte, phase = [], 0.0
            for i in range(int(0.12 * RATE)):
                t = i / RATE
                phase += (40 + 110 * math.exp(-t * 30)) / RATE
                werte.append(math.sin(2 * math.pi * phase) * math.exp(-t * 18) * 0.45)
        elif schlag == "s":
            werte = [(zufall.random() * 2 - 1) * math.exp(-i / RATE * 25) * 0.22 for i in range(int(0.15 * RATE))]
        elif schlag == "h":
            werte = [(zufall.random() * 2 - 1) * math.exp(-i / RATE * 90) * 0.10 for i in range(int(0.04 * RATE))]
        else:
            continue
        mischen(puffer, start, werte)


def wav_schreiben(datei: Path, puffer: list[float]) -> None:
    daten = b"".join(struct.pack("<h", max(-32767, min(32767, int(w * 32767)))) for w in puffer)
    fmt = struct.pack("<HHIIHH", 1, 1, RATE, RATE * 2, 2, 16)   # PCM, mono, 16 Bit
    # smpl: eine Schleife vom ersten bis zum letzten Sample. Godot liest das beim Import.
    smpl = struct.pack("<9I", 0, 0, 1_000_000_000 // RATE, 60, 0, 0, 0, 1, 0)
    smpl += struct.pack("<6I", 0, 0, 0, len(puffer) - 1, 0, 0)
    abschnitte = b"".join(name + struct.pack("<I", len(inhalt)) + inhalt
                          for name, inhalt in [(b"fmt ", fmt), (b"smpl", smpl), (b"data", daten)])
    datei.write_bytes(b"RIFF" + struct.pack("<I", 4 + len(abschnitte)) + b"WAVE" + abschnitte)


def erzeugen(datei: str, stueck: dict) -> None:
    takte = len(stueck["melodie"].split("|"))
    achtel_sek = 60 / stueck["tempo"] / 2
    puffer = [0.0] * int(round(takte * 8 * achtel_sek * RATE))
    for stimme in ("melodie", "begleitung", "bass"):
        if stueck[stimme]:
            noten = noten_lesen(stueck[stimme], takte, stimme, datei)
            stimme_spielen(puffer, noten, WELLE[stimme], LAUTSTAERKE[stimme], achtel_sek)
    if stueck["trommel"]:
        muster = stueck["trommel"].replace(" ", "")
        if len(muster) != takte * 8:
            raise SystemExit(f"{datei}, trommel: {len(muster)} Schläge statt {takte * 8}")
        trommel_spielen(puffer, muster, achtel_sek)
    spitze = max(abs(w) for w in puffer)
    if spitze > 0.95:
        puffer = [w * 0.95 / spitze for w in puffer]   # nicht übersteuern
    wav_schreiben(ORDNER / datei, puffer)
    print(f"{datei}: {takte} Takte, {len(puffer) / RATE:.1f} s, {(ORDNER / datei).stat().st_size // 1024} KB")


if __name__ == "__main__":
    for datei, stueck in STUECKE.items():
        erzeugen(datei, stueck)
