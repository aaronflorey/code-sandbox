FROM ubuntu:24.04

# 1. System packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential git git-lfs curl wget jq unzip zip sudo gosu \
      python3 python3-pip python3-venv \
      ripgrep fd-find tree sqlite3 shellcheck inotify-tools \
      ca-certificates gnupg2 openssh-client vim-tiny less \
      software-properties-common apt-transport-https \
      # networking & debugging
      dnsutils iputils-ping net-tools netcat-openbsd socat htop \
      # file & text tools
      bat zoxide fzf tmux rsync patch diffutils \
      # archives & compression
      xz-utils zstd p7zip-full \
      # process & system
      procps lsof strace \
      # database clients
      mysql-client postgresql-client redis-tools \
      # misc dev tools
      make cmake pkg-config libssl-dev direnv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Node.js 24 (required for LLM agents)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. mise (runtime manager for optional languages)
RUN curl https://mise.run | sh \
    && mv /root/.local/bin/mise /usr/local/bin/mise

# 4. NPM global tools (LLM agents)
RUN npm install -g \
      @anthropic-ai/claude-code \
      @openai/codex \
      @google/gemini-cli \
      opencode-ai@latest \
      @just-every/code

# 5. Entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
