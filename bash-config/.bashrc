foo() {
    echo "bar"
}

git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="[\[\e[36m\]\w\[\e[m\]]\[\033[00;32m\]\$(git_branch) \[\e[33m\]\u\[\e[m\] -> "