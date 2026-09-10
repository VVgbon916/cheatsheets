# 🎮 VVgBazz — Bazzite Gaming Handbook
### Dawa's Personal Rig | `VVgbon@VVgBazz` | i7-6700 · RTX 3060 12GB · Bazzite DX NVIDIA 44 · KDE Wayland
> Last reviewed: 2026-09-10 | Driver: 610.57.04 | Kernel: 7.2.3-ogc3.1.fc44

---

> [!IMPORTANT]
> This handbook is corrected and tailored to **your exact system**. Several items in the generic guide were wrong for your setup — errors are called out in each section.
> **Notation:** `//dawa` = command verified & ready to run | `//916` = flagged for AI review

---

## 0-A. Xwayland / Display Debug Tools

These commands help you inspect what's running under Xwayland vs native Wayland on your KDE session.

```bash
# See all monitor modes & resolutions available (works under Xwayland) //dawa
xrandr

# List X11 clients connected via Xwayland
# ⚠️ xlsclients is NOT installed by default — see distrobox method below
xlsclients

# Force specific apps into X11 mode (useful when an app breaks under Wayland)
GDK_BACKEND=x11 someapp        # GTK apps              //dawa
QT_QPA_PLATFORM=xcb someapp    # Qt apps               //dawa
SDL_VIDEODRIVER=x11 somegame   # SDL-based games       //dawa
```

### ✅ How to Use xlsclients Without Bloating Your Image

> [!NOTE]
> Do **not** `rpm-ostree install xorg-x11-utils` — that layers a niche debug package onto your immutable base and slows atomic upgrades. Use distrobox instead (pre-installed on Bazzite):

```bash
# //dawa — Run xlsclients via a disposable Distrobox container
distrobox create -n x11check -i fedora:latest
distrobox enter x11check
sudo dnf install -y xorg-x11-utils
xlsclients
exit
# Delete the box when done (optional)
distrobox rm x11check
```


---

## 0-C. Dev Tools for Bazzite — Verified Equivalents

> [!WARNING]
> **The `brew install` commands in your notes are macOS/Linuxbrew commands.** They are NOT the recommended approach on an immutable OS like Bazzite — use the native methods below.

| Tool | ❌ Homebrew (avoid on Bazzite) | ✅ Bazzite-correct method |
|---|---|---|
| `git-lfs` | `brew install git-lfs` | `distrobox enter devbox` → `sudo dnf install git-lfs` |
| `postgresql` | `brew install postgresql` | `podman run -d postgres` |
| `zsh` | `brew install zsh` | Already on Bazzite ✅ |
| `oh-my-zsh` | curl install script | Same curl script works directly ✅ |
| `tmux` | `brew install tmux` | `distrobox enter devbox` → `sudo dnf install tmux` |
| `node` | `brew install node` | distrobox or `flatpak` |
| `python` | `brew install python` | Already on Bazzite ✅ |
| `wget` / `curl` | `brew install wget` | Already on Bazzite ✅ |
| `nmap` | `brew install nmap` | `distrobox enter devbox` → `sudo dnf install nmap` |
| `fzf` | `brew install fzf` | `distrobox enter devbox` → `sudo dnf install fzf` |
| `ripgrep` | `brew install ripgrep` | `distrobox enter devbox` → `sudo dnf install ripgrep` |
| `htop` | `brew install htop` | `distrobox enter devbox` → `sudo dnf install htop` |
| `docker` | `brew install --cask docker` | **Use Podman** — pre-installed on Bazzite DX ✅ |
| `kubectl` | `brew install kubernetes-cli` | `distrobox enter devbox` → `sudo dnf install kubectl` |

```bash
# ✅ Best practice: one persistent dev distrobox for all CLI tools
distrobox create -n devbox -i fedora:latest
distrobox enter devbox
sudo dnf install -y git-lfs tmux nmap fzf ripgrep htop zsh kubectl
```

