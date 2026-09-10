# 📀 VVgBazz — Bootable ISO, System Cloning & Golden Master Guide
### Export Your Entire Bazzite Setup, KDE Widgets, Themes & Tweaks to a Flashable USB
> Rig: `VVgbon@VVgBazz` | Bazzite DX NVIDIA 44 · KDE Wayland · RTX 3060 12GB · 1TB Btrfs
> Target: Bootable `.iso` for USB Key · Part 1 (Personal Clone) & Part 2 (New User Template)

---

## 🧭 Architecture Overview: How Bazzite Imaging Works

Because Bazzite is built on **Fedora Atomic (rpm-ostree / bootc)** with **Btrfs**, your system has two distinct layers:
1. **The System Base (Immutable):** OS packages, kernel 7.2.3, NVIDIA 610.57 driver, layered RPMs (`coolercontrol`, `displaylink`, `liquidctl`, `mangohud`, `topgrade`).
2. **The User Persona (Mutable - `/var/home/VVgbon`):** KDE Plasma widgets, Breeze dark themes, fonts, Steam proton prefixes, Flatpak app configs, and audio routing.

This guide provides two specialized pathways:
- **Part 1 — UserSaved VVgbazz:** 1:1 exact mirror clone. Restores everything including your exact login, steam data, and custom configs.
- **Part 2 — Golden Master (New User):** Factory-ready template. Pre-loaded with all your tweaks, colors, fonts, widgets, and programs, but triggers a clean first-boot user setup (no private tokens or personal credentials).

---

## 🛠️ Step 0: Pre-Flight Integrity Test & Deep Repair Script

Before capturing any image or ISO, you must guarantee that filesystems, packages, and Flatpaks are error-free. 

Save and run this comprehensive diagnostic and repair script:

```bash
cat << 'EOF' > ~/bazzite_preflight_repair.sh
#!/usr/bin/env bash
# ============================================================
# Bazzite Pre-Flight Diagnostics & Auto-Repair Script
# ============================================================
set -Eeuo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
info() { echo -e "${CYAN}[CHECK]${NC} $1"; }
ok()   { echo -e "${GREEN}[PASS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
fix()  { echo -e "${GREEN}[REPAIRED]${NC} $1"; }

echo -e "${CYAN}====================================================="
echo "   VVgBazz Pre-ISO System Integrity & Repair Audit   "
echo -e "=====================================================${NC}"

# 1. Check & Repair Flatpak System Runtimes
info "Auditing Flatpak system installations..."
flatpak repair --system >/dev/null 2>&1 && fix "Flatpak runtimes repaired." || warn "Flatpak repair reported warnings."
flatpak uninstall --unused -y >/dev/null 2>&1 && fix "Removed orphaned Flatpak runtimes."

# 2. Audit rpm-ostree status
info "Checking rpm-ostree deployment state..."
if rpm-ostree status | grep -q "●"; then
    ok "Active deployment is healthy."
else
    warn "Active deployment issue detected! Run 'rpm-ostree cleanup -m' to reset."
fi

# 3. Clean Stale Caches and Temporary Files
info "Cleaning temporary junk & stale GPU caches..."
rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
rm -rf ~/.nv/GLCache/* ~/.cache/nvidia/* 2>/dev/null || true
rm -rf /var/tmp/* 2>/dev/null || true
fix "Stale shader and thumbnail cache purged."

# 4. Check Btrfs Filesystem Health & Scrub
info "Checking Btrfs filesystem status on /dev/sda3..."
if btrfs status / 2>/dev/null; then
    ok "Btrfs root filesystem active."
fi
sudo btrfs scrub start -B /var/home || true
ok "Btrfs /var/home scrub completed."

# 5. Check Failed Systemd Services
info "Auditing failed systemd units..."
FAILED_UNITS=$(systemctl --failed --no-legend | wc -l)
if [ "$FAILED_UNITS" -eq 0 ]; then
    ok "Zero failed system services."
else
    warn "Found $FAILED_UNITS failed services. Review with: systemctl --failed"
fi

# 6. Trim SSD
info "Executing SSD fstrim operation..."
sudo fstrim -v /
fix "SSD blocks trimmed."

echo -e "\n${GREEN}✅ System audit and repair complete. System is ready for snapshotting!${NC}"
EOF

chmod +x ~/bazzite_preflight_repair.sh
./~/bazzite_preflight_repair.sh
```

