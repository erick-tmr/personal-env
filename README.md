# Personal Environment Setup Script

This repository contains a bash script (`setup.sh`) designed to automate the setup of a personal development environment on a fresh Ubuntu Linux system.

## Purpose

The script aims to install and configure essential tools commonly used for software development, including:

*   Package manager updates (`apt update && apt upgrade`)
*   Core build dependencies (`build-essential`, etc.)
*   Version Control: `git`
*   Containerization: `docker` (Docker Engine, CLI, Compose)
*   Ruby Development: `rbenv` and `ruby-build` for managing Ruby versions
*   Python Development: `pyenv` for managing Python versions
*   Shell: `zsh` set as the default shell
*   Shell Framework: `Oh My Zsh`

## Prerequisites

*   An Ubuntu-based Linux distribution.
*   Access to a user account with `sudo` privileges.

## How to Run

1.  **Clone the repository or download the script:**
    ```bash
    git clone <repository-url> # Or download setup.sh manually
    cd <repository-directory>
    ```

2.  **Make the script executable:**
    ```bash
    chmod +x setup.sh
    ```

3.  **Run the script with `sudo -E`:**
    It is crucial to use `sudo` for system-wide installations and the `-E` flag to preserve the user environment, ensuring user-specific tools (like `rbenv`, `pyenv`, `oh-my-zsh`) are installed for the correct user.
    ```bash
    sudo -E ./setup.sh
    ```
    You will be prompted for your user password to grant `sudo` permissions.

## Post-Installation Steps

After the script finishes successfully:

1.  **Log Out and Log Back In:** This is necessary for changes like setting `zsh` as the default shell and adding your user to the `docker` group to take full effect.
2.  **Install Specific Language Versions:**
    *   Install desired Ruby versions: `rbenv install <version>` (e.g., `rbenv install 3.2.2`)
    *   Set a global Ruby version: `rbenv global <version>`
    *   Install desired Python versions: `pyenv install <version>` (e.g., `pyenv install 3.11.4`)
    *   Set a global Python version: `pyenv global <version>`
3.  **Customize Zsh:** Review and customize your `~/.zshrc` file further if needed.

## Script Details

*   The script uses `apt-get` for package management.
*   It installs `rbenv` and `pyenv` directly from their GitHub repositories for the user invoking `sudo` (identified by `$SUDO_USER`).
*   It installs Oh My Zsh using its official installer script.
*   It sets `DEBIAN_FRONTEND=noninteractive` to prevent package installation prompts.
*   It exits immediately if any command fails (`set -e`).
*   It requires being run via `sudo` and checks for the `$SUDO_USER` variable (hence the need for `sudo -E`). 
