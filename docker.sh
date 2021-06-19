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
    if [ "$1" = "-help" ]
    then
        echo "destroy all containers and images completely"
        return
    fi
    destroyContainers=''
    while [[ "${destroyContainers}" != "y" && "${destroyContainers}" != "n" ]] ; do
        echo 'Destroy all containers? [y/n]';
        read destroyContainers;
    done;
    destroyImages=''
    while [[ "${destroyImages}" != "y" && "${destroyImages}" != "n" ]] ; do
        echo 'Destroy all images? [y/n]';
        read destroyImages;
    done;
    if [[ ${destroyContainers} == "y" ]] ; then
        sudo docker rm -f -v $(sudo docker ps -a -q);
    fi
    if [[ ${destroyImages} == "y" ]] ; then
        sudo docker rmi -f $(sudo docker images -q -a);
    fi
    echo 'Dont forget docker volumes may be storing data and may need destorying!!!'
}
function dockerDestroyAllVolumesNotUsed(){
    docker volume prune;
}
function dockerDestroyAllUnused(){
    echo "docker system prune --all --force --volumes"
    docker system prune --all --force --volumes
}
function dockerComposeUpNoCache(){
    echoAndRun "sudo docker-compose build --force-rm --no-cache && sudo docker-compose up --abort-on-container-exit"
}


