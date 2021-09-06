#!/usr/bin/env bash

#######################################
# this folder location
#######################################
function customBashExtensionsFolder(){
    echo $(dirname "${BASH_SOURCE[0]}")
}

#######################################
# echo the command and run it
#######################################
function echoAndRun() {
    echo "\$\$  $@" ;
    eval "$@" ;
}

#######################################
# access the an online cheat sheet for the linux terminal
#######################################
function cheat(){
 echoAndRun "curl cheat.sh/$@"
}

#######################################
# composer update production
#######################################
function compup(){
    composer update --no-dev
}

#######################################
# databases folder (~/Documents/Databases)
#######################################
alias dbsLocation='echo ~/Documents/Databases'

#######################################
# repositries folder (~/Documents/Repositories)
#######################################
alias repoLocation='echo ~/Documents/Repositories'

#######################################
# sites folder (~/Documents/Repositories/sites)
#######################################
alias sitesLocation='echo ~/Documents/Repositories/sites'
array=( $(dbsLocation) $(repoLocation) $(sitesLocation) )
for i in "${array[@]}"; do
  #check folders exist
  if [ ! -d ${i} ]; then
      mkdir -p ${i} ;
  fi
done

#######################################
# go to dbs folder
#######################################
function dbs(){
  cd $(dbsLocation)
}

#######################################
# go to repositories folder
#######################################
function repo(){
   cd $(repoLocation)/${1}
}

#######################################
# go to sites folder
#######################################
function sites(){
   cd $(sitesLocation)/${1}
}


#######################################
# connect to mysql using connectrion set in ./mysql-connection-details.txt
# It stops the warning shown when using "mysql -uroot -proot"
# "Warning: Using a password on the command line interface can be insecure."
#######################################
alias localMysqlConnection='mysql --defaults-extra-file=$(customBashExtensionsFolder)/mysql-connection-details.txt'

#######################################
# check if db exits
#######################################
function dbExists(){
    if [  -z $1  ] || [ "$1" = "--help" ] ; then
      echo 'check if database exits';
      echo '';
      echo 'arguments missing';
      echo 'dbExists <<database name>>';
      echo 'please try again';
      return;
    fi
    local dbexists=$(localMysqlConnection -e "show databases like '${1}';")
    if [ -z "${dbexists}" ]; then
      echo 'false'
      return 1
    fi
    echo 'true';
}

#######################################
# drop database
#######################################
function dropDb(){
    if [  -z $1  ] || [ "$1" = "--help" ] ; then
      echo 'drop database';
      echo '';
      echo 'arguments missing';
      echo 'dropDb <<database name>>';
      echo 'please try again';
      return;
    fi
    local database dbexists continue
    for database in "$@"; do
      dbexists=$(localMysqlConnection -e "show databases like '${database}';")
      if [ -z "${dbexists}" ]; then
          echo "database ${1} not found"
          return 1
      fi
      echo "\nare you sure you want to drop database ${database} ? [n]"
      read continue
      if [ -z "${continue}" ]; then
          echo 'dropping database cancelled'
          return 1
      fi
      if [ "${continue}" = "n" ]; then
          echo 'dropping database cancelled'
          return 1
      fi
      if [ "${continue}" = "N" ]; then
          echo 'dropping database cancelled'
          return 1
      fi
      echo "dropping database ${database}";
      localMysqlConnection -e"drop database ${database};";
    done
}


#######################################
# List the database tables ordered by size in mb
#######################################
function dbTablesSizes(){
    if [  "$1" == "--help" ]; then
        echo 'List the database tables ordered by size in mb'
        echo 'dbTablesSizes'
        echo 'dbTablesSizes << database>>'
    fi
    if [ -z $1 ]; then
        localMysqlConnection -e '
            SELECT
            table_schema as `Database`,
            table_name AS `Table`,
            round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB`
            FROM information_schema.TABLES
            ORDER BY (data_length + index_length) DESC;'
    else
        localMysqlConnection -e '
            SELECT
            table_schema as `Database`,
            table_name AS `Table`,
            round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB`
            FROM information_schema.TABLES
            Where table_schema = "'${1}'"
            ORDER BY (data_length + index_length) DESC;'
    fi
}

