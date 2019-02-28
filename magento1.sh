#!/usr/bin/env bash

############ magento 1 #########
# n98-magerun.phar
alias n98='echoAndRun  n98-magerun.phar'
alias n98fl='echoAndRun  n98-magerun.phar cache:flush'
alias n98list='echoAndRun  n98-magerun.phar admin:user:list'
alias n98nu='echoAndRun  n98-magerun.phar admin:user:create'
alias n98pass='echoAndRun  n98-magerun.phar admin:user:change-password'
alias n98re='echoAndRun  n98-magerun.phar index:reindex:all'
alias n98dis='echoAndRun  n98-magerun.phar cache:disable'


alias rmcache='echo "rm -rf var/cache/* var/session/*"; rm -rf var/cache/* var/session/*'

function echoHtaccessMage1() {
  local scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/htaccess
}

function copyHtaccessMage1() {
  local scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/htaccess | xclip -selection clipboard
}

function echoLocalXmlTemplate() {
  local scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/local.xml
}

function copyLocalXmlTemplate() {
  local scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/local.xml | xclip -selection clipboard
}

# update local.xml with new db details (for magento 1.**)
function update_localxml() {
   if [  -z $2 ] || [ "$1" = "--help" ] ; then
     echo ;
     echo 'arguments missing'
     echo 'update_localxml <<db>> <<url>>'
     echo 'please try again'
   else
     local database=$1
     local url=$2
     local location=$(getVhostLocation "${url}")
     sed -i "s/<dbname>.*<\/dbname>/<dbname><\!\[CDATA\[${database}\]\]><\/dbname>/g" ${location}/app/etc/local.xml
  fi
}


