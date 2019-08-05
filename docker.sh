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
        docker rm -f -v $(docker ps -a -q);
    fi
    if [[ ${destroyImages} == "y" ]] ; then
        docker rmi -f $(docker images -q -a);
    fi
}


