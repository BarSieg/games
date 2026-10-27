# Roadmap: Von Ballwechsel zum DOOM-(2016)-Abklatsch

**Ziel:** Spieleentwicklung Schritt für Schritt lernen, mit den Werkzeugen, die echte Spieleentwickler benutzen.
**Endgegner:** ein spielbarer erster Level im Stil von DOOM (2016).

**Prinzip:** Jedes Projekt ist klein (oft nur Level 1). Es bringt **2–4 neue Konzepte** und **höchstens 1–2 neue Tools** mit. Was du in einem Projekt lernst, brauchst du im nächsten wieder.

Legende: 🆓 kostenlos · 💰 kostenpflichtig (Hinweis, wo es sich lohnen würde) · ⭐ Industriestandard

---

## 1. Die wichtigste Entscheidung: die Engine

| Engine | Kosten | Stärken | Schwächen |
|---|---|---|---|
| **Godot 4** 🆓 | Komplett kostenlos, Open Source (MIT), keine Umsatzbeteiligung | Klein (~100 MB), startet in Sekunden, GDScript ist leicht zu lernen (ähnlich wie Python), sehr gut für 2D und gut für 3D | 3D-Grafik nicht auf AAA-Niveau, kleinerer Asset-Store |
| Unity 6 | Personal-Version kostenlos bis 200.000 $ Umsatz/Jahr, darüber 💰 | Riesige Community, viele Tutorials, Mobile | Proprietär, hat 2023 mit Lizenzänderungen Vertrauen verspielt |
| Unreal Engine 5 ⭐ | Kostenlos, 5 % Umsatzbeteiligung erst ab 1 Mio. $ Umsatz pro Spiel | AAA-Grafik, hat ein fertiges Template für Ego-Shooter, Blueprints (visuelles Programmieren) | Schwer zu lernen, braucht einen starken PC (≥ 32 GB RAM empfohlen), C++ |
| Browser (JavaScript) 🆓 | Kostenlos | Keine Installation, man versteht jedes Detail selbst | Kein Editor, alles von Hand |

**Empfehlung:** Erst **Browser/JavaScript** (wie bei Ballwechsel), damit du die Grundlagen verstehst, ohne dass eine Engine sie versteckt. Danach **Godot 4** für alles Weitere, inklusive Finale.

> 💰-Hinweis: Wer später einen DOOM-Klon mit echter AAA-Optik will, ist mit **Unreal Engine 5** besser bedient. Sie ist zwar kostenlos, verlangt aber einen kräftigen PC und viel Einarbeitung. Deshalb ist sie als optionales **Bonus-Kapitel** am Ende eingeplant: dasselbe Finale noch einmal in Unreal, um den Industriestandard kennenzulernen.

---

## 2. Die Reise im Überblick

```
Phase 0  ✅ Ballwechsel                Game Loop, Input, Kollision, Spielzustände
   │
Phase 1  Grundlagen im Browser (JS)
   ├─ 01  Ziegelbrecher                Level-Daten, viele Objekte, Power-ups
   ├─ 02  Insekteninvasion             Gegner-Formationen, Schüsse, Sprite-Animation
   └─ 03  Weltraumsteine               Vektoren, Rotation, Trägheit  ← Mathe für 3D!
   │
Phase 2  Godot 2D
   ├─ 04  Flappy Bird                  Godot kennenlernen: Szenen, Nodes, Signale
   ├─ 05  Super Mario Bros. – Level 1-1    Plattformer-Physik, Tilemaps, Kamera
   ├─ 06  Zelda – erster Dungeon       State Machines, Inventar, Räume, Speichern
   └─ 07  Vampire Survivors (light)    Hunderte Gegner, Performance, Upgrades
   │
Phase 3  Der Weg in die 3D
   ├─ 08  Wolfenstein 3D (Raycaster, JS)   Wie aus 2D „3D“ wird, Ego-Perspektive
   ├─ 09  3D-Murmelbahn (Godot)        3D-Szenen, Licht, Blender-Import
   ├─ 10  DOOM (1993) – E1M1           FPS-Steuerung, Hitscan-Waffen, Türen, Keycards
   └─ 11  Quake – E1M1                 Echte 3D-Gegner, Animation, KI-Wegfindung
   │
Phase 4  🏁 FINALE: DOOM (2016) – „Vertical Slice“ des ersten Levels
   │
Bonus    Finale-Arena in Unreal Engine 5 nachbauen
```

