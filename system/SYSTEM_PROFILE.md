# 🎮 VVgBazz — Bazzite Gaming Desktop Profile
> Generated: Thu Sep 10, 2026 | Last Updated: 2026-09-10

---

## 🖥️ Operating System

| Field | Value |
|---|---|
| **Distro** | Bazzite DX NVIDIA (ublue-os) |
| **Image** | `ghcr.io/ublue-os/bazzite-dx-nvidia:stable` |
| **Version** | 44.20260908 (2026-09-08) |
| **Base** | Fedora 44 / rpm-ostree (immutable) |
| **Kernel** | Linux 7.2.3-ogc3.1.fc44.x86_64 (OGC custom kernel) |
| **Desktop** | KDE Plasma on **Wayland** |
| **Display Server** | kwin_wayland + Xwayland |

> [!NOTE]
> This is the **DX** (Developer Experience) variant of Bazzite — includes extra dev tools on top of the gaming base.

---

## ⚙️ CPU

| Field | Value |
|---|---|
| **Model** | Intel Core i7-6700 (Skylake, 6th Gen) |
| **Cores / Threads** | 4 cores / 8 threads |
| **Base Clock** | 3.40 GHz |
| **Boost Clock** | 4.00 GHz |
| **Cache L3** | 8 MiB |
| **Virtualization** | VT-x enabled |
| **Architecture** | x86_64 |

---

## 🎮 GPU

| Field | Value |
|---|---|
| **Model** | **NVIDIA GeForce RTX 3060** (GA104) |
| **Brand** | PNY |
| **VRAM** | 12 GB |
| **Driver** | 610.57.04 |
| **CUDA Version** | 13.3 |
| **Persistence Mode** | On |
| **Current Temp** | 37°C (Idle) |
| **Power Draw** | 8W / 170W |
| **Kernel Driver** | `nvidia` (nvidia_drm active) |

---

## 💾 RAM & Swap

| Field | Value |
|---|---|
| **Total RAM** | 16 GB |
| **Used (idle)** | ~4.5 GB |
| **Available** | ~11 GB |
| **Swap** | 7.8 GB (zram) |

---

## 💿 Storage

| Device | Size | Filesystem | Mount |
|---|---|---|---|
| `sda` (1TB SATA SSD) | 953.9 GB | — | — |
| `sda1` | 600 MB | vfat | `/boot/efi` |
| `sda2` | 2 GB | ext4 | `/boot` |
| `sda3` | 951.3 GB | **btrfs** | `/`, `/var`, `/home` |
| `zram0` | 7.8 GB | swap | `[SWAP]` |

**Disk Usage:** 255 GB used / 695 GB free (27%)

---

## 🔊 Audio

| Field | Value |
|---|---|
| **Audio Server** | **PipeWire 1.6.8** (PulseAudio compat layer) |
| **Default Output** | USB — Zgmicro AUDIO (USB DAC/headset) |
| **Onboard Audio** | Intel 100/C230 Series HD Audio (via motherboard) |
| **NVIDIA HDMI Audio** | GA104 HD Audio (available) |
| **Virtual Sinks** | `game_output`, `voice_output`, `browser_output`, `music_output` |

> [!TIP]
> Bazzite's audio routing is pre-configured with separate virtual sinks per use-case — great for gaming + streaming setups.

---

## 🌐 Network

| Field | Value |
|---|---|
| **Interface** | `enp3s0` (Realtek RTL8111 Gigabit Ethernet) |
| **Connection** | Wired (Gigabit) |
| **Local IP** | 192.168.1.56 |
| **IPv6** | Yes (dynamic) |

---

## 🎛️ Motherboard

| Field | Value |
|---|---|
| **Brand** | ASUSTeK Computer Inc. |
| **Model** | H110I-PLUS (Mini-ITX) |
| **Chipset** | Intel B150 |

---

## 🧩 Layered RPM Packages (rpm-ostree)

These are packages added ON TOP of the base Bazzite image:

| Package | Purpose |
|---|---|
| `coolercontrol` | Fan/cooling control GUI |
| `displaylink` | USB DisplayLink monitor support |
| `mangohud` | Gaming overlay (FPS, temps, etc.) |
| `topgrade` | System-wide update tool |

> [!NOTE]
> `mangohud` was added in the current deployment only (not in rollback).

---

## 📦 Installed Flatpaks

### 🎮 Gaming
| App | ID | Version |
|---|---|---|
| Steam | *(running via system)* | — |
| Protontricks | `com.github.Matoking.protontricks` | 1.14.1 |
| ProtonPlus | `com.vysp3r.ProtonPlus` | 0.6.7 |

### 🎵 Media & Entertainment
| App | ID | Version |
|---|---|---|
| VLC | `org.videolan.VLC` | 3.0.23 |
| Haruna | `org.kde.haruna` | 1.8.1 |
| Strawberry Music Player | `org.strawberrymusicplayer.strawberry` | 1.2.23 |
| Spotify | `com.spotify.Client` | 1.2.95 |

### 🎥 Streaming / Capture
| App | ID | Version |
|---|---|---|
| OBS Studio | `com.obsproject.Studio` | *(+ plugins)* |
| OBS VkCapture | `com.obsproject.Studio.Plugin.OBSVkCapture` | 1.5.6 |
| GStreamer VA-API | `com.obsproject.Studio.Plugin.GStreamerVaapi` | 0.4.2 |

### 🛠️ Dev / Utilities
| App | ID | Version |
|---|---|---|
| Zed Editor | `dev.zed.Zed` | v1.19.2 |
| Sublime Text | `com.sublimehq.SublimeText` | 4200 |
| Flatseal | `com.github.tchx84.Flatseal` | 2.4.1 |
| Warehouse | `io.github.flattool.Warehouse` | 2.2.0 |
| Podman Desktop | `io.podman_desktop.PodmanDesktop` | 1.29.3 |
| Firefox | `org.mozilla.firefox` | 155.0.1 |

### 🖼️ KDE Apps
| App | ID | Version |
|---|---|---|
| Gwenview | `org.kde.gwenview` | 26.04.3 |
| Okular | `org.kde.okular` | 26.04.3 |
| KCalc | `org.kde.kcalc` | 26.04.3 |

---

## 🎯 Gaming Stack Summary

| Component | Status |
|---|---|
| **GPU Driver** | NVIDIA 610.57.04 ✅ |
| **Wayland** | KWin Wayland ✅ |
| **Xwayland** | Active ✅ |
| **Steam** | Running ✅ |
| **MangoHud** | Installed (layered + Flatpak) ✅ |
| **Protontricks** | Installed ✅ |
| **ProtonPlus** | Installed ✅ |
| **OBS VkCapture** | Installed ✅ |
| **vkBasalt** | Available (Flatpak VulkanLayer) ✅ |
| **Vulkan** | NVIDIA + Mesa fallback ✅ |
| **VAAPI** | Intel + NVIDIA drivers ✅ |

---

## 🖱️ Input Devices (USB)

| Device | ID |
|---|---|
| Microsoft IntelliMouse Explorer 3.0 | `045e:0047` |
| Evision RGB Keyboard | `320f:5055` |
| Zgmicro USB Audio | `0ac8:9628` |

---

## 📌 Goals / Project Notes

- [ ] Perfect gaming session setup (RTX 3060 optimized)
- [ ] IPTV / TV streaming setup
- [ ] Internet Radio
- [ ] User-friendly KDE Desktop
- [ ] Bazzite tweaks & customization
- [ ] Building the best buddies AVA <3

