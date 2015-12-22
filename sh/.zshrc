SHELL_INIT_FILE="$HOME/.zgen/zgen.zsh"
SHELL_INIT_URL="https://raw.githubusercontent.com/tarjoilija/zgen/master/zgen.zsh"
[ ! -s "$SHELL_INIT_FILE" ] && mkdir "$HOME/.zgen" && curl -s -o "$SHELL_INIT_FILE" "$SHELL_INIT_URL"
[ -r "$SHELL_INIT_FILE" ] && source "$SHELL_INIT_FILE"
SHELL_COLORS="$HOME/.theme/base16-3024.dark.sh"
[ -r "$SHELL_COLORS" ] && source "$SHELL_COLORS"

# Options
setopt complete_aliases inc_append_history hist_ignore_dups
unsetopt correct

# Configuration
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zhistory

if [[ ! $(tty) =~ ^/dev/tty[0-9]*$ ]]; then
	TERM="xterm-256color"
	AUTOSUGGESTION_HIGHLIGHT_COLOR='fg=0'
	# PowerLevel9k
	POWERLEVEL9K_PROMPT_ON_NEWLINE=true
	POWERLEVEL9K_SHORTEN_DIR_LENGTH=5
	POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
	POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status vi_mode history time)
fi

# check if there's no init script
if ! zgen saved; then
	zgen prezto
	zgen prezto environment
	zgen prezto terminal
	zgen prezto editor
	zgen prezto directory
	zgen prezto spectrum
	zgen prezto utility
	zgen prezto tmux
	zgen prezto archive
	zgen prezto completion
	zgen prezto syntax-highlighting
	zgen prezto history-substring-search
	zgen prezto prompt
	# save all to init script
	zgen save
fi

export KEYTIMEOUT=1
bindkey -v

# bind UP and DOWN arrow keys
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

bindkey '^r' history-incremental-search-backward
bindkey '^P' up-history
bindkey '^N' down-history
# backspace and ^h working even after
# returning from command mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

# ctrl-w removed word backwards
bindkey '^w' backward-kill-word

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

[ -r ~/.aliases ] && source ~/.aliases
