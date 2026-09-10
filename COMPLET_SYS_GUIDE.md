# 👑 VVgBazz — COMPLET SYS GUIDE (Master System Bible)
### The Definitive Architecture, Optimization, Gaming & Recovery Manual
> **Owner:** Dawa (`VVgbon@VVgBazz`) | **Base:** Bazzite DX NVIDIA 44 (Fedora 44 Atomic / KDE Wayland)  
> **Core Hardware:** Intel Core i7-6700 (4.0 GHz) · NVIDIA GeForce RTX 3060 12GB · 16GB RAM · 1TB Btrfs SSD  
> **Audio:** PipeWire 1.6.8 Multi-Sink Matrix · **Cooling:** Liquid Cooling via CoolerControl & Liquidctl

---

```
========================================================================================
                                 VVgBazz SYSTEM TOPOLOGY
========================================================================================
 [ Hardware Layer ]       Intel i7-6700 · RTX 3060 12GB · 1TB Btrfs SSD · USB DAC
         │
 [ Kernel & Drivers ]     Linux 7.2.3-ogc3.1 · NVIDIA 610.57.04 (CUDA 13.3) · BBR TCP
         │
 [ Atomic OS Base ]       ghcr.io/ublue-os/bazzite-dx-nvidia:stable (rpm-ostree)
         │
 ┌───────┴────────────────────────┬────────────────────────┬────────────────────────┐
 │ Layered RPMs                   │ Flatpak Ecosystem      │ Distrobox Containers   │
 │ • coolercontrol & liquidctl    │ • Gaming: ProtonPlus,  │ • coding-lab (Fedora)  │
 │ • mangohud & topgrade          │   Protontricks, Heroic │   - Java 17/21 & Maven │
 │ • gh (GitHub CLI)              │ • Media: VLC, Haruna,  │   - ShellCheck & Cava  │
 │ • displaylink (optional)       │   Hypnotix, Strawberry │   - Git, JQ, Ripgrep   │
 └───────┬────────────────────────┴────────────────────────┴────────────────────────┘
         │
 [ Persona & Desktops ]   KDE Plasma Wayland · Breeze Dark · Konsave · PipeWire 4-Sink
========================================================================================
```

---

## 📑 TABLE OF CONTENTS

