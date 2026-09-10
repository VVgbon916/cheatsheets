# 📦 DEPENDENCIES & APPS — Fresh Bazzite to Perfection Blueprint
### Complete Setup Manual from Clean Install to Full VVgBazz System
> Target Base: **Bazzite NVIDIA:stable** (or Bazzite DX NVIDIA) | KDE Plasma Wayland
> Hardware: NVIDIA RTX GPU · Multi-Core CPU · PipeWire · Btrfs SSD

---

## 🎯 What This Guide Accomplishes

Starting from a **brand new, clean installation of Bazzite**, this blueprint installs and configures every dependency, tool, Flatpak, layered package, local AI engine, and desktop tweak required to reach the exact **VVgBazz** standard.

```
Fresh Bazzite Install (Clean)
         │
         ├── 1. Hardware & System Daemons (NVIDIA Persistence, TuneD, Swappiness)
         ├── 2. Essential Layered RPMs (CoolerControl, Liquidctl, MangoHud, Topgrade, GH)
         ├── 3. Curated Flatpaks (Gaming, IPTV, Radio, Media, Dev & Utils)
         ├── 4. Audio Architecture (PipeWire Virtual Sinks + qpwgraph)
         ├── 5. Local AI Engine (Ollama + Qwen 2.5 Coder 7B/14B)
         ├── 6. Distrobox "Coding-Lab" (Java 17/21, Maven, ShellCheck, CLI Tools)
         └── 7. KDE Persona & Desktop Tweaks (Konsave, Breeze Dark, Fonts)
```

---

## ⚡ 1. System Foundation & Daemons

Run these commands on first boot:

```bash
# 1. Enable NVIDIA Persistence Mode daemon (prevents idle-down latency on RTX cards)
sudo systemctl enable --now nvidia-persistenced

# 2. Set CPU & system power governor to throughput performance
sudo tuned-adm profile throughput-performance

# 3. Optimize SSD swappiness for 16GB+ RAM (reduces unnecessary disk thrashing)
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf

# 4. Verify BBR TCP Congestion Control is active
sysctl net.ipv4.tcp_congestion_control
```

---

## 🧩 2. Essential Layered RPMs (`rpm-ostree`)

These system-level packages integrate directly with the kernel and hardware monitoring.

```bash
# Layer only the essential hardware/maintenance tools:
rpm-ostree install \
    coolercontrol \
    liquidctl \
    mangohud \
    topgrade \
    gh

# Reboot to apply system layer
systemctl reboot
```

> [!NOTE]
> If the system uses a USB DisplayLink monitor, add `displaylink` to the install list above.

---

## 📦 3. Complete Flatpak Ecosystem Installation

Run this one-liner to install all gaming, media, IPTV, radio, and utility applications from Flathub:

```bash
# ============================================================
# 🎮 GAMING STACK
# ============================================================
flatpak install -y flathub \
    com.github.Matoking.protontricks \
    com.vysp3r.ProtonPlus \
    net.lutris.Lutris \
    com.heroicgameslauncher.hgl \
    org.freedesktop.Platform.VulkanLayer.MangoHud \
    org.freedesktop.Platform.VulkanLayer.vkBasalt

# ============================================================
# 📺 IPTV & STREAMING
# ============================================================
flatpak install -y flathub \
    org.videolan.VLC \
    org.kde.haruna \
    io.github.hypnotix

# ============================================================
# 📻 INTERNET RADIO & MUSIC
# ============================================================
flatpak install -y flathub \
    org.strawberrymusicplayer.strawberry \
    com.spotify.Client

# ============================================================
# 🔊 AUDIO ROUTING & DSP
# ============================================================
flatpak install -y flathub \
    org.rncbc.qpwgraph \
    com.github.wwmm.easyeffects

# ============================================================
# 🎥 CAPTURE & BROADCASTING
# ============================================================
flatpak install -y flathub \
    com.obsproject.Studio \
    com.obsproject.Studio.Plugin.OBSVkCapture \
    com.obsproject.Studio.Plugin.GStreamerVaapi \
    com.obsproject.Studio.Plugin.Gstreamer

# ============================================================
# 🛠️ EDITORS & SYSTEM UTILITIES
# ============================================================
flatpak install -y flathub \
    dev.zed.Zed \
    com.sublimehq.SublimeText \
    com.github.tchx84.Flatseal \
    io.github.flattool.Warehouse \
    io.podman_desktop.PodmanDesktop \
    org.fedoraproject.MediaWriter \
    org.kde.gwenview \
    org.kde.okular \
    org.kde.kcalc
```

