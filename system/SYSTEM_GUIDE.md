# 👑 VVgBazz — System Guide (Master System Bible)
### Architecture, Optimization, Gaming & Recovery
> **Owner:** Dawa (`VVgbon@VVgBazz`) | **Base:** Bazzite DX NVIDIA 44 (Fedora 44 Atomic / KDE Wayland)

> [!NOTE]
> Full hardware inventory (exact partition table, installed Flatpak versions,
> USB device IDs) lives in [`SYSTEM_PROFILE.md`](./SYSTEM_PROFILE.md) so it
> isn't duplicated here. This guide covers *how to configure and maintain*
> the system.

---

## 1. Kernel, Driver & Power Optimization

### NVIDIA GPU Clocks & Persistence
```bash
sudo systemctl enable --now nvidia-persistenced

nvidia-smi --query-gpu=pstate,clocks.sm,clocks.mem,temperature.gpu,power.draw,power.limit --format=csv

# KDE Wayland: nvidia-settings doesn't work natively — use Xwayland or a systemd unit
DISPLAY=:0 nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
```

> [!CAUTION]
> **170W is the max rated board power for this PNY RTX 3060.** Never run
> `sudo nvidia-smi -pl 180` or anything above 170W.

### CPU Governor (TuneD)
```bash
sudo tuned-adm profile throughput-performance
tuned-adm active
```

### SSD Swappiness
```bash
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf
```

---

## 2. Immutable OS Architecture: Layered vs Container vs Flatpak

```
  ┌─────────────────────────┬─────────────────────────┬─────────────────────────┐
  │ 1. LAYERED (rpm-ostree)  │ 2. FLATPAK (Flathub)    │ 3. DISTROBOX CONTAINER  │
  ├─────────────────────────┼─────────────────────────┼─────────────────────────┤
  │ ONLY kernel drivers /   │ GUI apps, games,        │ Compilers, CLI tools,   │
  │ hardware daemons.       │ browsers, media, IDEs.  │ SDKs, Java, Maven, etc. │
  │ Needs reboot.           │ No reboot.              │                         │
  └─────────────────────────┴─────────────────────────┴─────────────────────────┘
```

**Verified layered RPMs:**
```bash
rpm-ostree status
# Should show only: coolercontrol liquidctl mangohud topgrade gh
# (add displaylink only if you actually use a DisplayLink monitor)
```

### The Developer Lab

> [!WARNING]
> **`java-17-openjdk-devel` and `java-21-openjdk-devel` do not resolve on
> Fedora 44** (confirmed: your own `dnf install` attempt returned
> `No match for argument` for both). Older versions of this guide told you to
> install them — that was wrong. See
> [`/dev/DEV_LAB_SETUP.md`](../dev/DEV_LAB_SETUP.md) for the verified working
> method (Fedora 44 ships `java-25-openjdk-devel`; Java 21 comes from a
> Temurin tarball).

```bash
distrobox create -n coding-lab -i fedora:latest
distrobox enter coding-lab
sudo dnf install -y maven shellcheck libxml2 ffmpeg-free git jq curl ripgrep fzf htop cava
```

