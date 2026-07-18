# If you come from bash you might have to change your $PATH.
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH=/opt/local/bin:/opt/local/sbin:$PATH

# Path to your Oh My Zsh installation.
#export ZSH="$HOME/.oh-my-zsh"

set rtp+=/opt/local/share/fzf/vim

# Would you like to use another custom folder than $ZSH/custom?
# export ZSH_CUSTOM="$ZSH/custom"

# themes
# ZSH_THEME="dst"

CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

zstyle ':omz:update' frequency 7

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

HIST_STAMPS="yyyy-mm-dd"

plugins=(
	git
)

# source $ZSH/oh-my-zsh.sh

# User configuration
autoload -Uz colors && colors
setopt PROMPT_SUBST

RED='%F{red}'
GREEN='%F{green}'
ORANGE='%F{orange}'
YELLOW='%F{yellow}'
BLUE='%F{blue}'
MAGENTA='%F{magenta}'
CYAN='%F{cyan}'
WHITE='%F{white}'
ENDC='%f'

[[ -n "$SSH_CLIENT" ]] && ssh_message="-ssh_session" || ssh_message=""

PROMPT="${ENDC}${CYAN}%n${WHITE} at ${YELLOW}%m${RED}${ssh_message} ${WHITE}in ${BLUE}%~${ENDC}
${CYAN}->${ENDC} "

# export MANPATH="/usr/local/man:$MANPATH"

export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:

# aliases
[[ ! -f $HOME/.zsh-aliases ]] || source $HOME/.zsh-aliases

# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# nvm
source /opt/local/share/nvm/init-nvm.sh
