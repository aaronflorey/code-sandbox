#!/usr/bin/env bash
set -e

HOST_UID="${HOST_UID:-1000}"
HOST_GID="${HOST_GID:-1000}"

# Create group if needed
if ! getent group code >/dev/null 2>&1; then
  groupadd -g "$HOST_GID" code 2>/dev/null || groupadd code
fi

# Create user if needed
if ! id code >/dev/null 2>&1; then
  useradd -m -u "$HOST_UID" -g code -s /bin/bash code 2>/dev/null \
    || useradd -m -g code -s /bin/bash code
fi

# Passwordless sudo
echo "code ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/code
chmod 0440 /etc/sudoers.d/code

# Safe directory for git
git config --global --add safe.directory /workspace 2>/dev/null || true

# Fallback git identity if not mounted
if [ ! -f /home/code/.gitconfig ]; then
  gosu code git config --global user.name "code"
  gosu code git config --global user.email "code@sandbox"
fi

# Ensure home ownership
chown -R code:code /home/code 2>/dev/null || true

# Ensure mise data dir exists and is owned by code user
mkdir -p /home/code/.local/share/mise /home/code/.local/bin /home/code/.config/mise
chown -R code:code /home/code/.local

# Set up mise in code user's bashrc
BASHRC="/home/code/.bashrc"
if ! grep -q 'mise activate' "$BASHRC" 2>/dev/null; then
  echo 'eval "$(mise activate bash)"' >> "$BASHRC"
  chown code:code "$BASHRC"
fi

# Install languages via mise if requested
export PATH="/home/code/.local/share/mise/shims:/home/code/.local/bin:${PATH}"

if [ "${SANDBOX_LANGUAGES:-}" = "__mise_toml__" ]; then
  echo "Installing languages from .mise.toml ..."
  cd /workspace
  gosu code mise install -y
  gosu code mise reshim
elif [ -n "${SANDBOX_LANGUAGES:-}" ]; then
  IFS=',' read -ra LANGS <<< "$SANDBOX_LANGUAGES"
  for lang in "${LANGS[@]}"; do
    lang="$(echo "$lang" | xargs)"
    [ -z "$lang" ] && continue
    if [ "$lang" = "all" ]; then
      echo "Installing all languages via mise (php, go, rust, ruby, java, python, zig, erlang, elixir) ..."
      gosu code mise use -g php@latest go@latest rust@latest ruby@latest java@latest python@latest zig@latest erlang@latest elixir@latest
      gosu code mise reshim
      break
    fi
    case "$lang" in
      php|go|rust|ruby|java|python|zig|erlang|elixir)
        echo "Installing $lang via mise ..."
        gosu code mise use -g "${lang}@latest"
        ;;
      *)
        echo "Unknown language: $lang (skipping)"
        ;;
    esac
  done
  gosu code mise reshim
fi

# Install Composer if PHP was installed
if gosu code mise which php >/dev/null 2>&1 && ! command -v composer >/dev/null 2>&1; then
  echo "Installing Composer ..."
  curl -sS https://getcomposer.org/installer | gosu code php -- --install-dir=/home/code/.local/bin --filename=composer 2>/dev/null || true
fi

# TUI support
export COLORTERM=truecolor
export FORCE_COLOR=1

exec gosu code "$@"
