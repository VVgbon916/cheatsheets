#!/usr/bin/env python3
"""
===============================================================================
MASTER RADIO — PERSONAL WORLDWIDE INTERNET MUSIC RADIO DATABASE ENGINE
===============================================================================
Rig: Bazzite DX NVIDIA (Dawa / VVgbon@VVgBazz)
Python: Standard Library (zero pip install required)
Implements all 27 Core Rules:
  - 10 Broad Family Genres (No microgenre clutter)
  - 1 Station = 1 Authoritative Master Genre
  - Crossover Matrix (max 3 tags per station)
  - Stream Validation (pings stream with HTTP timeout to eliminate dead links)
  - Rich M3U (#EXTINF with group-title) & XML XSPF Generation
  - Generates ASCII Master Index, Crossover Map, and Non-External Logs
===============================================================================
"""

import os
import sys
import json
import time
import urllib.request
import urllib.error
import xml.etree.ElementTree as ET
from xml.dom import minidom
from concurrent.futures import ThreadPoolExecutor, as_completed

# =============================================================================
# 1. CANONICAL 10 BROAD MUSICAL GENRES (RULE 3 & 6)
# =============================================================================
BROAD_GENRES = [
    "ROCK",
    "POP & HITS",
    "ELECTRONIC & DANCE",
    "CHILL & AMBIENT",
    "HIP-HOP & R&B",
    "JAZZ & BLUES",
    "CLASSICAL & SOUNDTRACK",
    "COUNTRY & ROOTS",
    "REGGAE & WORLD",
    "DECIMAL & RETRO"
]

# Mapping rules to resolve incoming tags into the 10 Broad Families
TAG_MAPPING = {
    "rock": "ROCK", "classic rock": "ROCK", "hard rock": "ROCK", "metal": "ROCK",
    "alternative": "ROCK", "indie": "ROCK", "punk": "ROCK", "grunge": "ROCK", "prog rock": "ROCK",
    "pop": "POP & HITS", "top 40": "POP & HITS", "hits": "POP & HITS", "dance pop": "POP & HITS",
    "electronic": "ELECTRONIC & DANCE", "dance": "ELECTRONIC & DANCE", "techno": "ELECTRONIC & DANCE",
    "house": "ELECTRONIC & DANCE", "trance": "ELECTRONIC & DANCE", "edm": "ELECTRONIC & DANCE", "dnb": "ELECTRONIC & DANCE",
    "ambient": "CHILL & AMBIENT", "downtempo": "CHILL & AMBIENT", "chillout": "CHILL & AMBIENT", "lounge": "CHILL & AMBIENT",
    "lofi": "CHILL & AMBIENT", "lo-fi": "CHILL & AMBIENT", "drone": "CHILL & AMBIENT", "space": "CHILL & AMBIENT",
    "hip hop": "HIP-HOP & R&B", "hip-hop": "HIP-HOP & R&B", "rap": "HIP-HOP & R&B", "r&b": "HIP-HOP & R&B",
    "soul": "HIP-HOP & R&B", "funk": "HIP-HOP & R&B", "urban": "HIP-HOP & R&B",
    "jazz": "JAZZ & BLUES", "blues": "JAZZ & BLUES", "smooth jazz": "JAZZ & BLUES", "bebop": "JAZZ & BLUES",
    "classical": "CLASSICAL & SOUNDTRACK", "symphony": "CLASSICAL & SOUNDTRACK", "soundtrack": "CLASSICAL & SOUNDTRACK",
    "opera": "CLASSICAL & SOUNDTRACK", "instrumental": "CLASSICAL & SOUNDTRACK",
    "country": "COUNTRY & ROOTS", "folk": "COUNTRY & ROOTS", "americana": "COUNTRY & ROOTS", "bluegrass": "COUNTRY & ROOTS",
    "reggae": "REGGAE & WORLD", "dub": "REGGAE & WORLD", "roots": "REGGAE & WORLD", "latin": "REGGAE & WORLD", "world": "REGGAE & WORLD",
    "80s": "DECIMAL & RETRO", "70s": "DECIMAL & RETRO", "90s": "DECIMAL & RETRO", "oldies": "DECIMAL & RETRO", "retro": "DECIMAL & RETRO"
}

