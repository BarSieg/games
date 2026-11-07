"""Erzeugt die Bilder für die Touch-Knöpfe (Handy) in touch/: Steuerkreuz und A/B."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

GROESSE = 32
AUSGABE = Path(__file__).resolve().parent / "touch"

# Halbdurchsichtiges Weiß, gedrückt etwas heller
FARBEN = {
    "": ((255, 255, 255, 50), (255, 255, 255, 140), (255, 255, 255, 170)),
    "_gedrueckt": ((255, 255, 255, 120), (255, 255, 255, 220), (255, 255, 255, 255)),
}

# Pfeilspitzen als Dreiecke, Platz zum Rand gelassen
PFEILE = {
    "hoch": [(16, 9), (24, 21), (8, 21)],
    "runter": [(16, 23), (24, 11), (8, 11)],
    "links": [(9, 16), (21, 8), (21, 24)],
    "rechts": [(23, 16), (11, 8), (11, 24)],
}


def leeres_bild() -> tuple[Image.Image, ImageDraw.ImageDraw]:
    bild = Image.new("RGBA", (GROESSE, GROESSE), (0, 0, 0, 0))
    return bild, ImageDraw.Draw(bild)


def main() -> None:
    AUSGABE.mkdir(exist_ok=True)
    schrift = ImageFont.load_default(size=16)
    for endung, (fuellung, rand, zeichen) in FARBEN.items():
        for name, dreieck in PFEILE.items():
            bild, malen = leeres_bild()
            malen.rounded_rectangle((1, 1, GROESSE - 2, GROESSE - 2), radius=5, fill=fuellung, outline=rand, width=2)
            malen.polygon(dreieck, fill=zeichen)
            bild.save(AUSGABE / f"pfeil_{name}{endung}.png")
        for buchstabe in ("a", "b"):
            bild, malen = leeres_bild()
            malen.ellipse((1, 1, GROESSE - 2, GROESSE - 2), fill=fuellung, outline=rand, width=2)
            malen.text((GROESSE / 2, GROESSE / 2), buchstabe.upper(), font=schrift, fill=zeichen, anchor="mm")
            bild.save(AUSGABE / f"knopf_{buchstabe}{endung}.png")


if __name__ == "__main__":
    main()
