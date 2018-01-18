#!/usr/bin/env bash
_update_localxml(){
    if [ $COMP_CWORD -eq 1 ]; then
        #Build a list of our keywords for auto-completion using
        #the tags file
        local tags=$(listdbs);
    elif [ $COMP_CWORD -eq 2 ]; then
        #Build a list of our keywords for auto-completion using
        #the tags file
        local tags=$(listhosts);
    fi
        local cur
        COMPREPLY=()
        #Variable to hold the current word
        cur="${COMP_WORDS[COMP_CWORD]}"
        #Generate possible matches and store them in the
        #array variable COMPREPLY
        COMPREPLY=($(compgen -W "${tags}" $cur))

}

#Assign the auto-completion function _get for our command get.
complete -F _update_localxml update_localxml