# =============================================================================
# 2. SEED DATABASE — PREMIER CURATED STATIONS (USA / UK / FR / QC / CA)
# =============================================================================
INITIAL_STATIONS = [
    {
        "name": "SomaFM Groove Salad",
        "primary_genre": "CHILL & AMBIENT",
        "crossover_genres": ["CHILL & AMBIENT", "ELECTRONIC & DANCE"],
        "country": "USA",
        "stream_url": "https://ice1.somafm.com/groovesalad-256-mp3",
        "alt_stream_url": "https://ice1.somafm.com/groovesalad-128-mp3",
        "bitrate": 256,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://somafm.com"
    },
    {
        "name": "SomaFM Drone Zone",
        "primary_genre": "CHILL & AMBIENT",
        "crossover_genres": ["CHILL & AMBIENT"],
        "country": "USA",
        "stream_url": "https://ice1.somafm.com/dronezone-256-mp3",
        "alt_stream_url": "",
        "bitrate": 256,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://somafm.com"
    },
    {
        "name": "SomaFM Indie Pop Rocks!",
        "primary_genre": "ROCK",
        "crossover_genres": ["ROCK", "POP & HITS"],
        "country": "USA",
        "stream_url": "https://ice1.somafm.com/indiepop-128-mp3",
        "alt_stream_url": "",
        "bitrate": 128,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://somafm.com"
    },
    {
        "name": "Radio Paradise (Main Mix)",
        "primary_genre": "ROCK",
        "crossover_genres": ["ROCK", "CHILL & AMBIENT", "POP & HITS"],
        "country": "USA",
        "stream_url": "https://stream.radioparadise.com/mp3-320",
        "alt_stream_url": "https://stream.radioparadise.com/flac",
        "bitrate": 320,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://radioparadise.com"
    },
    {
        "name": "Radio Paradise (Mellow Mix)",
        "primary_genre": "CHILL & AMBIENT",
        "crossover_genres": ["CHILL & AMBIENT", "ROCK"],
        "country": "USA",
        "stream_url": "https://stream.radioparadise.com/mellow-320",
        "alt_stream_url": "",
        "bitrate": 320,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://radioparadise.com"
    },
    {
        "name": "NTS Radio 1",
        "primary_genre": "ELECTRONIC & DANCE",
        "crossover_genres": ["ELECTRONIC & DANCE", "HIP-HOP & R&B", "CHILL & AMBIENT"],
        "country": "UK",
        "stream_url": "https://stream-relay-geo.ntslive.net/stream",
        "alt_stream_url": "",
        "bitrate": 192,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://www.nts.live"
    },
    {
        "name": "KEXP 90.3 FM Seattle",
        "primary_genre": "ROCK",
        "crossover_genres": ["ROCK", "HIP-HOP & R&B", "REGGAE & WORLD"],
        "country": "USA",
        "stream_url": "https://kexp.streamguys1.com/kexp160.mp3",
        "alt_stream_url": "",
        "bitrate": 160,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://kexp.org"
    },
    {
        "name": "FIP (Radio France)",
        "primary_genre": "JAZZ & BLUES",
        "crossover_genres": ["JAZZ & BLUES", "CHILL & AMBIENT", "REGGAE & WORLD"],
        "country": "France",
        "stream_url": "https://icecast.radiofrance.fr/fip-midfi.mp3",
        "alt_stream_url": "",
        "bitrate": 192,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://www.radiofrance.fr/fip"
    },
    {
        "name": "Ici Musique (Radio-Canada Montréal)",
        "primary_genre": "POP & HITS",
        "crossover_genres": ["POP & HITS", "JAZZ & BLUES", "CLASSICAL & SOUNDTRACK"],
        "country": "Québec",
        "stream_url": "https://ici-musique.streamguys1.com/live.mp3",
        "alt_stream_url": "",
        "bitrate": 128,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://ici.radio-canada.ca/musique"
    },
    {
        "name": "CHOM 97.7 The Spirit of Rock",
        "primary_genre": "ROCK",
        "crossover_genres": ["ROCK", "DECIMAL & RETRO"],
        "country": "Québec",
        "stream_url": "https://18093.live.streamtheworld.com/CHOMFMAAC.aac",
        "alt_stream_url": "",
        "bitrate": 128,
        "format": "AAC",
        "no_login": True,
        "homepage": "https://www.iheartradio.ca/chom"
    },
    {
        "name": "WWOZ 90.7 New Orleans Jazz & Heritage",
        "primary_genre": "JAZZ & BLUES",
        "crossover_genres": ["JAZZ & BLUES", "HIP-HOP & R&B", "COUNTRY & ROOTS"],
        "country": "USA",
        "stream_url": "https://wwoz-sc.streamguys1.com/wwoz-hi.mp3",
        "alt_stream_url": "",
        "bitrate": 128,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://www.wwoz.org"
    },
    {
        "name": "Linn Classical",
        "primary_genre": "CLASSICAL & SOUNDTRACK",
        "crossover_genres": ["CLASSICAL & SOUNDTRACK"],
        "country": "UK",
        "stream_url": "http://radio.linn.co.uk:8004/autodj",
        "alt_stream_url": "",
        "bitrate": 320,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://www.linn.co.uk"
    },
    {
        "name": "Ibiza Global Radio",
        "primary_genre": "ELECTRONIC & DANCE",
        "crossover_genres": ["ELECTRONIC & DANCE", "CHILL & AMBIENT"],
        "country": "Spain",
        "stream_url": "https://inlive54.radiocontrol.hk:8022/live",
        "alt_stream_url": "",
        "bitrate": 192,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://ibizaglobalradio.com"
    },
    {
        "name": "181.FM The Eagle (Classic Rock)",
        "primary_genre": "ROCK",
        "crossover_genres": ["ROCK", "DECIMAL & RETRO"],
        "country": "USA",
        "stream_url": "https://listen.181fm.com/181-eagle_128k.mp3",
        "alt_stream_url": "",
        "bitrate": 128,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://www.181.fm"
    },
    {
        "name": "CINQ FM 102.3 Radio Centre-Ville Montréal",
        "primary_genre": "REGGAE & WORLD",
        "crossover_genres": ["REGGAE & WORLD", "HIP-HOP & R&B"],
        "country": "Québec",
        "stream_url": "https://stream.radiocentreville.com:8000/stream",
        "alt_stream_url": "",
        "bitrate": 128,
        "format": "MP3",
        "no_login": True,
        "homepage": "https://radiocentreville.com"
    }
]

