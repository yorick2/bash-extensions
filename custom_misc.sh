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
  elif [ "${1}" = "mage" ] || [ "${1}" = "magento" ] ; then
        echo
        grep function ${DIR}/magento.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" | tr '\n' ' ';
        grep alias ${DIR}/magento.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" | tr '\n' ' ';
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
        } | grep "${1}" | tr '\n' ' ';
        echo
        echo
        echo "-- Local Setup --"
        { \
          grep function ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep "${1}" | tr '\n' ' ';
        echo
        echo
        echo "-- Magento --"
        { \
          grep function ${DIR}/magento.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ${DIR}/magento.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep "${1}" | tr '\n' ' ';
        echo
        echo
        echo "-- Misc --"
        { \
          grep function ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep "${1}" | tr '\n' ' ';
        if [ -e ${DIR}/personal.sh ] ; then \
          echo
          echo
          echo "-- Personal --"
          { \
              grep function ${DIR}/personal.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
              grep alias ${DIR}/personal.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
          } | grep "${1}" | tr '\n' ' ';
        fi ; \
      echo
      echo
  fi 
}


