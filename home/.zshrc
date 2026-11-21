# ---------------------------------------------------------------- PATH
# typeset -U remove entradas duplicadas; a primeira da lista tem prioridade.
typeset -U path PATH
path=(
	/opt/local/bin
	/opt/local/sbin
	$HOME/nvim-macos-x86_64/bin
	$HOME/.local/bin
	$HOME/.config/emacs/bin   # Doom Emacs (comando `doom`)
	$path
)
export PATH

# Emacs fora do PATH padrão (MacPorts já está acima)
if ! command -v emacs >/dev/null; then
	if [ -x "/Applications/Emacs.app/Contents/MacOS/Emacs" ]; then
		path=(/Applications/Emacs.app/Contents/MacOS /Applications/Emacs.app/Contents/MacOS/bin $path)
	elif [ -x "/Applications/MacPorts/Emacs.app/Contents/MacOS/Emacs" ]; then
		path=(/Applications/MacPorts/Emacs.app/Contents/MacOS /Applications/MacPorts/Emacs.app/Contents/MacOS/bin $path)
	else
		echo "GNU Emacs não encontrado. Instale o Emacs 31.1 (emacsformacosx.com) em /Applications." >&2
	fi
fi

# ---------------------------------------------------------------- fzf (MacPorts)
# Ajuste os caminhos se necessário: `port contents fzf`
[[ -r /opt/local/share/fzf/shell/key-bindings.zsh ]] && source /opt/local/share/fzf/shell/key-bindings.zsh
[[ -r /opt/local/share/fzf/shell/completion.zsh ]] && source /opt/local/share/fzf/shell/completion.zsh

# ---------------------------------------------------------------- Shell
export CLICOLOR=1
export LANG=en_US.UTF-8

# Completion
autoload -Uz compinit && compinit

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE EXTENDED_HISTORY

# ---------------------------------------------------------------- Prompt
# Macos = ""
autoload -Uz colors && colors
setopt PROMPT_SUBST

RED='%F{red}'
GREEN='%F{green}'
ORANGE='%F{208}'
YELLOW='%F{yellow}'
BLUE='%F{blue}'
MAGENTA='%F{magenta}'
CYAN='%F{cyan}'
WHITE='%F{white}'
ENDC='%f'

[[ -n "$SSH_CLIENT" ]] && ssh_message="-ssh_session" || ssh_message=""

PROMPT=" ${ENDC}${CYAN}%n${WHITE} at ${YELLOW}%m${RED}${ssh_message} ${WHITE}in ${BLUE}%~${ENDC}
${CYAN}->${ENDC} "

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
else
	export EDITOR='nvim'
fi

# ---------------------------------------------------------------- aliases
[[ ! -f $HOME/.zsh-aliases ]] || source $HOME/.zsh-aliases

# ---------------------------------------------------------------- nvm
[[ -s /opt/local/share/nvm/init-nvm.sh ]] && source /opt/local/share/nvm/init-nvm.sh