# =============================================================================
# 3. STREAM VALIDATION ENGINE (NO DEAD LINKS - RULE 13)
# =============================================================================
def validate_stream_url(url, timeout=4.0):
    """Pings HTTP audio stream with HEAD/GET range to verify it is alive."""
    if not url or not url.startswith("http"):
        return False
    try:
        req = urllib.request.Request(
            url,
            headers={
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) MasterRadio/1.0",
                "Range": "bytes=0-1024"
            }
        )
        with urllib.request.urlopen(req, timeout=timeout) as response:
            code = response.getcode()
            if code in (200, 206):
                return True
    except Exception:
        return False
    return False

# =============================================================================
# 4. MASTER ENGINE CLASS
# =============================================================================
class MasterRadioEngine:
    def __init__(self, base_dir="MASTER_RADIO"):
        self.base_dir = os.path.abspath(base_dir)
        self.playlists_dir = os.path.join(self.base_dir, "PLAYLISTS")
        self.docs_dir = os.path.join(self.base_dir, "DOCUMENTATION")
        self.db_dir = os.path.join(self.base_dir, "DATABASE")
        self.db_file = os.path.join(self.db_dir, "master_radio_db.json")
        self.stations = []
        self.broken_stations = []
        self.init_structure()

    def init_structure(self):
        """Creates directory structure per specification rule 23."""
        for path in [self.playlists_dir, self.docs_dir, self.db_dir]:
            os.makedirs(path, exist_ok=True)
        if os.path.exists(self.db_file):
            with open(self.db_file, "r", encoding="utf-8") as f:
                self.stations = json.load(f)
        else:
            self.stations = INITIAL_STATIONS
            self.save_db()

    def save_db(self):
        """Saves stations database as master JSON truth."""
        with open(self.db_file, "w", encoding="utf-8") as f:
            json.dump(self.stations, f, indent=2, ensure_ascii=False)

    def deduplicate(self):
        """Deduplicates stations intelligently by Name + Stream (Rule 9)."""
        seen_names = set()
        seen_urls = set()
        deduped = []
        for s in self.stations:
            name_key = s["name"].strip().lower()
            url_key = s["stream_url"].strip().lower()
            if name_key in seen_names or url_key in seen_urls:
                continue
            seen_names.add(name_key)
            seen_urls.add(url_key)
            deduped.append(s)
        self.stations = deduped
        self.save_db()

    def verify_all_streams(self, workers=8):
        """Validates all streams in parallel and routes dead ones to broken list."""
        print(f"[*] Validating {len(self.stations)} audio streams...")
        active = []
        dead = []

        with ThreadPoolExecutor(max_workers=workers) as executor:
            future_to_station = {executor.submit(validate_stream_url, s["stream_url"]): s for s in self.stations}
            for future in as_completed(future_to_station):
                st = future_to_station[future]
                is_alive = False
                try:
                    is_alive = future.result()
                except Exception:
                    is_alive = False
                
                if is_alive:
                    print(f"  [PASS] {st['name']}")
                    active.append(st)
                else:
                    print(f"  [FAIL] {st['name']} -> Moved to BROKEN_OR_EXCLUDED.txt")
                    dead.append(st)

        self.stations = active
        self.broken_stations.extend(dead)
        self.save_db()
        self.write_broken_log()

    # =========================================================================
    # PLAYLIST WRITERS (M3U & XSPF)
    # =========================================================================
    def generate_m3u(self, stations, filepath, title="MASTER RADIO"):
        """Generates rich M3U playlist with group-title attributes (Rule 21 & 22)."""
        with open(filepath, "w", encoding="utf-8") as f:
            f.write("#EXTM3U\n")
            f.write(f"#PLAYLIST:{title}\n\n")
            for s in stations:
                genre = s.get("primary_genre", "ROCK")
                name = s["name"]
                url = s["stream_url"]
                f.write(f'#EXTINF:-1 group-title="{genre}",{name} [{s.get("country", "")}]\n')
                f.write(f"{url}\n\n")

    def generate_xspf(self, stations, filepath, title="MASTER RADIO"):
        """Generates XML XSPF playlist (Rule 21)."""
        playlist = ET.Element("playlist", version="1", xmlns="http://xspf.org/ns/0/")
        ET.SubElement(playlist, "title").text = title
        trackList = ET.SubElement(playlist, "trackList")

        for s in stations:
            track = ET.SubElement(trackList, "track")
            ET.SubElement(track, "title").text = s["name"]
            ET.SubElement(track, "location").text = s["stream_url"]
            ET.SubElement(track, "album").text = s.get("primary_genre", "ROCK")
            if s.get("homepage"):
                ET.SubElement(track, "info").text = s["homepage"]

        xml_str = ET.tostring(playlist, encoding="utf-8")
        parsed = minidom.parseString(xml_str)
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(parsed.toprettyxml(indent="  "))

    # =========================================================================
    # DOCUMENTATION GENERATORS (ASCII & RULES)
    # =========================================================================
    def generate_master_index(self):
        """Builds clean ASCII MASTER_INDEX.txt tree index (Rule 24 & 25)."""
        idx_file = os.path.join(self.docs_dir, "MASTER_INDEX.txt")
        with open(idx_file, "w", encoding="utf-8") as f:
            f.write("===============================================================================\n")
            f.write("                 MASTER RADIO — WORLDWIDE INDEX & TREE DIRECTORY                \n")
            f.write("===============================================================================\n\n")
            f.write("MASTER RADIO\n")

            # Group stations by canonical genres
            genre_map = {g: [] for g in BROAD_GENRES}
            for s in sorted(self.stations, key=lambda x: x["name"].lower()):
                g = s.get("primary_genre", "ROCK")
                if g in genre_map:
                    genre_map[g].append(s)

            total_genres = len(BROAD_GENRES)
            for i, genre in enumerate(BROAD_GENRES):
                prefix_branch = "└── " if i == total_genres - 1 else "├── "
                sub_indent = "    " if i == total_genres - 1 else "│   "
                f.write(f"{prefix_branch}[ {genre} ] ({len(genre_map[genre])} Stations)\n")

                stations_in_genre = genre_map[genre]
                for j, st in enumerate(stations_in_genre):
                    st_prefix = "└── " if j == len(stations_in_genre) - 1 else "├── "
                    f.write(f"{sub_indent}{st_prefix}{st['name']} ({st.get('country', 'WW')}) [{st.get('bitrate', 128)}k {st.get('format', 'MP3')}]\n")
                f.write(f"{sub_indent}\n")

    def generate_crossover_documentation(self):
        """Generates CROSSOVER.txt index with multi-tag mapping (Rule 4 & 5)."""
        crossover_file = os.path.join(self.docs_dir, "CROSSOVER.txt")
        with open(crossover_file, "w", encoding="utf-8") as f:
            f.write("===============================================================================\n")
            f.write("                      MASTER RADIO — CROSSOVER DISCOVERY INDEX                  \n")
            f.write("  Note: Stations may appear in up to 3 legitimate secondary categories for      \n")
            f.write("        discovery. This is not a duplicate in the source database.              \n")
            f.write("===============================================================================\n\n")

            for s in sorted(self.stations, key=lambda x: x["name"].lower()):
                genres = s.get("crossover_genres", [s.get("primary_genre", "ROCK")])
                genres_str = " | ".join(genres[:3])
                f.write(f"• {s['name']} [{s.get('country', '')}]\n")
                f.write(f"  Primary:   {s.get('primary_genre', '')}\n")
                f.write(f"  Crossover: {genres_str}\n")
                f.write(f"  Stream:    {s['stream_url']}\n\n")

    def write_broken_log(self):
        """Writes dead streams to BROKEN_OR_EXCLUDED.txt (Rule 18)."""
        log_file = os.path.join(self.docs_dir, "BROKEN_OR_EXCLUDED.txt")
        with open(log_file, "w", encoding="utf-8") as f:
            f.write("# Candidates excluded due to dead links or connection failure\n")
            f.write("# Format: Station Name | Stream URL | Timestamp\n\n")
            for b in self.broken_stations:
                f.write(f"{b['name']} | {b['stream_url']} | {time.strftime('%Y-%m-%d %H:%M:%S')}\n")

    def write_non_external_log(self):
        """Writes web/app-only stations to NON_EXTERNAL_RADIO.txt (Rule 16)."""
        log_file = os.path.join(self.docs_dir, "NON_EXTERNAL_RADIO.txt")
        with open(log_file, "w", encoding="utf-8") as f:
            f.write("===============================================================================\n")
            f.write("                  NON-EXTERNAL MUSIC RADIO (WEB / APP ONLY)                    \n")
            f.write("===============================================================================\n\n")
            f.write("Station                        Country       Genre          Website/WebPlayer\n")
            f.write("-------------------------------------------------------------------------------\n")
            f.write("BBC Radio 6 Music (Web Player) UK            ROCK           https://www.bbc.co.uk/sounds/play/live:bbc_6music\n")
            f.write("SiriusXM Chill (Subscription)  USA           CHILL          https://player.siriusxm.com\n")
            f.write("iHeartRadio Pop Hits           USA           POP & HITS     https://www.iheart.com\n")

    def write_other_radio_log(self):
        """Writes non-music categories to OTHER_RADIO_RESOURCES.txt (Rule 17)."""
        log_file = os.path.join(self.docs_dir, "OTHER_RADIO_RESOURCES.txt")
        with open(log_file, "w", encoding="utf-8") as f:
            f.write("===============================================================================\n")
            f.write("           OTHER RADIO RESOURCES (NEWS, TALK, SPORTS & SCANNERS)               \n")
            f.write("  Note: Excluded from Master Radio music database per Project Scope Rule 17.   \n")
            f.write("===============================================================================\n\n")
            f.write("• BBC World Service English (News / Talk)       -> https://stream.live.vc.bbcmedia.co.uk/bbc_world_service\n")
            f.write("• Radio-Canada Première Montréal (News / Talk)  -> https://ici-premiere.streamguys1.com/live.mp3\n")
            f.write("• NPR News 24/7 (News / Current Affairs)        -> https://npr-ice.streamguys1.com/live.mp3\n")

    # =========================================================================
    # BUILD ALL TARGETS
    # =========================================================================
    def build_all(self):
        """Builds all Master, Accurate, Crossover, and NoLogin playlists."""
        print("[*] Deduplicating stations...")
        self.deduplicate()

        # Sort stations A-Z
        sorted_stations = sorted(self.stations, key=lambda x: x["name"].lower())

        # 1. MASTER PLAYLIST (1 Station = 1 Authoritative Genre)
        print("[*] Generating MASTER_PLAYLIST (.m3u & .xspf)...")
        self.generate_m3u(sorted_stations, os.path.join(self.playlists_dir, "MASTER_PLAYLIST.m3u"), "MASTER RADIO PLAYLIST")
        self.generate_xspf(sorted_stations, os.path.join(self.playlists_dir, "MASTER_PLAYLIST.xspf"), "MASTER RADIO PLAYLIST")

        # 2. ACCURATE PLAYLIST (Source of Truth mirror)
        print("[*] Generating ACCURATE_PLAYLIST (.m3u & .xspf)...")
        self.generate_m3u(sorted_stations, os.path.join(self.playlists_dir, "ACCURATE_PLAYLIST.m3u"), "ACCURATE RADIO DATABASE")
        self.generate_xspf(sorted_stations, os.path.join(self.playlists_dir, "ACCURATE_PLAYLIST.xspf"), "ACCURATE RADIO DATABASE")

        # 3. CROSSOVER PLAYLIST (Multi-genre duplicates for discovery)
        print("[*] Generating CROSSOVER_PLAYLIST (.m3u & .xspf)...")
        crossover_list = []
        for s in sorted_stations:
            genres = s.get("crossover_genres", [s.get("primary_genre", "ROCK")])
            for g in genres[:3]:
                dup = dict(s)
                dup["primary_genre"] = g
                crossover_list.append(dup)
        crossover_sorted = sorted(crossover_list, key=lambda x: (x["primary_genre"], x["name"].lower()))
        self.generate_m3u(crossover_sorted, os.path.join(self.playlists_dir, "CROSSOVER_PLAYLIST.m3u"), "CROSSOVER DISCOVERY PLAYLIST")
        self.generate_xspf(crossover_sorted, os.path.join(self.playlists_dir, "CROSSOVER_PLAYLIST.xspf"), "CROSSOVER DISCOVERY PLAYLIST")

        # 4. NOLOGIN PLAYLIST (Convenience public streams only)
        print("[*] Generating NOLOGIN_PLAYLIST (.m3u & .xspf)...")
        nologin_stations = [s for s in sorted_stations if s.get("no_login", True)]
        self.generate_m3u(nologin_stations, os.path.join(self.playlists_dir, "NOLOGIN_PLAYLIST.m3u"), "NO-LOGIN PUBLIC STREAMS")
        self.generate_xspf(nologin_stations, os.path.join(self.playlists_dir, "NOLOGIN_PLAYLIST.xspf"), "NO-LOGIN PUBLIC STREAMS")

        # 5. Documentation
        print("[*] Building documentation and tree index...")
        self.generate_master_index()
        self.generate_crossover_documentation()
        self.write_non_external_log()
        self.write_other_radio_log()
        self.write_broken_log()

        print(f"\n[SUCCESS] Master Radio Suite built cleanly in: {self.base_dir}")
        print(f"  • Total Curated Stations: {len(self.stations)}")
        print(f"  • Playlists:  {self.playlists_dir}")
        print(f"  • Documents:  {self.docs_dir}")

# =============================================================================
# CLI ENTRYPOINT
# =============================================================================
if __name__ == "__main__":
    target_dir = sys.argv[1] if len(sys.argv) > 1 else "MASTER_RADIO"
    engine = MasterRadioEngine(base_dir=target_dir)

    if "--verify" in sys.argv:
        engine.verify_all_streams()
    
    engine.build_all()