---

## 0-D. CLI Command Audit — Corrections

```bash
# ✅ List all PCI devices
lspci

# ✅ List network interfaces and IPs (modern preferred)
ip addr

# ⚠️ DEPRECATED — still works but use 'ip addr' instead
# ifconfig

# ✅ System monitor (run inside distrobox if not on host)
htop

# ✅ Reduce swappiness for SSD (10 = only swap when nearly out of RAM)
sudo sysctl vm.swappiness=10
# ⚠️ TEMPORARY — resets on reboot. To make it permanent:
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf

# ✅ Flatpak commands
flatpak list
flatpak update
flatpak uninstall com.example.App
```

> [!CAUTION]
> **These commands from your notes DO NOT EXIST or are WRONG:**
>
> | ❌ Bad Command | Problem | ✅ Real Alternative |
> |---|---|---|
> | `sudo trimcache` | Not a real command | `sudo fstrim -v /` |
> | `sudo cgset -c cpuGHz 0 Performance` | Completely invalid syntax — not real | `sudo tuned-adm profile throughput-performance` |
> | `sudo dnf install cpufrequtils` | Never use `dnf install` on Bazzite host — breaks immutability | `cpupower` already available; use `tuned-adm` |

```bash
# ✅ CORRECT way to TRIM your SATA SSD (replaces the fake 'trimcache')
sudo fstrim -v /

# ✅ CORRECT way to set CPU to performance (replaces the fake 'cgset' command)
sudo tuned-adm profile throughput-performance
```

---

## 0-E. OS Rebase — Correction

> [!CAUTION]
> **`brh rebase bazzite-dx-nvidia:stable` is NOT a real command.** `brh` does not exist.

```bash
# ✅ CORRECT — Full rebase command to bazzite-dx-nvidia:stable  //dawa
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bazzite-dx-nvidia:stable

# Then reboot to apply
systemctl reboot
```

---

## 0-F. GitHub CLI (`gh`) — Best Commands for Your Setup

> [!NOTE]
> `gh` is currently layered only on your **916 machine**. To use it on your main machine (VVgbon), either layer it or run it from your devbox:
> ```bash
> # Option A — Layer it (simple, single tool, acceptable)
> rpm-ostree install gh && systemctl reboot
>
> # Option B — Use from devbox (no image bloat)
> distrobox enter devbox
> sudo dnf install -y gh
> ```

### 🔐 Step 1 — Authenticate First (required once)

```bash
# //dawa — Login to GitHub (opens browser)
gh auth login

# Verify you're logged in
gh auth status
```

---

### 🤖 Most Useful: Copilot in the Terminal

The `gh copilot` command gives you **AI command suggestions right in your terminal** — perfect for when you forget a command or need help with your Bazzite setup.

```bash
# Ask Copilot to suggest a command (describe what you want to do)
gh copilot suggest "how to check if nvidia persistence mode is on"
gh copilot suggest "trim my btrfs SSD"
gh copilot suggest "list all flatpak apps installed on system"
gh copilot suggest "set cpu to performance mode on fedora"

# Ask Copilot to explain a command you don't understand
gh copilot explain "sudo tuned-adm profile throughput-performance"
gh copilot explain "rpm-ostree rebase ostree-image-signed:docker://..."
gh copilot explain "nvidia-smi --query-gpu=pstate,clocks.sm --format=csv"
```

> [!TIP]
> This is your AI terminal assistant — use `gh copilot suggest` any time you're not sure of a command instead of guessing. It knows Linux, Fedora, and system admin commands well.

---

### 📦 Repo & Config Management

```bash
# Search GitHub for Bazzite configs and community tweaks //dawa
gh search repos bazzite --sort stars
gh search repos "bazzite gaming" --sort stars
gh search repos "kde plasma dotfiles" --sort stars

# Clone a repo you found
gh repo clone username/reponame

# Clone ublue-os community repos (gaming configs, scripts)
gh repo clone ublue-os/bazzite

# View a repo in browser
gh browse ublue-os/bazzite
```

