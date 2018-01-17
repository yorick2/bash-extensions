#!/usr/bin/env bash

_listCustomCommands(){
    local cur tags

    # possible arguments to use
    tags="git local custom magento1 magento2 personal"

    COMPREPLY=()
    #Variable to hold the current word
    cur="${COMP_WORDS[COMP_CWORD]}"


    #Generate possible matches and store them in the
    #array variable COMPREPLY
    COMPREPLY=($(compgen -W "${tags}" $cur))
}
#Assign the auto-completion function _get for our command get.
complete -F _listCustomCommands listCustomCommands
complete -F _listCustomCommands listcustomcommands


_repo()
{
    local cur
    COMPREPLY=()
    #Variable to hold the current word
    cur="${COMP_WORDS[COMP_CWORD]}"

    #Build a list of our keywords for auto-completion using
    #the tags file
    local tags=$(for t in `ls $(repoLocation) | \
                      awk '{print $1}'`; do echo ${t}; done)

    #Generate possible matches and store them in the
    #array variable COMPREPLY
    COMPREPLY=($(compgen -W "${tags}" $cur))
}
#Assign the auto-completion function _get for our command get.
complete -o dirnames -F _repo repo

_sites()
{
    local cur
    COMPREPLY=()
    #Variable to hold the current word
    cur="${COMP_WORDS[COMP_CWORD]}"

    #Build a list of our keywords for auto-completion using
    #the tags file
    local tags=$(for t in `ls $(sitesLocation) | \
                      awk '{print $1}'`; do echo ${t}; done)

    #Generate possible matches and store them in the
    #array variable COMPREPLY
    COMPREPLY=($(compgen -W "${tags}" $cur))
}
#Assign the auto-completion function _get for our command get.
complete -o dirnames -F _sites  sites
