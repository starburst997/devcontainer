FROM --platform=$BUILDPLATFORM mcr.microsoft.com/devcontainers/javascript-node:dev-24-bookworm

ARG TZ
ENV TZ="$TZ"

# Install neovim
RUN apt-get update && apt-get install -y neovim && apt-get clean

# Disable Oh My Zsh update prompt
ENV DISABLE_UPDATE_PROMPT=true
ENV DISABLE_AUTO_UPDATE=true

# Install powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k

# Persist bash history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history

RUN echo 'export PROMPT_COMMAND="history -a"' >> /root/.zshrc
RUN echo 'export PROMPT_COMMAND="history -a"' >> /root/.bashrc
RUN echo 'export HISTFILE=/commandhistory/.bash_history' >> /root/.zshrc
RUN echo 'export HISTFILE=/commandhistory/.bash_history' >> /root/.bashrc

# Copy setup script
COPY setup-p10k.sh /tmp/setup-p10k.sh
RUN chmod +x /tmp/setup-p10k.sh

# Configure powerlevel10k
RUN echo 'source /root/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme' >> /root/.zshrc \
    && echo '# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.' >> /root/.zshrc \
    && echo 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then' >> /root/.zshrc \
    && echo '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"' >> /root/.zshrc \
    && echo 'fi' >> /root/.zshrc \
    && echo '' >> /root/.zshrc \
    && echo '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.' >> /root/.zshrc \
    && echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> /root/.zshrc \
    && /tmp/setup-p10k.sh

# Set up common aliases
RUN echo 'alias vim="nvim"' >> /root/.zshrc \
    && echo 'alias vi="nvim"' >> /root/.zshrc \
    && echo 'alias ll="ls -la"' >> /root/.zshrc \
    && echo 'alias la="ls -a"' >> /root/.zshrc \
    && echo 'alias l="ls -l"' >> /root/.zshrc

# Claude Code
ARG CLAUDE_CODE_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

SHELL ["/bin/zsh", "-c"]

# Add labels for dev container metadata
LABEL dev.containers.metadata='{"version":"1.0.0","description":"Personal development environment with Node.js, PowerLevel10k, neovim, Claude Code, and GitHub CLI"}'