Die Zeitangaben unten sind grobe Schätzungen für jemanden, der **ein paar Abende pro Woche** daran arbeitet.

---

## 3. Phase 1: Grundlagen im Browser (JavaScript)

Kein Editor, keine Engine. Du siehst jede Zeile, die das Spiel ausmacht. Das ist die beste Schule, um später zu verstehen, was eine Engine dir abnimmt.

### 01 · Ziegelbrecher – nach Breakout / Arkanoid (2–4 Abende)
- **Du lernst:** Level als Daten (ein Array bestimmt, wo die Steine liegen), Kollision mit vielen Objekten, Power-ups, Leben, mehrere Level hintereinander
- **Neue Tools:** 🆓 **VS Code** (Code-Editor), 🆓 **Git + GitHub** (Versionsverwaltung, ab jetzt für jedes Projekt)
- **Umfang:** 3 Level, 2 Power-ups (breiterer Schläger, Multiball)

### 02 · Insekteninvasion – nach Space Invaders (3–5 Abende)
- **Du lernst:** Sprites und Sprite-Animation, Gegner, die sich als Formation bewegen, Schüsse in beide Richtungen, Zerstörbare Deckung, Highscore speichern (localStorage)
- **Neue Tools:** 🆓 **Piskel** oder 🆓 **Pixelorama** (Pixel-Art-Editoren), 🆓 **jsfxr** (Retro-Soundeffekte per Knopfdruck)
- 💰 **Aseprite** (~20 $) ist der ⭐ Standard für Pixel-Art. Lohnt sich, wenn du viel Pixel-Art machst. Der Quellcode ist frei, d. h. wer es selbst kompiliert, bekommt es gratis. Die kostenlose Alternative **LibreSprite** ist ein Ableger einer alten Aseprite-Version.
- **Umfang:** 1 Welle + Kakerlake, Highscore

### 03 · Weltraumsteine – nach Asteroids (3–5 Abende)
- **Du lernst:** **Vektoren** (Position, Geschwindigkeit, Richtung), Rotation mit sin/cos, Trägheit, Bildschirm-Wrap, Objekte zerfallen in kleinere Objekte, Partikeleffekte
- **Warum wichtig:** Das ist genau die Mathematik, die du später für jede 3D-Bewegung und jedes Zielen brauchst.
- **Umfang:** Endlosmodus mit steigender Schwierigkeit

---

## 4. Phase 2: Godot 2D

Jetzt kommt die erste echte Engine. Du wirst merken, wie viel schneller es geht, und du verstehst trotzdem, was im Hintergrund passiert.

### 04 · Flappy Bird (2–3 Abende)
- **Du lernst:** den Godot-Editor, **Szenen & Nodes** (Godots Baukasten-Prinzip), **Signale** (Objekte schicken sich Nachrichten), GDScript, Physik-Körper, Export als Web-Spiel
- **Neue Tools:** 🆓 **Godot 4**
- **Warum Flappy Bird:** Ein Spiel, das so klein ist, dass du dich ganz auf das Lernen der Engine konzentrieren kannst

### 05 · Super Mario Bros. – Level 1-1 (2–3 Wochen)
- **Du lernst:** Plattformer-Physik, die sich *gut anfühlt* („Coyote Time“, „Jump Buffering“, variable Sprunghöhe), **Tilemaps**, Kamera, die dem Spieler folgt, Gegner, Animationen (AnimationPlayer), Blöcke und Items
- **Neue Tools:** Godot-TileMap 🆓, optional 🆓 **LDtk** oder 🆓 **Tiled** (spezialisierte Level-Editoren), 🆓 **Kenney.nl** (riesige Sammlung freier Grafiken, CC0)
- **Umfang:** Nur 1-1, mit eigenen/freien Grafiken

