# Repository Guidelines

## Project Structure & Module Organization
This repository is intentionally small and script-first.
- `code-sandbox.ab`: source of truth (Amber language) for the launcher.
- `code-sandbox`: compiled Bash output generated from `code-sandbox.ab`.
- `entrypoint.ab`: source of truth (Amber language) for the container entrypoint.
- `entrypoint.sh`: compiled Bash output generated from `entrypoint.ab`.
- `Dockerfile`: base image and global tooling installation.
- `.github/workflows/docker.yml`: CI workflow that builds and pushes the image to GHCR.
- `.githooks/pre-commit`: compiles Amber source before commit when needed.

## Build, Test, and Development Commands
- `./setup-hooks.sh`: enables local git hooks (`core.hooksPath=.githooks`).
- `amber build code-sandbox.ab code-sandbox`: compile launcher source into executable Bash.
- `amber build entrypoint.ab entrypoint.sh`: compile entrypoint source into executable Bash.
- `./code-sandbox --build`: build the Docker image locally from this repo.
- `./code-sandbox --pull`: pull the latest published image.
- `./code-sandbox --shell`: run directly into a shell for manual validation.

No dedicated automated test suite exists yet; validate behavior by running launcher flows (for example: `./code-sandbox --languages go,rust --shell`).

## Coding Style & Naming Conventions
- Shell scripts use `bash` with strict mode (`set -e` or `set -euo pipefail`).
- Use 2-space indentation in shell blocks; keep conditionals and `case` arms compact and readable.
- Prefer lowercase snake_case for shell variables and function names.
- Treat `code-sandbox.ab` and `entrypoint.ab` as canonical; do not hand-edit generated sections in `code-sandbox` or `entrypoint.sh`.

## Testing Guidelines
- For launcher changes, test both interactive and non-interactive modes.
- For container changes, run `./code-sandbox --build` and verify startup from a clean shell.
- If touching Docker/entrypoint logic, include at least one real command/output check in your PR notes.

## Commit & Pull Request Guidelines
Current history uses Conventional Commits (`feat: ...`, `fix: ...`); continue this format.
- Keep commits scoped to one concern.
- If `code-sandbox.ab` changes, ensure `code-sandbox` is regenerated and committed.
- PRs should include: purpose, behavior changes, manual test commands run, and any impact on image build/publish.
- Link related issues when available; include terminal snippets when behavior changes are user-visible.

## Security & Configuration Tips
- Never commit API keys or `.env.sandbox` contents.
- Prefer passing credentials via environment variables at runtime.
- Keep mounts and permissions minimal when modifying Docker/runtime behavior.
