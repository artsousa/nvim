
#!/usr/bin/env bash
set -e

echo "== Updating system =="
apt update

echo "== Installing neovim requirements =="
apt install -y \
    git \
    curl \
    ripgrep \
    build-essential \
    nodejs \
    npm \
    python3 \
    python3-pip \
    ninja-build \
    gettext \
    cmake 

echo "== Installing Pyright (Python LSP) =="
npm install -g pyright

echo "== Installing Codex =="
apt install bubblewrap
curl -fsSL https://chatgpt.com/codex/install.sh | sh

echo "== Installing Rust (for Yazi) =="
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

echo "== Installing Yazi =="
cargo install --force yazi-build

echo "== Installing Neovim =="
git clone https://github.com/neovim/neovim && cd neovim/
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo && make install
cd ..

curl -LsSf https://astral.sh/uv/install.sh | sh

echo "== Done =="

