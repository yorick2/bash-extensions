#!/usr/bin/env bash

function branch_data() {
    curr_branch=$(git rev-parse --abbrev-ref HEAD);
    curr_remote=$(git config branch.$curr_branch.remote);
    branch_data=$(git branch -vv | grep '*');
    aheadbehind=${branch_data%]*};
    aheadbehind=${aheadbehind##*: };
    echo " (${curr_branch}) [${curr_remote}:${aheadbehind}]"
}

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(branch_data)\[\033[00m\]\$ '
    else
        color_prompt=
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)$(branch_data)\$ '
    fi
fi


unset color_prompt

