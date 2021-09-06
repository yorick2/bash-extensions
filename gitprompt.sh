#!/usr/bin/env bash

function branch_data() {
  local curr_remote curr_branch tags uncommitedFlag branch_data aheadbehind
    if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]; then # 2>/dev/null to stop errors showing if not in git folder
        return 1;
    fi
    # if has no commmits yet
    if [ -z $(git rev-list -n 1 --all) ]; then
        status_output=$(git status -sb | grep '##'); # "## No commits yet on <<branch name>>"
        echo " (${status_output#### })";
        return 1;
    fi
    if [[ -z $(git status -s) ]]; then
        uncommitedFlag=""
    else
        uncommitedFlag="! "
    fi
    curr_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null);
    # if on a detached head
    if [[ "$curr_branch" = "HEAD" ]]; then
        echo " (${curr_branch}) ${uncommitedFlag}[] ";
        return 1;
    fi;
    curr_remote=$(git config branch.$curr_branch.remote);
    tags=$(git tag --points-at HEAD | tr '\r\n' ' ');
    branch_data=$(git branch -vv | grep '*');
    if [[ ${branch_data} != *"["* ]]; then
        echo " (${curr_branch}) ${uncommitedFlag}[${curr_remote}] ${tags}";
        return 1;
    fi
    branch_data="$( cut -d ']' -f 1 <<< "$branch_data" )"
    branch_data=${branch_data##*\[};
    if [[ ${branch_data} = *":"* ]]; then
        aheadbehind=${branch_data##*: };
        echo " (${curr_branch}) ${uncommitedFlag}[${curr_remote}:${aheadbehind}] ${tags}";
    else
        echo " (${curr_branch}) ${uncommitedFlag}[${curr_remote}] ${tags}";
    fi
}

function enableGitPrompt(){
    yorick_git_prompt=true
    reloadGitPrompt
}
function disableGitPrompt(){
    unset yorick_git_prompt
    reloadGitPrompt
}

PS1_original="$PS1"
function reloadGitPrompt(){
    if [ -z "${yorick_prompt}" ] || [ "${yorick_prompt}" != true ]; then
        export PS1="$PS1_original"
        return 1;
    fi
    local noColourText='\[\033[0m\]'
    local greenText='\[\033[01;32m\]'
    local blueText='\[\033[01;34m\]'
    local redText='\[\033[01;31m\]'

    local userPrompt='${debian_chroot:+($debian_chroot)}\u@\h'
    local locationPrompt='\w'
    if [ "$yorick_time_prompt" != "false" ]; then
        local datePrompt="[$(date +%H:%M:%S)] "
    else
        local datePrompt=''
    fi
	if [ "$yorick_git_prompt" != "false" ]; then
        branchData="$(branch_data)"
    else
        branchData=''
    fi;
	if [ "$yorick_color_prompt" != "false" ]; then
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
            # We have color support; assume it's compliant with Ecma-48
            # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
            # a case would tend to support setf rather than setaf.)
            color_prompt=yes
            export PS1="${datePrompt}${greenText}${userPrompt}${noColourText}:${blueText}${locationPrompt} ${redText}$(branch_data)${noColourText}"
            return 1
        fi
    fi
    export PS1="${datePrompt}${userPrompt}:${locationPrompt} ${branchData}" # add time to line
    unset color_prompt
    return 1
}
# run git prompt (if yorick_prompt set)
reloadGitPrompt
