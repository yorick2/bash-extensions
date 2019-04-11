alias listdocker="echo running \"docker ps\";echo ; docker ps"

function dockerssh(){
    if [  -z $1  ] || [ "$1" = "--help" ] ; then
        echo 'ssh into docker container';
        echo '';
        echo 'arguments missing';
        echo 'dockerssh <<container name>>';
        echo 'please try again';
        return;
    fi
    echo running \"docker exec -it ${1} /bin/bash\";
    echo ;
    docker exec -it ${1} /bin/bash;
}