---

### 📋 Backup Your Configs as Gists (cloud clipboard)

Gists are perfect for backing up your config files — MangoHud, DXVK settings, etc.

```bash
# Backup your MangoHud config to a private GitHub Gist //dawa
gh gist create ~/.config/MangoHud/MangoHud.conf --desc "MangoHud config - VVgBazz RTX 3060"

# Backup multiple configs at once
gh gist create ~/.config/MangoHud/MangoHud.conf ~/bazzite_system_snapshot.txt \
  --desc "VVgBazz system configs backup" --public false

# List your gists
gh gist list

# View a gist
gh gist view <gist-id>

# Pull an updated gist back down
gh gist clone <gist-id>
```

---

### 🔍 Search & Browse

```bash
# Search for gaming-related issues on Bazzite GitHub
gh search issues "RTX 3060" --repo ublue-os/bazzite
gh search issues "KDE wayland nvidia" --repo ublue-os/bazzite

# Open Bazzite issues tracker in browser
gh browse --repo ublue-os/bazzite

# Check your notifications (PRs, issues, mentions)
gh status
```

---

### 🔌 Useful Extensions

```bash
# Install a dashboard extension (see all your repos/PRs at once)
gh extension install github/gh-dash
gh dash

# Install copilot extension (if not already available)
gh extension install github/gh-copilot

# List installed extensions
gh extension list
```

---

### 📊 Quick Reference — Most Used `gh` Commands

| Command | What it does |
|---|---|
| `gh auth login` | Authenticate with GitHub |
| `gh copilot suggest "..."` | AI suggests a shell command |
| `gh copilot explain "..."` | AI explains a command |
| `gh search repos bazzite` | Find Bazzite community repos |
| `gh repo clone user/repo` | Clone a GitHub repo |
| `gh gist create file.txt` | Back up a config to GitHub |
| `gh gist list` | See all your saved gists |
| `gh status` | Your GitHub notifications & activity |
| `gh browse` | Open current repo in browser |

---

## 0-G. Desktop Overlay Fix-Up — Script Review & Corrections

Your `bazzite-overlay-fixup.sh` is **well-structured** — good use of colors, `set -e`, and OS detection. However it has **3 significant errors** for your specific setup.

---

### ❌ Problem 1 — `brew install cava` is Wrong for Bazzite

The script tries `brew install cava` as the "recommended" method. As established in section **0-C**, Homebrew is not the right approach on an immutable OS.

> [!CAUTION]
> **`brew install cava` is wrong here.** The correct Bazzite-native approach is **distrobox** (no reboot, no image bloat) or `rpm-ostree install cava` (needs reboot but system-wide).

```bash
# ✅ CORRECT — Install cava via distrobox (best, no reboot) //dawa
distrobox enter devbox
sudo dnf install -y cava
# Then run cava from inside distrobox, or export it:
distrobox-export --app cava

# ✅ OR — Layer it with rpm-ostree (needs reboot, but accessible system-wide)
rpm-ostree install cava
systemctl reboot
```

---

### ❌ Problem 2 — conky Has Broken/Limited Support on KDE Wayland

> [!WARNING]
> **You are on KDE Plasma + Wayland.** Conky was designed for X11 and has **no native Wayland support**. On your setup it can only run through Xwayland, which means:
> - Desktop widget/overlay mode (`own_window_type desktop`) **does not work** on Wayland
> - It may appear as a floating window instead of a proper desktop overlay
> - It can cause flickering or rendering artifacts

**Better alternatives for KDE Wayland desktop overlays:**

