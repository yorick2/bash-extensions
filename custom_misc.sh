#!/usr/bin/env bash

## required for local setups
alias dbsLocation='echo ~/Documents/Databases'
alias repoLocation='echo ~/Documents/Repositories'
alias sitesLocation='echo ~/Documents/Repositories/sites'

function customBashExtensionsFolder(){
    echo $(dirname "${BASH_SOURCE[0]}")
}


function dbs(){
  cd $(dbsLocation)
}
function repo(){
   cd $(repoLocation)/${1}
}

function sites(){
   cd $(sitesLocation)/${1}
}

# stops the warning shown when using "mysql -uroot -proot"
# "Warning: Using a password on the command line interface can be insecure."
alias localMysqlConnection='mysql --defaults-extra-file=$(customBashExtensionsFolder)/mysql-connection-details.txt'

# run php through a shell for xdebug
alias phpDebug="php -dxdebug.remote_enable=1 -dxdebug.remote_autostart=On"


# turn on auto change directory. so dont have to type cd when changing directory
shopt -s autocd

function open(){
	nautilus ${1} 
}

alias listcustomcommands="listCustomCommands"

function listCustomCommands(){
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  if [ "${1}" = "git"  ] ; then
        echo
        grep function ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ' ;
        echo
        echo
  elif [ "${1}" = "local"  ] ; then
        echo
        grep function ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ';
        echo
        echo
  elif [ "${1}" = "custom"  ] ; then
        echo
        grep function ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ';
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
        echo "-- Git --"
        { \
            grep function ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
            grep alias ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
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


