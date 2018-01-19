#!/usr/bin/env bash

# types of auto completion

# auto complete from files in folder location given
# _fromArrayAutoCompletion <<folder location>>
# e.g. _fromArrayAutoCompletion ~/Documents
_lsFolderAutoComplete(){
    local cur location tags
    location="${1}"

    COMPREPLY=()
    #Variable to hold the current word
    cur="${COMP_WORDS[COMP_CWORD]}"

    #Build a list of our keywords for auto-completion using
    #the tags file
    tags=$(for t in `ls ${location} | \
                      awk '{print $1}'`; do echo ${t}; done)

    #Generate possible matches and store them in the
    #array variable COMPREPLY
    COMPREPLY=($(compgen -W "${tags}" $cur))
}

# auto complete from array of strings given
# _fromArrayAutoCompletion <<tags array>>
# e.g. _fromArrayAutoCompletion "test live --help"
_fromArrayAutoCompletion(){
    local tags cur
    #Build a list of our keywords for auto-completion using
    #the tags file
    tags="${1}";

    COMPREPLY=()
    #Variable to hold the current word
    cur="${COMP_WORDS[COMP_CWORD]}"
    #Generate possible matches and store them in the
    #array variable COMPREPLY
    COMPREPLY=($(compgen -W "${tags}" $cur))
}