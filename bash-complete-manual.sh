#!/bin/bash
################################################################################
# COMPLETE BASH MANUAL FOR OLLAMA & GITHUB CLI
# Terminal-First Development: No GUI, Pure CLI Workflows
################################################################################

################################################################################
# PART 1: BASH FUNDAMENTALS FOR CLI DEVELOPERS
################################################################################

echo "=== BASH FUNDAMENTALS ==="

# === VARIABLES ===
# Define variables (no spaces around =)
name="Dawa"
age=25
working_dir=$(pwd)

# Access variables with $
echo "Hello, $name"
echo "You are $age years old"
echo "Current directory: $working_dir"

# Read user input
read -p "Enter your name: " user_name
echo "Welcome, $user_name!"

# === COMMAND SUBSTITUTION ===
# Two ways to run commands and capture output
current_date=$(date +%Y-%m-%d)  # Modern syntax (preferred)
current_date=`date +%Y-%m-%d`   # Old syntax (still works)

# === ARRAYS ===
colors=("red" "green" "blue")
echo "${colors[0]}"              # Access first element
echo "${colors[@]}"              # All elements
echo "${#colors[@]}"             # Array length

# === CONDITIONAL STATEMENTS ===
if [ -z "$name" ]; then
    echo "Name is empty"
elif [ "$age" -gt 18 ]; then
    echo "You are an adult"
else
    echo "You are a minor"
fi

# Test operators:
# [ -z string ]      # True if string is empty
# [ -n string ]      # True if string is NOT empty
# [ $a -eq $b ]      # Numbers: equal
# [ $a -ne $b ]      # Numbers: not equal
# [ $a -lt $b ]      # Numbers: less than
# [ $a -gt $b ]      # Numbers: greater than
# [ -f file ]        # True if file exists
# [ -d dir ]         # True if directory exists

# === LOOPS ===

# FOR loop
for i in {1..5}; do
    echo "Number: $i"
done

# FOR loop over array
for color in "${colors[@]}"; do
    echo "Color: $color"
done

# WHILE loop
counter=1
while [ $counter -le 5 ]; do
    echo "Counter: $counter"
    ((counter++))
done

# === FUNCTIONS ===
greet() {
    echo "Hello, $1!"  # $1 is first argument
}

greet "Dawa"

# Function with return value
add_numbers() {
    local sum=$(($1 + $2))  # local = function-scoped variable
    echo $sum
}

result=$(add_numbers 5 3)
echo "5 + 3 = $result"

################################################################################
# PART 2: WORKING WITH FILES & DIRECTORIES
################################################################################

echo "=== FILE & DIRECTORY OPERATIONS ==="

# === CREATE & NAVIGATE ===
mkdir -p ~/projects/myapp              # -p creates parent dirs
cd ~/projects/myapp
pwd                                     # Print working directory
ls -la                                  # List with details
tree -L 2                               # Tree view (if installed)

# === CREATE FILES ===
touch myfile.txt                        # Create empty file
echo "Hello World" > file.txt           # Write (overwrites)
echo "New line" >> file.txt             # Append
cat > config.txt << 'EOF'               # Heredoc (multi-line)
server=localhost
port=8000
debug=true
EOF

# === READ FILES ===
cat file.txt                            # Print entire file
head -n 5 file.txt                      # First 5 lines
tail -n 5 file.txt                      # Last 5 lines
less file.txt                           # Interactive viewer (press q to exit)
grep "pattern" file.txt                 # Find lines with pattern
wc -l file.txt                          # Count lines

# === EDIT FILES ===
nano file.txt                           # Easy editor
vim file.txt                            # Powerful editor (press :q to exit)
sed 's/old/new/g' file.txt              # Replace text (g = global)
sed -i 's/old/new/g' file.txt           # Replace in-place

# === COPY, MOVE, DELETE ===
cp file.txt backup.txt                  # Copy
cp -r folder/ backup_folder/            # Copy directory
mv file.txt newname.txt                 # Move/rename
mv file.txt ~/documents/                # Move to directory
rm file.txt                             # Delete file
rm -rf folder/                          # Delete directory (CAREFUL!)