### 06 · Zelda – erster Dungeon (3–4 Wochen)
- **Du lernst:** **State Machines** (Gegner: Patrouille → Verfolgen → Angriff), Top-Down-Steuerung, Inventar, Schlüssel & verschlossene Türen, Dialoge, **Speichern und Laden**, Raumwechsel
- **Neue Tools:** 🆓 **Krita** (zum Malen, z. B. Titelbild), 🆓 **LMMS** oder 🆓 **BeepBox** (Musik machen)
- **Warum wichtig für DOOM:** Gegner-KI als State Machine, Keycards und Türen – das brauchst du 1:1 wieder

### 07 · Vampire Survivors (light) (≈ 2 Wochen)
- **Du lernst:** **Performance** (hunderte Gegner gleichzeitig), **Object Pooling** (Objekte wiederverwenden statt ständig neu erzeugen), den Godot-**Profiler**, Upgrade-Systeme, „Game Feel“ (Screen Shake, Treffer-Blitzen, Zahlen, die aufploppen)
- **Warum wichtig für DOOM:** DOOM 2016 lebt von Arenen voller Gegner und von befriedigendem Treffer-Feedback

---

## 5. Phase 3: Der Weg in die 3D

### 08 · Wolfenstein 3D – Raycaster im Browser (1–2 Wochen)
- **Du lernst:** Wie 1992 aus einer 2D-Karte ein 3D-Bild wurde (**Raycasting**), Ego-Perspektive, Texturen auf Wänden, Gegner als Sprites
- **Neue Tools:** keine, reines JavaScript. Dafür ist die Mathematik spannend.
- **Warum:** Es ist der historische Vorfahr von DOOM und entmystifiziert die 3D-Darstellung

### 09 · 3D-Murmelbahn à la Super Monkey Ball (≈ 1 Woche)
- **Du lernst:** Godot 3D (Kamera, Licht, Materialien, 3D-Physik), **erste eigene 3D-Modelle**, Import aus Blender
- **Neue Tools:** 🆓 ⭐ **Blender** (3D-Modellierung, Animation, Texturen – auch in Profi-Studios im Einsatz), 🆓 **Poly Haven** (freie Texturen, Modelle, HDRIs)
- **Warum so klein:** 3D ist ein großer Sprung. Ein simples Spiel lässt dir Raum, Blender und Godot 3D in Ruhe zu lernen.

### 10 · DOOM (1993) – E1M1 „Hangar“ (4–6 Wochen)
- **Du lernst:** **FPS-Controller** (Maus-Look, Laufen, Strafing), **Hitscan-Waffen** (Raycast-Treffer), Waffenwechsel, Munition, Gegner als Billboard-Sprites (wie im Original), Türen, Aufzüge, Keycards, HUD
- **Neue Tools:** 🆓 **TrenchBroom** (Level-Editor aus der Quake-Welt, perfekt für Shooter-Level) + 🆓 Godot-Plugin **func_godot** (importiert TrenchBroom-Karten), Godot **CSG** für schnelles Level-„Blockout“ (Grobentwurf aus Klötzen)
- **Umfang:** Ein Level, 2–3 Waffen, 2 Gegnertypen

### 11 · Quake – E1M1 (6–8 Wochen)
- **Du lernst:** Echte 3D-Gegner mit **Skelett-Animation** (AnimationTree), **Navigation Mesh** (Gegner finden selbst den Weg), Projektil-Waffen (Raketen, Granaten), Licht & Schatten, Lightmaps
- **Neue Tools:** 🆓 **Mixamo** (Adobe; kostenloses Riggen & fertige Animationen für Figuren), 🆓 **Material Maker** (Texturen prozedural erzeugen, ist selbst in Godot gebaut)
- 💰 Hier wäre ⭐ **Adobe Substance 3D Painter** (Abo) das Profi-Werkzeug zum Bemalen von 3D-Modellen. Gratis-Alternativen: Material Maker, Texture-Painting in Blender, 💰 **ArmorPaint** (günstig, Quellcode frei)

