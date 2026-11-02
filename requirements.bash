
#!/usr/bin/env bash
set -euo pipefail

# Helper function to handle system packages gracefully
install_system_deps() {
    local DEPS="git curl ripgrep build-essential nodejs npm python3 python3-pip ninja-build gettext cmake bubblewrap"
    
    if [ "$(id -u)" -eq 0 ]; then
        # We are root (e.g., in a container), just run apt
        apt update
        apt install -y $DEPS
    elif command -v sudo >/dev/null 2>&1; then
        # Sudo is available, use it
        sudo apt update
        sudo apt install -y $DEPS
    else
        # No root and no sudo available. Warn the user and continue.
        echo "=========================================================================="
        echo "WARNING: 'sudo' is not available. Skipping system package installation."
        echo "Make sure the following dependencies are installed by your administrator:"
        echo "$DEPS"
        echo "=========================================================================="
        sleep 3
    fi
}

echo "== Updating system & Installing requirements =="
install_system_deps

echo "== Installing Pyright (Python LSP) =="
# Configure NPM to install global packages into the user's home directory instead of /usr/lib
NPM_GLOBAL_DIR="$HOME/.npm-global"
mkdir -p "$NPM_GLOBAL_DIR"
npm config set prefix "$NPM_GLOBAL_DIR"
npm install -g pyright

echo "== Installing Codex =="
curl -fsSL https://chatgpt.com/codex/install.sh | sh

echo "== Installing Rust (for Yazi) =="
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "$HOME/.cargo/env"

echo "== Installing Yazi =="
CARGOTMPDIR="$HOME/cargo_build_tmp"
mkdir -p "$CARGOTMPDIR"
TMPDIR="$CARGOTMPDIR" cargo install --locked --force yazi-build
rm -rf "$CARGOTMPDIR"

echo "== Installing Neovim =="
if [ -d "neovim" ]; then
    rm -rf neovim
fi

git clone https://github.com/neovim/neovim && cd neovim/
git checkout stable
# Configure CMake to install Neovim to ~/.local instead of /usr/local
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="$HOME/.local" -j"$(nproc)"
make install
cd ..
rm -rf neovim

echo "== Installing uv =="
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "== Done =="
echo ""
echo "IMPORTANT: Because we installed without sudo, Neovim and Pyright were placed in your home folder."
echo "Please add the following line to the end of your ~/.bashrc or ~/.zshrc file:"
echo 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"'
