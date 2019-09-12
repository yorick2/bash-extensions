alias listdocker="echoAndRun sudo docker ps"

function dockerssh(){
    if [  -z $1  ] || [ "$1" = "--help" ] ; then
        echo 'ssh into docker container';
        echo '';
        echo 'arguments missing';
        echo 'dockerssh <<container name>>';
        echo 'please try again';
        return;
    fi
    echo running \"sudo docker exec -it ${1} /bin/bash\";
    echo ;
    sudo docker exec -it ${1} /bin/bash;
}
function dockerDestroyAllContainersAndImages(){
    echo "docker system prune --all --force --volumes"
    docker system prune --all --force --volumes
}
function dockerComposeUpNoCache(){
    echoAndRun "sudo docker-compose build --force-rm --no-cache && sudo docker-compose up --abort-on-container-exit"
}


