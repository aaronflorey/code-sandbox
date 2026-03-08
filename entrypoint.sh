#!/usr/bin/env bash
set -e

HOST_UID="${HOST_UID:-1000}"
HOST_GID="${HOST_GID:-1000}"
HOME_DIR="/workspace"
PROJECT_DIR="${SANDBOX_PROJECT_DIR:-/workspace}"
export HOME="$HOME_DIR"

# Create group if needed
if ! getent group code >/dev/null 2>&1; then
  groupadd -g "$HOST_GID" code 2>/dev/null || groupadd code
fi

# Create user if needed
if ! id code >/dev/null 2>&1; then
  useradd -m -d "$HOME_DIR" -u "$HOST_UID" -g code -s /bin/bash code 2>/dev/null \
    || useradd -m -d "$HOME_DIR" -g code -s /bin/bash code
fi

mkdir -p "$HOME_DIR" "$PROJECT_DIR"
chown code:code "$HOME_DIR" 2>/dev/null || true

# Passwordless sudo
echo "code ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/code
chmod 0440 /etc/sudoers.d/code

# Safe directory for git
git config --global --add safe.directory "$HOME_DIR" 2>/dev/null || true
git config --global --add safe.directory "$PROJECT_DIR" 2>/dev/null || true

# Fallback git identity if not mounted
if [ ! -f "$HOME_DIR/.gitconfig" ]; then
  gosu code git config --global user.name "code"
  gosu code git config --global user.email "code@sandbox"
fi

# Ensure user-local data dirs exist and are writable by code user
mkdir -p "$HOME_DIR/.local/share/mise" "$HOME_DIR/.local/bin" "$HOME_DIR/.config/mise" "$HOME_DIR/.config/composer"
chown -R code:code "$HOME_DIR/.local" "$HOME_DIR/.config" 2>/dev/null || true

# @just-every/code may download a platform binary into its package dir at runtime.
# Ensure that global package path is writable by the runtime user.
if [ -d "/usr/local/install/global/node_modules/@just-every/code" ]; then
  chown -R code:code "/usr/local/install/global/node_modules/@just-every/code" 2>/dev/null || true
fi

# Set up mise in code user's bashrc
BASHRC="$HOME_DIR/.bashrc"
if ! grep -q 'mise activate' "$BASHRC" 2>/dev/null; then
  # shellcheck disable=SC2016
  echo 'eval "$(mise activate bash)"' >> "$BASHRC"
  chown code:code "$BASHRC"
fi

# Install languages via mise if requested
export PATH="$HOME_DIR/.local/share/mise/shims:$HOME_DIR/.local/bin:/usr/local/bun/bin:${PATH}"

# Some @just-every/code versions expose the CLI as "coder" instead of "code".
# Provide a stable "code" command when only "coder" exists.
if ! command -v code >/dev/null 2>&1 && command -v coder >/dev/null 2>&1; then
  ln -sf "$(command -v coder)" "$HOME_DIR/.local/bin/code"
  chown code:code "$HOME_DIR/.local/bin/code" 2>/dev/null || true
fi

if [ "${SANDBOX_LANGUAGES:-}" = "__mise_toml__" ]; then
  echo "Installing languages from .mise.toml ..."
  cd "$PROJECT_DIR"
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
  curl -sS https://getcomposer.org/installer | gosu code php -- --install-dir="$HOME_DIR/.local/bin" --filename=composer 2>/dev/null || true
fi

# TUI support
export COLORTERM=truecolor
export FORCE_COLOR=1

if [ -d "$PROJECT_DIR" ]; then
  cd "$PROJECT_DIR"
fi

exec gosu code "$@"