# === FILE PERMISSIONS ===
chmod 755 script.sh                     # Make executable (755)
chmod +x script.sh                      # Add execute permission
ls -l                                   # Shows permissions (rwxrwxrwx)
# First 3: owner, next 3: group, last 3: others
# r=4, w=2, x=1 (so 7=rwx, 5=r-x, 0=---)

# === FIND FILES ===
find . -name "*.py"                     # Find all Python files
find . -type f -size +100k              # Find files > 100KB
find . -name "*.txt" -exec cat {} \;    # Find and process

################################################################################
# PART 3: TEXT PROCESSING & SEARCHING
################################################################################

echo "=== TEXT PROCESSING ==="

# === GREP - FIND PATTERNS ===
grep "error" logfile.txt                # Find lines with "error"
grep -n "error" logfile.txt             # Show line numbers (-n)
grep -i "error" logfile.txt             # Case-insensitive (-i)
grep -c "error" logfile.txt             # Count matches (-c)
grep -r "error" .                       # Recursive search (-r)
grep -E "error|warning" log.txt         # Extended regex (OR)

# === SORT & UNIQUE ===
sort file.txt                           # Sort lines
sort -n file.txt                        # Sort numerically
sort -u file.txt                        # Sort + remove duplicates
uniq file.txt                           # Show unique lines (needs sorted input)
uniq -c file.txt                        # Count occurrences

# === AWK - POWERFUL TEXT PROCESSING ===
# awk 'pattern { action }'
awk '{print $1}' file.txt               # Print first column
awk -F: '{print $1}' /etc/passwd        # Use : as field separator
awk '{sum += $1} END {print sum}' nums  # Sum numbers
awk 'NR > 1' file.txt                   # Skip first line

# === CUT - EXTRACT COLUMNS ===
cut -d: -f1 /etc/passwd                 # Get first field (delimiter :)
cut -c1-5 file.txt                      # Get first 5 characters

# === SED - STREAM EDITOR ===
sed 's/old/new/' file.txt               # Replace first match
sed 's/old/new/g' file.txt              # Replace all (g = global)
sed '2d' file.txt                       # Delete line 2
sed '1,3d' file.txt                     # Delete lines 1-3
sed -n '5,10p' file.txt                 # Print lines 5-10

################################################################################
# PART 4: PROCESS MANAGEMENT
################################################################################

echo "=== PROCESS MANAGEMENT ==="

# === RUN COMMANDS ===
command &                               # Run in background
jobs                                    # List background jobs
fg                                      # Bring to foreground
Ctrl+Z                                  # Suspend current job
bg                                      # Resume in background

# === PROCESS INFO ===
ps aux                                  # List all processes
ps aux | grep python                    # Find Python processes
top                                     # Real-time process monitor
htop                                    # Better top (if installed)
kill 1234                               # Kill process by ID
pkill -f "python script"                # Kill by pattern

# === BACKGROUND PROCESSES ===
nohup long_running_script.sh &          # Run after logout (nohup)
screen                                  # Terminal multiplexer
tmux                                    # Better multiplexer

# === CHECKING RUNNING SERVICES ===
systemctl status ollama                 # Check service status
systemctl start ollama                  # Start service
systemctl stop ollama                   # Stop service
systemctl restart ollama                # Restart service
journalctl -u ollama -n 100             # View service logs

################################################################################
# PART 5: GITHUB CLI - COMPLETE GUIDE
################################################################################

echo "=== GITHUB CLI GUIDE ==="

# === AUTHENTICATION ===
gh auth login                           # Login (interactive)
gh auth status                          # Check auth status
gh auth logout                          # Logout

# === REPOSITORY OPERATIONS ===
gh repo create myapp --public           # Create new repo
gh repo clone owner/repo                # Clone repository
gh repo view                            # View repo info
gh repo list                            # List your repos
gh repo set-default owner/repo          # Set default repo