| Tool | Wayland Support | Best For |
|---|---|---|
| **KDE Plasma Widgets** | ✅ Native | CPU/GPU/RAM monitors, clocks, system stats |
| **MangoHud** | ✅ Native | In-game FPS/temp/frame time overlay |
| **Waybar** | ✅ Native | Status bar with system info |
| **eww** | ✅ Native | Custom widgets (advanced) |
| **conky** | ⚠️ Xwayland only | Legacy — not recommended on Wayland |

> [!TIP]
> For system monitoring on your desktop, use the **KDE System Monitor widget** (right-click desktop → Add Widgets → System Monitor). It's native Wayland, integrates with Plasma, and shows CPU/GPU/RAM/network — no extra install needed.

---

### ❌ Problem 3 — `sensors` (lm_sensors) May Not Be on Host

The script checks for `sensors` but `lm_sensors` is not always present on the Bazzite host. Install it in distrobox or check with:

```bash
# Check if sensors is available on host
command -v sensors && sensors || echo "not found — use distrobox"

# Install in devbox if needed
distrobox enter devbox
sudo dnf install -y lm_sensors
sudo sensors-detect --auto
sensors
```

---

### ✅ Corrected Script — `bazzite-overlay-fixup.sh`

Save this as the fixed version:

```bash
#!/bin/bash
# ============================================================
# BAZZITE DESKTOP OVERLAY FIX-UP (CORRECTED)
# Rig: Bazzite DX NVIDIA 44 · KDE Plasma Wayland
#      i7-6700 / RTX 3060 12GB / PipeWire
# ============================================================
set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'
RED='\033[0;31m';   CYAN='\033[0;36m'; RESET='\033[0m'

info() { echo -e "${CYAN}==>${RESET} $1"; }
ok()   { echo -e "${GREEN}[OK]${RESET} $1"; }
warn() { echo -e "${YELLOW}[!]${RESET} $1"; }
fail() { echo -e "${RED}[X]${RESET} $1"; }

echo -e "${CYAN}"
echo "  ┌────────────────────────────────────────┐"
echo "  │  BAZZITE OVERLAY FIX-UP - $(date +%Y-%m-%d)      │"
echo "  └────────────────────────────────────────┘"
echo -e "${RESET}"

# 1. Confirm Bazzite
info "Checking OS..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "bazzite" || "$PRETTY_NAME" == *"Bazzite"* ]]; then
        ok "Confirmed Bazzite ($PRETTY_NAME)"
    else
        warn "Not Bazzite (detected: $PRETTY_NAME) — results may vary."
    fi
fi

# 2. Wayland warning for conky
info "Checking desktop session..."
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    warn "You are on WAYLAND — conky desktop overlay mode does NOT work natively."
    warn "Use KDE Plasma Widgets or MangoHud for overlays instead."
    warn "conky will only work via Xwayland as a floating window."
fi

# 3. Install cava the Bazzite-correct way (distrobox, NOT brew)
info "Checking for cava..."
if command -v cava >/dev/null 2>&1; then
    ok "cava found: $(cava --version 2>&1 | head -n1)"
else
    warn "cava not found."
    if distrobox list 2>/dev/null | grep -q devbox; then
        info "Installing cava in devbox (no reboot needed)..."
        distrobox run --name devbox -- sudo dnf install -y cava
        distrobox-export --app cava 2>/dev/null || true
        ok "cava installed in devbox."
    else
        warn "devbox not set up. Falling back to rpm-ostree (REBOOT required)."
        read -p "Layer cava with rpm-ostree now? [y/N] " -n 1 -r; echo
        [[ $REPLY =~ ^[Yy]$ ]] && sudo rpm-ostree install cava && \
            warn "Reboot required: systemctl reboot"
    fi
fi

# 4. Check other dependencies
info "Checking overlay dependencies..."
check_cmd() {
    command -v "$1" >/dev/null 2>&1 && ok "$1 found" || warn "$1 not found"
}
check_cmd flatpak
check_cmd distrobox
check_cmd mangohud    # preferred overlay for gaming on Wayland
check_cmd gamemoded

# conky check with Wayland warning
if command -v conky >/dev/null 2>&1; then
    warn "conky found — but reminder: limited on KDE Wayland (see handbook 0-G)"
else
    info "conky not found — consider KDE Plasma Widgets or MangoHud instead"
fi

# 5. Restart conky only if already running (Xwayland fallback mode)
if pgrep -x conky >/dev/null 2>&1; then
    info "conky running (via Xwayland) — restarting..."
    pkill conky; sleep 1
    (DISPLAY=:0 conky &) >/dev/null 2>&1
    ok "conky restarted on Xwayland display."
fi

echo
ok "Done. Check handbook section 0-G for Wayland overlay alternatives."
```