---

## 6. Phase 4: 🏁 FINALE – DOOM (2016) Vertical Slice

Ein **Vertical Slice** ist in der Branche ein kleines Stück Spiel, das in jeder Hinsicht so aussieht und sich so anfühlt wie das fertige Produkt. Unser Ziel: **ein Level im Stil der ersten Mission** (UAC-Marsbasis) mit 2–3 Kampfarenen. Geschätzte Dauer: **3–6 Monate**.

Das Herz von DOOM 2016 ist der **„Push-Forward Combat“**: Statt dich hinter Deckung zu verstecken, wirst du belohnt, wenn du angreifst.

| Meilenstein | Inhalt | Neue Konzepte & Tools |
|---|---|---|
| **M1 · Bewegung** | Schnelles Laufen, Doppelsprung, an Kanten hochziehen | Character Controller, „Game Feel“ |
| **M2 · Waffen** | Schrotflinte, Sturmgewehr, Plasmagewehr, Waffen-Mods (Zweitfunktion) | Waffen als Daten (Resources), Rückstoß, Mündungsfeuer, Treffer-Decals |
| **M3 · Gegner** | Imp (wirft Feuerbälle, klettert), besessener Soldat, Hell Knight (springt dich an) | Behavior Trees (🆓 Plugin **LimboAI** oder **Beehave**), „Token-System“: Nur wenige Gegner greifen gleichzeitig an (echter Trick aus DOOM) |
| **M4 · Kampf-Loop** | **Glory Kills** (angeschlagene Gegner leuchten → Nahkampf-Finisher → Gesundheit), **Kettensäge** → Munition | Synchronisierte Animationen, Ressourcen-Kreislauf, Kamera-Animation |
| **M5 · Arenen** | Türen verriegeln sich, Gegnerwellen spawnen, Arena gilt als „geschafft“ | Encounter-Design, Wave Spawner, Level-Design mit TrenchBroom/Blender |
| **M6 · Look & Sound** | Marsbasis-Optik, Nebel, Leuchtmaterialien, Partikel, Blut, dynamische Musik (ruhig ↔ Kampf) | PBR-Materialien, Volumetric Fog, Post-Processing, Shader, Godot-Audio-Busse, interaktive Musik (AudioStreamInteractive ab Godot 4.3) |
| **M7 · Politur** | Menü, HUD, Einstellungen, Performance, Build für Windows | Profiler, 🆓 **RenderDoc** (GPU-Debugger), LOD, Occlusion Culling, Export |

**💰-Hinweise fürs Finale:**
- **Texturen:** ⭐ Substance 3D Painter/Designer (Abo) wäre hier der Profi-Weg. Gratis: Material Maker + Poly Haven / ambientCG.
- **Sound:** 💰 **Reaper** (~60 $, sehr lange Testphase) ist eine sehr gute, günstige Audio-Software. Gratis: 🆓 Audacity (Bearbeiten), 🆓 LMMS (Musik), 🆓 freesound.org (Geräusche).
- **Audio-Middleware:** ⭐ **FMOD** / **Wwise** sind Standard in großen Studios. Für kleine Indie-Projekte sind beide kostenlos (Budgetgrenzen beachten). Für uns reicht Godots eingebautes Audio.

### Bonus · Dieselbe Arena in Unreal Engine 5
Wenn das Finale in Godot läuft: eine Arena in UE5 nachbauen (First-Person-Template, Blueprints, Nanite/Lumen, kostenlose Assets auf **Fab**). So lernst du den ⭐ AAA-Industriestandard kennen und kannst beide Engines aus eigener Erfahrung vergleichen.

---

## 7. Werkzeugkasten auf einen Blick

