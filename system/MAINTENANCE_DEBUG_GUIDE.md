# 🛠️ VVgBazz — Topgrade, Update, Debug & Re-initialization Master Guide
### Dawa's Personal Rig | `VVgbon@VVgBazz` | Bazzite DX NVIDIA 44 · RTX 3060 · i7-6700 · KDE Wayland
> Reference Date: 2026-09-10 | Driver: 610.57.04 | Kernel: 7.2.3-ogc3.1.fc44

---

## 1. ⚙️ Topgrade Configuration (`~/.config/topgrade.toml`)

Since Bazzite is an atomic/immutable operating system with `rpm-ostree`, Flatpaks, Podman containers, and Distroboxes, you need a custom `topgrade.toml` so it updates everything smoothly without choking or running unnecessary system commands.

### Setup Command:
```bash
mkdir -p ~/.config
cat << 'EOF' > ~/.config/topgrade.toml
# Topgrade configuration for Bazzite DX NVIDIA (VVgBazz)

[misc]
# Do not run dnf or package managers directly on host
disable = [
    "dnf",
    "composer",
    "gem",
    "cargo",
    "pip"
]
# Commands to run before upgrades (e.g. check battery, free space)
pre_commands = { "Check Btrfs Free Space" = "df -h /var/home" }

# Steps to run during update
[include]

[commands]
# Keep system atomic and sync containers
"Bazzite Native Update" = "ujust update"
"Trim SSD Cache" = "sudo fstrim -v /"

[flatpak]
# Flatpak updates are handled by ujust, but topgrade can keep them in sync
use_sudo = false

[distrobox]
# Update all distrobox containers automatically (e.g., devbox)
use_all = true

[containers]
# Podman container updates
runtime = "podman"
EOF
```

### Running Topgrade:
```bash
# Run system-wide automated update
topgrade

# Run only specific steps (dry-run mode to test)
topgrade --dry-run
```

---

## 2. 🔄 Master Update Procedures (Bazzite Native)

On Bazzite, **never** run `sudo dnf update`. Use these verified commands:

```bash
# 1. Complete one-shot system update (OS, Flatpaks, Firmware, Containers) //dawa
ujust update

# 2. Update Flatpaks individually
flatpak update -y

# 3. Clean Flatpak unneeded dependencies & runtimes
flatpak uninstall --unused -y

# 4. Check rpm-ostree status before rebooting
rpm-ostree status
```

> [!IMPORTANT]
> If `rpm-ostree status` shows an asterisk (`*`) or a newly prepared deployment after an update, **reboot your PC** before launching high-demand games:
> ```bash
> systemctl reboot
> ```

---

## 3. 🔍 Driver & Hardware Debugging Cheat Sheet

### A. NVIDIA GPU (RTX 3060 12GB)
```bash
# Real-time GPU monitor (refresh every 1s)
nvidia-smi -l 1

# Check clocks, temperature, power draw, and p-state
nvidia-smi --query-gpu=pstate,clocks.sm,clocks.mem,temperature.gpu,power.draw,fan.speed --format=csv

# Verify NVIDIA kernel modules loaded properly
lsmod | grep -i nvidia

# Check for GPU driver crashes or resets in kernel logs
sudo dmesg | grep -iE "nvrm|nvidia|nouveau" | tail -n 30
```

### B. CPU & Thermals (i7-6700 + Liquid Cooling)
```bash
# Check CPU governor and active TuneD profile
tuned-adm active

# Re-engage performance profile if needed
sudo tuned-adm profile throughput-performance

# Liquid cooler & fan status (liquidctl & coolercontrol)
sudo liquidctl status
systemctl status coolercontrol --no-pager
```

### C. Audio Stack (PipeWire & USB DAC)
```bash
# Check PipeWire & WirePlumber services
systemctl --user status pipewire wireplumber --no-pager

# Restart PipeWire audio server without rebooting (fixes missing sound/hangs) //dawa
systemctl --user restart pipewire wireplumber pipewire-pulse

# Verify default output sink is your USB DAC
pactl info | grep "Default Sink"
pactl list sinks short
```

### D. Display & Wayland/Xwayland
```bash
# Check current session type (should output 'wayland')
echo $XDG_SESSION_TYPE

# Check display outputs and refresh rates
xrandr --current

# Inspect KWin compositor errors
journalctl --user -u plasma-kwin_wayland -b 0 | tail -n 40
```

---

## 4. 🚨 Re-initialization & Disaster Recovery (Rollback & Reset)

If a system update breaks a driver, audio, or game launcher, use these non-destructive recovery steps:

### A. Rollback Operating System Deployment
Bazzite keeps your previous known-working deployment intact.
```bash
# View deployment list
rpm-ostree status

# Roll back to the previous boot deployment //dawa
rpm-ostree rollback

# Reboot immediately into the previous working build
systemctl reboot
```

### B. Reset / Clear GPU Shader Cache & DXVK Cache
When games stutter after a driver or Proton update, wiping stale shader caches resolves frame pacing issues:
```bash
# Clear DXVK / VKD3D shader cache for Steam games
rm -rf ~/.local/share/Steam/steamapps/shadercache/*

# Clear NVIDIA GL cache
rm -rf ~/.nv/GLCache/*
rm -rf ~/.cache/nvidia/*
```

### C. Reset Steam Proton Prefixes for a Single Game
If a game refuses to launch:
```bash
# Launch Protontricks or ProtonPlus to repair prefixes
flatpak run com.vysp3r.ProtonPlus

# Alternatively delete the prefix manually (replace <AppID>):
# rm -rf ~/.local/share/Steam/steamapps/compatdata/<AppID>
```

### D. Reset PipeWire Audio Routing Defaults
If audio channels get stuck in virtual sinks (`game_output`, `music_output`) or your USB DAC won't produce sound:
```bash
# Clear WirePlumber device state
rm -rf ~/.local/state/wireplumber/

# Restart PipeWire services
systemctl --user restart pipewire wireplumber pipewire-pulse
```

---

## 5. 📂 Archive & Batch Media Workflow (Downloads & Music)

For multi-part downloaded audio archives (e.g. `muzik_01.zip`, `muzik_02.zip`):

```bash
# 1. Navigate to your Downloads folder
cd ~/Downloads

# 2. Extract and merge all sequential zip parts cleanly //dawa
for f in muzik_*.zip; do unzip -o "$f"; done

# 3. Trim storage cache after large extractions
sudo fstrim -v /
```

---

## 6. 📋 Quick Command Summary

| Action | Command | Note |
|---|---|---|
| **System Update** | `ujust update` | Recommended method |
| **All-in-one Tool Update** | `topgrade` | Uses our custom `topgrade.toml` |
| **OS Rollback** | `rpm-ostree rollback` | Instant disaster recovery |
| **Audio Restart** | `systemctl --user restart pipewire` | Quick sound fix |
| **GPU Status** | `nvidia-smi` | Check power, VRAM & temp |
| **CPU Perf Mode** | `sudo tuned-adm profile throughput-performance` | Verified TuneD command |
| **TRIM SSD** | `sudo fstrim -v /` | Real replacement for fake `trimcache` |