To use a CLI tool like `cava` from the host afterward, see the export fix in
[`/ai/AI_GUIDE.md`](../ai/AI_GUIDE.md#4-the-developer-lab-distrobox) — it needs
`distrobox-export --bin`, not `--app`.

---

## 3. Audio Architecture: PipeWire 4-Sink Matrix

```
 [ Applications ]                    [ Virtual Sinks ]              [ Output ]
  Steam/Lutris        ───────►    game_output      ──┐
  Discord/Voice       ───────►    voice_output     ──┼──►  USB DAC
  Strawberry/Spotify  ───────►    music_output     ──┤
  Firefox/VLC/IPTV    ───────►    browser_output   ──┘
```

`~/.config/pipewire/pipewire.conf.d/99-virtual-sinks.conf`:
```ini
context.modules = [
    { name = libpipewire-module-loopback args = { node.description = "Game Audio Sink" capture.props = { node.name = "game_output" media.class = "Audio/Sink" audio.position = [ FL FR ] } playback.props = { node.target = "auto" } } },
    { name = libpipewire-module-loopback args = { node.description = "Music & Radio Sink" capture.props = { node.name = "music_output" media.class = "Audio/Sink" audio.position = [ FL FR ] } playback.props = { node.target = "auto" } } },
    { name = libpipewire-module-loopback args = { node.description = "Voice Chat Sink" capture.props = { node.name = "voice_output" media.class = "Audio/Sink" audio.position = [ FL FR ] } playback.props = { node.target = "auto" } } },
    { name = libpipewire-module-loopback args = { node.description = "Browser & Media Sink" capture.props = { node.name = "browser_output" media.class = "Audio/Sink" audio.position = [ FL FR ] } playback.props = { node.target = "auto" } } }
]
```

Route visually with `flatpak run org.rncbc.qpwgraph`.

---

## 4. Gaming & Overlay Calibration

See [`/gaming/GAMING_HANDBOOK.md`](../gaming/GAMING_HANDBOOK.md) for the full,
corrected gaming reference (launch options, MangoHud config, GameMode,
liquid cooling, `gh` CLI usage). Quick reference:

```bash
# Standard Steam launch options
PROTON_ENABLE_NVAPI=1 gamemoderun MANGOHUD=1 %command%
```
> [!WARNING]
> `DXVK_ASYNC=1` was removed in DXVK 2.3+. Do not use it.

---

## 5. Media Suite (IPTV & Internet Radio Apps)

| App | ID | Purpose |
|---|---|---|
| Shortwave | `de.haeckerfelix.Shortwave` | 50,000+ radio stations, song ID |
| Tuner | `io.github.tuner_labs.tuner` | Shuffle/discovery mode |
| Strawberry | `org.strawberrymusicplayer.strawberry` | FLAC library, bit-perfect output |
| MusicPod | `org.feichtmeier.Musicpod` | Combined radio/TV/music/podcasts |
| Goodvibes | `io.gitlab.Goodvibes` | Ultra-lightweight tray radio |
| Hypnotix | `io.github.hypnotix` | Live TV / M3U playlists |
| Haruna / VLC | `org.kde.haruna` / `org.videolan.VLC` | General media playback |

---

## 6. Updates, Topgrade & Disaster Recovery

See [`/system/MAINTENANCE_DEBUG_GUIDE.md`](./MAINTENANCE_DEBUG_GUIDE.md) for
topgrade config, driver debugging, and rollback procedures — not duplicated
here.

---

## 7. Desktop Persona Export & Custom ISO

```bash
pip install --user konsave
konsave -s VVgBazz_Gaming_KDE
konsave -e VVgBazz_Gaming_KDE
# Saved at: ~/.config/konsave/profiles/VVgBazz_Gaming_KDE.knsv

mkdir -p ~/bazzite_persona_export
tar -czvf ~/bazzite_persona_export/dawa_configs.tar.gz \
    ~/.config/MangoHud/ ~/.config/plasma* ~/.config/coolercontrol/ ~/.config/topgrade.toml ~/.local/share/fonts/
```

Bootable ISO generation:
```bash
mkdir -p ~/bazzite_iso_build
podman run --rm --privileged \
    -v ~/bazzite_iso_build:/build-container-installer/build \
    ghcr.io/jasonn3/build-container-installer:latest \
    IMAGE_NAME="bazzite-dx-nvidia" IMAGE_TAG="stable" VARIANT="KDE" VERSION="44"
```

---

## 8. Fresh Bazzite → VVgBazz Standard (One-Shot Bootstrap)

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

# 1. System daemons & swappiness
sudo systemctl enable --now nvidia-persistenced
sudo tuned-adm profile throughput-performance
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf

# 2. Layered packages
sudo rpm-ostree install -y coolercontrol liquidctl mangohud topgrade gh

# 3. Curated Flatpaks — see /dev/DEV_LAB_SETUP.md and README.md Quick Start
#    for the full list; omitted here to avoid a 4th copy of the same list.

# 4. Local AI host daemon
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable --now ollama

# 5. Distrobox dev lab — see /dev/DEV_LAB_SETUP.md for the verified
#    (non-broken) package list.
distrobox create -n coding-lab -i fedora:latest -Y

echo "✅ Bootstrap core steps complete. Continue with /dev/DEV_LAB_SETUP.md."
```
