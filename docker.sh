alias listdocker="echo running \"sudo docker ps\";echo ; sudo docker ps"

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
}


