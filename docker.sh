#!/usr/bin/env bash

#######################################
# List running docker containers
#######################################
alias listdocker="echoAndRun sudo docker ps"

#######################################
# list all docker elements i.e. containers, volumes, networks and images
#######################################
function dockerList(){
    if [ "$1" = "--help" ] ; then
        echo 'list all docker elements i.e. containers, volumes, networks and images';
        return;
    fi
    echo '##### docker containers #####'
    docker ps -a
    echo
    echo '##### docker volumes #####'
    docker volume ls
    echo
    echo '##### docker images #####'
    docker images
    echo 
    echo '##### docker networks #####'
    docker network ls

}

#######################################
# open a shell terminal inside a given container
#######################################
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

#######################################
# destroy all containers and images completely
#######################################
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

#######################################
# destroy all volumes not being used
#######################################
function dockerDestroyAllVolumesNotUsed(){
    docker volume prune;
}

#######################################
# destroy all unused containers, images and volumes
#######################################
function dockerDestroyAllUnused(){
    echo "docker system prune --all --force --volumes"
    docker system prune --all --force --volumes
}

#######################################
# docker compose rebuild without cache and start
#######################################
function dockerComposeUpNoCache(){
    echoAndRun "docker-compose build --force-rm --no-cache && docker-compose up --abort-on-container-exit"
}


