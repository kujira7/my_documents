###################################
# プロンプト
# 2行表示

PROMPT="$n
%F{green}[%C]%F{white}$ "

RPROMPT='`rprompt-git-current-branch`%F{white}[%~]%'
#####################################

#基本
setopt no_beep # beep を無効にする
setopt noclobber
setopt notify # バックグラウンド処理の状態変化をすぐに通知する
setopt rm_star_wait # rm * の前に確認をとる
setopt auto_pushd # cd したら自動的にpushdする
setopt auto_cd # ディレクトリ名だけでcdする
setopt transient_rprompt # コマンド実行後は右プロンプトを消す
chpwd() { ls --color=auto } #cdのあとに自動でls
setopt prompt_subst # プロンプトが表示されるたびにプロンプト文字列を評価、置換する

#補完
autoload -U compinit
setopt correct
setopt COMPLETE_IN_WORD # allow tab completion in the middke of word

#環境変数
export HISTFILE=~/.zhistory # コマンド履歴を保存するファイルを指定する
export HISTSIZE=1000 # メモリに保存する履歴の件数を指定
export SAVEHIST=100000 # ファイルに保存する履歴の件数を指定する

# history
setopt hist_ignore_all_dups # 履歴中の重複行をすべて削除する
setopt hist_ignore_dups # 直前と重複するコマンドを記録しない
setopt share_history  # シェルのプロセスごとに履歴を共有
setopt extended_history  # 履歴ファイルに時刻を記録
setopt append_history  # 複数の zsh をhistory ファイルに上書きせず追加

## alias
# 基本
alias v='vim'
alias vi='vim'
alias la='ls -la --color=auto'
alias ls="ls -F"
alias woodh="/mnt/c/Users/woodh"

# cd
alias '..'='cd ..'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# git 更新
alias ga='git add'
alias gb='git branch'
alias gco='git checkout'
alias gci='git commit'
alias gcm='git commit -m'
# git 確認
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log'
alias glo='git log --online'
# git 変更取り消し
alias grh='git reset HEAD'
alias gca='git commit --amend'
# git push
alias gp='git push'
# git remote
alias gr='git remote'
alias grs='git remote show'
# git fetch
alias gf='git fetch'
alias gfo='git fetch origin'
# git merge
alias gm='git merge'

# zsh
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

# python
alias python="python3"
alias jnote="jupyter notebook"
alias jlab="jupyter-lab"
alias pip="python -m pip"
alias pip-upgrade-all="pip list -o | tail -n +3 | awk '{ print \$1 }' | xargs pip install -U"



###########################################
### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk
# Two regular plugins loaded without tracking.
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma/fast-syntax-highlighting

# Plugin history-search-multi-word loaded with tracking.
zinit load zdharma/history-search-multi-word

# Binary release in archive, from GitHub-releases page.
# After automatic unpacking it provides program "fzf".
zinit ice from"gh-r" as"program"
zinit load junegunn/fzf-bin

#fzfの設定
export FZF_DEFAULT_OPTS='--color=fg+:11 --height 70% --reverse --select-1 --exit-0 --multi'

# fzf-cdr 
 alias cdd='fzf-cdr'
 function fzf-cdr() {
     target_dir=`cdr -l | sed 's/^[^ ][^ ]*  *//' | fzf`
     target_dir=`echo ${target_dir/\~/$HOME}`
     if [ -n "$target_dir" ]; then
          cd $target_dir
     fi
}


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
#PATH
export PATH=$PATH:~/.local/bin  


