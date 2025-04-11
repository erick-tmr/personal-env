#!/bin/bash

# Personal Environment Setup Script
# Aimed for Ubuntu Linux platforms

set -e # Exit immediately if a command exits with a non-zero status.
export DEBIAN_FRONTEND=noninteractive # Prevents interactive prompts during apt installs

# --- Configuration ---
TARGET_USER=${SUDO_USER:-$(whoami)} # User for whom user-specific installs are done
TARGET_HOME=$(eval echo ~$TARGET_USER)
ZSHRC_PATH="$TARGET_HOME/.zshrc"
OH_MY_ZSH_DIR="$TARGET_HOME/.oh-my-zsh"

# --- Helper Functions ---
run_as_user() {
    sudo -u $TARGET_USER bash -c "$@"
}

# --- Sanity Checks ---
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root (use sudo)." >&2
  exit 1
fi

if [ -z "$SUDO_USER" ]; then
    echo "ERROR: SUDO_USER environment variable not set." >&2
    echo "This script relies on SUDO_USER to correctly install user-specific tools." >&2
    echo "Please run this script using 'sudo -E ./setup.sh' to preserve the user environment." >&2
    exit 1
fi

echo "Starting personal environment setup for user: $TARGET_USER ..."

# --- System Updates & Core Dependencies ---
echo "Updating package lists and upgrading packages..."
apt-get update
apt-get upgrade -y

echo "Installing core dependencies and utilities..."
apt-get install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    git \
    zsh \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    software-properties-common

# --- Docker ---
echo "Installing Docker..."
# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Adding user $TARGET_USER to the docker group..."
usermod -aG docker $TARGET_USER || echo "Warning: Failed to add user $TARGET_USER to docker group. Group might not exist yet or user might already be in it."
# Docker group might not exist immediately after install, might need daemon restart or relogin.

# --- Zsh & Oh My Zsh ---
echo "Installing Oh My Zsh..."
if [ ! -d "$OH_MY_ZSH_DIR" ]; then
    # Ensure Zsh is installed first
    if ! command -v zsh &> /dev/null; then
        echo "Error: zsh not found. It should have been installed earlier." >&2
        exit 1
    fi
    # Ensure .zshrc exists or Oh My Zsh installer might fail/prompt
    run_as_user "touch $ZSHRC_PATH"
    # Oh My Zsh installer might try to chsh, run it as the target user
    # It will also likely create/overwrite .zshrc
    run_as_user 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
else
    echo "Oh My Zsh already installed."
fi

# --- rbenv (Ruby Version Manager) ---
echo "Installing rbenv and ruby-build..."
if [ ! -d "$TARGET_HOME/.rbenv" ]; then
    # Ensure .zshrc exists before attempting to append
    run_as_user "touch $ZSHRC_PATH"
    run_as_user 'git clone https://github.com/rbenv/rbenv.git ~/.rbenv'
    run_as_user 'echo '\''export PATH="$HOME/.rbenv/bin:$PATH"'\'' >> '"$ZSHRC_PATH"
    run_as_user 'echo '\''eval "$(rbenv init -)"'\'' >> '"$ZSHRC_PATH"

    # Install ruby-build (plugin)
    run_as_user 'git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build'
    run_as_user 'echo '\''export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"'\'' >> '"$ZSHRC_PATH"
else
    echo "rbenv already installed."
fi

# --- pyenv (Python Version Manager) ---
echo "Installing pyenv..."
if [ ! -d "$TARGET_HOME/.pyenv" ]; then
    # Ensure .zshrc exists before attempting to append
    run_as_user "touch $ZSHRC_PATH"
    run_as_user 'curl https://pyenv.run | bash'
    # The installer adds necessary lines to .bashrc, .profile, .zprofile.
    # We need to ensure they are also added to .zshrc for zsh shell.
    run_as_user 'echo '\''export PYENV_ROOT="$HOME/.pyenv"'\'' >> '"$ZSHRC_PATH"
    run_as_user 'echo '\''command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'\'' >> '"$ZSHRC_PATH"
    run_as_user 'echo '\''eval "$(pyenv init -)"'\'' >> '"$ZSHRC_PATH"
else
    echo "pyenv already installed."
fi

# Setting the default shell should happen after zsh is confirmed installed
echo "Setting Zsh as the default shell for $TARGET_USER..."
chsh -s "$(which zsh)" "$TARGET_USER"

echo "-----------------------------------------------------"
echo "Setup complete!"
echo "IMPORTANT:"
echo "- Please log out and log back in for all changes to take effect (especially docker group and default shell)."
echo "- You might need to install specific Ruby versions using 'rbenv install <version>'."
echo "- You might need to install specific Python versions using 'pyenv install <version>'."
echo "- Review $ZSHRC_PATH to customize your Zsh setup."
echo "-----------------------------------------------------"

exit 0 
