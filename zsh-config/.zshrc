foo() {
    echo "bar"
}

td() {
    task "$1" done
}


git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ ✳ (\1)/'
}

export EDITOR='nvim'
export PATH="$PATH:/home/rushdynamic/Scripts/dotfiles-nixos/misc"

setopt PROMPT_SUBST
export PS1='%B%F{yellow}%n%f%b [%F{cyan}%~%f]%B%F{red}$(git_branch)%f%b %B%F{yellow}➔ %f%b'