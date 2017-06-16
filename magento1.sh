#!/usr/bin/env bash

############ magento 1 #########
# n98-magerun.phar
alias n98='echo running n98-magerun.phar; n98-magerun.phar'
alias n98fl='echo running n98-magerun.phar cache:flush; n98-magerun.phar cache:flush'
alias n98list='echo running n98-magerun.phar admin:user:list; n98-magerun.phar admin:user:list'
alias n98nu='echo running n98-magerun.phar admin:user:create; n98-magerun.phar admin:user:create'
alias n98pass='echo running n98-magerun.phar admin:user:change-password; n98-magerun.phar admin:user:change-password'
alias n98re='echo running n98-magerun.phar index:reindex:all; n98-magerun.phar index:reindex:all'
alias n98dis='echo running n98-magerun.phar cache:disable; n98-magerun.phar cache:disable'


alias rmcache='echo "rm -rf var/cache/* var/session/*"; rm -rf var/cache/* var/session/*'

function echoHtaccessMage1() {
  scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/htaccess
}

function copyHtaccessMage1() {
  scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/htaccess | xclip -selection clipboard
}

function echoLocalXmlTemplate() {
  scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/local.xml
}

function copyLocalXmlTemplate() {
  scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
  cat ${scriptDir}/local_setup_files/local.xml | xclip -selection clipboard
}

# update local.xml with new db details (for magento 1.**)
function update_localxml() {
    vhost_file_location=$(get_vhost_location_file)

   if [  -z $1  ] || [  -z $2 ] ; then
     echo ;
     echo 'arguments missing'
     echo 'update_localxml <<db>> <<url>>'
     echo 'please try again'
   else
     database=$1
     url=$2
     grepped=$(grep -B 7 -A 8  "${url}" ${vhost_file_location})
     location=$(getVhostLocation "${url}")
     sed -i "s/<dbname>.*<\/dbname>/<dbname><\!\[CDATA\[${database}\]\]><\/dbname>/g" ${location}/app/etc/local.xml
  fi
}

setupNewLocalMagento1(){
  if [  -z $1  ] || [  -z $2 ] || [  -z $3 ] ; then
      echo ;
      echo 'git clone, import database, make into vhost, add .htaccess, copy local.xml'
      echo "dosn't download git repo or create folder"
      echo ''
      echo 'arguments missing'
      echo 'setupNewLocalMagento1 <<git url>> <<db file>> <<url>>'
      echo 'or setupNewLocalMagento1 <<git url>> <<db file>> <<url>> <<htdocs location>>'
      echo 'or setupNewLocalMagento1 <<git url>> <<db file>> <<url>> <<htdocs location>> <<db>>'
      echo 'please try again'
    else
      giturl=$1;
      dbfile=$2;
      url=$3;
      htdocsLocation=$4;
      dbname=$5;

      subfolder=${giturl%.git};
      subfolder=${subfolder##*/};

      if [ -d "$subfolder" ] ; then
        echo "error: subfolder  ${subfolder} already used, please clone the git repository and use setupLocalMagento1";
      fi

      git clone ${giturl} ${subfolder};
      cd ${subfolder}
      composer install --no-dev
      echo "setupLocalMagento1 ${subfolder} ${dbfile} ${url} ${htdocsLocation} ${dbname}";
    fi
}


# make vhost and setup magento
######## needs work ########
function setupLocalMagento1() {
  if [  -z $1  ] || [  -z $2 ] || [  -z $3 ] ; then
      echo ;
      echo 'import database, make into vhost, add .htaccess, copy local.xml'
      echo "dosn't download git repo or create folder"
      echo ''
      echo 'arguments missing'
      echo 'setupLocalMagento1 <<sub folder>> <<db file>> <<url>>'
      echo 'or setupLocalMagento1 <<sub folder>> <<db file>> <<url>> <<htdocs location>>'
      echo 'or setupLocalMagento1 <<sub folder>> <<db file>> <<url>> <<htdocs location>> <<db>>'
      echo 'please try again'
    else
      subfolder=$1;
      if [[ "${2}" == *'.'* ]] ; then
        dbfile=$2;
      else
        dbname=$2;
      fi
      url=$3;
      if [ -z ${dbname} ] ; then
          if [  -z $5  ]; then
            dbname=${dbfile%.*};
            dbname=${dbname%.tar};
            dbname=${dbname%.sql};
            dbname=${dbname##*:};
            dbname=${dbname##*/};
            dbname=${dbname//[-.]/_}; #make db name valid when created from filenames not valid db names
          else
            dbname=$5
          fi
          echo "------- importing database -------";
          import2mysql ${dbfile} ${url} ${dbname};
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
      cp ${scriptDir}/local_setup_files/htaccess .htaccess  ###### <<<<<<<<<<< location not always right, composer puts everything in htdocs folder
      echo "------- copying local.xml -------";
      cp ${scriptDir}/local_setup_files/local.xml app/etc   ###### <<<<<<<<<<< location not always right, composer puts everything in htdocs folder
      echo "------- updating local.xml -------";
      update_localxml "${dbname}" "${url}";
      echo "------- flushing cache -------";
      n98-magerun.phar cache:flush;
      echo ran 'n98-magerun.phar cache:flush' here:
      pwd
      echo 'n98 sometimes throws an error on this line, just ignore it'
      #echo "------- reindexing -------";
      #n98-magerun.phar index:reindex:all;
      echo 'mamp users: please restart mamp'
    fi
}
alias setupMage1='setupLocalMagento1';