SHELL_BUNDLE="$HOME/.zgen/zgen.zsh"
if [ ! -s "$SHELL_BUNDLE" ]; then
	mkdir "$HOME/.zgen"
	curl "https://raw.githubusercontent.com/tarjoilija/zgen/master/zgen.zsh" > $SHELL_BUNDLE
fi
source "$SHELL_BUNDLE"

SHELL_COLORS="$HOME/.theme/base16-3024.dark.sh"
if [ -f "$SHELL_COLORS" ]; then
	source "$SHELL_COLORS"
fi

#Options
setopt complete_aliases
setopt inc_append_history
setopt hist_ignore_dups

#Configuration
TERM="xterm-256color"
AUTOSUGGESTION_HIGHLIGHT_COLOR='fg=0'
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zhistory

#PowerLevel9k
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_SHORTEN_DIR_LENGTH=5
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context vi_mode dir vcs)

# check if there's no init script
if ! zgen saved; then
	zgen prezto
	THEME_DIR="$HOME/.zprezto/modules/prompt/external/powerlevel9k"
	if [ ! -d "$THEME_DIR" ]; then
		git clone https://github.com/bhilburn/powerlevel9k.git "$THEME_DIR"
		ln -s "$THEME_DIR/powerlevel9k.zsh-theme" "$THEME_DIR/../../functions/prompt_powerlevel9k_setup"
	fi
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

if [ -f "$HOME/.aliases" ]; then
	source "$HOME/.aliases"
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
