# no duplicates in history
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
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

alias umk='uv run manage.py makemigrations'
alias umi='uv run manage.py migrate'
alias ums='uv run manage.py runserver'
alias umc='uv run manage.py createsuperuser'
alias umsh='uv run manage.py shell'

alias ve='source $WORKON_HOME/$(basename "$PWD")/bin/activate'
alias vc='mkvirtualenv $(basename "$PWD")'
alias vd='deactivate'
alias vrm='rmvirtualenv'
alias vls='lsvirtualenv'

alias groot='cd $(git rev-parse --git-common-dir)/..'
# aliases end

# functions
function ve() {
    local venv_name=${1:-$(basename "$PWD")}
    source "$WORKON_HOME/$venv_name/bin/activate"
}

function vc() {
    local venv_name=${1:-$(basename "$PWD")}
    mkvirtualenv "$venv_name"
}

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

function lz() {
    local ls_opts=()
    local zq_args=()
    local parsing_ls=true

    # Parse arguments
    for arg in "$@"; do
        if [[ $arg == "--" ]]; then
            parsing_ls=false
            continue
        fi

        if $parsing_ls; then
            if [[ $arg == -* ]]; then
                ls_opts+=("$arg")
            else
                parsing_ls=false
                zq_args+=("$arg")
            fi
        else
            zq_args+=("$arg")
        fi
    done

    # Execute the command
    ls "${ls_opts[@]}" "$(zq "${zq_args[@]}")"
}

# git commit in the past
function git_commit_date() {
    local date_cmd

    # Check if gdate is available (GNU date for macOS)
    if command -v gdate &> /dev/null; then
        date_cmd="gdate"
    elif command -v date &> /dev/null; then
        date_cmd="date"
    else
        echo "Error: No suitable date command found" >&2
        return 1
    fi

    local date_override="$1"
    if [[ -n "$date_override" ]]; then
        shift  # Remove the first argument (date) from the argument list
        GIT_AUTHOR_DATE="$($date_cmd -d "$date_override")" \
        GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE" \
        git commit "$@"
    else
        git commit "$@"
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