1. [Hardware Profile & Verified Baseline](#1-hardware-profile--verified-baseline)
2. [Kernel, Driver & Power Optimization](#2-kernel-driver--power-optimization)
3. [Immutable OS Architecture: Layered vs Container vs Flatpak](#3-immutable-os-architecture-layered-vs-container-vs-flatpak)
4. [Audio Architecture: The PipeWire 4-Sink Matrix](#4-audio-architecture-the-pipewire-4-sink-matrix)
5. [Gaming & Overlay Calibration (RTX 3060 Specifics)](#5-gaming--overlay-calibration-rtx-3060-specifics)
6. [IPTV, Internet Radio & Media Suite](#6-iptv-internet-radio--media-suite)
7. [System Updates, Topgrade & Disaster Recovery](#7-system-updates-topgrade--disaster-recovery)
8. [Pre-Flight Health Audit & Auto-Repair Routine](#8-pre-flight-health-audit--auto-repair-routine)
9. [Desktop Persona Export & Custom ISO Creation](#9-desktop-persona-export--custom-iso-creation)
10. [Fresh Bazzite to Perfection (One-Shot Bootstrap)](#10-fresh-bazzite-to-perfection-one-shot-bootstrap)

---

## 1. Hardware Profile & Verified Baseline

| Subsystem | Verified Hardware Component | Status / Working Configuration |
|---|---|---|
| **CPU** | Intel Core i7-6700 (4 Cores / 8 Threads @ 3.40 GHz - 4.00 GHz Boost) | Liquid cooled; TuneD `throughput-performance` profile |
| **GPU** | NVIDIA GeForce RTX 3060 (GA104 Die, 12GB GDDR6 VRAM, PNY) | Driver 610.57.04, Persistence Mode active, 170W default cap |
| **Motherboard** | ASUSTeK H110I-PLUS (Intel B150 Chipset, Mini-ITX) | PCIe 3.0 x16, UEFI SecureBoot compliant |
| **Memory** | 16 GB Physical DDR4 + 7.8 GB zram compressed swap | Total ~24 GB effective RAM |
| **Storage** | 1TB SATA SSD (`sda`) formatted in **Btrfs** (`/`, `/var`, `/var/home`) | 255 GB used / ~695 GB available (27% capacity) |
| **Audio** | Z-Star Zgmicro USB DAC (`0ac8:9628`) + Motherboard Intel HDA | PipeWire 1.6.8 routing through 4 dedicated virtual sinks |
| **Network** | Realtek RTL8111 Gigabit Ethernet (`enp3s0`) | BBR TCP Congestion Control enabled; IPv4 + IPv6 active |

---

## 2. Kernel, Driver & Power Optimization

### A. NVIDIA GPU Clocks & Persistence Daemon
Your RTX 3060 is an Ampere GA104 card. On Bazzite KDE Wayland, configure it as follows:

```bash
# 1. Enable NVIDIA persistence daemon (survives all reboots) //dawa
sudo systemctl enable --now nvidia-persistenced

# 2. Check GPU telemetry (p-state, clocks, power, temperature)
nvidia-smi --query-gpu=pstate,clocks.sm,clocks.mem,temperature.gpu,power.draw,power.limit --format=csv

# 3. Apply maximum performance PowerMizer mode via Xwayland (KDE Wayland safe)
DISPLAY=:0 nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
```

> [!CAUTION]
> **Power Limit Guard:** Do NOT exceed **170W** on this PNY RTX 3060. 170W is the maximum rated board power. Never use `sudo nvidia-smi -pl 180`.

### B. CPU Governor & TuneD Tuning
Bazzite uses **TuneD** (not `power-profiles-daemon`).
```bash
# Set throughput-performance for high FPS and low frame-time jitter
sudo tuned-adm profile throughput-performance

# Verify active profile
tuned-adm active
```

### C. SSD Swappiness Optimization
For an SSD with 16GB RAM + zram, reduce Linux kernel swappiness to 10 so it only swaps under severe memory pressure:
```bash
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf
```

---

## 3. Immutable OS Architecture: Layered vs Container vs Flatpak

Bazzite is an atomic operating system. To ensure fast atomic updates without breaking rollbacks, follow the **Three-Tier Rule**:

```
                       HOW TO INSTALL SOFTWARE ON BAZZITE
  ┌─────────────────────────┬─────────────────────────┬─────────────────────────┐
  │ 1. LAYERED (rpm-ostree)  │ 2. FLATPAK (Flathub)    │ 3. DISTROBOX CONTAINER  │
  ├─────────────────────────┼─────────────────────────┼─────────────────────────┤
  │ ONLY for kernel drivers  │ For all GUI apps,       │ For all compilers, CLI  │
  │ and hardware daemons.   │ games, browsers, media  │ tools, dev SDKs, Java,  │
  │ Needs reboot to apply.  │ and IDEs. No reboot.    │ Maven, ShellCheck, etc. │
  └─────────────────────────┴─────────────────────────┴─────────────────────────┘
```

### Verified Layered RPMs on VVgBazz:
```bash
# Only these 5 packages should be layered:
rpm-ostree status
# LayeredPackages: coolercontrol displaylink liquidctl mangohud topgrade
```

### The Developer Lab (Distrobox):
```bash
# Create and enter your isolated Fedora dev lab
distrobox create -n coding-lab -i fedora:latest
distrobox enter coding-lab

# Inside coding-lab: Install whatever you want with standard dnf!
sudo dnf install -y java-17-openjdk-devel maven shellcheck git jq curl ripgrep fzf htop cava
```

---

## 4. Audio Architecture: The PipeWire 4-Sink Matrix

Your system features a PipeWire 1.6.8 routing architecture that isolates audio streams into **4 distinct virtual channels**:

```
 [ Applications ]                       [ PipeWire Virtual Sinks ]              [ Output Hardware ]
  • Steam / Lutris Games    ───────►    game_output (Node 43)        ──┐
  • Discord / Voice Chat    ───────►    voice_output (Node 45)       ──┼──►  USB DAC Headset
  • Strawberry / Spotify    ───────►    music_output (Node 49)       ──┤     (Zgmicro 0ac8:9628)
  • Firefox / VLC / IPTV    ───────►    browser_output (Node 47)     ──┘
```

### Persistent Configuration File:
Place this in `~/.config/pipewire/pipewire.conf.d/99-virtual-sinks.conf`:
```ini
context.modules = [
    { name = libpipewire-module-loopback args = { node.description = "Game Audio Sink" capture.props = { node.name = "game_output" media.class = "Audio/Sink" audio.position = [ FL FR ] } playback.props = { node.target = "auto" } } },
    { name = libpipewire-module-loopback args = { node.description = "Music & Radio Sink" capture.props = { node.name = "music_output" media.class = "Audio/Sink" audio.position = [ FL FR ] } playback.props = { node.target = "auto" } } },
    { name = libpipewire-module-loopback args = { node.description = "Voice Chat Sink" capture.props = { node.name = "voice_output" media.class = "Audio/Sink" audio.position = [ FL FR ] } playback.props = { node.target = "auto" } } },
    { name = libpipewire-module-loopback args = { node.description = "Browser & Media Sink" capture.props = { node.name = "browser_output" media.class = "Audio/Sink" audio.position = [ FL FR ] } playback.props = { node.target = "auto" } } }
]
```

### Visual Routing with `qpwgraph`:
```bash
flatpak run org.rncbc.qpwgraph
```
Simply drag lines from game audio to `game_output` and radio to `music_output`.

---

## 5. Gaming & Overlay Calibration (RTX 3060 Specifics)

### A. Steam Launch Options (Corrected for Modern Proton)
> [!WARNING]
> `DXVK_ASYNC=1` was **removed in DXVK 2.3+** and is completely obsolete. Do not use it.

```bash
# Recommended standard launch options:
PROTON_ENABLE_NVAPI=1 gamemoderun MANGOHUD=1 %command%

# For framerate capping (e.g. 144Hz monitor):
DXVK_FRAME_RATE=144 %command%

# For crash troubleshooting (generates ~/steam-<appid>.log):
PROTON_LOG=1 %command%
```

### B. Optimal MangoHud Config (`~/.config/MangoHud/MangoHud.conf`)
```ini
legacy_layout=false
fps
frametime
gpu_stats
gpu_temp
gpu_power
cpu_stats
cpu_temp
ram
vram
fps_limit_method=late
position=top-left
font_size=22
background_alpha=0.4
```

### C. Liquid Cooling & Fan Control
```bash
# Check liquidctl AIO cooler status
sudo liquidctl status

# Launch CoolerControl GUI for real-time fan curves
coolercontrol-ui &
```

---

## 6. IPTV, Internet Radio & Media Suite

### The 5 Radio Apps Breakdown:
1. **Shortwave (`de.haeckerfelix.Shortwave`):** 50,000+ worldwide stations with automated song ID.
2. **Tuner (`io.github.tuner_labs.tuner`):** Shuffle mode for random, obscure global radio discovery.
3. **Strawberry (`org.strawberrymusicplayer.strawberry`):** High-res FLAC library + bit-perfect audio output.
4. **MusicPod (`org.feichtmeier.Musicpod`):** Combined Radio, TV, Music, and Podcasts.
5. **Goodvibes (`io.gitlab.Goodvibes`):** 569 KB ultra-lightweight system tray radio.

### IPTV & Live Video Stack:
- **Hypnotix (`io.github.hypnotix`):** Dedicated live TV and M3U playlist browser.
- **Haruna (`org.kde.haruna`):** Modern KDE libmpv media player with YouTube-DL integration.
- **VLC (`org.videolan.VLC`):** Universal fallback player for M3U8 IPTV network streams.

---

## 7. System Updates, Topgrade & Disaster Recovery

### A. Custom Topgrade Configuration (`~/.config/topgrade.toml`)
```toml
[misc]
disable = ["dnf", "composer", "gem", "cargo", "pip"]
pre_commands = { "Check Btrfs Free Space" = "df -h /var/home" }

[commands]
"Bazzite Native Update" = "ujust update"
"Trim SSD Cache" = "sudo fstrim -v /"

[flatpak]
use_sudo = false

[distrobox]
use_all = true

[containers]
runtime = "podman"
```

### B. Atomic OS Rollback (Instant Disaster Fix)
If a future kernel or driver update ever causes an issue:
```bash
# Check available deployments
rpm-ostree status

# Roll back to the previous boot deployment //dawa
rpm-ostree rollback && systemctl reboot
```

### C. Shader Cache Reset (Fixes Game Stutters After Driver Updates)
```bash
rm -rf ~/.local/share/Steam/steamapps/shadercache/*
rm -rf ~/.nv/GLCache/* ~/.cache/nvidia/*
```

---

## 8. Pre-Flight Health Audit & Auto-Repair Routine

Save and run this script whenever you want to test and heal the entire system:

```bash
#!/usr/bin/env bash
# ~/bazzite_preflight_repair.sh
set -Eeuo pipefail
echo "🔍 Running VVgBazz Deep Diagnostics & Auto-Repair..."

# 1. Repair Flatpaks
flatpak repair --system
flatpak uninstall --unused -y

# 2. Clear stale cache
rm -rf ~/.nv/GLCache/* ~/.cache/nvidia/* ~/.cache/thumbnails/* /var/tmp/* 2>/dev/null || true

# 3. Btrfs Scrub
sudo btrfs scrub start -B /var/home || true

# 4. Check Failed Services
systemctl --failed --no-legend

# 5. TRIM SSD
sudo fstrim -v /

echo "✅ System 100% healthy, scrubbed, and optimized!"
```

---

## 9. Desktop Persona Export & Custom ISO Creation

### A. Export Your KDE Plasma Persona (Widgets, Fonts, Colors)
```bash
# 1. Install Konsave
pip install --user konsave

# 2. Export full KDE environment
konsave -s VVgBazz_Gaming_KDE
konsave -e VVgBazz_Gaming_KDE
# Saved at: ~/.config/konsave/profiles/VVgBazz_Gaming_KDE.knsv

# 3. Export custom configuration files
mkdir -p ~/bazzite_persona_export
tar -czvf ~/bazzite_persona_export/dawa_configs.tar.gz \
    ~/.config/MangoHud/ ~/.config/plasma* ~/.config/coolercontrol/ ~/.config/topgrade.toml ~/.local/share/fonts/
```

### B. Bootable ISO Generation (Universal Blue Method)
```bash
mkdir -p ~/bazzite_iso_build
podman run --rm --privileged \
    -v ~/bazzite_iso_build:/build-container-installer/build \
    ghcr.io/jasonn3/build-container-installer:latest \
    IMAGE_NAME="bazzite-dx-nvidia" \
    IMAGE_TAG="stable" \
    VARIANT="KDE" \
    VERSION="44"
```
Flash the generated `.iso` to USB using **Fedora Media Writer** (`flatpak run org.fedoraproject.MediaWriter`).

---

## 10. Fresh Bazzite to Perfection (One-Shot Bootstrap)

To transform any clean Bazzite installation into the exact VVgBazz standard with one command:

```bash
#!/usr/bin/env bash
# fresh_bazzite_bootstrap.sh
set -Eeuo pipefail

# 1. System daemons & swappiness
sudo systemctl enable --now nvidia-persistenced
sudo tuned-adm profile throughput-performance
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf

# 2. Hardware layered packages
sudo rpm-ostree install -y coolercontrol liquidctl mangohud topgrade gh

# 3. Curated Flatpak ecosystem
flatpak install -y flathub \
    com.github.Matoking.protontricks com.vysp3r.ProtonPlus net.lutris.Lutris com.heroicgameslauncher.hgl \
    org.videolan.VLC org.kde.haruna io.github.hypnotix org.strawberrymusicplayer.strawberry com.spotify.Client \
    org.rncbc.qpwgraph com.github.wwmm.easyeffects com.obsproject.Studio dev.zed.Zed com.sublimehq.SublimeText \
    com.github.tchx84.Flatseal io.github.flattool.Warehouse org.fedoraproject.MediaWriter

# 4. Local AI Host Daemon
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable --now ollama

# 5. Distrobox Development Lab
distrobox create -n coding-lab -i fedora:latest -Y
distrobox enter coding-lab -- sudo dnf install -y java-17-openjdk-devel maven shellcheck git jq curl cava

echo "✅ Bootstrap Complete! Reboot system to apply all layers: systemctl reboot"
```