function setupNewLocalMagento1(){
  if [  -z $3 ] || [ "$1" = "--help" ] ; then
      echo ;
      echo 'git clone, import database, make into vhost, add .htaccess, copy local.xml'
      echo ''
      echo 'arguments missing'
      echo 'setupNewLocalMagento1 <<git url>> <<db file>> <<url>>'
      echo 'or setupNewLocalMagento1 <<git url>> <<db file>> <<url>> <<htdocs location>>'
      echo 'or setupNewLocalMagento1 <<git url>> <<db file>> <<url>> <<htdocs location>> <<db>>'
      echo 'please try again'
    else
      local subfolder testSshConnection
      local giturl=$1;
      local dbfile=$2;
      local url=$3;
      local htdocsLocation=$4;
      local dbname=$5;

      subfolder=${giturl%.git};
      subfolder=${subfolder##*/}


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
      setupLocalMagento1 ${subfolder} ${dbfile} ${url} ${htdocsLocation} ${dbname};
    fi
}


# make vhost and setup magento
######## needs work ########
function setupLocalMagento1() {
  if [  -z $3 ] || [ "$1" = "--help" ] ; then
      echo ;
      echo 'import database, make into vhost, add .htaccess, copy local.xml'
      echo ''
      echo 'arguments missing'
      echo 'setupLocalMagento1 <<git url>> <<db file>> <<url>>'
      echo 'setupLocalMagento1 <<sub folder>> <<db file>> <<url>>'
      echo 'or setupLocalMagento1 <<sub folder>> <<db file>> <<url>> <<htdocs location>>'
      echo 'or setupLocalMagento1 <<sub folder>> <<db file>> <<url>> <<htdocs location>> <<db>>'
      echo 'To use the current folder as the subfolder use .'
      echo 'please try again'
    else
      local subfolder dbfile dbname url htdocsLocation scriptDir testSshConnection dbexists
      subfolder=$1;
      if [ "$subfolder" = "." ] ; then
        subfolder=$(getCurrentFolderName);
      fi;
      if [[ "${2}" == *'.'* ]] ; then
        dbfile=$2;
      else
        dbname=$2;
      fi

      if [[ ${dbfile} == *':'* ]] ; then
          testSshConnection=$(testSshConnection ${dbfile%:*});
          if [[ "$testSshConnection" != 'true' ]]; then
            echo 'unable to download database: connection failed'
            return;
          fi
      fi

      # if a git repo used
      if [[ "${1}" == *'.git' ]] ; then
        setupNewLocalMagento1 $1 $2 $3 $4 $5
        return 1;
      fi

      url=$3;
      if [ -z ${dbname} ] ; then
          if [  -z $5  ]; then
            dbname=$(createDatabaseName "${dbfile}")
          else
            dbname=$5
          fi
      fi

      if [ -f "composer.json" ]; then
        echo "------- composer update -------";
        composer install --no-dev
      fi

      echo "------- importing database -------";
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

      if [ -z $4 ] ; then
        sites;
        if [ -d "${subfolder}/htdocs" ] ; then
            htdocsLocation="htdocs"
        fi
      elif [[ "$4" = '.' ]] ; then
          htdocsLocation='';
      else
          htdocsLocation=$4
      fi

      echo "------- making vhost -------";
      repo # move to repos folder
      if [  -z ${htdocsLocation}  ] ; then
          mkvhost ${subfolder} ${url};
      else
          mkvhost "${subfolder}/$htdocsLocation" ${url};
      fi

      echo "------- adding .htaccess -------";
      sites; # move to repos folder
      cd ${subfolder}
      if [ ! -z ${htdocsLocation} ] ; then
        cd ${htdocsLocation}
      fi
      scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
      cp ${scriptDir}/local_setup_files/htaccess .htaccess

      echo "------- copying local.xml -------";
      cp ${scriptDir}/local_setup_files/local.xml app/etc

      echo "------- updating local.xml -------";

      update_localxml "${dbname}" "${url}";

      echo '-------- create media cache folder--------'
      if [ ! -d "media/cache" ] ; then
         mkdir -p "media/cache"
      fi

      echo "------- disabling and flushing cache -------";
      n98-magerun.phar cache:disable
      echo ran 'n98-magerun.phar cache:disable'
      n98-magerun.phar cache:flush;
      echo ran 'n98-magerun.phar cache:flush'
      echo "------- create test admin user -------";
      echo ran 'n98-magerun.phar admin:user:create  test t@test.com password1 a testman'
      n98-magerun.phar admin:user:create  test t@test.com password1 a testman
      echo 'new user created:'
      echo 'user:test'
      echo 'password:password1'
      pwd
      echo 'n98 sometimes throws an error on this line, just ignore it'
      #echo "------- reindexing -------";
      #n98-magerun.phar index:reindex:all;
      echo 'mamp users: please restart mamp'
    fi
}
alias setupMage1='setupLocalMagento1';

function updateMage1Db(){
     if [  -z $2 ] || [ "$1" = "--help" ]; then
          echo ;
          echo 'import database and set to current database in magento setting file'
          echo ''
          echo 'arguments missing'
          echo 'updateMage1Db <<db file>> <<url>'
          echo 'please try again'
          return 1;
    fi
    local file url dbname vhostLocation vhost_file_location dbexists
    file=$1
    url=$2
    vhost_file_location=$(get_vhost_location_file "${url}")
    if [ ! -f "${vhost_file_location}" ]; then
        echo "unable to find ${url} in your host files";
        return 1;
    fi
    vhostLocation=$(getVhostLocation "${url}")
    if [ ! -f "${vhostLocation}/app/etc/local.xml" ]; then
        echo "Please check this is a magento 1 site and it has a local.xml file";
        return 1;
    fi
    dbname=$(createDatabaseName "${file}");
    dbexists=$(dbExists ${dbname})
    if [ -n "${dbexists}" ]; then
      echo "db ${dbname} already exists";
      return 1
    fi
    echo "-------importing database--------"
    importMage2mysql "${file}" "${url}" "${dbname}"
    dbexists=$(dbExists ${dbname})
    if [ -z "${dbexists}" ]; then
      echo 'db not created. It already exists';
      return 1
    fi
    echo "-------updating local.xml--------"
    update_localxml "${dbname}" "${url}"
    echo "------- flushing cache -------";
    cd ${vhostLocation}
    n98-magerun.phar cache:disable;
    n98-magerun.phar cache:flush;
    echo ran 'n98-magerun.phar cache:flush'
    echo "------- create test admin user -------";
    echo ran 'n98-magerun.phar admin:user:create  test t@test.com password1 a testman'
    n98-magerun.phar admin:user:create  test t@test.com password1 a testman
    echo 'new user created:'
    echo 'user:test '
    echo 'password:password1 '
}