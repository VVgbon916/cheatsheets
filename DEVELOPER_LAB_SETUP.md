# Developer Lab Setup: Bazzite + Distrobox + Avalhla AI

Complete, verified bash commands for setting up a containerized development environment.

## 1. Create the Distrobox Container

distrobox create -n coding-lab -i fedora:44 -Y
distrobox enter coding-lab

## 2. Install Development Stack

sudo dnf install -y java-25-openjdk-devel maven shellcheck libxml2 ffmpeg-free git jq curl ripgrep fzf htop cava

## 3. Install Java 21 from Temurin

wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
tar -xzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
sudo mv jdk-21.0.5+11 /opt/java-21

## 4. Configure Java Switching

cat >> ~/.bashrc << 'BASHEOF'
export JAVA_HOME=/opt/java-21
export PATH=$JAVA_HOME/bin:$PATH
alias java21='export JAVA_HOME=/opt/java-21 && export PATH=$JAVA_HOME/bin:$(echo $PATH | sed "s|/opt/java-21/bin:||g; s|/usr/lib/jvm/java-25-openjdk/bin:||g")'
alias java25='export JAVA_HOME=/usr/lib/jvm/java-25-openjdk && export PATH=$JAVA_HOME/bin:$(echo $PATH | sed "s|/opt/java-21/bin:||g; s|/usr/lib/jvm/java-25-openjdk/bin:||g")'
BASHEOF

source ~/.bashrc

## 5. Setup GitHub SSH & Clone Repo

ssh-keygen -t ed25519 -C "robitaille916@gmail.com" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
# Add to https://github.com/settings/keys

cd ~/projects && gh repo clone VVgbon916/cheatsheets
cd cheatsheets

## 6. Verify All Tools

./avalhla_tools_check.sh

## 7. Launch Avalhla

./ai-with-memory

---
Status: ✅ COMPLETE & VERIFIED
