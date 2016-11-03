# turn on auto change directory. so dont have to type cd when changing directory
shopt -s autocd

alias n98fl='echo running n98-magerun.phar cache:flush; n98-magerun.phar cache:flush'
alias n98nu='echo running n98-magerun.phar admin:user:create; n98-magerun.phar admin:user:create'
alias n98pass='echo running n98-magerun.phar admin:user:change-password; n98-magerun.phar admin:user:change-password'
alias n98re='echo running n98-magerun.phar index:reindex:all; n98-magerun.phar index:reindex:all'
alias n98dis='echo running n98-magerun.phar cache:disable; n98-magerun.phar cache:disable'
alias rmcache='echo "rm -rf var/cache/* var/session/*"; rm -rf var/cache/* var/session/*'

function open(){
	nautilus ${1} 
}

function listCustomCommands(){
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  if [ "$1" = "git"  ] ; then
        grep function ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ;
        grep alias ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ;
  elif [ "$1" = "local"  ] ; then
        grep function ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ;
        grep alias ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ;
  elif [ "$1" = "custom"  ] ; then
        grep function ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ;
        grep alias ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ;
  elif [ "$1" = "personal"  ] ; then
        grep function ${DIR}/personal.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ;
        grep alias ${DIR}/personal.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ;
  else
         { \
          grep function ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep function ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep function ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep function ${DIR}/personal.sh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ${DIR}/gitextension.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
          grep alias ${DIR}/local_setup.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
          grep alias ${DIR}/custom_misc.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
          grep alias ${DIR}/personal.sh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep "${1}";
  fi 
}


