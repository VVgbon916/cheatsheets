# 📻 MASTER RADIO — Worldwide Internet Music Radio Database & Application Guide
### Personal Database Architecture & Radio Player Suite for Bazzite KDE
> System: `VVgbon@VVgBazz` | Players: Shortwave · Tuner · Strawberry · VLC · MusicPod

---

## 🏆 Part 1: The Top 5 Radio Apps for Bazzite KDE

Based on your ranking and system profile, here is how each app serves a specific purpose without fighting each other:

| Rank | Application | Flatpak ID | Best For | Role in Your Rig |
|---|---|---|---|---|
| 🥇 **1** | **Shortwave** | `de.haeckerfelix.Shortwave` | 50,000+ stations, clean UI, song identification | Everyday worldwide browsing |
| 🥈 **2** | **Tuner** | `io.github.tuner_labs.tuner` | Random discovery, shuffle mode | "Surprise me" station discovery |
| 🥉 **3** | **Strawberry** | `org.strawberrymusicplayer.strawberry` | Local FLAC collection + Bit-perfect radio | Audiophile & playlist manager |
| 4 | **MusicPod** | `org.feichtmeier.Musicpod` | Music + Radio + TV + Podcasts | All-in-one entertainment hub |
| 5 | **Goodvibes** | `io.gitlab.Goodvibes` | Ultra-lightweight (569 KB), MPRIS keys | Background low-resource listening |

### Quick Installation:
```bash
flatpak install -y flathub \
    de.haeckerfelix.Shortwave \
    io.github.tuner_labs.tuner \
    org.strawberrymusicplayer.strawberry \
    org.feichtmeier.Musicpod \
    io.gitlab.Goodvibes
```

---

## 🏗️ Part 2: The Master Radio Database Engine (`master_radio_builder.py`)

A custom Python engine has been written specifically to implement your locked **27 Core Rules**:
👉 Script location: [master_radio_builder.py](file:///home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/master_radio_builder.py)

### The 10 Broad Canonical Families:
1. `ROCK` (Classic, Alternative, Metal, Indie, Punk, Grunge)
2. `POP & HITS` (Top 40, Contemporary, Synthpop)
3. `ELECTRONIC & DANCE` (House, Techno, Trance, EDM, Drum & Bass)
4. `CHILL & AMBIENT` (Downtempo, Lounge, Lo-Fi, Ambient, Space)
5. `HIP-HOP & R&B` (Rap, Soul, Funk, Urban)
6. `JAZZ & BLUES` (Smooth Jazz, Bebop, Delta Blues)
7. `CLASSICAL & SOUNDTRACK` (Symphony, Opera, Film Score)
8. `COUNTRY & ROOTS` (Americana, Folk, Bluegrass)
9. `REGGAE & WORLD` (Dub, Roots, Latin, Afrobeat)
10. `DECIMAL & RETRO` (80s, 90s, 70s, Oldies, Classic Hits)

---

## ⚡ Part 3: Running the Python Engine on Bazzite

The script uses **Python standard library** only (zero pip dependencies required). You can run it directly in your terminal:

```bash
# 1. Create a radio workspace in your home folder
mkdir -p ~/Music/MASTER_RADIO
cd ~/Music/MASTER_RADIO

# 2. Copy the builder script here
cp /home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/master_radio_builder.py ./

# 3. Run the generator (builds all Playlists and Documents)
python3 master_radio_builder.py

# 4. Optional: Run with live stream validation (tests HTTP links in parallel)
python3 master_radio_builder.py --verify
```

---

## 📂 Part 4: Generated Files & Folder Structure

Running the builder produces the exact structure required by your specification:

```
MASTER_RADIO/
├── PLAYLISTS/
│   ├── MASTER_PLAYLIST.m3u        # 1 station = 1 broad genre (with group-title)
│   ├── MASTER_PLAYLIST.xspf       # XML playlist for Strawberry / VLC
│   ├── ACCURATE_PLAYLIST.m3u      # Database truth mirror
│   ├── ACCURATE_PLAYLIST.xspf
│   ├── CROSSOVER_PLAYLIST.m3u     # Discovery (max 3 categories per station)
│   ├── CROSSOVER_PLAYLIST.xspf
│   ├── NOLOGIN_PLAYLIST.m3u       # Strictly open public streams
│   └── NOLOGIN_PLAYLIST.xspf
├── DOCUMENTATION/
│   ├── MASTER_INDEX.txt           # Clean ASCII tree directory A -> Z
│   ├── CROSSOVER.txt              # Cross-reference documentation
│   ├── NON_EXTERNAL_RADIO.txt     # Web-only / App-only stations
│   ├── OTHER_RADIO_RESOURCES.txt  # News, Talk, Sports, Scanners
│   └── BROKEN_OR_EXCLUDED.txt     # Failed/dead links quarantine
└── DATABASE/
    └── master_radio_db.json       # Canonical source-of-truth database
```

---

## 🎧 Part 5: How to Load Your Playlists

### In Strawberry Music Player:
1. Open Strawberry (`flatpak run org.strawberrymusicplayer.strawberry`).
2. Go to **Playlist** -> **Load Playlist**.
3. Choose `~/Music/MASTER_RADIO/PLAYLISTS/MASTER_PLAYLIST.xspf` (or `.m3u`).
4. All stations appear organized by their broad family genre!

### In VLC Media Player:
1. Open VLC (`flatpak run org.videolan.VLC`).
2. Drag and drop `MASTER_PLAYLIST.m3u` into the VLC window.
3. Open the Playlist view (**Ctrl + L**) to browse grouped genres.

### On Apple Devices / Mobile:
1. Copy `MASTER_PLAYLIST.m3u` or `NOLOGIN_PLAYLIST.m3u` to iCloud Drive or send via email.
2. Open in **Audials Play**, **Smart M3U Player**, or **myTuner Radio**.
