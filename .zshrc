###################################
# プロンプト
# 2行表示

PROMPT="$n
%F{green}[%C]%F{white}$ "

RPROMPT='`rprompt-git-current-branch`%F{white}[%~]%'
#####################################

#PATH
export PATH=$PATH:~/.local/bin 

#基本
bindkey ";5C" forward-word
bindkey ";5D" backward-word
setopt no_beep # beep を無効にする
setopt noclobber
setopt notify # バックグラウンド処理の状態変化をすぐに通知する
setopt rm_star_wait # rm * の前に確認をとる
setopt auto_pushd # cd したら自動的にpushdする
setopt auto_cd # ディレクトリ名だけでcdする
setopt transient_rprompt # コマンド実行後は右プロンプトを消す
chpwd() { ls } #cdのあとに自動でls
setopt prompt_subst # プロンプトが表示されるたびにプロンプト文字列を評価、置換する

#区切り文字と認識しない記号
export WORDCHARS="*?.[]~&;=!#$%^(){}<>"

#補完
autoload -U compinit
compinit
setopt correct
setopt COMPLETE_IN_WORD # allow tab completion in the middke of word

# history
setopt hist_ignore_all_dups # 履歴中の重複行をすべて削除する
setopt hist_ignore_dups # 直前と重複するコマンドを記録しない
setopt share_history  # シェルのプロセスごとに履歴を共有
setopt extended_history  # 履歴ファイルに時刻を記録
setopt append_history  # 複数の zsh をhistory ファイルに上書きせず追加
setopt histignorealldups sharehistory

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

## alias
# 基本
alias v='vim'
alias vi='vim'
alias la='ls -la --color=auto'
alias ls="ls -F"
alias ll="ls -l"

# cd
alias '..'='cd ..'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# zshrv
alias sz='source ~/.zshrc'
alias sv='source ~/.vimrc'
alias vz='vim ~/.zshrc'
alias vv='vim ~/.vimrc'
alias cz='code ~/.zshrc'
alias cv='code ~/.vimrc'

#pipe
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sed'
alias -g C='| cat'
alias -g clip='| xsel --clipboard --input'

# python
alias python="python3" 
alias pip="pip3"
alias jnote="jupyter notebook"
alias jlab="jupyter-lab"
alias pip-upgrade-all="pip list -o | tail -n +3 | awk '{ print \$1 }' | xargs pip install -U"



###########################################
### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-bin-gem-node
### End of Zinit's installer chunk

source $HOME/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# two regular plugins loaded without tracking.
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

# Plugin history-search-multi-word loaded with tracking.
zinit load zdharma-continuum/history-search-multi-word

# Binary release in archive, from GitHub-releases page.
# After automatic unpacking it provides program "fzf".
zinit ice from"gh-r" as"program"
zinit load junegunn/fzf-bin

zinit wait lucid atload"zicompinit; zicdreplay" blockf for zsh-users/zsh-completions


# fzfの設定
export FZF_DEFAULT_OPTS='--color=fg+:11 --height 70% --reverse --multi'