| Bereich | 🆓 Kostenlos (nutzen wir) | 💰 / ⭐ Profi-Alternative | Wann sich zahlen lohnt |
|---|---|---|---|
| Engine | Godot 4 | Unreal 5 (gratis bis 1 Mio. $), Unity Pro | Bei AAA-Grafik: Unreal |
| Code-Editor | VS Code, Godot-Editor | JetBrains Rider (für nicht-kommerzielle Nutzung gratis) | Erst bei großen C#-Projekten |
| Versionsverwaltung | Git, GitHub, GitHub Desktop | Perforce (Standard in AAA-Studios) | Bei vielen großen Binärdateien im Team; für uns reicht Git + Git LFS |
| Pixel-Art | Pixelorama, Piskel, LibreSprite | Aseprite (~20 $) | Sobald du regelmäßig Pixel-Art machst – kleinste und beste Investition auf der Liste |
| 2D-Malen / Vektor | Krita, GIMP, Inkscape | Photoshop, Illustrator (Abo) | Für uns gar nicht |
| Level-Editoren | Godot TileMap, LDtk, Tiled, TrenchBroom | – | – |
| 3D-Modellierung | Blender | Maya, 3ds Max (teures Abo) | Nur in großen Studios mit festen Pipelines |
| Texturen | Material Maker, Poly Haven, ambientCG | Substance 3D Painter/Designer (Abo) | Beim Finale, wenn du viele eigene 3D-Modelle bemalst |
| Animation | Blender, Mixamo | Motion-Capture-Pakete | Für uns gar nicht |
| Sound/Musik | Audacity, LMMS, BeepBox, jsfxr, freesound.org | Reaper (~60 $), FMOD/Wwise | Reaper, wenn dich Sounddesign packt |
| Fertige Assets | Kenney.nl, itch.io (Kategorie „free“), OpenGameArt, Fab (freie Assets) | Asset-Stores | Wenn Zeit wichtiger ist als Lernen |
| Planung | GitHub Projects, Trello, HacknPlan | Jira | Für uns gar nicht |
| Veröffentlichen | itch.io | Steam (100 $ Gebühr pro Spiel) | Wenn du ein *eigenes* Spiel verkaufen willst |

---

## 8. Wichtig: Rechtliches bei Nachbauten

Nachbauen **zum Lernen** ist völlig in Ordnung und in der Szene üblich. Aber:
- **Keine Original-Grafiken, -Sounds oder -Musik** verwenden. Nutze eigene oder freie Assets (CC0).
- **Nicht unter dem Originalnamen veröffentlichen.** „DOOM“, „Mario“, „Zelda“ sind Markenzeichen. Öffentlich also z. B. „Mars Inferno“ statt „DOOM“.
- Spielmechaniken (Doppelsprung, Glory Kill …) sind nicht geschützt. Deshalb funktionieren Nachbauten überhaupt.

---

## 9. Kostenlose Lernquellen

- **Godot-Dokumentation**, vor allem die Tutorials „Your first 2D game“ und „Your first 3D game“
- **Game Programming Patterns** von Robert Nystrom (komplett kostenlos online lesbar) – erklärt State Machines, Object Pooling & Co.
- **Red Blob Games** – anschauliche Spiele-Mathematik (Vektoren, Wegfindung, Raster)
- **Lode's Computer Graphics Tutorial – Raycasting** – Grundlage für Projekt 08
- **Game Maker's Toolkit** (YouTube) – warum sich Spiele gut anfühlen (Game Design)
- **GDQuest**, **Brackeys** (YouTube) – Godot-Tutorials
- **„DOOM (2016) – Graphics Study“** von Adrian Courrèges – zeigt Bild für Bild, wie DOOM 2016 gerendert wird
- **GDC-Vorträge** (YouTube) – Vorträge der id-Software-Entwickler zu DOOM-Kampfdesign und KI

---

## 10. Projektstruktur in diesem Ordner

```
games/
├── ROADMAP.md
├── 00-ballwechsel/
├── 01-ziegelbrecher/
├── 02-insekteninvasion/
├── ...
└── 12-doom-2016/
```

Jedes Projekt bekommt eine kurze `README.md`: Was habe ich gelernt, was war schwer, was würde ich anders machen. Am Ende hast du so ein Lerntagebuch und ein Portfolio.

**Nächster Schritt:** Git einrichten, Ballwechsel nach `00-ballwechsel/` verschieben, dann mit **01 · Ziegelbrecher** loslegen.
