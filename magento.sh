#!/usr/bin/env bash
############ magento 1 #########
# n98-magerun.phar
alias n98='echo running n98-magerun.phar; n98-magerun.phar'
alias n98fl='echo running n98-magerun.phar cache:flush; n98-magerun.phar cache:flush'
alias n98nu='echo running n98-magerun.phar admin:user:create; n98-magerun.phar admin:user:create'
alias n98pass='echo running n98-magerun.phar admin:user:change-password; n98-magerun.phar admin:user:change-password'
alias n98re='echo running n98-magerun.phar index:reindex:all; n98-magerun.phar index:reindex:all'
alias n98dis='echo running n98-magerun.phar cache:disable; n98-magerun.phar cache:disable'


alias rmcache='echo "rm -rf var/cache/* var/session/*"; rm -rf var/cache/* var/session/*'
alias echoLocalXmlTemplate='scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; cat ${scriptDir}/local_setup_files/local.xml'


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
        echo dbfile
        dbfile=$2;
      else
        echo dbname
        dbname=$2;
      fi
      url=$3;

      if [ -z $4 ] ; then
        if [ -e "/Users/Paul/Documents/Repositories/sites/${subfolder}/htdocs" ] ; then
            htdocsLocation="htdocs"
        fi
      else
            htdocsLocation=$4
      fi
      if [ -z ${dbname} ] ; then
          if [  -z $5  ]; then
            dbname=${dbfile%.*};
            dbname=${dbname%.tar};
            dbname=${dbname##*/};
            dbname=${dbname//[-.]/_}; #make db name valid when created from filenames not valid db names
          else
            dbname=$5
          fi
          echo "------- importing database -------";
          import2mysql ${dbfile} ${url} ${dbname};
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


#########################################
#             magento 2
#########################################

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
      echo 'or setupLocalMagento1 <<sub folder>> <<db file>> <<url>> <<htdocs location>>'
      echo 'or setupLocalMagento1 <<sub folder>> <<db file>> <<url>> <<htdocs location>> <<db>>'
      echo 'please try again'
    else
      subfolder=$1;
      if [[ "${2}" == *'.'* ]] ; then
        echo dbfile
        dbfile=$2;
      else
        echo dbname
        dbname=$2;
      fi
      url=$3;

      if [ -z $4 ] ; then
        if [ -e "/Users/Paul/Documents/Repositories/sites/${subfolder}/htdocs" ] ; then
            htdocsLocation="htdocs"
        fi
      else
            htdocsLocation=$4
      fi
      if [ -z ${dbname} ] ; then
          if [  -z $5  ]; then
            dbname=${dbfile%.*};
            dbname=${dbname%.tar};
            dbname=${dbname##*/};
            dbname=${dbname//[-.]/_}; #make db name valid when created from filenames not valid db names
          else
            dbname=$5
          fi
          echo "------- importing database -------";
          import2mysql ${dbfile} ${url} ${dbname};
      fi
      echo "------- making vhost -------";
      repo # move to repos folder
      if [  -z ${htdocsLocation}  ] ; then
          mkvhost ${subfolder} ${url};
      else
          mkvhost "${subfolder}/$htdocsLocation" ${url};
      fi
      echo "------- adding magento settings files -------";
      sites; # move to repos folder
      cd ${subfolder}
      if [ ! -z ${htdocsLocation} ] ; then
        cd ${htdocsLocation}
      fi
      scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
      cp ${scriptDir}/local_setup_files/magento2/env.php app/etc/env.php
      sed -i "s/<<<database>>>>/${dbname}/g" app/etc/env.php
      echo "------- magento packages upgrade -------";
      php bin/magento setup:upgrade
      echo "------- flushing cache -------";
      n98-magerun2.phar cache:flush;
      echo "------- removing generated folders -------";
      rm -rf var/cache/* var/page_cache/* var/view_preprocessed/* var/generation/* var/di/*
      echo "------- generating static files -------";
      php bin/magento setup:static-content:deploy
      php bin/magento setup:static-content:deploy en_GB
      echo 'mamp users: please restart mamp'
    fi
}


alias n982='echo running n98-magerun2.phar; n98-magerun2.phar'
alias n982fl='echo running n98-magerun2.phar cache:flush; n98-magerun2.phar cache:flush'
alias n982nu='echo running n98-magerun2.phar admin:user:create; n98-magerun2.phar admin:user:create'
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