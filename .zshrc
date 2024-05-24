# no duplicates in history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

zstyle :omz:plugins:ssh-agent identities idrsa

if [[ $(uname) == "Darwin" ]]; then
    	source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
else
	source $HOME/.antidote/antidote.zsh
fi
antidote load

# aliases
alias c='clear'
alias o='open'
alias q='exit'
alias v='nvim'

alias ls='eza'
alias vi='nvim'
alias lt='eza --tree --level=2'
alias llt='eza --tree --long --level=2'

alias zq='zoxide query'

alias pg='pgcli'
alias ir='iredis'
alias cpy='code --profile Python'
alias cwe='code --profile Web'
alias rizz='source ~/.zshrc'
alias pncp='pnpm nuxt cleanup && pnpm nuxt prepare'

alias mk='python manage.py makemigrations'
alias mi='python manage.py migrate'
alias ms='python manage.py runserver'
alias mc='python manage.py createsuperuser'
alias msh='python manage.py shell'

alias ve='source $WORKON_HOME/$(basename "$PWD")/bin/activate'
alias vc='mkvirtualenv $(basename "$PWD")'
alias vd='deactivate'
alias vrm='rmvirtualenv'
alias vls='lsvirtualenv'

alias groot='cd $(git rev-parse --git-common-dir)/..'
# aliases end

# functions
# create a file with parent directories if they don't exist
function t(){
  for arg in $@; do
    mkdir -p $(dirname $arg)
    touch $arg
  done
}

# create a file with parent directories if they don't exist and open it vs code
function tc(){
  for arg in $@; do
    mkdir -p $(dirname $arg)
    touch $arg
    code $arg
  done
}

# cd into worktree or create a new worktree
function gwtsw() {
    local branch_name=$1

    # Check if the branch exists
    if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo "branch '$branch_name' does not exist."
        return 1
    fi

    # Use git worktree ls to find the worktree path
    local worktree_path=$(git worktree list | grep -e "$branch_name" | awk '{print $1}')
    local git_dir=$(git rev-parse --git-common-dir)
    echo $git_dir

    # Check if the worktree exists
    if [ -d "$worktree_path" ]; then
        # Change directory into the worktree
        cd "$worktree_path"
    else
        # Create the worktree and change directory into it
        cd "$git_dir/.."
        git worktree add ".worktrees/$branch_name"
        cd ".worktrees/$branch_name"
    fi
}
# functions end

# exports
# export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/opt/python@3.12/libexec/bin:$PATH
# exports end

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# starship
eval "$(starship init zsh)"
# starship end

# completion for zoxide z
__zoxide_z_completion() {
    (( $+compstate )) && compstate[insert]=menu

    local expl
    local completions=($(zoxide query -l ${(@)words:1}))

    _files -/

    if [[ ${#completions[@]} -gt 0 ]]; then
        _description -V completions expl 'zoxide query'
        compadd "${expl[@]}" -QU -V z -- "${completions[@]}"
    fi

    return 0
}

if [ "${+functions[compdef]}" -ne 0 ]; then
    compdef __zoxide_z_completion z 2> /dev/null
fi
# zoxide z completions end