---

### 📋 Summary of Script Corrections

| # | Original | Problem | Fix |
|---|---|---|---|
| 1 | `brew install cava` | Wrong for Bazzite immutable | `distrobox` → `dnf install cava` |
| 2 | No Wayland check | conky breaks on KDE Wayland | Added `$XDG_SESSION_TYPE` check + warning |
| 3 | `pkill conky && conky &` | No DISPLAY set for Xwayland | Added `DISPLAY=:0` for Xwayland restart |
| 4 | Checks for `conky` as primary | conky not recommended on Wayland | Check MangoHud + KDE widgets instead |

---

## 1. Sanity Checks — Confirm the Base is Healthy

```bash
# What image/build am I on, and is an update pending?
rpm-ostree status

# Full device report (GPU, kernel, driver) — handy for bug reports
ujust device-info

# Kernel + NVIDIA driver version
uname -r
nvidia-smi --query-gpu=driver_version,name,vbios_version --format=csv

# Any kernel errors from last boot (catch GPU resets, OOM kills, etc.)
ujust logs-last-boot
```

> [!TIP]
> Your current image is **44.20260908** (2026-09-08). If `rpm-ostree status` shows a pending deployment, reboot **before** a gaming session — driver/kernel pairs only fully apply after reboot.

---

## 2. NVIDIA Driver & Power State (RTX 3060 Specifics)

### ✅ What's Already Good On Your System
Your `nvidia-smi` output already shows:
- **Persistence Mode: ON** — no action needed right now
- **Temp: 37°C idle** — excellent thermals (your liquid cooling is working)
- **Power: 8W / 170W** — card is correctly idle

### Make Persistence Survive Reboots
Persistence mode is currently ON but **resets on reboot** unless you enable the daemon:

```bash
sudo systemctl enable --now nvidia-persistenced
```

### Check & Force Max Clocks

```bash
# Check current performance state / clocks / temp / power draw
nvidia-smi --query-gpu=pstate,clocks.sm,clocks.mem,temperature.gpu,power.draw,power.limit --format=csv

# See power limit range (min/max/current)
nvidia-smi -q -d POWER | grep -A5 "Power Limit"
```

> [!WARNING]
> **Power limit correction**: Your RTX 3060 (PNY) has a default TDP of **170W** — that IS already the rated max for this chip. The original guide's example of `sudo nvidia-smi -pl 180` would push **10W over your card's rated limit**. Do NOT exceed 170W. Leave the power limit at default.

### Force Max Performance Mode (Wayland-Safe Method)

> [!CAUTION]
> You're on **KDE Wayland**, not X11. `nvidia-settings` does not work natively on Wayland. The only safe method is via the Xwayland display or via environment variable.

