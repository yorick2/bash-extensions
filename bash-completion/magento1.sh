#!/usr/bin/env bash

_update_localxml(){
    if [ $COMP_CWORD -eq 1 ]; then
        _fromArrayAutoCompletion "$(listdbs)";
    elif [ $COMP_CWORD -eq 2 ]; then
        _fromArrayAutoCompletion "$(listhosts)";
    fi
}
#Assign the auto-completion function _update_localxml for our command update_localxml.
complete -F _update_localxml update_localxml

_updateMage1Db(){
    if [ $COMP_CWORD -eq 1 ]; then
        # standard auto complete
        _minimal;
    elif [ $COMP_CWORD -eq 2 ]; then
        _fromArrayAutoCompletion "$(listhosts)"
    fi
}
complete -F _updateMage1Db updateMage1Db

