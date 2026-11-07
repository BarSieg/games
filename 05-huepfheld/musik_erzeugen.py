"""Erzeugt zwei originale Chiptune-Loops als WAV (ohne Fremdmelodien)."""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

SR = 44100
AUSGABE = Path(__file__).resolve().parent


def midi_hz(midi: int | None) -> float:
    if midi is None:
        return 0.0
    return 440.0 * (2.0 ** ((midi - 69) / 12.0))


def huelle(t: float, dauer: int, attack=0.012, decay=0.06, sustain=0.55, release=0.07) -> float:
    if dauer <= 0:
        return 0.0
    a = max(1, int(attack * SR))
    d = max(1, int(decay * SR))
    r = max(1, int(release * SR))
    if t < a:
        return t / a
    if t < a + d:
        return 1.0 - (1.0 - sustain) * ((t - a) / d)
    if t > dauer - r:
        rest = max(0.0, (dauer - t) / r)
        return sustain * rest
    return sustain


def rechteck(phase: float, duty: float) -> float:
    return 1.0 if (phase % 1.0) < duty else -1.0


def dreieck(phase: float) -> float:
    p = phase % 1.0
    return 4.0 * p - 1.0 if p < 0.5 else 3.0 - 4.0 * p


def rauschen(t: int) -> float:
    # Deterministisches, hartes 8-Bit-Rauschen
    x = (t * 1103515245 + 12345) & 0x7FFFFFFF
    return ((x >> 16) & 0xFF) / 127.5 - 1.0


def spur_legen(
    samples: list[float],
    bpm: float,
    noten: list[tuple[int | None, float]],
    *,
    wellen: str,
    laut: float,
    duty: float = 0.5,
    schlag: float = 1.0,
) -> None:
    """noten: (midi oder None, dauer in Schlägen). schlag=1 ist eine Viertel."""
    beat = 60.0 / bpm
    pos = 0
    phase = 0.0
    for midi, schlaege in noten:
        dauer = int(beat * schlaege * schlag * SR)
        freq = midi_hz(midi)
        for i in range(dauer):
            if pos + i >= len(samples):
                return
            if freq <= 0:
                continue
            dt = freq / SR
            phase += dt
            if wellen == "quad":
                w = rechteck(phase, duty)
            elif wellen == "tri":
                w = dreieck(phase)
            else:
                w = rauschen(pos + i)
            samples[pos + i] += w * laut * huelle(i, dauer)
        if midi is None:
            phase = 0.0
        pos += dauer


def mischen_und_schreiben(pfad: Path, spuren: list[list[float]], echo: float = 0.0) -> None:
    n = len(spuren[0])
    mix = [0.0] * n
    for spur in spuren:
        for i, v in enumerate(spur):
            mix[i] += v
    if echo > 0:
        delay = int(0.18 * SR)
        for i in range(delay, n):
            mix[i] += mix[i - delay] * echo
    spitze = max(1e-9, max(abs(v) for v in mix))
    skala = 0.86 / spitze
    with wave.open(str(pfad), "w") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SR)
        roh = bytearray()
        for v in mix:
            s = max(-1.0, min(1.0, v * skala))
            roh += struct.pack("<h", int(s * 32767))
        wav.writeframes(roh)


