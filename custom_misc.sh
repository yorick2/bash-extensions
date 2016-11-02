alias n98fl='echo running n98-magerun.phar cache:flush; n98-magerun.phar cache:flush'
alias n98nu='echo running n98-magerun.phar admin:user:create; n98-magerun.phar admin:user:create'
alias n98pass='echo running n98-magerun.phar admin:user:change-password; n98-magerun.phar admin:user:change-password'
alias n98re='echo running n98-magerun.phar index:reindex:all; n98-magerun.phar index:reindex:all'
alias n98dis='echo running n98-magerun.phar cache:disable; n98-magerun.phar cache:disable'
alias rmcache='echo "rm -rf var/cache/* var/session/*"; rm -rf var/cache/* var/session/*'

alias phpstorm='/Applications/PhpStorm.app/Contents/MacOS/phpstorm'
alias phpstorm_diff='/Applications/PhpStorm.app/Contents/MacOS/phpstorm diff'

function listCustomCommands(){
  if [ "$1" = "git"  ] ; then
        grep function ~/.oh-my-zsh/custom/gitextension.zsh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ;
        grep alias ~/.oh-my-zsh/custom/gitextension.zsh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ;
  elif [ "$1" = "local"  ] ; then
        grep function ~/.oh-my-zsh/custom/local_setup.zsh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ;
        grep alias ~/.oh-my-zsh/custom/local_setup.zsh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ;
  elif [ "$1" = "custom"  ] ; then
        grep function ~/.oh-my-zsh/custom/custom_misc.zsh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ;
        grep alias ~/.oh-my-zsh/custom/custom_misc.zsh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ;
  elif [ "$1" = "personal"  ] ; then
        grep function ~/.oh-my-zsh/custom/personal.zsh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ;
        grep alias ~/.oh-my-zsh/custom/personal.zsh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ;
  else
         { \
          grep function ~/.oh-my-zsh/custom/gitextension.zsh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep function ~/.oh-my-zsh/custom/local_setup.zsh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep function ~/.oh-my-zsh/custom/custom_misc.zsh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep function ~/.oh-my-zsh/custom/personal.zsh | grep -v 'grep' | sed -e's/\s*function\s*//' | cut -f1 -d"(" ; \
          grep alias ~/.oh-my-zsh/custom/gitextension.zsh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
          grep alias ~/.oh-my-zsh/custom/local_setup.zsh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
          grep alias ~/.oh-my-zsh/custom/custom_misc.zsh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
          grep alias ~/.oh-my-zsh/custom/personal.zsh | grep -v 'grep' | sed -e's/\s*alias\s*//' | cut -f1 -d"=" ; \
        } | grep "${1}";
  fi 
}