# === ISSUES ===
gh issue list                           # List issues
gh issue list -s open                   # Open issues only
gh issue view 42                        # View issue #42
gh issue create --title "Bug" --body "Description"  # Create issue
gh issue comment 42 --body "Comment"    # Add comment
gh issue close 42                       # Close issue

# === PULL REQUESTS ===
gh pr list                              # List PRs
gh pr view 42                           # View PR #42
gh pr create --title "Feature" --body "Description"  # Create PR
gh pr checkout 42                       # Checkout PR branch
gh pr merge 42                          # Merge PR
gh pr status                            # Status of PRs

# === BRANCHES ===
gh api repos/{owner}/{repo}/branches    # List branches
git branch -a                           # All branches
git branch new-feature                  # Create branch
git checkout new-feature                # Switch branch
git push origin new-feature             # Push branch

# === WORKFLOW/ACTIONS ===
gh workflow list                        # List workflows
gh workflow run workflow-name           # Run workflow
gh workflow view workflow-name          # View workflow details

# === RELEASES ===
gh release list                         # List releases
gh release create v1.0.0 --title "Version 1.0.0"  # Create release
gh release upload v1.0.0 file.zip       # Upload asset

################################################################################
# PART 6: GIT - COMPLETE WORKFLOW
################################################################################

echo "=== GIT WORKFLOW ==="

# === SETUP ===
git config --global user.name "Dawa"
git config --global user.email "dawa@example.com"
git config --list                       # View config

# === BASIC WORKFLOW ===
git init                                # Initialize repo
git add file.txt                        # Stage file
git add .                               # Stage all changes
git commit -m "Add feature"             # Commit changes
git push origin main                    # Push to remote
git pull origin main                    # Pull latest changes
git fetch origin                        # Fetch without merge

# === BRANCHING ===
git branch                              # List branches
git branch -a                           # All branches
git branch feature-x                    # Create branch
git checkout feature-x                  # Switch to branch
git checkout -b feature-x               # Create & switch in one
git merge feature-x                     # Merge into current branch
git branch -d feature-x                 # Delete branch

# === VIEWING HISTORY ===
git log                                 # Show commit history
git log --oneline                       # Short format
git log -n 5                            # Last 5 commits
git log --graph --all --decorate        # Visual tree
git show 1a2b3c                         # Show commit details
git diff                                # Show unstaged changes
git diff --staged                       # Show staged changes

# === UNDOING CHANGES ===
git restore file.txt                    # Discard changes (un-stage)
git restore --staged file.txt           # Un-stage file
git revert 1a2b3c                       # Create reverse commit
git reset --hard 1a2b3c                 # Reset to commit (CAREFUL!)
git clean -fd                           # Remove untracked files

# === STASHING ===
git stash                               # Save changes temporarily
git stash list                          # View stash list
git stash pop                           # Apply latest stash

# === TAGS ===
git tag v1.0.0                          # Create tag
git tag -l                              # List tags
git push origin v1.0.0                  # Push tag
git push origin --tags                  # Push all tags

################################################################################
# PART 7: OLLAMA - LOCAL AI
################################################################################

echo "=== OLLAMA COMPLETE GUIDE ==="

# === INSTALLATION ===
# curl -fsSL https://ollama.ai/install.sh | sh

# === BASIC COMMANDS ===
ollama list                             # List installed models
ollama pull codellama:7b                # Download model
ollama run codellama:7b                 # Run model (interactive)
ollama serve                            # Start server (background)
ollama stop                             # Stop server

# === RUNNING MODELS ===
ollama run codellama:7b "write hello world in python"
ollama run mistral "Explain AI to me"
ollama run neural-chat "What is machine learning?"

# === PIPING INPUT ===
echo "Write a Python script that reads a file" | ollama run codellama:7b

# === API SERVER ===
# Start server: ollama serve (runs on localhost:11434)
curl http://localhost:11434/api/generate -d '{
  "model": "codellama:7b",
  "prompt": "write hello world",
  "stream": false
}'

