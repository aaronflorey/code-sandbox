# code-sandbox

A single bash script that pulls a Docker container with every major LLM coding agent pre-installed. Language runtimes are installed on demand using [mise](https://mise.jdx.dev/), so you only get what you need.

The image is built via GitHub Actions and hosted on GHCR. You don't need to build anything locally.

## What's in the box

**Agents:**
- [Claude Code](https://github.com/anthropics/claude-code) (Anthropic)
- [Codex](https://github.com/openai/codex) (OpenAI)
- [Gemini CLI](https://github.com/google/gemini-cli) (Google)
- [OpenCode](https://github.com/opencode-ai/opencode)
- [Every Code](https://github.com/just-every/code) (multi-model)
- [GitHub Copilot](https://www.npmjs.com/package/@github/copilot) (GitHub)

**Always available:** Node.js 24, Bun, Python 3, git, gh CLI, ripgrep, fd, fzf, bat, jq, sqlite3, htop, tmux, and the usual dev tools.

**Install on demand via mise:** PHP, Go, Rust, Ruby, Java, Zig, Erlang, Elixir — or anything else mise supports.

## Requirements

- Docker
- Bash

## Quick start

```bash
# Download just the launcher script
curl -fsSL https://raw.githubusercontent.com/aaronflorey/code-sandbox/main/code-sandbox -o /usr/local/bin/code-sandbox
chmod +x /usr/local/bin/code-sandbox

# Go to any project directory
cd ~/projects/my-app

# Run it
code-sandbox
```

On first run it pulls the image from `ghcr.io/aaronflorey/code-sandbox:latest`. After that it's cached locally.

You'll be asked which languages to install:

```
Select languages to install via mise (comma-separated, 'all', or Enter for none):
  php  go  rust  ruby  java  python  zig  erlang  elixir

Languages: go,rust
```

Language installs are cached in a Docker volume, so they're only slow the first time. Then you get the agent menu:

```
Select an agent to launch:
  1) code      - Every Code (multi-model agent)
  2) claude    - Claude Code
  3) codex     - OpenAI Codex
  4) gemini    - Gemini CLI
  5) opencode  - OpenCode
  6) copilot   - GitHub Copilot
  7) shell     - Bash shell
```

Pick one and you're in.

## Usage

```bash
# Interactive (prompts for languages, then agent)
code-sandbox

# Skip the language prompt
code-sandbox --languages go,rust

# Skip everything, just give me a shell
code-sandbox --shell

# Run a specific agent directly
code-sandbox -- claude

# Install all supported languages
code-sandbox --languages all

# No extra languages
code-sandbox --languages ""

# Pull the latest image
code-sandbox --pull

# Build locally from the repo (instead of pulling)
code-sandbox --build

# Force a fresh pull then launch a shell
code-sandbox --pull --shell
```

## Using .mise.toml

If your project has a `.mise.toml` (or `mise.toml`), the language prompt is skipped entirely. mise reads the config and installs whatever it specifies.

```toml
# .mise.toml
[tools]
go = "1.23"
php = "8.4"
```

This is the recommended approach for teams — commit the file and everyone gets the same setup. See the [mise docs](https://mise.jdx.dev/configuration.html) for the full config format.

You can also install more tools at any time from inside the container:

```bash
mise use go@latest
mise use ruby@3.3
```

## API keys

The script forwards API keys from your host environment into the container. Just have them set before you run:

```bash
export ANTHROPIC_API_KEY="sk-..."
export OPENAI_API_KEY="sk-..."
export GEMINI_API_KEY="..."
```

Supported variables:

| Provider | Variables |
|---|---|
| Anthropic | `ANTHROPIC_API_KEY`, `ANTHROPIC_BASE_URL` |
| OpenAI | `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `OPENAI_ORG_ID` |
| Google | `GOOGLE_API_KEY`, `GEMINI_API_KEY`, `GOOGLE_CLOUD_PROJECT` |
| GitHub | `GITHUB_TOKEN`, `GH_TOKEN` |
| AWS | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION` |
| Others | `GROQ_API_KEY`, `MISTRAL_API_KEY`, `DEEPSEEK_API_KEY`, `OPENROUTER_API_KEY` |

You can also put keys in a `.env.sandbox` file in your project directory:

```
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
```

## How it works

Your project directory gets mounted at `/workspace` inside the container. A `code` user is created with your host UID/GID so file permissions stay sane.

Each project directory gets its own named container. Running the script twice from the same folder attaches to the existing container instead of creating a new one.

### What gets mounted

| Host | Container | Mode |
|---|---|---|
| `$PWD` | `/workspace` | read-write |
| `~/.claude` | `/home/code/.claude` | read-write (if exists) |
| `~/.codex` | `/home/code/.codex` | read-write (if exists) |
| `~/.gemini` | `/home/code/.gemini` | read-write (if exists) |
| `~/.opencode` | `/home/code/.opencode` | read-write (if exists) |
| `~/.code` | `/home/code/.code` | read-write (if exists) |
| `~/.ssh` | `/home/code/.ssh` | read-only (if exists) |
| `~/.gitconfig` | `/home/code/.gitconfig` | read-only (if exists) |

### Persistent volumes

These Docker volumes survive container removal:

- `code-sandbox-bun-cache` — bun package cache
- `code-sandbox-mise-data` — all mise-installed runtimes and tools

The mise volume is the important one. It means language installs persist across sessions — you won't have to reinstall Go every time you start a new container.

### Security

The container runs with `--security-opt=no-new-privileges` and `--pids-limit=500`. Default bridge networking. `/tmp` is a 2GB tmpfs. Nothing exotic, but reasonably contained.

## Building locally

If you want to build the image yourself instead of pulling from GHCR:

```bash
# Clone the repo
git clone https://github.com/aaronflorey/code-sandbox.git
cd code-sandbox

# Build and run
./code-sandbox --build
```

The GitHub Action builds and pushes automatically when `Dockerfile` or `entrypoint.sh` changes on `main`. It builds for both `linux/amd64` and `linux/arm64`.

## Development

The launcher script is written in [Amber](https://amber-lang.com/), a language that compiles to Bash. The source is `code-sandbox.ab` and the compiled output is `code-sandbox`.

To set up the development environment:

```bash
# Install Amber
bash <(curl -sL "https://github.com/amber-lang/amber/releases/download/0.5.1-alpha/install.sh")

# Enable the pre-commit hook
./setup-hooks.sh

# Compile manually
amber build code-sandbox.ab code-sandbox
```

A pre-commit hook automatically compiles `code-sandbox.ab` and adds the compiled `code-sandbox` to your commit whenever the source changes.

## Troubleshooting

**First pull is slow** — The image has Node, Bun, all the agents, and system packages. It's a one-time download.

**Language install is slow the first time** — mise is downloading the runtime. Cached in the `code-sandbox-mise-data` volume after that.

**Permission issues on mounted files** — The entrypoint creates a user matching your host UID/GID. If things are still weird, check your Docker user namespace mapping.

**Agent can't find my API key** — Keys are only forwarded if they're set in your shell when you run the script. Run `echo $ANTHROPIC_API_KEY` to verify.

**Want to start fresh?** — `docker volume rm code-sandbox-mise-data` to clear cached runtimes. `docker rmi ghcr.io/aaronflorey/code-sandbox` to clear the image.

## License

MIT
