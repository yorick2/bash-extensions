#!/usr/bin/env bash

function branch_data() {
    if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]; then # 2>/dev/null to stop errors showing if not in git folder
        return 1;
    fi
    curr_branch=$(git rev-parse --abbrev-ref HEAD);
    curr_remote=$(git config branch.$curr_branch.remote);
    tags=$(git tag --points-at HEAD | tr '\r\n' ' ');
    if [[ -z $(git status -s) ]]; then
        uncommitedFlag=""
    else
        uncommitedFlag="! "
    fi
    branch_data=$(git branch -vv | grep '*');
    branch_data=${branch_data%]*};
    branch_data=${branch_data##*[};
    if [[ ${branch_data} = *":"* ]]; then
        aheadbehind=${branch_data##*: };
        echo " (${curr_branch}) ${uncommitedFlag}[${curr_remote}:${aheadbehind}] ${tags}"
    else
        echo " (${curr_branch}) ${uncommitedFlag}[${curr_remote}] ${tags}"
    fi

}

if [ -n "$force_git_prompt" ]; then
    if [ -n "$force_git_color_prompt" ]; then
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
            # We have color support; assume it's compliant with Ecma-48
            # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
            # a case would tend to support setf rather than setaf.)
            color_prompt=yes
            PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(branch_data)\[\033[00m\]\$ '
            export PS1="[\$(date +%H:%M:%S)] "${PS1} # add time to line
            return 1
        fi
    fi
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(branch_data)\$ '
    export PS1="[\$(date +%H:%M:%S)] "${PS1} # add time to line
    unset color_prompt
fi