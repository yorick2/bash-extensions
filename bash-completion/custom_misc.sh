#!/usr/bin/env bash

#Assign the auto-completion function _get for our command get.
complete -W "git local custom magento1 magento2 personal" listCustomCommands
complete -W "git local custom magento1 magento2 personal" listcustomcommands

_repo()
{
    _lsFolderAutoComplete $(repoLocation)
}
#Assign the auto-completion function _repo for our command repo.
complete -o dirnames -F _repo repo

_sites()
{
    _lsFolderAutoComplete $(sitesLocation)
}
complete -o dirnames -F _sites  sites