---

## 🔊 4. Audio Routing: PipeWire Virtual Sinks

To route game audio, internet radio, IPTV, and voice chat without interference:

```bash
# 1. Create PipeWire user configuration directory
mkdir -p ~/.config/pipewire/pipewire.conf.d/

# 2. Add persistent virtual sinks (Game, Music, Voice, Browser)
cat << 'EOF' > ~/.config/pipewire/pipewire.conf.d/99-virtual-sinks.conf
context.modules = [
    {   name = libpipewire-module-loopback
        args = {
            node.description = "Game Audio Sink"
            capture.props = { node.name = "game_output" media.class = "Audio/Sink" audio.position = [ FL FR ] }
            playback.props = { node.target = "auto" }
        }
    },
    {   name = libpipewire-module-loopback
        args = {
            node.description = "Music & Radio Sink"
            capture.props = { node.name = "music_output" media.class = "Audio/Sink" audio.position = [ FL FR ] }
            playback.props = { node.target = "auto" }
        }
    },
    {   name = libpipewire-module-loopback
        args = {
            node.description = "Voice Chat Sink"
            capture.props = { node.name = "voice_output" media.class = "Audio/Sink" audio.position = [ FL FR ] }
            playback.props = { node.target = "auto" }
        }
    },
    {   name = libpipewire-module-loopback
        args = {
            node.description = "Browser & Media Sink"
            capture.props = { node.name = "browser_output" media.class = "Audio/Sink" audio.position = [ FL FR ] }
            playback.props = { node.target = "auto" }
        }
    }
]
EOF

# 3. Restart PipeWire to load virtual sinks
systemctl --user restart pipewire pipewire-pulse wireplumber
```

---

## 🧠 5. Free Local AI Engine (Ollama on GPU)

```bash
# 1. Install Ollama host daemon
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable --now ollama

# 2. Pull optimal Qwen 2.5 Coder models for RTX 3060 (12GB VRAM)
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:14b
```

---

## 📦 6. Distrobox "Coding Lab" (Java + Bash Stack)

```bash
# 1. Create Fedora development container
distrobox create -n coding-lab -i fedora:latest

# 2. Provision developer tools inside container
distrobox enter coding-lab -- sudo dnf install -y \
    java-17-openjdk-devel \
    java-21-openjdk-devel \
    maven \
    shellcheck \
    git \
    jq \
    curl \
    ripgrep \
    fzf \
    htop \
    nmap \
    cava

# 3. Export cava visualizer to desktop menu
distrobox enter coding-lab -- distrobox-export --app cava
```

---

## 🎨 7. KDE Plasma Desktop Customization & Widgets

```bash
# 1. Install Konsave (KDE configuration save & restore engine)
pip install --user konsave

# 2. Create custom directories
mkdir -p ~/.config/MangoHud ~/.config ~/.local/share/fonts

# 3. Write default MangoHud gaming config
cat << 'EOF' > ~/.config/MangoHud/MangoHud.conf
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
EOF

# 4. Write Topgrade maintenance configuration
cat << 'EOF' > ~/.config/topgrade.toml
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
EOF
```

---

## 🚀 8. Master Automated "One-Shot" Installer Script

Save this script as `fresh_bazzite_bootstrap.sh` to run the whole setup automatically on any new machine:

```bash
#!/usr/bin/env bash
# ============================================================
# VVgBazz Master System Bootstrap Script
# Transforms fresh Bazzite into the ultimate Gaming & Media rig
# ============================================================
set -Eeuo pipefail

echo "🎮 Starting VVgBazz System Setup..."

# Step 1: System Daemons
echo "==> Configuring system daemons..."
sudo systemctl enable --now nvidia-persistenced 2>/dev/null || true
sudo tuned-adm profile throughput-performance 2>/dev/null || true
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf

# Step 2: Layered Packages
echo "==> Layering hardware packages (rpm-ostree)..."
sudo rpm-ostree install -y coolercontrol liquidctl mangohud topgrade gh

# Step 3: Install Flatpaks
echo "==> Installing curated Flathub suite..."
flatpak install -y flathub \
    com.github.Matoking.protontricks \
    com.vysp3r.ProtonPlus \
    net.lutris.Lutris \
    com.heroicgameslauncher.hgl \
    org.videolan.VLC \
    org.kde.haruna \
    io.github.hypnotix \
    org.strawberrymusicplayer.strawberry \
    com.spotify.Client \
    org.rncbc.qpwgraph \
    com.github.wwmm.easyeffects \
    com.obsproject.Studio \
    dev.zed.Zed \
    com.sublimehq.SublimeText \
    com.github.tchx84.Flatseal \
    io.github.flattool.Warehouse \
    org.fedoraproject.MediaWriter

# Step 4: Ollama Local AI
echo "==> Installing Ollama host AI..."
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable --now ollama

# Step 5: Distrobox Lab
echo "==> Setting up Distrobox coding-lab..."
distrobox create -n coding-lab -i fedora:latest -Y
distrobox enter coding-lab -- sudo dnf install -y \
    java-17-openjdk-devel maven shellcheck git jq curl cava

echo "✅ Setup complete! Please reboot your PC to activate all layers:"
echo "   systemctl reboot"
```

---

## 📋 Complete Tool & Dependency Matrix

| Category | Application / Package | Source | Purpose |
|---|---|---|---|
| **Cooling** | `coolercontrol` | `rpm-ostree` | Fan curve GUI & AIO pump control |
| **Cooling** | `liquidctl` | `rpm-ostree` | Liquid cooler CLI control |
| **Overlay** | `mangohud` | `rpm-ostree` + Flatpak | FPS, VRAM, GPU/CPU thermals HUD |
| **Maintenance** | `topgrade` | `rpm-ostree` | Universal auto-updater tool |
| **GitHub** | `gh` | `rpm-ostree` | Git repository & gist management |
| **Game Manager** | `ProtonPlus` | Flatpak | Install GE-Proton & Wine runners |
| **Wine Helper** | `Protontricks` | Flatpak | Tweak Windows game prefixes |
| **Store** | `Lutris` / `Heroic` | Flatpak | Epic, GOG, and non-Steam launchers |
| **IPTV** | `Hypnotix` / `VLC` | Flatpak | Live television & M3U8 streaming |
| **Internet Radio**| `Strawberry` | Flatpak | Radio streams, FLAC & local audio |
| **Audio Patchbay**| `qpwgraph` | Flatpak | Visual PipeWire node connector |
| **Equalizer** | `EasyEffects` | Flatpak | Microphone noise gating & EQ |
| **Broadcasting** | `OBS Studio` | Flatpak | Stream/screen recording (VkCapture) |
| **Code Editor** | `Zed` / `Sublime` | Flatpak | Fast text editing & AI integration |
| **Local AI** | `Ollama` + `Qwen 2.5`| Host Native | Free unlimited coding AI on RTX 3060 |
| **Dev Container**| `coding-lab` | Distrobox | Java 17/21, Maven & ShellCheck |
| **KDE Backup** | `Konsave` | Python / User | Widget, theme, and font backup |