#######################################
# run php through a shell for xdebug
#######################################
alias phpDebug="php -dxdebug.remote_enable=1 -dxdebug.remote_autostart=On"

# turn on auto change directory. so dont have to type cd when changing directory
shopt -s autocd

#######################################
# open folder in nautilus
#######################################
function open(){
	nautilus ${1} 
}

#######################################
# returns a lower case string of the arguments passed, with spaces replaced with _
#######################################
function safestring(){
    local str
    str="$*"
    if [ "${str}" == "--help" ]; then
        echo 'returns a lower case string of the arguments passed, with spaces replaced with _'
    fi
    str=${str,,} #lower case
    echo "${str//[\:\;\-\. ]/_}" # replace white space and special characters
}

#######################################
# runs listCustomCommands
#######################################
alias listcustomcommands="listCustomCommands"

#######################################
# lists the custom commands. note prompt,git,docker,local,custom,laravel,mage1 or mage2 can be specified to filter only those commands
#######################################
function listCustomCommands(){
  local DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  if [ "${1}" = "prompt"  ] ; then
        echo
        grep function ${DIR}/gitprompt.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/gitprompt.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ' ;
        echo
        echo
  elif [ "${1}" = "git"  ] ; then
        echo
        grep function ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ' ;
        echo
        echo
  elif [ "${1}" = "docker" ] ; then
        echo
        grep function ${DIR}/docker.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/docker.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ';
        echo
        echo
  elif [ "${1}" = "local"  ] ; then
        echo
        grep function ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ';
        echo
        echo
  elif [ "${1}" = "custom"  ] || [ "${1}" = "misc" ]  ; then
        echo
        grep function ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ';
        echo
        echo
  elif [ "${1}" = "laravel" ] ; then
        echo
        grep function ${DIR}/laravel.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/laravel.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ';
        echo
        echo
  elif [ "${1}" = "mage1" ] || [ "${1}" = "magento1" ] ; then
        echo
        grep function ${DIR}/magento1.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/magento1.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ';
        echo
        echo
  elif [ "${1}" = "mage2" ] || [ "${1}" = "magento2" ] ; then
        echo
        grep function ${DIR}/magento2.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/magento2.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ';
        echo
        echo
  elif [ "${1}" = "personal"  ] ; then
        if [ -e ${DIR}/personal.sh ] ; then
	    echo
            grep function ${DIR}/personal.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
            grep alias ${DIR}/personal.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ';
            echo
            echo
        fi
    else
        echo "-- Git Prompt --"
        { \
            grep function ${DIR}/gitprompt.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
            grep alias ${DIR}/gitprompt.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep -i "${1}" | tr '\n' ' ';
        echo
        echo
        echo "-- Git --"
        { \
            grep function ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
            grep alias ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep -i "${1}" | tr '\n' ' ';
        echo
        echo
        echo "-- Docker --"
        { \
          grep function ${DIR}/docker.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ${DIR}/docker.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep -i "${1}" | tr '\n' ' ';
        echo
        echo
        echo "-- Local Setup --"
        { \
          grep function ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep -i "${1}" | tr '\n' ' ';
        echo
        echo
        echo "-- Laravel --"
        { \
          grep function ${DIR}/laravel.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ${DIR}/laravel.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep -i "${1}" | tr '\n' ' ';
        echo
        echo
        echo "-- Magento 1 --"
        { \
          grep function ${DIR}/magento1.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ${DIR}/magento1.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep -i "${1}" | tr '\n' ' ';
        echo
        echo
        echo "-- Magento 2 --"
        { \
          grep function ${DIR}/magento2.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ${DIR}/magento2.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep -i "${1}" | tr '\n' ' ';
        echo
        echo
		    echo "-- Misc --"
        { \
          grep function ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep -i "${1}" | tr '\n' ' ';
        if [ -e ${DIR}/personal.sh ] ; then \
          echo
          echo
          echo "-- Personal --"
          { \
              grep function ${DIR}/personal.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
              grep alias ${DIR}/personal.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
          } | grep -i "${1}" | tr '\n' ' ';
        fi ; \
      echo
      echo
  fi 
}