# fzf-cdr 
function cdd() {
    target_dir=`cdr -l | sed 's/^[^ ][^ ]*  *//' | fzf`
    target_dir=${target_dir/\~/$HOME}
    target_dir=${target_dir//\\/}
    if [ -n "$target_dir" ]; then
        cd $target_dir
    fi
}

# fzfでインタラクティブにgcloudのconfigをactivateする。
function gcloud-activate() {
  name="$1"
  project="$2"
  echo "gcloud config configurations activate \"${name}\""
  gcloud config configurations activate "${name}"
}
function set-credential() {
  name="$1"
  credentials_path=$(cat /home/morioka/.gcloud-credentials/credentilas-table.csv | grep -E "^${name}" | awk '{print $2}')
  echo "set GOOGLE_APPLICATION_CREDENTIALS \"${name}\""
  echo $credentials_path
  export GOOGLE_APPLICATION_CREDENTIALS="/home/morioka/.gcloud-credentials/json/$credentials_path"
}
function gx-complete() {
  _values $(gcloud config configurations list | awk '{print $1}')
}
function gx() {
  name="$1"
  if [ -z "$name" ]; then
    line=$(gcloud config configurations list | fzf)
    name=$(echo "${line}" | awk '{print $1}')
  else
    line=$(gcloud config configurations list | grep "$name")
  fi
  project=$(echo "${line}" | awk '{print $4}')
  gcloud-activate "${name}" "${project}"
  set-credential "${name}"
}
compdef gx-complete gx


#----- cdr#autoload -Uz is-at-least
if is-at-least 4.3.11
then
	autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
	add-zsh-hook chpwd chpwd_recent_dirs
	zstyle ':chpwd:*' recent-dirs-max 1000
	zstyle ':chpwd:*' recent-dirs-default yes
	zstyle ':completion:*' recent-dirs-insert both
fi

############################################
# git ブランチ名を色付きで表示させるメソッド
function rprompt-git-current-branch {
  local branch_name st branch_status
 
  if [ ! -e  ".git" ]; then
    # git 管理されていないディレクトリは何も返さない
    return
    echo '%{${fg[cyan]}%}[%~]%{${reset_color}%}'
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全て commit されてクリーンな状態
    branch_status="%F{green}"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # git 管理されていないファイルがある状態
    branch_status="%F{red}*"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git add されていないファイルがある状態
    branch_status="%F{red}+"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commit されていないファイルがある状態
    branch_status="%F{yellow}!"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "%F{red}!(no branch)"
    return
  else
    # 上記以外の状態の場合
    branch_status="%F{blue}"
  fi
  # ブランチ名を色付きで表示する
  echo "${branch_status}[$branch_name]"
}

############################################

ssh-fzf() {
    local sshLoginHost
    sshLoginHost=`cat ~/.ssh/config | grep -i ^host | awk '{print $2}' | fzf`
    if [[ -n "$sshLoginHost" ]]; then
        ssh ${sshLoginHost}
    fi
}

############################################

# Git

function git-switch() {
  git branch -vv | fzf +m | awk '{print $1}' | sed "s/.* //" | xargs --no-run-if-empty git switch
}

function git-download() {
  git branch -rvv | fzf +m | awk '{print $1}' | sed "s/.* //" | xargs --no-run-if-empty  git switch -c 
}


function git-delete() {
  local arg=-d
  if [[ $1 == "-f" ]] then
    arg=-D
  fi
  git branch -vv | fzf +m | awk '{print $1}' | sed "s/.* //" | xargs --no-run-if-empty git branch $arg
}

function git-add() {
  local selected=$(git status -s | fzf | awk '{print $2}' | sed -z "s/\n/ /g")
  if [[ -n "$selected" ]]; then
    git add ${=selected}
  fi
}

function git-restore() {
  local arg 

  if [[ $1 == "--worktree" ]] then
    arg=""
  elif [[ $1 == "--staged" ]] then
    arg="--staged"
  elif [[ $1 == "--hard" ]] then
    arg="--source=HEAD --staged --worktree"
  else 
    echo "arg shoud --worktree | --staged | --hard"
    return
  fi

  local selected=$(git status -s | fzf | awk '{print $2}' | sed -z "s/\n/ /g")
  if [[ -n "$selected" ]]; then
    git restore ${=arg} ${=selected}
  fi
}


## 歴史改変するためのgit alias ※参照（https://qiita.com/kawarimidoll/items/cc76b1913372ff478206）
# 歴史を思い出す
function git-log(){
  git log --graph --color=always --format="%C(auto)%h%d %C(black bold)%cr %C(auto)%s" "$@" | \
  fzf --ansi --exit-0 --no-sort --no-multi --tiebreak=index --height=100% \
  --preview="grep -o '[a-f0-9]\{7\}' <<< {} | head -1 | xargs --no-run-if-empty git show --color=always" \
  --header="Ctrl-y to toggle preview, Ctrl-u to preview down, Ctrl-i to preview up" \
  --bind="ctrl-y:toggle-preview,ctrl-u:preview-down,ctrl-i:preview-up" \
  --preview-window=down:60% | grep -oE '[a-f0-9]{7}' | head -1
}

# 歴史を巻き戻す
function git-reset(){
  git-log | xargs --no-run-if-empty git reset --soft
}

# 歴史を書き換える
function git-rebase(){
  git-log | xargs --no-run-if-empty --open-tty git rebase -i
}

# 未来へ戻る
function git-btf(){
  git rebase --continue
}

# 歴史を整理する
function git-fixup(){
  git-log | xargs --no-run-if-empty -I_ git commit --fixup _ && git rebase -i --autosquash
}

############################################
#GUI
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0

#yarn global bin
export PATH="$PATH:`yarn global bin`"

# golang
export GOPATH="$HOME/go"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/morioka/.google-cloud-sdk/path.zsh.inc' ]; then . '/home/morioka/.google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/morioka/.google-cloud-sdk/completion.zsh.inc' ]; then . '/home/morioka/.google-cloud-sdk/completion.zsh.inc'; fi
