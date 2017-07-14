#!/usr/bin/env bash

######## needs work ########
# update local.xml with new db details (for magento 1.**)
#function update_envphp() {
#    vhost_file_location=$(get_vhost_location_file)
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
function setupLocalMagento2() {
  if [  -z $1  ] || [  -z $2 ] || [  -z $3 ] ; then
      echo ;
      echo 'import database, make into vhost, add .htaccess, copy local.xml'
      echo "dosn't download git repo or create folder"
      echo ''
      echo 'arguments missing'
      echo 'setupLocalMagento1 <<sub folder>> <<db file>> <<url>>'
      echo 'or setupLocalMagento1 <<sub folder>> <<db file>> <<url>> <<db>>'
      echo 'please try again'
    else
      unset dbname;
      subfolder=$1;
      # if $2 is a filename, set db filename or set db name
      if [[ "${2}" == *'.'* ]] ; then
        echo dbfile
        dbfile=$2;
      else
        dbname=$2;
      fi
      url=$3;

      runStaticDeploy=''
      while [[ "${runStaticDeploy}" != "y" && "${runStaticDeploy}" != "n" ]] ; do
          echo 'run setup:static-content:deploy?';
          read runStaticDeploy;
      done;


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
      echo "------- setting developer mode -------";
      php bin/magento deploy:mode:set developer;
      echo "------- magento packages upgrade -------";
      php bin/magento setup:upgrade;
      echo "------- disabling and flushing cache -------";
      php bin/magento cache:disable;
      php bin/magento cache:flush;
      echo "------- create test admin user -------";
      echo ran 'n98-magerun2.phar admin:user:create --admin-user="test" --admin-email="t@test.com" --admin-password="test" --admin-firstname="test" --admin-lastname="test"' here:
      n98-magerun2.phar admin:user:create --admin-user="test" --admin-email="t@test.com" --admin-password="password1" --admin-firstname="test" --admin-lastname="test"
      echo 'new user created:'
      echo 'user:test '
      echo 'password:password1 '
      echo "------- removing generated folders -------";
      rm -rf var/cache/* var/page_cache/* var/view_preprocessed/* var/generation/* var/di/*
      echo "------- generating static files -------";
      if [ "${runStaticDeploy}" = "y" ] ; then
        php bin/magento setup:static-content:deploy
        php bin/magento setup:static-content:deploy en_GB
      fi
      echo 'mamp users: please restart mamp'
    fi
}

alias setupMage2='setupLocalMagento2';

function echoConfigMage2() {
  scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/magento2/config.php
}

function copyConfigMage2() {
  scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/magento2/config.php | xclip -selection clipboard
}

function echoEnvMage2() {
  scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/magento2/env.php
}

function copyEnvMage2() {
  scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/magento2/env.php | xclip -selection clipboard
}

alias n982='echo running n98-magerun2.phar; n98-magerun2.phar'
alias n982fl='echo running n98-magerun2.phar cache:flush; n98-magerun2.phar cache:flush'
alias n982pass='echo running n98-magerun2.phar admin:user:change-password; n98-magerun2.phar admin:user:change-password'
alias n982re='echo running n98-magerun2.phar indexer:reindex; n98-magerun2.phar indexer:reindex'
alias n982dis='echo running n98-magerun2.phar cache:disable; n98-magerun2.phar cache:disable'

alias mage2DevMode="echo 'php bin/magento deploy:mode:set developer' ; php bin/magento deploy:mode:set developer"
alias mage2ProdMode="echo 'php bin/magento deploy:mode:set production' ; php bin/magento deploy:mode:set production"

alias mage2modules='php bin/magento module:status'


alias mage2UpgradeNStatic="echo 'php bin/magento setup:upgrade \
 && php bin/magento setup:static-content:deploy \
 && php bin/magento cache:clean' \
 ; php bin/magento setup:upgrade \
 && php bin/magento setup:static-content:deploy \
 && php bin/magento cache:clean"
alias mage2staticFlush="echo 'php bin/magento setup:static-content:deploy \
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
