#!/usr/bin/env bash

# update local.xml with new db details (for magento 2.**)
function update_envphp() {
   if [  -z $2 ] || [ "$1" = "--help" ] ; then
     echo ;
     echo 'arguments missing'
     echo 'update_envphp <<db>> <<url>>'
     echo 'please try again'
   else
     database=$1
     url=$2
     vhostLocation=$(getVhostLocation "${url}")
     quotes="['\"]"
     notQuotes="[^'\"]"
     if [ -f  ${vhostLocation}/../app/etc/env.php ] ; then
        location="${vhostLocation}/../app/etc/env.php";
     elif [ -f  ${vhostLocation}/app/etc/env.php ] ; then
        location="${vhostLocation}/app/etc/env.php";
     else
        echo 'env file not found';
        return;
     fi
     sed -i "s/${quotes}dbname${quotes}\s=>\s${quotes}${notQuotes}*${quotes}/'dbname' => '${database}'/g" ${location}
  fi
}

function setupNewLocalMagento2(){
  if [  -z $3 ] || [ "$1" = "--help" ] ; then
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
  if [  -z $3 ] || [ "$1" = "--help" ] ; then
      echo ;
      echo 'git clone, import database, make into vhost, copy env.php & config.php'
      echo ''
      echo 'arguments missing'
      echo 'setupLocalMagento1 <<git url>> <<db file>> <<url>>'
      echo 'setupLocalMagento1 <<sub folder>> <<db file>> <<url>>'
      echo 'or setupLocalMagento1 <<sub folder>> <<db file>> <<url>> <<db>>'
      echo 'To use the current folder as the subfolder use .'
      echo 'please try again'
    else
      local runStaticDeploy subfolder dbfile dbname url scriptDir testSshConnection
      subfolder=$1;
      if [ "$subfolder" = "." ] ; then
        subfolder=$(getCurrentFolderName);
      fi;
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
            dbname=$(createDatabaseName "${dbfile}")
          else
            dbname=$4
          fi
      fi
      dbexists=$(dbExists ${dbname})
        if [ -n "${dbexists}" ]; then
          echo 'already exists';
          return 1
        fi
      import2mysql ${dbfile} ${url} ${dbname};
      dbexists=$(dbExists ${dbname})
        if [ -z "${dbexists}" ]; then
          echo 'db not created';
          return 1
        fi
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
      php bin/magento setup:upgrade
      echo "------- disabling full_page cache and flushing cache -------";
      php bin/magento cache:enable;
      php bin/magento cache:disable full_page;
      php bin/magento cache:flush;
      echo "------- removing generated folders -------";
      rm -rf var/cache/* var/page_cache/* var/view_preprocessed/* var/generation/* var/di/*
      echo "------- generating static files -------";
      if [ "${runStaticDeploy}" = "y" ] ; then
        m2staticFlush
      fi
      echo "------- create test admin user -------";
      n982nu --admin-user="test" --admin-email="t@test.com" --admin-password="password1" --admin-firstname="test" --admin-lastname="test"
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
alias m2composer="echo 'composer update --no-dev;\
 php bin/magento setup:upgrade; \
 php bin/magento setup:di:compile; \
 php bin/magento cache:clean'\
 ; composer update --no-dev;\
 php bin/magento setup:upgrade; \
 php bin/magento setup:di:compile; \
 php bin/magento cache:clean;"
alias m2compile="echo 'php bin/magento setup:di:compile; \
 php bin/magento cache:clean'\
 ; php bin/magento setup:di:compile; \
 php bin/magento cache:clean;"
alias m2upgrade="echo 'php bin/magento setup:upgrade \
 && php bin/magento cache:clean \
 && php bin/magento setup:di:compile'; \
 php bin/magento setup:upgrade \
 && php bin/magento cache:clean \
 && php bin/magento setup:di:compile"
# newer versions claim static deploy is not required but it dosnt work, so we need to run with -f to force it to run
alias m2upgradeNstatic="echo 'php bin/magento setup:upgrade \
 && m2staticFlush \
 && php bin/magento setup:di:compile' \
 ; php bin/magento setup:upgrade \
 && m2staticFlush"
 # newer versions claim static deploy is not required but it dosnt work, so we need to run with -f to force it to run
function m2staticFlush(){
    # --quite stops it returning anything unless theres an error
    echo 'php bin/magento setup:static-content:deploy --quiet --theme="Magento/backend" en_US'
    test=$(php bin/magento setup:static-content:deploy --quiet --theme="Magento/backend" en_US && echo 'success')
    # if we dont have to force the static deploy
    if [ -z "${test}" ]
    then
        echo 'static deploy failed, sttempting to force the statiuc deploy'
        echo 'php bin/magento setup:static-content:deploy -f --quiet --theme="Magento/backend" en_US'
        php bin/magento setup:static-content:deploy -f --quiet --theme="Magento/backend" en_US
        echo 'php bin/magento setup:static-content:deploy -f --quiet en_GB'
        php bin/magento setup:static-content:deploy -f --quiet en_GB
        echo 'php bin/magento cache:clean'
        php bin/magento cache:clean
    else
        echo 'php bin/magento setup:static-content:deploy --quiet en_GB'
        php bin/magento setup:static-content:deploy --quiet en_GB
        echo 'php bin/magento cache:clean'
        php bin/magento cache:clean
    fi
}

function n982nu () {
  if [  -z $1  ] || [ "$1" = "--help" ] ; then
    echo 'arguments missing'
    echo 'e.g.'
    echo '  n98-magerun2.phar admin:user:create --admin-user="my_user_name" --admin-email="example@example.com" --admin-password="mypassword" --admin-firstname="paul" --admin-lastname="test"'
  fi
  # a bug caused by n98 dump with --strip=@development
  echo 'adding administrator user if missing'
  n98-magerun2.phar db:query "INSERT IGNORE INTO authorization_role (role_id, parent_id, tree_level, sort_order,
  role_type, user_id, user_type, role_name) VALUES (1, 0, 1, 1, 'G', 0, '2', 'Administrators')"
  n98-magerun2.phar db:query "INSERT IGNORE INTO authorization_rule (rule_id, role_id, resource_id, privileges, permission)
  VALUES (1, 1, 'Magento_Backend::all', null, 'allow')"
  ###
  echo running n98-magerun2.phar admin:user:create "$@";
  n98-magerun2.phar admin:user:create "$@"
}

function updateMage2Db(){
     if [  -z $2 ] || [ "$1" = "--help" ]; then
          echo ;
          echo 'import database and set to current database in magento setting file'
          echo ''
          echo 'arguments missing'
          echo 'updateMage2Db <<db file>> <<url>'
          echo 'please try again'
    else
        local file url dbname
        file=$1
        url=$2
        dbname=$(createDatabaseName "${file}");
        vhost_file_location=$(get_vhost_location_file "${url}")
        if [ ! -f "${vhost_file_location}" ]; then
            echo "unable to find ${url} in your host files";
            return 1;
        fi
        dbexists=$(dbExists ${dbname})
        if [ -n "${dbexists}" ]; then
          echo 'db already created';
          return 1
        fi
        echo "-------importing database--------"
        import2mysql "${file}" "${url}" "${dbname}"
        dbexists=$(dbExists ${dbname})
        if [ -z "${dbexists}" ]; then
          echo 'db not created';
          return 1
        fi
        echo "-------updating env.php--------"
        update_envphp "${dbname}" "${url}"
        echo "------- setting developer mode -------";
        vhostLocation=$(getVhostLocation "${url}")
        if [ -f  ${vhostLocation}/../app/etc/env.php ] ; then
           location="${vhostLocation}";
        elif [ -f  ${vhostLocation}/app/etc/env.php ] ; then
           location="${vhostLocation}/pub";
        else
           echo 'env file not found';
           return;
        fi
        cd "${location}"
        cd ..
        php bin/magento deploy:mode:set developer;
        echo "------- magento packages upgrade -------";
        php bin/magento setup:upgrade;
        echo "------- disabling full_page cache and flushing cache -------";
        php bin/magento cache:enable;
        php bin/magento cache:disable full_page;
        php bin/magento cache:flush;
        echo "------- removing generated folders -------";
        rm -rf var/cache/* var/page_cache/* var/view_preprocessed/* var/generation/* var/di/*
        echo "------- create test admin user -------";
        n982nu --admin-user="test" --admin-email="t@test.com" --admin-password="password1" --admin-firstname="test" --admin-lastname="test"
        echo 'new user created:'
        echo 'user:test '
        echo 'password:password1 '
    fi
}


