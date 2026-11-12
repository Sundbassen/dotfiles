#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf 'Color escapes are %s\n' '\e[${value};...;${value}m'
	printf 'Values 30..37 are \e[33mforeground colors\e[m\n'
	printf 'Values 40..47 are \e[43mbackground colors\e[m\n'
	printf 'Value  1 gives a  \e[1mbold-faced look\e[m\n\n'

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals='${fgc:+$fgc;}${bgc}'
			vals=${vals%%;}

			seq0='${vals:+\e[${vals}m}'
			printf '  %-9s' '${seq0:-(default)}'
			printf ' ${seq0}TEXT\e[m'
			printf ' \e[${vals:+${vals+$vals;}}1mBOLD\e[m'
		done
		echo; echo
	done
} #End of colors function 

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true
RED='\[\033[01;31m\]'
CYAN='\[\033[01;36m\]'
RESET='\[\033[00m\]'
GREEN='\[\033[01;32m\]'
WHITE='\[\033[01;37m\]'
# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='${RED}[\h${CYAN} \W${RED}]\$${RESET} '
	else
		PS1="${GREEN}[\u@\h${WHITE} \W${GREEN}]\$${RESET} "
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='grep -E --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

#alias cp="cp -i"                          # confirm before overwriting something
#alias df='df -h'                          # human-readable sizes
#alias free='free -m'                      # show sizes in MB
#alias np='nano -w PKGBUILD'
#alias more=less

xhost +local:root > /dev/null 2>&1

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend
alias cc="wl-copy"
[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
[ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:/usr/local/go/bin:$HOME/go/bin
alias gob='go build'
alias gs='git status'
alias dcup='docker compose up --detach'
alias dc='docker compose'
export PATH="$HOME/bin:$PATH"

if [ -f /usr/share/bash-completion/completions/docker ]; then
    . /usr/share/bash-completion/completions/docker
fi
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
fi
if [ -f /usr/share/bash-completion/completions/make ]; then
    . /usr/share/bash-completion/completions/make
fi

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_AGENT_RUNNING=$(ssh-add -l 2>&1)

if [[ "$SSH_AGENT_RUNNING" == *"The agent has no identities."* ]]; then
    ssh-add "$SSH_KEY" >/dev/null 2>&1
fi


alias prunebranches="git switch main && git branch | grep -Ev '(^|\s)main($|\s)' | xargs git branch -D"

# Machine-local secrets and paths; template in ~/private/dotfiles/dotfiles.env.example
[ -f "$HOME/.config/dotfiles.env" ] && . "$HOME/.config/dotfiles.env"

export GDK_SCALE=1
export GDK_DPI_SCALE=1
export QT_SCALE_FACTOR=1
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.local/bin

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Run ~/bin/wt and cd into the worktree it prints last
wt() {
  local out dir
  out="$(command wt "$@")" || { printf '%s\n' "$out"; return 1; }
  printf '%s\n' "$out"
  dir="$(printf '%s\n' "$out" | tail -n1)"
  [[ -d "$dir" ]] && cd "$dir"
}

# Work and machine-specific shell bits, untracked
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"

# gh
alias ghnoti="gh api notifications"
