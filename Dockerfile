# syntax=docker/dockerfile:1.7
FROM ubuntu:25.10@sha256:4a9232cc47bf99defcc8860ef6222c99773330367fcecbf21ba2edb0b810a31e

# 1. System packages + GitHub CLI
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential git git-lfs curl wget jq unzip zip sudo gosu \
      locales \
      python3 python3-pip python3-venv \
      ripgrep fd-find tree sqlite3 shellcheck inotify-tools \
      ca-certificates gnupg2 openssh-client vim-tiny less \
      software-properties-common apt-transport-https \
      dnsutils iputils-ping net-tools netcat-openbsd socat htop \
      bat zoxide fzf tmux rsync patch diffutils \
      xz-utils zstd p7zip-full \
      procps lsof strace \
      make cmake pkg-config libssl-dev direnv \
      autoconf bison re2c libxml2-dev libsqlite3-dev libcurl4-openssl-dev \
      libonig-dev libzip-dev libreadline-dev libjpeg-dev libpng-dev libwebp-dev \
      libxpm-dev libfreetype6-dev libicu-dev libxslt1-dev libbz2-dev libgmp-dev \
      libtidy-dev libkrb5-dev libpq-dev libldb-dev libldap2-dev libsasl2-dev \
      libffi-dev libyaml-dev libedit-dev libargon2-dev libenchant-2-dev \
      plocate autoconf bison gettext libgd-dev libcurl4-openssl-dev libedit-dev \
      libicu-dev libjpeg-dev libmysqlclient-dev libonig-dev libpng-dev libpq-dev \
      libreadline-dev libsqlite3-dev libssl-dev libxml2-dev libzip-dev \
      re2c zlib1g-dev

RUN sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i 's/^# *en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8

# 2. Node.js 24 (required for LLM agents)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs

# 3. Bun
ENV BUN_INSTALL=/usr/local
RUN curl -fsSL https://bun.sh/install | bash

# 4. mise (runtime manager for optional languages)
ENV MISE_INSTALL_PATH=/usr/local/bin/mise
RUN curl https://mise.run | sh

# 5. Global tools (LLM agents — installed via npm for Node.js compatibility)
RUN bun install -g \
      @anthropic-ai/claude-code \
      @openai/codex \
      @google/gemini-cli \
      opencode-ai@latest \
      @just-every/code \
      @github/copilot \
      && rm -rf /tmp/*

# 6. Install Bin
RUN curl -fsSL https://raw.githubusercontent.com/aaronflorey/bin/master/install.sh | sh \
  && bin install https://github.com/rtk-ai/rtk \
  && bin install https://github.com/jesseduffield/lazygit \ 
  && bin install https://github.com/burntsushi/ripgrep \ 
  && bin install https://github.com/ast-grep/ast-grep

# 7. Entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV HOME=/workspace
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN mkdir -p /workspace
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
