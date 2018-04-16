#!/usr/bin/env bash

function branch_data() {
    if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]; then # 2>/dev/null to stop errors showing if not in git folder
        return 1;
    fi
    curr_branch=$(git rev-parse --abbrev-ref HEAD);
    curr_remote=$(git config branch.$curr_branch.remote);
    tags=$(git tag --points-at HEAD | tr '\r\n' ' ');
    branch_data=$(git branch -vv | grep '*');
    if [[ ${branch_data} = *":"* ]]; then
        aheadbehind=${branch_data%]*};
        aheadbehind=${aheadbehind##*: };
        echo " (${curr_branch}) [${curr_remote}:${aheadbehind}] ${tags}"
    else
        echo " (${curr_branch}) [${curr_remote}] ${tags}"
    fi

}

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(branch_data)\[\033[00m\]\$ '
        return 1;
    fi
    color_prompt=
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)$(branch_data)\$ '
fi

unset color_prompt

