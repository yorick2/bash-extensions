complete -W "$(docker ps -q) $(docker ps --format '{{.Names}}')"  dockerssh

