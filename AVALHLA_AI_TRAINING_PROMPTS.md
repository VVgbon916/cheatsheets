# 🛡️ AVALHLA — Local AI Training & Benchmark Prompt Suite
### Testing Your Personal CLI AI on the Master Radio Python & Markdown Project
> AI Persona: **Avalhla** | Model: Qwen 2.5 / 3.5 Coder (7B/9B/14B on Ollama)
> Rig: `VVgbon@VVgBazz` | Hardware: NVIDIA RTX 3060 12GB (Full VRAM Offload)

---

## 🎭 Step 1: Giving Her the "Avalhla" Persona in Ollama

Before testing her, make sure she knows who she is and what system she is running on. You can create a custom Ollama model named `avalhla`:

```bash
# 1. Create a Modelfile
cat << 'EOF' > ~/Modelfile.avalhla
FROM qwen2.5-coder:7b

# System prompt giving Avalhla her personality and rules
SYSTEM """
You are Avalhla, Dawa's private, high-performance personal AI companion and senior systems engineer.
You run locally on Dawa's Bazzite DX NVIDIA gaming rig (RTX 3060 12GB, i7-6700, KDE Wayland).
Your core directives:
1. Always write clean, idiomatic Python (standard library first) and robust Bash.
2. Adhere strictly to the project rules and never invent non-existent APIs or microgenres.
3. Be concise, sharp, and structured. Explain your architectural logic clearly.
"""

PARAMETER temperature 0.2
PARAMETER top_p 0.9
PARAMETER num_ctx 8192
EOF

# 2. Build the Avalhla model in Ollama
ollama create avalhla -f ~/Modelfile.avalhla

# 3. Test that she knows who she is
ollama run avalhla "Who are you, what is your name, and whose system are you running on?"
```

---

## 🧰 Step 1.5: Verify Avalhla's Complete Tool Stack

To ensure Avalhla has **100% of the tools she needs** (Python 3, JQ, Curl, ShellCheck, XMLlint, FFmpeg, Java 17, Maven, Ripgrep) before she begins generating or inspecting code, run the audit script:

```bash
# Run the audit script directly (can be run on host or inside Distrobox)
bash /home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/avalhla_tools_check.sh
```

If any tool is missing, install it inside your Distrobox container:
```bash
distrobox enter coding-lab -- sudo dnf install -y python3 curl jq git shellcheck libxml2 ffmpeg-free java-17-openjdk-devel maven ripgrep fzf
```

---

## 🧪 Step 2: The 4-Stage Benchmark Prompts

Feed these prompts to **Avalhla** one stage at a time in your terminal. This trains her to tackle complex multi-file projects without getting confused or hitting context limits.

---

### 🟢 STAGE 1 — The Architecture & Rule Verification Test
> **Goal:** Test if Avalhla can comprehend all 27 rules of the Master Radio specification without inventing unnecessary microgenres.

**Prompt to copy/paste to Avalhla:**
```text
Avalhla, I am giving you the specification for project "MASTER RADIO".
Before writing any code, I want you to act as lead software architect and summarize the core constraints:

1. What are the EXACT 10 broad canonical music genres we must use?
2. What is the fundamental difference between ACCURATE_PLAYLIST, MASTER_PLAYLIST, and CROSSOVER_PLAYLIST?
3. What is our rule regarding stream quality, dead links, and seasonal/holiday radio?
4. What is our geographic priority?

Do not write Python code yet. Only demonstrate complete comprehension of these rules in structured markdown.
```

#### ✅ How to Grade Avalhla:
- **PASS:** She outputs exactly 10 broad categories (e.g., Rock, Pop, Electronic, Chill/Ambient, etc.) and refuses subgenres like "Post-Punk" or "Industrial Death Metal".
- **PASS:** She notes that `ACCURATE` is 1 station = 1 genre (source of truth), while `CROSSOVER` allows max 3 discovery categories.
- **FAIL:** If she creates 20+ genres or allows Christmas stations in the main playlist.

---

### 🟡 STAGE 2 — JSON Schema & Data Model Benchmark
> **Goal:** Test if she can design the underlying database schema that feeds both M3U and XSPF generators.

