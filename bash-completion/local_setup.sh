#!/usr/bin/env bash

# uses same auto complete as ssh command
complete -F _known_hosts testSshConnection

_import2mysql(){
    if [ $COMP_CWORD -eq 1 ]; then
        # standard auto complete
        _minimal;
    elif [ $COMP_CWORD -eq 2 ]; then
        _fromArrayAutoCompletion "$(listdbs)";
    fi
}
#Assign the auto-completion function _update_localxml for our command update_localxml.
complete -F _import2mysql tar2mysql
complete -F _import2mysql gz2mysql
complete -F _import2mysql sql2mysql
complete -F _import2mysql import2mysql

complete -W "$(listhosts)" getVhostLocation