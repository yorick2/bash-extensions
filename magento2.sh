#!/usr/bin/env bash

######## needs work ########
# update local.xml with new db details (for magento 1.**)
#function update_envphp() {
#    vhost_file_location=$(get_vhost_location_file "${url}")
#
#   if [  -z $1  ] || [  -z $2 ] ; then
#     echo ;
#     echo 'arguments missing'
#     echo 'update_localxml <<db>> <<url>>'
#     echo 'please try again'
#   else
#     database=$1
#     url=$2
#     grepped=$(grep -B 7 -A 8  "${url}" ${vhost_file_location})
#     location=$(getVhostLocation "${url}")
#     sed -i "s/['|""]dbname['|"]\s*=>\s*['|"].*['|"]/'dbname' => '${database}'/g" ${location}/app/etc/env.php <<<<<<< not finished yet
#  fi
#}

function setupNewLocalMagento2(){
  if [  -z $1  ] || [  -z $2 ] || [  -z $3 ] ; then
      echo ;
      echo 'git clone, import database, make into vhost, copy env.php & config.php'
      echo ''
      echo 'arguments missing'
      echo 'setupNewLocalMagento1 <<git url>> <<db file>> <<url>>'
      echo 'or setupNewLocalMagento1 <<git url>> <<db file>> <<url>>'
      echo 'or setupNewLocalMagento1 <<git url>> <<db file>> <<url>> <<db>>'
      echo 'please try again'
    else
      local  subfolder testSshConnection
      local giturl=$1;
      local dbfile=$2;
      local url=$3;
      local htdocsLocation=$4;
      local dbname=$5;

      subfolder=${giturl%.git};
      subfolder=${subfolder##*/};

      if [[ ${dbfile} == *':'* ]] ; then
          testSshConnection=$(testSshConnection ${dbfile%:*});
          if [[ "$testSshConnection" != 'true' ]]; then
            echo 'unable to download database: connection failed'
            return;
          fi
      fi

      sites # move to sites folder
      if [ -d "$subfolder" ] ; then
        echo "error: subfolder  ${subfolder} already used, please clone the git repository and use setupLocalMagento1";
      fi
      git clone ${giturl} ${subfolder};
      cd ${subfolder}
      setupLocalMagento2 ${subfolder} ${dbfile} ${url} ${dbname};
    fi
}

function setupLocalMagento2() {
  if [  -z $1  ] || [  -z $2 ] || [  -z $3 ] ; then
      echo ;
      echo 'git clone, import database, make into vhost, copy env.php & config.php'
      echo ''
      echo 'arguments missing'
      echo 'setupLocalMagento1 <<git url>> <<db file>> <<url>>'
      echo 'setupLocalMagento1 <<sub folder>> <<db file>> <<url>>'
      echo 'or setupLocalMagento1 <<sub folder>> <<db file>> <<url>> <<db>>'
      echo 'please try again'
    else
      local runStaticDeploy subfolder dbfile dbname url scriptDir testSshConnection
      subfolder=$1;
      # if $2 is a filename, set db filename or set db name
      if [[ "${2}" == *'.'* ]] ; then
        echo dbfile
        dbfile=$2;
      else
        dbname=$2;
      fi
      url=$3;

      if [[ ${dbfile} == *':'* ]] ; then
          testSshConnection=$(testSshConnection ${dbfile%:*});
          if [[ "$testSshConnection" != 'true' ]]; then
            echo 'unable to download database: connection failed'
            return;
          fi
      fi

      runStaticDeploy=''
      while [[ "${runStaticDeploy}" != "y" && "${runStaticDeploy}" != "n" ]] ; do
          echo 'run setup:static-content:deploy? [y/n]';
          read runStaticDeploy;
      done;

      # if a git repo used
      if [[ "${1}" == *'.git' ]] ; then
        setupNewLocalMagento2 $1 $2 $3 $4 $5
        return 1;
      fi



      if [ -f "composer.json" ]; then
        echo "------- composer update -------";
        composer install --no-dev
      fi

      if [ -z ${dbname} ] ; then
          echo "------- importing database -------";
          if [  -z $4  ]; then
            dbname=${dbfile%.*};
            dbname=${dbname%.tar};
            dbname=${dbname%.sql};
            dbname=${dbname##*:};
            dbname=${dbname##*/};
            dbname=${dbname//[-.]/_}; #make db name valid when created from filenames not valid db names
          else
            dbname=$4
          fi
      fi
      import2mysql ${dbfile} ${url} ${dbname};
      echo "------- making vhost -------";
      sites # move to sites folder
      mkvhost ${subfolder}/pub ${url};
      echo "------- composer install --no-dev -------";
      sites; # move to repos folder
      cd ${subfolder}
      composer install --no-dev
      echo "------- adding magento settings files -------";
      scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
      cp ${scriptDir}/local_setup_files/magento2/config.php app/etc/config.php
      cp ${scriptDir}/local_setup_files/magento2/env.php app/etc/env.php
      sed -i "s/<<<databasename>>>/${dbname}/g" app/etc/env.php
      cp ${scriptDir}/local_setup_files/magento2/.htaccess .htaccess
      cp ${scriptDir}/local_setup_files/magento2/pub/.htaccess pub/.htaccess
      echo "------- setting developer mode -------";
      php bin/magento deploy:mode:set developer;
      echo "------- magento packages upgrade -------";
      php bin/magento setup:upgrade;
      echo "------- disabling full_page cache and flushing cache -------";
      php bin/magento cache:enable;
      php bin/magento cache:disable full_page;
      php bin/magento cache:flush;
      echo "------- removing generated folders -------";
      rm -rf var/cache/* var/page_cache/* var/view_preprocessed/* var/generation/* var/di/*
      echo "------- generating static files -------";
      if [ "${runStaticDeploy}" = "y" ] ; then
        php bin/magento setup:static-content:deploy
        php bin/magento setup:static-content:deploy en_GB
      fi
      echo "------- create test admin user -------";
      echo ran 'n98-magerun2.phar admin:user:create --admin-user="test" --admin-email="t@test.com" --admin-password="test" --admin-firstname="test" --admin-lastname="test"' here:
      n98-magerun2.phar admin:user:create --admin-user="test" --admin-email="t@test.com" --admin-password="password1" --admin-firstname="test" --admin-lastname="test"
      echo 'new user created:'
      echo 'user:test '
      echo 'password:password1 '
      echo 'mamp users: please restart mamp'
    fi
}

alias setupMage2='setupLocalMagento2';

function echoConfigMage2() {
  local scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/magento2/config.php
}

function copyConfigMage2() {
  local scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/magento2/config.php | xclip -selection clipboard
}

function echoEnvMage2() {
  local scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/magento2/env.php
}

function copyEnvMage2() {
  local scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/magento2/env.php | xclip -selection clipboard
}

alias n982='echo running n98-magerun2.phar; n98-magerun2.phar'
alias n982pass='echo running n98-magerun2.phar admin:user:change-password; n98-magerun2.phar admin:user:change-password'
alias n982re='echo running n98-magerun2.phar indexer:reindex; n98-magerun2.phar indexer:reindex'
alias n982st='echo running n98-magerun2.phar cache:status; n98-magerun2.phar cache:status'
alias n982fl='echo running n98-magerun2.phar cache:flush; n98-magerun2.phar cache:flush'
alias n982en='echo running n98-magerun2.phar cache:enable; n98-magerun2.phar cache:enable'
alias n982dis='echo running n98-magerun2.phar cache:disable; n98-magerun2.phar cache:disable'

alias m2='echo running php bin/magento; php bin/magento'
alias m2re='echo running php bin/magento indexer:reindex; php bin/magento indexer:reindex'
alias m2st='echo running php bin/magento cache:status; php bin/magento cache:status'
alias m2fl='echo running php bin/magento cache:flush; php bin/magento cache:flush'
alias m2en='echo running php bin/magento cache:enable; php bin/magento cache:enable'
alias m2dis='echo running php bin/magento cache:disable; php bin/magento cache:disable'
alias m2dis_without_full_page='echo running php bin/magento cache:enable && php bin/magento cache:disable full_page; \
 php bin/magento cache:enable && php bin/magento cache:disable full_page'
alias m2DevMode="echo 'php bin/magento deploy:mode:set developer' ; php bin/magento deploy:mode:set developer"
alias m2ProdMode="echo 'php bin/magento deploy:mode:set production' ; php bin/magento deploy:mode:set production"
alias m2modules='php bin/magento module:status'
alias m2UpgradeNStatic="echo 'php bin/magento setup:upgrade \
 && php bin/magento setup:static-content:deploy \
 && php bin/magento cache:clean' \
 ; php bin/magento setup:upgrade \
 && php bin/magento setup:static-content:deploy \
 && php bin/magento cache:clean"
alias m2staticFlush="echo 'php bin/magento setup:static-content:deploy \
 && php bin/magento cache:clean' \
 ; php bin/magento setup:static-content:deploy \
 && php bin/magento cache:clean"

function n982nu () {
  if [  -z $1  ] ; then
    echo 'arguments missing'
    echo 'e.g.'
    echo '  n98-magerun2.phar admin:user:create --admin-user="my_user_name" --admin-email="example@example.com" --admin-password="mypassword" --admin-firstname="paul" --admin-lastname="test"'
  fi
  echo running n98-magerun2.phar admin:user:create "$@";
  n98-magerun2.phar admin:user:create "$@"
}



