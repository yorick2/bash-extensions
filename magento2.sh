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

      if [ "$subfolder" = "." ] ; then
        subfolder=$(getCurrentFolderName);
      fi;

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
      # if a git repo used
      if [[ "${1}" == *'.git' ]] ; then
        setupNewLocalMagento2 $1 $2 $3 $4 $5
        return 1;
      fi

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
      importMage2mysql ${dbfile} ${url} ${dbname};
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
      echo "------- disabling full_page cache and flushing cache -------";
      php bin/magento cache:enable;
      php bin/magento cache:disable full_page;
      php bin/magento cache:flush;
      echo "------- setting developer mode -------";
      php bin/magento deploy:mode:set developer;
      echo "------- magento packages upgrade -------";
      php bin/magento setup:upgrade
      echo "------- removing generated folders -------";
      rm -rf var/cache/* var/page_cache/* var/view_preprocessed/* var/generation/* var/di/*
      echo "------- generating static files -------";
      if [ "${runStaticDeploy}" = "y" ] ; then
        m2static
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

alias n982="echoAndRun n98-magerun2.phar"
alias n982pass="echoAndRun n98-magerun2.phar admin:user:change-password"
alias n982re="echoAndRun  n98-magerun2.phar indexer:reindex"
alias n982st="echoAndRun n98-magerun2.phar cache:status"
alias n982fl="echoAndRun n98-magerun2.phar cache:flush"
alias n982en="echoAndRun n98-magerun2.phar cache:enable"
alias n982dis="echoAndRun n98-magerun2.phar cache:disable"

alias m2="echoAndRun  php bin/magento"
alias m2re="echoAndRun  php bin/magento indexer:reindex"
alias m2st="echoAndRun  php bin/magento cache:status"
alias m2fl="echoAndRun  php bin/magento cache:flush"
alias m2en="echoAndRun  php bin/magento cache:enable"
alias m2dis="echoAndRun  php bin/magento cache:disable"
alias m2dis_without_full_page="echoAndRun 'php bin/magento cache:enable && php bin/magento cache:disable full_page'"
alias m2DevMode="echoAndRun 'php bin/magento deploy:mode:set developer'"
alias m2ProdMode="echoAndRun 'php bin/magento deploy:mode:set production'"
alias m2modules="echoAndRun 'php bin/magento module:status'"

alias m2composerupdate="echoAndRun 'composer update --no-dev &&\
 php bin/magento setup:upgrade && \
 php bin/magento setup:di:compile && \
 touch pub/static/deployed_version.txt && \
 m2static && \
 php bin/magento cache:clean'"
alias m2composerinstall="echoAndRun 'composer install --no-dev &&\
 php bin/magento setup:upgrade && \
 php bin/magento setup:di:compile && \
 touch pub/static/deployed_version.txt && \
 m2static && \
 php bin/magento cache:clean'"
function m2composer(){
    echo 'Composer update or install?'
    echo 'install [i]'
    echo 'update  [u]'
    read option
    if [ -z "${option}" ]; then
        echo 'answer not recognised, please try again';
        return 1
    fi
    if [ "${option}" = "i" ]; then
        m2composerinstall
        return 1
    fi
    if [ "${option}" = "u" ]; then
        m2composerupdate
        return 1
    fi
    echo 'answer not recognised, please try again';
}

alias m2compile="echoAndRun 'php bin/magento setup:di:compile; \
touch pub/static/deployed_version.txt; \
 php bin/magento cache:clean'"
alias m2upgrade="echoAndRun 'php bin/magento setup:upgrade \
 && php bin/magento cache:clean \
 && php bin/magento setup:di:compile \
 && touch pub/static/deployed_version.txt'"
# newer versions claim static deploy is not required but it dosnt work, so we need to run with -f to force it to run
alias m2upgradeNstatic="echoAndRun 'php bin/magento setup:upgrade \
 && m2static '"

 # newer versions claim static deploy is not required but it dosnt work, so we need to run with -f to force it to run
function m2static(){
    if [ "$1" = "--help" ] ; then
      echo ;
      echo 'build statics the supplied language or '
      echo 'builds for en_GB and the backend for en_US '
      echo 'm2static'
      echo 'm2static <<language>>'
      echo ''
      return 1;
    fi
    if [  -z $1  ]; then
        # --quite stops it returning anything unless there is an error
        echo 'php bin/magento setup:static-content:deploy --quiet --theme="Magento/backend" en_US'
        test=$(php bin/magento setup:static-content:deploy --quiet --theme="Magento/backend" en_US && echo 'success')
        # if we have to force the static deploy
        if [ -z "${test}" ]
        then
            echo 'static deploy failed, attempting to force the static deploy'
            echo 'php bin/magento setup:static-content:deploy -f --quiet --theme="Magento/backend" en_US'
            php bin/magento setup:static-content:deploy -f --quiet --theme="Magento/backend" en_US
            echo "php bin/magento setup:static-content:deploy -f --quiet en_GB"
            php bin/magento setup:static-content:deploy -f --quiet en_GB
            echo 'php bin/magento cache:clean'
            php bin/magento cache:clean
        else
            echo "php bin/magento setup:static-content:deploy --quiet en_GB"
            php bin/magento setup:static-content:deploy --quiet en_GB
            echo 'php bin/magento cache:clean'
            php bin/magento cache:clean
        fi
    else
        # --quite stops it returning anything unless there is an error
        echo php bin/magento setup:static-content:deploy --quiet --theme="Magento/backend" ${1}
        test=$(php bin/magento setup:static-content:deploy --quiet --theme="Magento/backend" ${1} && echo 'success')
        # if we have to force the static deploy
        if [ -z "${test}" ]
        then
            echo "php bin/magento setup:static-content:deploy -f --quiet en_GB"
            php bin/magento setup:static-content:deploy -f --quiet en_GB
            echo 'php bin/magento cache:clean'
            php bin/magento cache:clean
        else
            echo 'php bin/magento cache:clean'
            php bin/magento cache:clean
        fi
    fi
}

 # newer versions claim static deploy is not required but it dosnt work, so we need to run with -f to force it to run
function m2staticAll(){
    # --quite stops it returning anything unless there is an error
    echo 'php bin/magento setup:static-content:deploy --quiet --theme="Magento/backend" en_US'
    test=$(php bin/magento setup:static-content:deploy --quiet --theme="Magento/backend" en_US && echo 'success')
    languages=$(n98-magerun2.phar db:query 'select value from core_config_data where path="general/locale/code";');
    languages=${languages/value/} # remove the column header from the list
    languages=${languages//$'\n'/ } # replace new lines with a space
    # if we have to force the static deploy
    if [ -z "${test}" ]
    then
        echo 'static deploy failed, attempting to force the static deploy'
        echo 'php bin/magento setup:static-content:deploy -f --quiet --theme="Magento/backend" en_US'
        php bin/magento setup:static-content:deploy -f --quiet --theme="Magento/backend" en_US
        echo "php bin/magento setup:static-content:deploy -f --quiet ${languages}"
        php bin/magento setup:static-content:deploy -f --quiet ${languages}
        echo 'php bin/magento cache:clean'
        php bin/magento cache:clean
    else
        echo "php bin/magento setup:static-content:deploy --quiet ${languages}"
        php bin/magento setup:static-content:deploy --quiet ${languages}
        echo 'php bin/magento cache:clean'
        php bin/magento cache:clean
    fi
}

function n982nu () {
  if [  -z $1  ] || [ "$1" = "--help" ] ; then
    echo 'arguments missing'
    echo 'e.g.'
    echo '  n98-magerun2.phar admin:user:create --admin-user="my_user_name" --admin-email="example@example.com" --admin-password="mypassword" --admin-firstname="paul" --admin-lastname="test"'
    return;
  fi
  # a bug caused by n98 dump with --strip=@development
  echo 'adding administrator user if missing'
  n98-magerun2.phar db:query "delete From authorization_role where role_id=1;";
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
          echo "db ${dbname} already exists";
          return 1
        fi
        echo "-------importing database--------"
        importMage2mysql "${file}" "${url}" "${dbname}"
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


# import sql file into sql database it creates
function importMage2mysql(){
  if [  -z $2  ] || [ "$1" = "--help" ] ; then
    echo ;
    echo 'arguments missing';
    echo 'importMage2mysql <<db file>> <<url>> or importMage2mysql <db file>> <<url>> <<db>>';
    echo 'for files on remote server ';
    echo 'importMage2mysql <<login details>>:<<db file>> <<url>> or importMage2mysql <db file>> <<url>> <<db>>';
    echo 'eg. importMage2mysql user@example.com:~/example.sql l.example';
    echo 'please try again';
    return 1;
  fi
  local file url db fileextension prevfileextension testSshConnection
  file=$1;
  url=$2;
  db=$3;
  if [[ ${file} == *':'* ]] ; then
      echo '-->  testing ssh connection'
      testSshConnection=$(testSshConnection ${file%:*});
      if [[ "$testSshConnection" != 'true' ]]; then
          echo 'unable to download database: connection failed'
          return 1;
      fi
      echo '-->  downloading db file'
      rsync -ahz -e "ssh -o StrictHostKeyChecking=no" ${file} $(dbsLocation) &&
      file=${file##*:} &&
      file=${file##*/}
      file="$(dbsLocation)/${file}"
  fi
  if [ ! -f "${file}" ]; then
      echo 'database file dosent exist';
      return 1;
  fi
  fileextension="${file##*.}"; # last file extension if example.sql.tar.gz it returns gz if example.sql returns sql
  if [[ -z "${db}" ]]; then
      db=$(createDatabaseName ${file} )
  fi
  # if sql file
  if [[ ${fileextension} == "sql" ]]; then
    echo "--> sql file detected"
    sql2mysql ${file} ${url} ${db};
  # if ****.zip file
  elif [[ ${fileextension} == "zip" ]]; then
    echo "--> zip file detected"
    zip2mysql ${file} ${url} ${db};
  # if ****.gz file
  elif [[ ${fileextension} == "gz" ]]; then
    prevfileextension=${file%.gz};
    prevfileextension=${prevfileextension##*.};
    # if tar.gz file
    if [[ ${prevfileextension} == "tar" ]]; then
      echo "--> tar.gz file detected"
      tar2mysql ${file} ${url} ${db};
    else
      echo "--> gz file detected"
      gz2mysql ${file} ${url} ${db};
    fi
  else
    echo "error: unrecognised file format";
    return 1;
  fi

  echo '-->updating db'
  table='core_config_data'
  # for magento 1 & 2
  cmd="update ${db}.${table} set value='http://${url}/' where path='web/secure/base_url';"

  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set value='http://${url}/' where path='web/unsecure/base_url';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set VALUE='test@test.com' where PATH like '%email%' AND VALUE like '%@%';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set VALUE='31536000' where path='admin/security/session_lifetime';"
  localMysqlConnection -e"${cmd}"

  # for magento 1
  cmd="update ${db}.${table} set value='{{secure_base_url}}' where path='web/secure/base_link_url';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set value='{{secure_base_url}}js/' where path='web/secure/base_js_url';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set value='{{secure_base_url}}media/' where path='web/secure/base_media_url';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set value='{{secure_base_url}}skin/' where path='web/secure/base_skin_url';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set value='{{secure_base_url}}static/' where path='web/secure/base_static_url';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set value='{{unsecure_base_url}}' where path='web/unsecure/base_link_url';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set value='{{unsecure_base_url}}js/' where path='web/unsecure/base_js_url';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set value='{{unsecure_base_url}}media/' where path='web/unsecure/base_media_url';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set value='{{unsecure_base_url}}skin/' where path='web/unsecure/base_skin_url';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set value='{{unsecure_base_url}}static/' where path='web/unsecure/base_static_url';"
  localMysqlConnection -e"${cmd}"
  cmd="delete from ${db}.${table} where path='web/cookie/cookie_domain';"
  localMysqlConnection -e"${cmd}"
  # check/money order
  cmd="update ${db}.${table} set VALUE='1' where PATH='payment/checkmo/active'"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set VALUE='0' where PATH='payment/checkmo/min_order_total'"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set VALUE='999999999' where PATH='payment/checkmo/max_order_total'"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set VALUE='0' where PATH='payment/checkmo/allowspecific'"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set VALUE='0' where PATH='system/guidance_cachebuster/is_enabled'"
  localMysqlConnection -e"${cmd}"

  # for magento 2
  cmd="update ${db}.${table} set VALUE='0' where PATH='web/secure/use_in_frontend';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set VALUE='0' where PATH='web/secure/use_in_admin';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set VALUE='0' where PATH='dev/css/merge_css_files';"
  localMysqlConnection -e"${cmd}"
  cmd="update ${db}.${table} set VALUE='0' where PATH='dev/js/merge_files';"
  localMysqlConnection -e"${cmd}"

  echo '-->import complete'
  echo "your database name is ${db}"
}
