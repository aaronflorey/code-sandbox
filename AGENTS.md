# Repository Guidelines

## Project Overview
This repository provides a Docker-based sandbox environment for LLM coding agents. The launcher and entrypoint are written in Amber (a language that compiles to Bash), with language runtimes installed on demand via mise.

## Project Structure & Module Organization
This repository is intentionally small and script-first:
- `code-sandbox.ab`: **source of truth** (Amber language) for the launcher script
- `code-sandbox`: compiled Bash output generated from `code-sandbox.ab` (DO NOT edit directly)
- `entrypoint.ab`: **source of truth** (Amber language) for the container entrypoint
- `entrypoint.sh`: compiled Bash output generated from `entrypoint.ab` (DO NOT edit directly)
- `Dockerfile`: base image and global tooling installation
- `.github/workflows/docker.yml`: CI workflow that builds and pushes multi-arch images to GHCR
- `.github/workflows/test.yml`: CI smoke tests for Docker image and mise language installs
- `.githooks/pre-commit`: automatically compiles Amber source before commit when needed
- `setup-hooks.sh`: enables local git hooks (`core.hooksPath=.githooks`)

## Build, Test, and Development Commands

### Setup & Compilation
```bash
# Install Amber (required for development)
bash <(curl -sL "https://github.com/amber-lang/amber/releases/download/0.5.1-alpha/install.sh")

# Enable pre-commit hooks (auto-compiles Amber on commit)
./setup-hooks.sh

# Manually compile launcher
amber build code-sandbox.ab code-sandbox

# Manually compile entrypoint
amber build entrypoint.ab entrypoint.sh
```

### Docker Build & Image Management
```bash
# Build the Docker image locally from this repo
./code-sandbox --build

# Pull the latest published image from GHCR
./code-sandbox --pull

# Force pull latest and launch shell
./code-sandbox --pull --shell
```

### Testing & Validation
No dedicated automated test suite exists locally; CI runs smoke tests via `.github/workflows/test.yml`.

**Manual validation patterns:**
```bash
# Test interactive mode (prompts for language selection, then agent menu)
./code-sandbox

# Test non-interactive mode with specific languages
./code-sandbox --languages go,rust --shell

# Test direct agent launch
./code-sandbox -- opencode

# Test sandbox isolation (in a git repo)
./code-sandbox --shell
# (make changes, exit, verify isolation prompts work)

# Test mise.toml detection
cd project-with-mise-toml && ./code-sandbox --shell
```

**CI smoke tests:**
- Verify agents are installed and executable (`codex`, `claude`, `gemini`, `opencode`)
- Verify all mise languages install correctly (`php`, `go`, `rust`, `ruby`, `java`, `python`, `zig`, `erlang`, `elixir`)
- Compile and run simple programs in each language

## Coding Style & Naming Conventions

### Amber Language Guidelines
- **Imports**: Place all `import` statements at the top of the file
  ```amber
  import { file_exists, dir_exists } from "std/fs"
  import { env_var_get, input_prompt } from "std/env"
  import { trim, split, starts_with, slice } from "std/text"
  ```

- **Variable naming**: Use `snake_case` for variables and function names
  ```amber
  let host_uid = trust $ id -u $
  let sandbox_dir = "/tmp/code-sandbox/{folder}"
  ```

- **Function definitions**: Use `fun` keyword with explicit return types when not `Null`
  ```amber
  fun container_name(): Text { ... }
  fun setup_user(host_uid: Text, host_gid: Text): Null { ... }
  ```

- **Constants**: Use `const` for values that don't change
  ```amber
  const home_dir = "/workspace"
  ```

- **String interpolation**: Use `{variable}` inside strings
  ```amber
  echo "Building {IMAGE_NAME} locally ..."
  ```

- **Shell command execution**:
  - `$ command $` - execute and continue
  - `$ command $?` - execute and propagate exit code
  - `trust $ command $` - trust command output (suppress warnings)
  - `silent $ command $` - suppress all output
  - `$ command $ failed { ... }` - error handling block
  ```amber
  $ docker pull "{IMAGE_NAME}" $?
  silent $ grep -q "mise activate" "{bashrc}" $ failed {
      has_mise = false
  }
  ```

- **Control flow**:
  - Use `if { ... } else { ... }` blocks (not parentheses)
  - Use `loop { ... break }` instead of `while true`
  - Use multi-condition `if` blocks with pattern matching:
  ```amber
  if {
      choice == "A" { ... }
      choice == "B" { ... }
      else { ... }
  }
  ```

- **Indentation**: 4 spaces (Amber standard)

- **Error handling**: Use `failed { ... }` blocks instead of try-catch
  ```amber
  let val = env_var_get(var) failed {
      continue
  }
  ```

### Generated Bash Guidelines
- **DO NOT EDIT** `code-sandbox` or `entrypoint.sh` directly
- These files are generated from `.ab` sources and will be overwritten
- Pre-commit hook automatically regenerates them when `.ab` files change
- Use strict mode: `set -euo pipefail` (automatically added by Amber)

