# Developer Lab Setup (Distrobox)

Bazzite + Distrobox, for development tools only.

Note: Ollama no longer runs in Distrobox. It runs in a Podman container
managed by systemd. See ai/AI_GUIDE.md.

## 1. Create The Distrobox Container

    distrobox create -n coding-lab -i fedora:44 -Y
    distrobox enter coding-lab

## 2. Install The Development Stack

    sudo dnf install -y \
        java-25-openjdk-devel \
        maven \
        shellcheck \
        libxml2 \
        ffmpeg-free \
        git \
        jq \
        curl \
        ripgrep \
        fzf \
        htop \
        cava

## 3. Install Java 21 From Temurin

Fedora 44 ships Java 25 (java-25-openjdk-devel). If you need Java 21 LTS
specifically, get it from the Temurin tarball.

    wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
    tar -xzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
    sudo mv jdk-21.0.5+11 /opt/java-21

## 4. Configure Java Switching

Append to ~/.bashrc:

    export JAVA_HOME=/opt/java-21
    export PATH=$JAVA_HOME/bin:$PATH

    alias java21='export JAVA_HOME=/opt/java-21 && export PATH=$JAVA_HOME/bin:$(echo $PATH | sed "s|/opt/java-21/bin:||g; s|/usr/lib/jvm/java-25-openjdk/bin:||g")'
    alias java25='export JAVA_HOME=/usr/lib/jvm/java-25-openjdk && export PATH=$JAVA_HOME/bin:$(echo $PATH | sed "s|/opt/java-21/bin:||g; s|/usr/lib/jvm/java-25-openjdk/bin:||g")'

Switch: type "java21" or "java25" in any terminal.

## 5. GitHub SSH & Clone

    ssh-keygen -t ed25519 -C "<your-email>" -f ~/.ssh/id_ed25519 -N ""
    cat ~/.ssh/id_ed25519.pub
    # Add to https://github.com/settings/keys

    cd ~/projects && gh repo clone VVgbon916/cheatsheets
    cd cheatsheets

## 6. Export CLI Tools To Host

Tools with no .desktop file (like cava) need --bin, not --app:

    distrobox-export --bin /usr/bin/cava

Do NOT use "distrobox-export --app cava" -- it fails because cava has no
.desktop entry.

## 7. Verify The Lab

    ./scripts/avalhla_tools_check.sh

## Boundary Rule

  Distrobox coding-lab   ->   dev tools (Java, Maven, ShellCheck, cava)
  Podman ollama container  ->  Ollama + models
  Host                    ->  everything else

Never mix the two. Ollama stays out of Distrobox. Dev tools stay out of
the Ollama container.

## Signature

    Dawa > AwA < Avalhla.
    (^.-)