**Option A — Via Xwayland (quick, doesn't survive reboot):**
```bash
DISPLAY=:0 nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
```

**Option B — Systemd user service (survives reboots):**
```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/nvidia-perf-mode.service << 'EOF'
[Unit]
Description=Force NVIDIA PowerMizer to max performance
After=graphical-session.target

[Service]
Environment=DISPLAY=:0
ExecStart=/usr/bin/nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=graphical-session.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now nvidia-perf-mode.service
```

`GpuPowerMizerMode` values: `0` = Adaptive, `1` = **Prefer Maximum Performance**, `2` = Auto.

---

## 3. CPU Governor / System Power Profile

> [!NOTE]
> **First — check which backend you actually have** (Bazzite 44 may use either):
> ```bash
> systemctl status tuned 2>/dev/null | head -5
> systemctl status power-profiles-daemon 2>/dev/null | head -5
> ```

### If TuneD is active:
```bash
tuned-adm active                              # see current profile
tuned-adm list                                # list available
sudo tuned-adm profile throughput-performance # max for gaming session
sudo tuned-adm profile balanced               # back to normal after
```

### If power-profiles-daemon is active:
```bash
powerprofilesctl get                  # current profile
powerprofilesctl set performance      # max for gaming
powerprofilesctl set balanced         # back to normal
```

### ✅ Desktop-Specific Note (Your i7-6700)
The original guide warned about **laptop thermal throttling** — **this does not apply to you**. You're on a desktop motherboard (ASUS H110I-PLUS) with liquid cooling. You can safely leave it pinned to `throughput-performance` / `performance` permanently if you want.

> [!TIP]
> Your i7-6700 is a **6th Gen (Skylake, 2015)** chip — 10+ years old. In CPU-heavy games (open-world, RTS, simulations), it may bottleneck before your RTX 3060. Use MangoHud to watch both CPU and GPU usage — if GPU is <80% while CPU is at 100%, that's a CPU bottleneck.

---

## 4. GameMode + MangoHud

### ✅ Correction — GameMode is Already on Bazzite
> [!WARNING]
> The original guide says `rpm-ostree install gamemode` — **do not do this**. GameMode is **already built into the Bazzite base image**. Installing it as a layered package is redundant and wastes an atomic upgrade slot.

```bash
# Confirm it's already present
which gamemoded
gamemoded -s         # check status

# Monitor GameMode engage in real time when a game launches
gamemoded -m

# Force a non-Steam binary to run under GameMode
gamemoderun ./game_binary
```

### MangoHud — ✅ Already Layered on Your System
You already have `mangohud` as a **layered RPM** and the Flatpak VulkanLayer (`org.freedesktop.Platform.VulkanLayer.MangoHud 0.8.4`) installed. Nothing to install.

```bash
# Create/edit your MangoHud config
mkdir -p ~/.config/MangoHud
$EDITOR ~/.config/MangoHud/MangoHud.conf
```

**Recommended config for your RTX 3060 + i7-6700:**
```ini
# ~/.config/MangoHud/MangoHud.conf
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

**Steam launch option to enable overlay per-game:**
```
MANGOHUD=1 %command%
```

---

## 5. Proton / DXVK / VKD3D Tuning (Steam Launch Options)

> [!WARNING]
> **`DXVK_ASYNC=1` is deprecated** and was **removed in DXVK 2.3+**. Modern Proton ships DXVK 2.x which uses a background pipeline compiler instead. Setting `DXVK_ASYNC=1` does **nothing** (at best) or causes issues on newer titles. **Remove it from launch options.**

### ✅ Correct Launch Options for Your RTX 3060

```bash
# Enable DLSS + NVAPI passthrough (RTX features, ray tracing, reflex)
PROTON_ENABLE_NVAPI=1 %command%

# Cap framerate via DXVK (set to your monitor's refresh rate, e.g. 144, 165, 60)
DXVK_FRAME_RATE=144 %command%

# Enable GameMode for the game process
gamemoderun %command%

# Full recommended combo for most games
PROTON_ENABLE_NVAPI=1 gamemoderun MANGOHUD=1 %command%

# If a game crashes, add this to get a log in your home dir
PROTON_LOG=1 %command%
```

### Managing Proton Versions
You have **ProtonPlus** and **Protontricks** already installed via Flatpak — use ProtonPlus GUI to install GE-Proton versions:

```bash
# Launch ProtonPlus (Flatpak)
flatpak run com.vysp3r.ProtonPlus

# Find a game's AppID (for Protontricks)
flatpak run com.github.Matoking.protontricks -s "Game Name"

# Open winecfg for a specific game prefix
flatpak run com.github.Matoking.protontricks <appid> winecfg
```

---

## 6. Storage & Memory

```bash
# zram status — Bazzite enables zram swap by default ✅ already active on your system
zramctl
swapon --show
# You have: zram0 = 7.8G [SWAP] ✅

# Confirm your game drive type (ROTA=0 = SSD, ROTA=1 = HDD)
lsblk -d -o NAME,ROTA,SIZE,MODEL
# Your sda = SATA SSD (not NVMe) — still fast, but NVMe would give faster load times

# Check free space before a big download
df -h /home
# You have: ~695 GB free ✅ plenty of room
```

> [!NOTE]
> You're on a **SATA SSD** (not NVMe). Game load times are slightly slower than NVMe but perfectly fine for gaming. No action needed.

---

## 7. Liquid Cooling — CoolerControl (Your Setup)

You've got `coolercontrol` and `liquidctl` layered — make sure the service is running:

```bash
# Check the coolercontrol daemon status
systemctl status coolercontrol

# Enable it if not running
sudo systemctl enable --now coolercontrol

# Launch the GUI (if you installed coolercontrol-ui)
coolercontrol-ui &

# Check liquidctl devices directly
sudo liquidctl list
sudo liquidctl status
```

> [!TIP]
> Set an aggressive fan curve in CoolerControl before long gaming sessions — your i7-6700 can get warm under sustained load even with liquid cooling.

---

## 8. Network

Bazzite already defaults to BBR TCP congestion control. Verify it's active:

```bash
sysctl net.ipv4.tcp_congestion_control
# Expected: bbr ✅
```

Your setup: **Wired Gigabit Ethernet** (Realtek RTL8111) — ideal for gaming. No WiFi latency issues. ✅

---

## 9. Audio — Virtual Sinks (Already Configured)

Your PipeWire setup already has Bazzite's **per-use-case audio routing** active:

| Sink | Purpose |
|---|---|
| `game_output` | Game audio |
| `voice_output` | Voice chat / mic |
| `browser_output` | Browser audio |
| `music_output` | Music / radio |
| `alsa_output.usb-0ac8_Zgmicro...` | Your USB DAC (default output) |
| `alsa_output.pci-0000_00_1f.3...` | Motherboard audio (backup) |

This is already the optimal setup for gaming + radio + streaming simultaneously. To route apps to specific sinks, use **qpwgraph** or **EasyEffects**:

```bash
# Install qpwgraph (PipeWire routing GUI) as Flatpak
flatpak install flathub org.rncbc.qpwgraph
```

---

## 10. DisplayLink Note (You Have It Layered)

You have `displaylink` layered. On KDE Wayland, DisplayLink monitors have known limitations:

> [!WARNING]
> **DisplayLink on Wayland** can cause screen tearing, refresh rate caps, or instability. If you use a DisplayLink USB monitor and notice gaming issues, try switching to your directly-connected HDMI/DP output for gaming sessions.

---

## 11. Useful `ujust` Commands

```bash
ujust --choose           # interactive TUI menu of every available ujust command
ujust update             # update OS + flatpaks + containers in one shot
ujust clean-system       # clear old podman/flatpak/rpm-ostree cruft (free disk space)
ujust setup-sunshine     # enable game-streaming host (Moonlight/Sunshine)
ujust logs-last-boot     # check for GPU resets, OOM kills, errors
ujust device-info        # full system report for bug reports
```

---

## 12. Pre-Gaming Session Checklist

Run this before a serious session:

```bash
# 1. Check for pending OS updates (reboot if yes, do NOT update mid-session)
rpm-ostree status

# 2. Confirm GPU is healthy
nvidia-smi

# 3. Ensure persistence mode is on
nvidia-smi --query-gpu=persistence_mode --format=csv,noheader

# 4. Set performance power profile
sudo tuned-adm profile throughput-performance
# OR
powerprofilesctl set performance

# 5. Check thermals are good (liquid cooling)
sudo liquidctl status

# 6. Confirm GameMode daemon is running
gamemoded -s

# 7. Check disk space
df -h /home
```

---

## ⚡ Summary of Corrections vs. Original Guide

| # | Original Guide Said | Correction for Your System |
|---|---|---|
| 1 | Enable persistence mode | Already ON — just enable `nvidia-persistenced` to persist it |
| 2 | `sudo nvidia-smi -pl 180` (180W) | ❌ Wrong — your 3060 max is **170W** (don't exceed) |
| 3 | `nvidia-settings` on Wayland | Use `DISPLAY=:0 nvidia-settings` or the systemd unit |
| 4 | `rpm-ostree install gamemode` | ❌ Not needed — GameMode is **pre-installed** on Bazzite |
| 5 | `DXVK_ASYNC=1` | ❌ **Deprecated** in DXVK 2.3+, does nothing on modern Proton |

---

## 13. 🛠️ Maintenance, Topgrade & Debug Guide

For full OS upgrades, Topgrade configuration, driver crash analysis, and disaster recovery / rollback steps, see the dedicated companion guide:
👉 [VVgBazz_Maintenance_Update_Debug_Guide.md](file:///home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/VVgBazz_Maintenance_Update_Debug_Guide.md)

---

## 14. 🧠 Free Local AI CLI Guide (RTX 3060 12GB + Distrobox)

For running private, free, unlimited-token AI models (Qwen 2.5 Coder 7B/14B) on your GPU for Bash and Java 17/21 engineering without modifying the immutable host:
👉 [VVgBazz_Local_AI_CLI_Guide.md](file:///home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/VVgBazz_Local_AI_CLI_Guide.md)

---

## 15. 📀 Bootable ISO Export & System Cloning Guide

For capturing your exact desktop (all widgets, fonts, color schemes, Flatpaks, and settings) into a bootable USB ISO — for both 1:1 Personal Restoration (`UserSaved VVgbazz`) and a clean OEM Golden Master (`New User`):
👉 [VVgBazz_ISO_Export_Cloning_Guide.md](file:///home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/VVgBazz_ISO_Export_Cloning_Guide.md)

---

## 16. 📦 Fresh Bazzite to Perfection Blueprint (Dependencies & Apps)

For rebuilding or provisioning a fresh Bazzite install from scratch up to the exact VVgBazz standard (layered RPMs, Flatpaks, PipeWire routing, Distrobox, Local AI, and KDE persona):
👉 [DEPENDENCIES_APPS_NewUser_Guide.md](file:///home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/DEPENDENCIES_APPS_NewUser_Guide.md)

---

## 17. 📻 Master Radio — Worldwide Music Database & Generator

For the Top 5 Bazzite Radio Apps (Shortwave, Tuner, Strawberry, MusicPod, Goodvibes) and the automated Python engine that builds M3U/XSPF playlists, ASCII tree indexes, and Crossover directories according to the 27 core rules:
👉 [MASTER_RADIO_GUIDE.md](file:///home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/MASTER_RADIO_GUIDE.md)  
👉 Engine Script: [master_radio_builder.py](file:///home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/master_radio_builder.py)

---

## 18. 🛡️ Avalhla — Personal AI CLI Training & Benchmark Suite

For testing your local AI companion (Avalhla) on Ollama with Qwen Coder models (7B/14B) on the Master Radio architecture:
👉 [AVALHLA_AI_TRAINING_PROMPTS.md](file:///home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/AVALHLA_AI_TRAINING_PROMPTS.md)