# === CUSTOM MODELS (Modelfile) ===
cat > Modelfile << 'EOF'
FROM codellama:7b
SYSTEM You are a helpful programming assistant
PARAMETER temperature 0.7
EOF

ollama create mymodel -f Modelfile
ollama run mymodel                      # Use custom model

# === DELETING MODELS ===
ollama rm codellama:7b                  # Delete model to free space
ollama rm -a                            # Delete all models

################################################################################
# PART 8: PRACTICAL WORKFLOWS
################################################################################

echo "=== PRACTICAL WORKFLOWS ==="

# === CLONE, CODE, COMMIT, PUSH (DAILY CYCLE) ===
gh repo clone owner/myapp
cd myapp
git checkout -b feature/new-feature     # Create feature branch
# ... edit files ...
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
gh pr create --title "New Feature" --body "Description"
# Review on GitHub, then merge

# === DEBUG WITH AI ===
# Get error details
error_log=$(python script.py 2>&1)
# Ask AI
echo "$error_log" | ollama run codellama:7b "Why does this error occur?"

# === AUTOMATE WITH BASH ===
cat > deploy.sh << 'EOF'
#!/bin/bash
set -e  # Exit on error

echo "🚀 Deploying..."
git add .
git commit -m "Auto-deploy $(date)"
git push origin main
gh workflow run deploy
echo "✓ Deployed!"
EOF

chmod +x deploy.sh
./deploy.sh

# === MONITOR LOGS ===
tail -f ~/.ollama/logs/server.log       # Watch Ollama logs
journalctl -u ollama -f                 # System logs
git log --oneline -n 10                 # Recent commits

################################################################################
# PART 9: SHORTCUTS & ALIASES
################################################################################

echo "=== PRODUCTIVITY SHORTCUTS ==="

# Add to ~/.bashrc or ~/.zshrc
alias ll='ls -lah'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline -n 10'
alias ai='ollama run codellama:7b'
alias ai-chat='ai-with-memory'

# Function shortcuts
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() { tar -xf "$1"; }
serve() { python -m http.server 8000; }

# Add to ~/.bashrc
# source /path/to/aliases.sh

################################################################################
# PART 10: DEBUGGING & TROUBLESHOOTING
################################################################################

echo "=== DEBUGGING GUIDE ==="

# === BASH DEBUG MODE ===
bash -x script.sh                       # Run with debug output
set -x                                  # Enable debug in script
set +x                                  # Disable debug

# === ERROR HANDLING ===
set -e                                  # Exit on error
set -u                                  # Error on undefined variables
set -o pipefail                         # Catch errors in pipes

#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
# Now script is safer

# === LOGGING ===
exec 2>&1                               # Redirect stderr to stdout
log_file="debug.log"
exec > >(tee "$log_file")
exec 2>&1

# === CHECK COMMAND EXISTS ===
if command -v ollama &> /dev/null; then
    echo "Ollama is installed"
else
    echo "Ollama not found"
fi

################################################################################
# QUICK REFERENCE
################################################################################

echo "=== QUICK COMMAND REFERENCE ==="

# System
uname -a                    # System info
df -h                       # Disk usage
free -h                     # Memory usage
uptime                      # System uptime
whoami                      # Current user
date                        # Current date

# Network
ping google.com             # Test connection
curl https://example.com    # Fetch URL
wget https://example.com    # Download file
netstat -an                 # Network connections
ss -an                      # Socket statistics

# Package Management
apt update && apt upgrade   # Debian/Ubuntu
apt install package         # Install
apt remove package          # Remove
apt search package          # Search

# Compression
tar -czf archive.tar.gz dir/  # Create archive
tar -xzf archive.tar.gz       # Extract archive
zip -r archive.zip dir/       # ZIP archive
unzip archive.zip             # Unzip

echo "✓ All sections completed!"
echo "This manual covers everything you need for terminal development!"
