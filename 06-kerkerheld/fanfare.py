"""Kurze Fanfare (etwa 1,5 s) als WAV schreiben. Nur die Standardbibliothek."""

import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44100
DAUER = 1.55
AUSGABE = Path(__file__).with_name("fanfare.wav")

# frequenz Hz, start s, dauer s, lautstärke
# Aufsteigender Dreiklang, letzter Ton als kleiner Akkord gehalten.
NOTEN = [
    (523.25, 0.00, 0.16, 0.70),  # C5
    (659.25, 0.14, 0.16, 0.72),  # E5
    (783.99, 0.28, 0.20, 0.76),  # G5
    (1046.50, 0.46, 1.00, 0.80),  # C6
    (783.99, 0.46, 1.00, 0.34),  # G5
    (659.25, 0.46, 1.00, 0.22),  # E5
    (523.25, 0.46, 1.00, 0.16),  # C5
]

HARMONISCHE = (1.0, 0.55, 0.34, 0.18, 0.10, 0.05, 0.03)


def huellkurve(t: float, dauer: float) -> float:
    anschlag = 0.018
    ausklang = min(0.14, dauer * 0.28)
    if t < 0.0 or t > dauer:
        return 0.0
    if t < anschlag:
        return t / anschlag
    if t > dauer - ausklang:
        return max(0.0, (dauer - t) / ausklang)
    gehalten = (t - anschlag) / max(dauer - anschlag - ausklang, 1e-6)
    return 1.0 - 0.30 * min(gehalten, 1.0)


def ton(freq: float, t: float, dauer: float, staerke: float, index: int) -> float:
    env = huellkurve(t, dauer)
    if env <= 0.0:
        return 0.0

    # Tonhöhe steigt kurz an, dadurch klingt es eher nach Blech als nach Orgel.
    gleitung = min(t / 0.045, 1.0)
    f = freq * (0.965 + 0.035 * gleitung)
    vibrato = min(max(t - 0.06, 0.0) / 0.12, 1.0) * 0.006 * math.sin(2 * math.pi * 5.4 * t)

    wert = 0.0
    for k, amplitude in enumerate(HARMONISCHE, start=1):
        wert += amplitude * math.sin(2 * math.pi * f * k * t * (1.0 + vibrato))

    if t < 0.025:
        rauschen = ((index * 1103515245 + 12345) & 0x7FFFFFFF) / 0x7FFFFFFF * 2.0 - 1.0
        wert += rauschen * (1.0 - t / 0.025) * 0.12

    return wert * env * staerke


def erzeugen() -> None:
    anzahl = int(SAMPLE_RATE * DAUER)
    puffer = [0.0] * anzahl

    for freq, start, dauer, staerke in NOTEN:
        anfang = int(start * SAMPLE_RATE)
        ende = min(anzahl, int((start + dauer) * SAMPLE_RATE))
        for i in range(anfang, ende):
            puffer[i] += ton(freq, (i - anfang) / SAMPLE_RATE, dauer, staerke, i)

    spitze = max(abs(wert) for wert in puffer) or 1.0
    skala = 0.9 / spitze
    rahmen = bytearray()
    for wert in puffer:
        sample = int(wert * skala * 32767)
        sample = max(-32767, min(32767, sample))
        rahmen += struct.pack("<h", sample)

    with wave.open(str(AUSGABE), "w") as datei:
        datei.setnchannels(1)
        datei.setsampwidth(2)
        datei.setframerate(SAMPLE_RATE)
        datei.writeframes(rahmen)

    print(f"{AUSGABE.name}: {DAUER:.2f} s, {SAMPLE_RATE} Hz, mono")


if __name__ == "__main__":
    erzeugen()
