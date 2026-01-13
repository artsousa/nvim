
#!/usr/bin/env bash
set -e

echo "== Updating system =="
sudo apt update

echo "== Installing core tools =="
sudo apt install -y \
  git \
  curl \
  ripgrep \
  build-essential \
  nodejs \
  npm \
  python3 \
  python3-pip

echo "== Installing Neovim =="
sudo apt install -y neovim

echo "== Installing Pyright (Python LSP) =="
npm install -g pyright

echo "== Installing Rust (for Yazi) =="
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

echo "== Installing Yazi =="
cargo install --locked yazi-fm yazi-cli

echo "== Done =="
echo "Restart your terminal, then open Neovim with: nvim"

