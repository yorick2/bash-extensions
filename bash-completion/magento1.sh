#!/usr/bin/env bash
_update_localxml(){
    if [ $COMP_CWORD -eq 1 ]; then
        _minimal
    elif [ $COMP_CWORD -eq 2 ]; then
        local cur
        COMPREPLY=()
        #Variable to hold the current word
        cur="${COMP_WORDS[COMP_CWORD]}"

        #Build a list of our keywords for auto-completion using
        #the tags file
        local tags=$(listhosts);

        #Generate possible matches and store them in the
        #array variable COMPREPLY
        COMPREPLY=($(compgen -W "${tags}" $cur))
    fi
}

#Assign the auto-completion function _get for our command get.
complete -F _update_localxml update_localxml