**Prompt to copy/paste to Avalhla:**
```text
Avalhla, design the master JSON schema for our "master_radio_db.json" database.
The schema must support:
- Station Name
- Primary Genre (Must be strictly one of our 10 broad genres)
- Crossover Genres (List of up to 3 valid broad genres)
- Country (e.g., USA, UK, France, Québec, Canada)
- Primary Stream URL & Bitrate/Codec
- Secondary/320k Alt Stream URL (optional)
- No-login flag (boolean)
- Official Homepage URL

Provide the JSON Schema format and show 3 complete real-world examples:
1. SomaFM Groove Salad (Ambient/Chill)
2. Radio Paradise (Rock/Chill Crossover)
3. FIP Radio France (Eclectic/Jazz)
```

#### ✅ How to Grade Avalhla:
- **PASS:** Clean, valid JSON with `no_login: true`, proper bitrate integers (e.g. `256`, `320`), and correct broad genre assignments.
- **PASS:** `crossover_genres` has at most 3 entries.

---

### 🟠 STAGE 3 — Python Code Challenge: M3U & XSPF Generator
> **Goal:** Test her ability to generate compliant `#EXTINF group-title` M3U and XML-valid XSPF code using **only Python standard library**.

**Prompt to copy/paste to Avalhla:**
```text
Avalhla, write a standalone, clean Python 3 function that takes a list of station dictionaries and generates TWO files:
1. "MASTER_PLAYLIST.m3u": Must use rich metadata format:
   #EXTINF:-1 group-title="<GENRE>",<Station Name> [<Country>]
   <STREAM_URL>
2. "MASTER_PLAYLIST.xspf": Valid XML format using `xml.etree.ElementTree` with indentation, including <trackList>, <track>, <title>, <location>, and <album> (used for genre).

Requirements:
- Python standard library ONLY (no pip packages).
- Sort stations alphabetically A-Z by station name.
- Write production-grade code with clear error handling.
```

#### ✅ How to Grade Avalhla:
- **PASS:** No `import requests` or `import m3u8` — she uses `xml.etree.ElementTree` and built-in file I/O.
- **PASS:** Valid XML string formatting.
- **PASS:** `group-title="GENRE"` syntax is exactly right in the M3U output.

---

### 🔴 STAGE 4 — Live Stream Validator Challenge (Concurrency Test)
> **Goal:** Test her advanced systems programming skills (multi-threaded stream checking to eliminate dead links without freezing).

**Prompt to copy/paste to Avalhla:**
```text
Avalhla, Rule 13 states: "No dead links in playable playlists."
Write a Python function `validate_all_streams(stations, max_workers=8)` that:
1. Uses `concurrent.futures.ThreadPoolExecutor` to test stream URLs concurrently.
2. Sends an HTTP request with a 3.5-second timeout and a "Range: bytes=0-1024" header so it does not download the entire audio stream.
3. Checks for HTTP status 200 or 206 (Partial Content).
4. Separates valid stations from dead stations.
5. Returns two lists: `(valid_stations, dead_stations)`.
```

#### ✅ How to Grade Avalhla:
- **PASS:** Uses `Range: bytes=0-1024` (crucial so the script doesn't hang downloading a 320kbps endless stream!).
- **PASS:** Handles `urllib.error.URLError` and `socket.timeout` gracefully.

---

## 🏆 Step 3: The Grand Final Test (Full Project Generation)

Once she passes the 4 stages, run this master prompt to have her assemble the full project:

```text
Avalhla, you have passed all component benchmarks.
Now, generate the complete, production-ready "master_radio_builder.py" script that combines:
1. The 10 canonical Broad Genres.
2. Initial seed database of premier stations (SomaFM, Radio Paradise, NTS, KEXP, FIP, CHOM 97.7, Ici Musique).
3. Live stream validator with ThreadPoolExecutor.
4. Intelligent deduplication (station name & stream URL).
5. Generation of MASTER, ACCURATE, CROSSOVER, and NOLOGIN playlists (both .m3u and .xspf).
6. Generation of ASCII "MASTER_INDEX.txt" tree directory and "CROSSOVER.txt".
7. Zero external pip dependencies.

Give me the entire single-file executable script with `#!/usr/bin/env python3`.
```

---

## 💡 Pro-Tips for Running Avalhla on RTX 3060

1. **Keep Context Clean:** If Avalhla starts repeating herself or slowing down, type `/clear` in Ollama to reset her context buffer.
2. **Speed:** On your RTX 3060, `qwen2.5-coder:7b` will generate at **~60 tokens/second** using ~5.5 GB VRAM.
3. **If You Want Deeper Logic:** Run `ollama run qwen2.5-coder:14b`. It uses ~9.5 GB VRAM (fits in your 12GB) and provides even sharper architectural code.