def level_musik() -> None:
    """F-Lydisch, 132 BPM: hell, hüpfend, andere Intervalle als typische Fanfaren."""
    bpm = 132.0
    takte = 8
    n = int((takte * 4) * (60.0 / bpm) * SR)
    lead = [0.0] * n
    bass = [0.0] * n
    arp = [0.0] * n

    # Achtel. F-Lydisch: F G A B C D E
    F3, G3, A3, B3, C4, D4, E4, F4 = 53, 55, 57, 59, 60, 62, 64, 65
    G4, A4, B4, C5, D5, E5 = 67, 69, 71, 72, 74, 76

    lead_noten = [
        (A4, 1), (C5, 1), (D5, 1), (C5, 1), (A4, 1), (F4, 1), (G4, 1), (A4, 1),
        (B4, 1), (C5, 1), (D5, 1), (E5, 1), (C5, 1), (A4, 1), (None, 1), (B4, 1),
        (C5, 2), (E5, 1), (D5, 1), (C5, 1), (A4, 1), (G4, 1), (F4, 1),
        (G4, 1), (A4, 1), (B4, 1), (G4, 1), (A4, 2), (None, 1), (C4, 1),
        (D5, 1), (C5, 1), (A4, 1), (C5, 1), (B4, 1), (G4, 1), (A4, 1), (F4, 1),
        (E5, 1), (D5, 1), (C5, 1), (A4, 1), (G4, 1), (B4, 1), (C5, 1), (D5, 1),
        (A4, 2), (C5, 1), (A4, 1), (F4, 1), (G4, 1), (A4, 1), (C5, 1),
        (B4, 1), (A4, 1), (G4, 1), (F4, 1), (G4, 2), (F4, 1), (None, 1),
    ]
    bass_noten = [
        (F3, 2), (C4, 2), (G3, 2), (D4, 2), (A3, 2), (E4, 2), (F3, 2), (C4, 2),
        (D4, 2), (A3, 2), (G3, 2), (D4, 2), (C4, 2), (G3, 2), (F3, 2), (C4, 2),
    ]
    arp_noten = [
        (C5, 1), (F4, 1), (C5, 1), (F4, 1), (D5, 1), (G4, 1), (D5, 1), (G4, 1),
        (E5, 1), (A4, 1), (E5, 1), (A4, 1), (C5, 1), (F4, 1), (C5, 1), (F4, 1),
        (A4, 1), (D4, 1), (A4, 1), (D4, 1), (B4, 1), (G4, 1), (B4, 1), (G4, 1),
        (G4, 1), (C4, 1), (G4, 1), (C4, 1), (A4, 1), (F4, 1), (A4, 1), (F4, 1),
        (C5, 1), (F4, 1), (C5, 1), (F4, 1), (D5, 1), (G4, 1), (D5, 1), (G4, 1),
        (E5, 1), (A4, 1), (E5, 1), (A4, 1), (C5, 1), (F4, 1), (C5, 1), (F4, 1),
        (A4, 1), (D4, 1), (A4, 1), (D4, 1), (B4, 1), (G4, 1), (B4, 1), (G4, 1),
        (G4, 1), (C4, 1), (G4, 1), (C4, 1), (A4, 1), (F4, 1), (None, 1), (F4, 1),
    ]

    spur_legen(lead, bpm, lead_noten, wellen="quad", laut=0.22, duty=0.18, schlag=0.5)
    spur_legen(bass, bpm, bass_noten, wellen="tri", laut=0.28, schlag=1.0)
    spur_legen(arp, bpm, arp_noten, wellen="quad", laut=0.08, duty=0.5, schlag=0.5)
    mischen_und_schreiben(AUSGABE / "musik_level.wav", [lead, bass, arp])


def bonus_musik() -> None:
    """D-Moll / dorisch, 88 BPM: dunkel, weit, ohne chromatische Keller-Arpeggios."""
    bpm = 88.0
    takte = 8
    n = int((takte * 4) * (60.0 / bpm) * SR)
    lead = [0.0] * n
    bass = [0.0] * n
    pad = [0.0] * n
    hats = [0.0] * n

    D2, E2, F2, G2, A2, Bb2, C3, D3 = 38, 40, 41, 43, 45, 46, 48, 50
    F3, G3, A3, Bb3, C4, D4, E4, F4, G4, A4 = 53, 55, 57, 58, 60, 62, 64, 65, 67, 69

    lead_noten = [
        (D4, 2), (None, 1), (F4, 1), (A4, 2), (G4, 2),
        (F4, 2), (E4, 2), (D4, 3), (None, 1),
        (F4, 2), (None, 1), (D4, 1), (C4, 2), (A3, 2),
        (D4, 4), (None, 4),
        (A3, 2), (None, 1), (D4, 1), (F4, 2), (E4, 2),
        (D4, 2), (C4, 2), (A3, 3), (None, 1),
        (Bb3, 2), (A3, 2), (F3, 2), (G3, 2),
        (A3, 3), (None, 1), (D4, 3), (None, 1),
    ]
    bass_noten = [
        (D2, 2), (A2, 2), (D3, 2), (A2, 2),
        (C3, 2), (G2, 2), (C3, 2), (G2, 2),
        (Bb2, 2), (F2, 2), (Bb2, 2), (F2, 2),
        (A2, 2), (E2, 2), (A2, 2), (D2, 2),
        (D2, 2), (A2, 2), (D3, 2), (A2, 2),
        (C3, 2), (G2, 2), (C3, 2), (G2, 2),
        (Bb2, 2), (F2, 2), (A2, 2), (E2, 2),
        (D2, 4), (A2, 4),
    ]
    pad_noten = [
        (D3, 8), (C3, 8), (Bb2, 8), (A2, 8),
        (D3, 8), (C3, 8), (Bb2, 4), (A2, 4), (D3, 8),
    ]
    hat_noten = []
    for _takt in range(8):
        hat_noten.extend([(None, 1), (1, 0.15), (None, 0.85), (None, 1), (1, 0.12), (None, 0.88)])

    spur_legen(lead, bpm, lead_noten, wellen="tri", laut=0.20, schlag=1.0)
    spur_legen(bass, bpm, bass_noten, wellen="quad", laut=0.16, duty=0.28, schlag=1.0)
    spur_legen(pad, bpm, pad_noten, wellen="tri", laut=0.10, schlag=1.0)
    spur_legen(hats, bpm, hat_noten, wellen="noise", laut=0.045, schlag=1.0)
    mischen_und_schreiben(AUSGABE / "musik_bonus.wav", [lead, bass, pad, hats], echo=0.28)


if __name__ == "__main__":
    level_musik()
    bonus_musik()
    print("geschrieben:", AUSGABE / "musik_level.wav")
    print("geschrieben:", AUSGABE / "musik_bonus.wav")