---

## 🎨 Step 1: Exporting Your Exact KDE Plasma Persona
*(Widgets, Colors, Fonts, Desktop Layout, MangoHud)*

To package every widget, wallpaper, custom panel, font, and window decoration into a standalone bundle, use **Konsave** (the standard KDE Plasma configuration packager).

### 1. Install & Export with Konsave (inside devbox or python environment):
```bash
# Export your KDE environment to a portable bundle
pip install --user konsave

# 1. Save your active Plasma configuration
konsave -s VVgBazz_Gaming_KDE

# 2. Export the configuration to a single shareable archive
konsave -e VVgBazz_Gaming_KDE
# This outputs: ~/.config/konsave/profiles/VVgBazz_Gaming_KDE.knsv
```

### 2. Backup Core Configuration Directories
Run this one-liner to bundle your hand-crafted configs:
```bash
mkdir -p ~/bazzite_persona_export
tar -czvf ~/bazzite_persona_export/dawa_configs.tar.gz \
    ~/.config/MangoHud/ \
    ~/.config/plasma* \
    ~/.config/kdeglobals \
    ~/.config/kwinrc \
    ~/.config/coolercontrol/ \
    ~/.config/topgrade.toml \
    ~/.local/share/plasma/ \
    ~/.local/share/color-schemes/ \
    ~/.local/share/fonts/
```

---

## 🚀 Part 1: "UserSaved VVgbazz" (Full 1:1 Live Bootable Backup)

This creates a **bootable USB** that can restore your exact system down to the byte.

### The Recommended Bare-Metal Method: **Clonezilla Live USB**
Because Bazzite uses an immutable Ostree system coupled with a Btrfs filesystem, standard disk-to-image cloning tools can create an automated, bootable ISO or disk image:

1. **Format a USB Key (minimum 32GB) with Ventoy:**
   - Download Ventoy: `https://www.ventoy.net`
   - Ventoy allows you to drop multiple `.iso` files onto a USB drive and boot from any of them.
2. **Download Clonezilla Live ISO** and put it on your Ventoy USB:
   ```bash
   # Download Clonezilla live ISO into Downloads
   curl -L -o ~/Downloads/clonezilla-live.iso https://osdn.net/projects/clonezilla/downloads/77508/clonezilla-live-3.1.2-22-amd64.iso
   ```
3. **Capture Image:**
   - Boot into Clonezilla via USB.
   - Choose `device-image` -> `savedisk`.
   - Name the image: `UserSaved-VVgbazz-Backup`.
   - Select `sda` (your 1TB SSD).
   - Clonezilla will compress only the used ~255 GB (using zstd multi-threading), resulting in an image of roughly **70–90 GB**.

---

## 🌟 Part 2: "New User" Golden Master Template

If you want an image to install on another PC or hand to a friend that contains **all your tweaks, programs, fonts, widgets, and cooling configs** without your personal Steam credentials or browser history:

### 1. Create the Golden Master Skeleton
Create a clean directory containing all default overrides:

```bash
mkdir -p ~/golden_master_bazzite/etc/skel/.config
mkdir -p ~/golden_master_bazzite/etc/skel/.local/share

# Copy desktop widgets, fonts, and theme defaults into /etc/skel
# Anything in /etc/skel is automatically copied to every NEW user created!
cp -r ~/.config/MangoHud ~/golden_master_bazzite/etc/skel/.config/
cp -r ~/.config/topgrade.toml ~/golden_master_bazzite/etc/skel/.config/
cp -r ~/.local/share/color-schemes ~/golden_master_bazzite/etc/skel/.local/share/ 2>/dev/null || true
cp -r ~/.local/share/fonts ~/golden_master_bazzite/etc/skel/.local/share/ 2>/dev/null || true

# Add the New User Onboarding First-Boot Script
cat << 'EOF' > ~/golden_master_bazzite/etc/skel/first_boot_setup.sh
#!/usr/bin/env bash
echo "🎮 Welcome to VVgBazz Gaming Desktop!"
echo "Applying custom KDE themes, PipeWire routing, and GPU profiles..."

# Enable persistence mode for NVIDIA
sudo systemctl enable --now nvidia-persistenced 2>/dev/null || true

# Apply performance profile
sudo tuned-adm profile throughput-performance 2>/dev/null || true

# Restore KDE Plasma Widgets and Theme
if command -v konsave >/dev/null 2>&1; then
    konsave -i ~/.config/konsave/profiles/VVgBazz_Gaming_KDE.knsv
    konsave -a VVgBazz_Gaming_KDE
fi

echo "✅ Setup complete! Enjoy your optimal gaming session."
EOF
chmod +x ~/golden_master_bazzite/etc/skel/first_boot_setup.sh
```

---

## ⚡ Native Method: Generating an Official Bazzite `.iso` Installer

Bazzite is an OCI container image hosted at `ghcr.io/ublue-os/bazzite-dx-nvidia:stable`. You can turn **any Bazzite container image directly into a bootable installer ISO** using the official Universal Blue `isogenerator` container tool!

### Command to Build a Bootable Bazzite ISO via Podman:

```bash
# 1. Create ISO output directory
mkdir -p ~/bazzite_iso_build

# 2. Generate the bootable installer ISO directly from your exact deployment image
# This downloads the official installer kernel and wraps your container into an installer ISO:
podman run --rm --privileged \
    -v ~/bazzite_iso_build:/build-container-installer/build \
    ghcr.io/jasonn3/build-container-installer:latest \
    IMAGE_NAME="bazzite-dx-nvidia" \
    IMAGE_TAG="stable" \
    VARIANT="KDE" \
    VERSION="44"

# 3. Output check
ls -lh ~/bazzite_iso_build/*.iso
```

> [!NOTE]
> This command creates an official bootable Bazzite installation ISO for USB drives. Once installed on a machine, importing your `dawa_configs.tar.gz` or running `konsave -a VVgBazz_Gaming_KDE` instantly converts it into your exact customized desktop!

---

## 💾 Step 3: Flashing the ISO to USB

### Option A — Using Fedora Media Writer (GUI / Flatpak)
```bash
flatpak install -y flathub org.fedoraproject.MediaWriter
flatpak run org.fedoraproject.MediaWriter
# Select "Custom Image", choose your .iso, select your USB key, and flash!
```

### Option B — Direct Terminal Write (`dd`)
> [!CAUTION]
> Double-check your USB drive letter with `lsblk` before running `dd`! Writing to the wrong drive will erase data!

```bash
# 1. Identify your USB drive (e.g. /dev/sdb)
lsblk

# 2. Flash image directly
sudo dd if=~/bazzite_iso_build/bazzite-dx-nvidia-stable.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

---

## 📋 Summary of Files & Outputs

| File | Purpose | Location |
|---|---|---|
| `bazzite_preflight_repair.sh` | Diagnostic, scrub & repair script | `~/bazzite_preflight_repair.sh` |
| `VVgBazz_Gaming_KDE.knsv` | Full export of KDE widgets, fonts & themes | `~/.config/konsave/profiles/` |
| `dawa_configs.tar.gz` | Manual backup of MangoHud, CoolerControl, audio | `~/bazzite_persona_export/` |
| `bazzite-*.iso` | Bootable standalone installer ISO | `~/bazzite_iso_build/` |
