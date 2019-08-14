_dockerssh(){
    # do not change to single line "complete -W ..." as this is saved as static set of options, so as this is a dynamic
    # list it isn't suitable
    _fromArrayAutoCompletion "$(docker ps -q) $(docker ps --format '{{.Names}}')";
}
#Assign the auto-completion function _get for our command get.
complete -F _dockerssh dockerssh