### Shell Script Conventions (for any additional bash scripts)
- Use 2-space indentation
- Strict mode: `set -euo pipefail` at the top
- Lowercase `snake_case` for variables and function names
- Quote all variable expansions: `"${variable}"`
- Keep conditionals and `case` arms compact and readable

### Dockerfile Guidelines
- Group `RUN` commands to minimize layers
- Use `--no-install-recommends` with `apt-get install`
- Clean up package lists: `&& apt-get clean && rm -rf /var/lib/apt/lists/*`
- Place `COPY` commands late to maximize cache hits
- Document each numbered section with comments

## Testing Guidelines

### Before Committing
- **Launcher changes**: Test both interactive and non-interactive modes
- **Entrypoint changes**: Run `./code-sandbox --build` and verify startup from a clean shell
- **Docker/entrypoint changes**: Include at least one real command/output check in your commit message

### Test Coverage Areas
- Interactive language selection prompt
- Non-interactive `--languages` flag
- Mise.toml detection and auto-install
- Direct agent launch via `-- agent-name`
- Sandbox isolation (git clone, rsync, exit menu)
- Volume mounts (config dirs, SSH keys, gitconfig)
- Environment variable forwarding
- `.env.sandbox` file parsing

### CI Validation
CI automatically runs smoke tests on:
- PRs and pushes to `main`
- Changes to `Dockerfile`, `entrypoint.sh`, `code-sandbox`, or workflow files
- Tests: Docker build, agent presence, mise language installs, basic compilation

## Commit & Pull Request Guidelines

### Commit Message Format
Use Conventional Commits format:
- `feat: add support for X` - new features
- `fix: correct Y behavior` - bug fixes
- `docs: update README` - documentation
- `test: add smoke test for Z` - tests
- `refactor: simplify function X` - code refactoring
- `chore: update dependencies` - maintenance

Examples from history:
```
feat: move sandbox isolation to host-side launcher
fix: silence groupadd/useradd warnings from macOS host UIDs/GIDs
feat: convert entrypoint.sh to Amber
```

### Commit Guidelines
- Keep commits scoped to **one concern**
- If `code-sandbox.ab` changes, ensure `code-sandbox` is regenerated and committed
- If `entrypoint.ab` changes, ensure `entrypoint.sh` is regenerated and committed
- Pre-commit hook handles this automatically if `./setup-hooks.sh` was run

### Pull Request Guidelines
PRs should include:
1. **Purpose**: What problem does this solve?
2. **Behavior changes**: What changes for the user?
3. **Manual test commands**: What did you run to verify this works?
4. **Impact on image**: Does this change the Docker image build/size/publish?
5. **Linked issues**: Reference related issues when available
6. **Terminal snippets**: Include actual output when behavior changes are user-visible

## Error Handling & Edge Cases

### Amber Error Handling
- Use `failed { ... }` blocks for error handling
- Use `trust` for commands with expected non-zero exits
- Use `silent` to suppress output when checking command success
- Propagate exit codes with `$?` when appropriate

### Common Edge Cases to Handle
- Missing Docker image (auto-pull)
- Container already running (attach instead of create)
- Missing `.mise.toml` (prompt for languages)
- Git repo vs non-git directory (sandbox isolation logic)
- Host UID/GID conflicts (entrypoint handles with gosu)
- Missing Amber compiler (pre-commit hook error message)

## Security & Configuration

### Security Constraints
- Container runs with `--security-opt=no-new-privileges`
- `--pids-limit=500` to prevent fork bombs
- `/tmp` is a 2GB tmpfs
- Default bridge networking (no host networking)
- SSH keys and gitconfig mounted read-only

### Secrets Management
- **NEVER** commit API keys or `.env.sandbox` contents
- Add sensitive patterns to `.gitignore` if needed
- Prefer passing credentials via environment variables at runtime
- Supported env vars: `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GITHUB_TOKEN`, etc.

### Permissions & Mounts
- Keep mounts and permissions minimal when modifying Docker/runtime behavior
- User namespace mapping: entrypoint creates `code` user matching host UID/GID
- Workspace mounted at `/workspace` with read-write access
- Config dirs mounted conditionally (only if they exist on host)

## Common Pitfalls & Best Practices

### When Working with Amber
- Don't forget to compile after changes (or rely on pre-commit hook)
- Use `trust` for commands that legitimately produce warnings
- Remember Amber uses 0-based array indexing
- Main function receives args including script path at `args[0]`

### When Working with Docker
- Test with both pulled and locally-built images
- Remember the image supports both `linux/amd64` and `linux/arm64`
- Check that new dependencies don't significantly increase image size
- Verify new tools work on both architectures

### When Adding Features
- Consider impact on existing workflows (interactive vs non-interactive)
- Update help text if adding new flags
- Test with and without `.mise.toml` present
- Verify sandbox isolation still works correctly
