foo() {
    echo "bar"
}

# taskwarrior3
td() {
    task "$1" done
}

git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ ✳ (\1)/'
}

export PS1="\[\e[01;33m\]\u\[\e[m\] [\[\e[36m\]\w\[\e[m\]]\[\033[01;31m\]\$(git_branch) \e[01;33m\]➔ \[\e[m\]"
export EDITOR='nvim'
