# Developer Lab Setup: Bazzite + Distrobox + Avalhla AI

> [!NOTE]
> This replaces the dev-lab sections previously duplicated (with a broken
> Java package name) across `COMPLET_SYS_GUIDE.md`, `COMPLET_AI_GUIDE.md`,
> `DEPENDENCIES_APPS_NewUser_Guide.md`, and `VVgBazz_Local_AI_CLI_Guide.md`.
> This version is the one confirmed to actually work on your machine.

## 1. Create the Distrobox Container

```bash
distrobox create -n coding-lab -i fedora:44 -Y
distrobox enter coding-lab
```

## 2. Install the Development Stack

> [!WARNING]
> `java-17-openjdk-devel` and `java-21-openjdk-devel` **do not exist** as
> package names on Fedora 44 — confirmed by your own terminal output
> (`No match for argument`). Fedora 44 ships Java under a different package;
> get Java 21 via the Temurin tarball instead (step 3).

```bash
sudo dnf install -y java-25-openjdk-devel maven shellcheck libxml2 ffmpeg-free git jq curl ripgrep fzf htop cava
```

## 3. Install Java 21 from Temurin (verified working)

```bash
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
tar -xzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
sudo mv jdk-21.0.5+11 /opt/java-21
```

## 4. Configure Java Switching

```bash
cat >> ~/.bashrc << 'BASHEOF'
export JAVA_HOME=/opt/java-21
export PATH=$JAVA_HOME/bin:$PATH
alias java21='export JAVA_HOME=/opt/java-21 && export PATH=$JAVA_HOME/bin:$(echo $PATH | sed "s|/opt/java-21/bin:||g; s|/usr/lib/jvm/java-25-openjdk/bin:||g")'
alias java25='export JAVA_HOME=/usr/lib/jvm/java-25-openjdk && export PATH=$JAVA_HOME/bin:$(echo $PATH | sed "s|/opt/java-21/bin:||g; s|/usr/lib/jvm/java-25-openjdk/bin:||g")'
BASHEOF

source ~/.bashrc
```

## 5. GitHub SSH & Clone the Repo

```bash
ssh-keygen -t ed25519 -C "<your-email>" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
# Add to https://github.com/settings/keys

cd ~/projects && gh repo clone VVgbon916/cheatsheets
cd cheatsheets
```

## 6. Verify All Tools

```bash
./scripts/avalhla_tools_check.sh
```

## 7. Export CLI-only Tools to the Host

Tools with no `.desktop` file (like `cava`) need `--bin`, not `--app`:

```bash
distrobox-export --bin /usr/bin/cava
```

## 8. Launch Avalhla

```bash
./scripts/ai-with-memory
```

---
Status: ✅ Verified against actual terminal output — no aspirational/untested commands.
