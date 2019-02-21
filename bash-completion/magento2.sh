#!/usr/bin/env bash

_update_envphp(){
    if [ $COMP_CWORD -eq 1 ]; then
        _fromArrayAutoCompletion "$(listdbs)";
    elif [ $COMP_CWORD -eq 2 ]; then
        _fromArrayAutoCompletion "$(listhosts)";
    fi
}
#Assign the auto-completion function _get for our command get.
complete -F _update_envphp update_envphp

# n98nu
complete -W "--admin-user= --admin-email= --admin-password= --admin-firstname= --admin-lastname=" n982nu


_updateMage2Db(){
    if [ $COMP_CWORD -eq 1 ]; then
        # standard auto complete
        _minimal;
    elif [ $COMP_CWORD -eq 2 ]; then
        _fromArrayAutoCompletion "$(listhosts)"
    fi
}
complete -F _updateMage1Db updateMage1Db


_importMage2mysql(){
    if [ $COMP_CWORD -eq 1 ]; then
        # standard auto complete
        _minimal;
    elif [ $COMP_CWORD -eq 2 ]; then
        _fromArrayAutoCompletion "$(listhosts)";
    elif [ $COMP_CWORD -eq 3 ]; then
        _fromArrayAutoCompletion "$(listdbs)";
    fi
}
complete -F _importMage2mysql importMage2mysql
