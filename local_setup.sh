#!/usr/bin/env bash

#######################################
#  get the name of the current folder without full folder path
#######################################
function getCurrentFolderName(){
    echo "${PWD##*/}";
}

#######################################
# create safe db name from filename
# example: folder/myWebsite-name.database.tar.gz
#######################################
function createDatabaseName(){
    if [  -z $1  ] || [ "$1" = "--help" ] ; then
        echo 'create safe db name from filename';
        echo '';
        echo 'arguments missing';
        echo 'createDatabaseName <<database filename>>';
        echo 'please try again';
        return;
    fi
    local dbfile dbname
    dbfile=$1
    dbname=${dbfile%.*};
    dbname=${dbname%.zip};
    dbname=${dbname%.gz};
    dbname=${dbname%.tar};
    dbname=${dbname%.sql};
    dbname=${dbname##*:};
    dbname=${dbname##*/};
    dbname=${dbname//[-.]/_}; #make db name valid when created from filenames not valid db names
    echo "${dbname}"
}

#######################################
# lists databases in mysql
# example: listdbs example.c
#######################################
function listdbs() {
  if [ "$1" = "--help" ] ; then
    echo "lists databases in mysql"
    echo "e.g."
    echo "listdbs"
    echo "listdbs <<search needle>>"
    echo "please try again"
  fi
  if [ -z $1  ] ; then
    localMysqlConnection -e'show databases' ;
    return;
  fi
  localMysqlConnection -e'show databases' | grep "${1}"
}

#######################################
# test an ssh connection
#######################################
testSshConnection () {
    if [  -z $1  ] || [ "$1" = "--help" ] ; then
        echo ;
        echo 'arguments missing'
        echo 'testSshConnection <<ssh details>>'
        echo 'e.g.'
        echo 'testSshConnection root@test.com'
        echo 'please try again'
        return;
    fi
    local testSshConnection=$( ( ssh -oStrictHostKeyChecking=no $1 "echo true;" ) & sleep 5 ; kill $! 2>/dev/null; )
    if [ "${testSshConnection}" != "true" ]; then
        echo 'ssh connection failed'
        return;
    fi
    echo 'true';
}

#######################################
# import sql file inside a tar.gz file into sql database it creates (only works for ***.tar.gz files not ***.sql.tar.gz)
#######################################
function tar2mysql() {
  if [  -z $1 ] || [ "$1" = "--help" ] ; then
    echo ;
    echo 'arguments missing'
    echo 'tar2mysql <<file>> or tar2mysql <<file>> <<db>>'
    echo 'please try again'
    echo '';
  else
    local file db
    file=$1
    db=$2
    echo '-->uncompressing file'
    tar -xzvf ${file} --directory="$(dbsLocation)" &&
    file=${file%.gz} &&
    file=${file%.tar} &&
    file=${file%.sql} &&
    file=${file##*/} &&
    sql2mysql $(dbsLocation)/${file}.sql ${db}  &&
    echo '-->removing sql' &&
    rm $(dbsLocation)/${file}.sql
  fi
}

#######################################
# import sql file inside a gz file into sql database it creates
#######################################
function gz2mysql() {
  if [  -z $1 ] || [ "$1" = "--help" ] ; then
    echo ;
    echo 'arguments missing'
    echo 'gz2mysql <<file>> or gz2mysql <<file>> <<db>>'
    echo 'please try again'
  else
    local file db
    file=$1
    db=$2
    echo ${db}
    echo '-->uncompressing file'
    gunzip -k ${file} &&
    file=${file%.gz} &&
    file=${file%.sql} &&
    sql2mysql ${file}.sql ${db} &&
    echo '-->removing sql'
    rm ${file}.sql
  fi
}

#######################################
# import sql file inside a gz file into sql database it creates
#######################################
function zip2mysql() {
  if [  -z $1 ] || [ "$1" = "--help" ] ; then
    echo ;
    echo 'arguments missing'
    echo 'zip2mysql <<file>> or zip2mysql <<file>> <<db>>'
    echo 'please try again'
  else
    local file db
    file=$1
    db=$2
    echo ${db}
    echo '-->uncompressing file'
    unzip ${file} -d $(dbsLocation) &&
    file=${file%.zip} &&
    file=${file%.sql} &&
    file=${file##*/} &&
    sql2mysql $(dbsLocation)/${file}.sql ${db} &&
    echo '-->removing sql'
    rm $(dbsLocation)/${file}.sql
  fi
}

#######################################
# attempts  to fix known (sanitize) sql issues in a file ready to import
#######################################
function sanitizeSqlFile() {
    if [  -z $1 ] || [ "$1" = "--help" ] ; then
        echo ;
        echo 'arguments missing'
        echo 'sanitiseSqlFile <<file>>'
        echo 'please try again'
        return 1;
    fi;
    local file filecopy
    file="${1}"
    if [ -n "$(cat ${file} | grep ROW_FORMAT=FIXED)" ] ; then
            filecopy="${file}.sanitized"
            sed -e 's/ROW_FORMAT=FIXED//g' ${file} > ${filecopy};
            file="${filecopy}"
    fi
    if [ -n "$(cat ${file} | grep "DATA DIRECTORY='./'" )" ] ; then
        if [[ "${file}" = *".sanitized" ]] ; then
            sed -i -e 's/DATA DIRECTORY=.\.\/.//g' ${file};
        else
            filecopy="${file%.sanitized}.sanitized"
            sed -e 's/DATA DIRECTORY=.\.\/.//g' ${file} > ${filecopy};
            file="${filecopy}"
        fi
    fi
    echo "${file}"
}

#######################################
# import sql file into sql database it creates
#######################################
function sql2mysql() {
    if [  -z $1 ] || [ "$1" = "--help" ] ; then
      echo ;
      echo 'arguments missing'
      echo 'sql2mysql <<file>> or sql2mysql <<file>> <<db>>'
      echo 'please try again'
    else
      local user password file filecopy db dbexists table cmd
      file=$1;
      filecopy=""
      if [  -z $2  ]; then
        db=$(createDatabaseName "${file}")
      else
        db=$2;
      fi
      dbexists=$(localMysqlConnection --batch --skip-column-names -e "SHOW DATABASES LIKE '"${db}"';" | grep "${db}" > /dev/null; echo "$?")
      if [ ${dbexists} -eq 1 ]; then
        file="$(sanitizeSqlFile ${file})"
        echo '-->creating db'
        localMysqlConnection -e"create database ${db}"
        echo '-->importing db'
        echo "localMysqlConnection ${db} < ${file}"
        localMysqlConnection ${db} < ${file}
        echo "your database ${db} is imported"
        if [[ "${file}" = *".sanitized" ]] && [ -e "${file}" ]; then
          echo 'removing sanitised file'
          rm ${file}
        fi
      else
        echo "error: database name ${db} used"
      fi
    fi
}

#######################################
# import sql file into sql database it creates
#######################################
function import2mysql(){
  if [  -z $1  ] || [ "$1" = "--help" ] ; then
    echo ;
    echo 'arguments missing';
    echo 'import2mysql <<db file>> or import2mysql <db file>> <<db>>';
    echo 'for files on remote server ';
    echo 'import2mysql <<login details>>:<<db file>> or import2mysql <db file>> <<db>>';
    echo 'eg. import2mysql user@example.com:~/example.sql l.example';
    echo 'please try again';
    return 1
  fi
  local file db fileextension prevfileextension testSshConnection
  file=$1;
  db=$2;
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
    sql2mysql ${file} ${db};
  # if ****.zip file
  elif [[ ${fileextension} == "zip" ]]; then
    echo "--> zip file detected"
    zip2mysql ${file} ${db};
  # if ****.gz file
  elif [[ ${fileextension} == "gz" ]]; then
    prevfileextension=${file%.gz};
    prevfileextension=${prevfileextension##*.};
    # if tar.gz file
    if [[ ${prevfileextension} == "tar" ]]; then
      echo "--> tar.gz file detected"
      tar2mysql ${file} ${db};
    else
      echo "--> gz file detected"
      gz2mysql ${file} ${db};
    fi
  else
    echo "error: unrecognised file format";
    return 1;
  fi
}

#######################################
# attempt to find vhost file
#######################################
function get_vhost_location_file(){
  if [  -z $1  ] || [ "$1" = "--help" ] ; then
    echo ;
    echo 'arguments missing';
    echo 'get_vhost_location_file <<url>>';
    echo 'please try again';
    return;
  fi;
  local url=$1;
  local vhost_file_location='/Applications/MAMP/conf/apache/extra/httpd-vhosts.conf'
  if [ ! -a "${vhost_file_location}" ]; then
    vhost_folder_location='/etc/apache2/extra';
    if [ ! -d "${vhost_folder_location}" ]; then
      vhost_folder_location='/etc/apache2/sites-enabled';
    fi
    vhost_file_location=$( grep --files-with-matches "${url}" $vhost_folder_location/* | head -1 )
  fi
  echo ${vhost_file_location}
}

#######################################
# get vhost location
#######################################
function getVhostLocation() {
   if [  -z $1  ] || [ "$1" = "--help" ]; then
     echo ;
     echo 'arguments missing';
     echo 'getVhostLocation <<url>>';
     echo 'please try again';
     return 1;
  fi
  local url vhost_file_location string delimter documentRoot
  url=$1

  vhost_file_location=$(get_vhost_location_file "${url}")
  if [ ! -f "${vhost_file_location}" ]; then
     return 1;
  fi
  string=$(cat ${vhost_file_location})
  #
  # add ; to EOL and put into single line
  string=$( echo "${string}" | sed -e 's/$/;/g' | sed ':a;N;$!ba;s/\n//g' );
  # for some reason my system so some systems dont always understand [[[:space:]];] as space or semi-colon, so 
  # spaces -> |
  string=$( echo "${string}" | sed "s/[[:space:]]/|/g");
  # add spaces to allow patern matching of space separeted sections
  delimter='<|*VirtualHost|*\*:80|*>'
  string=$( echo "${string}" | sed "s/${delimter}//g" );
  delimter='<|*\/|*VirtualHost|*>'
  string=$( echo "${string}" | sed -e "s/${delimter}/ /g" );
  # return section that has our server info
  string=$(echo "${string}" | grep -oe "[^ ]*ServerName[|;][|;]*${url}[|;][|;]*[^ ]*")
  # retrun the folderloaction
  documentRoot=$(echo "${string}" | grep -oe "DocumentRoot[|]*[^ ;]*" | sed -e "s/^DocumentRoot['|]*//g" | sed -e "s/['|]*$//g" | sed -e 's/"*//g' )
  # add back  any required spaces
  documentRoot=$(echo "${documentRoot}" | sed -e "s/|/ /")
  echo ${documentRoot};
}

#######################################
# make vhost
#######################################
function mkvhost() {
    if [  -z $2 ] || [ "$1" = "--help" ] ; then
      echo ;
      echo 'sets up a vhost (adds to hotst file and httpd-vhosts.conf file)'
      echo ''
      echo 'arguments missing'
      echo 'mkvhost <<sub folder>> <<url>>'
      echo 'To use the current folder as the subfolder use .'
      echo 'please try again'
    else
      local subfolder scriptDir httpdvhosts https_vhosts hostsfile setupfile magentoSubfolder url restart regexSubfolder userDir

      scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
      #--file locations--
      httpdvhosts='/Applications/MAMP/conf/apache/extra/httpd-vhosts.conf';
      if [ ! -e "${httpdvhosts}" ]; then
        httpdvhosts='/etc/apache2/extra/httpd-vhosts.conf';
      fi
      if [ ! -e "${httpdvhosts}" ]; then
        httpdvhosts='/etc/apache2/sites-enabled/httpd-vhosts.conf';
      fi
      #-
      https_vhosts='/Applications/MAMP/conf/apache/extra/httpd-ssl-vhosts.conf';
      if [ ! -e "${https_vhosts}" ]; then
        https_vhosts='/etc/apache2/extra/httpsd-ssl-vhosts.conf';
      fi
      if [ ! -e "${https_vhosts}" ]; then
        https_vhosts='/etc/apache2/sites-enabled/httpd-ssl-vhosts.conf';
      fi
       if [ ! -e "${https_vhosts}" ]; then
        https_vhosts='';
      fi
      #-
      hostsfile='/etc/hosts'
      setupfile='${scriptDir}/local_setup_files/vhost_template.txt'
      #------------------
      subfolder=$1;
      if [ "$subfolder" = "." ] ; then
        subfolder=$(getCurrentFolderName);
      fi;
      url=$2;
      restart="false";
      regexSubfolder=${subfolder/\//\\\/}

      if [ ! -w "${httpdvhosts}" ] ; then
            echo "${httpdvhosts} is not writable"
            return
      fi
      if [ ! -w "/etc/hosts" ] ; then
            echo "/etc/hosts is not writable"
            return
      fi

      if grep -q "${url}" /etc/hosts ; then
         echo "--> no need to update hosts file"
      else
      	 echo "--> updating hosts file"
         echo '127.0.0.1 '${url} >> ${hostsfile};
         restart="true";
      fi

      if [ -w "${httpdvhosts}" ] 
      then
        # standard http connection
        if grep -q "${url}" "${httpdvhosts}" ; then
            echo "--> no need to update vhosts file"
        else
            echo "--> updating vhosts file"
            eval userDir=~$(whoami); # get user folder location

            # standard connection
            cp ${scriptDir}/local_setup_files/vhost_template.txt ${scriptDir}/local_setup_files/vhost_template.txt.swp
            sed -i "s/myurl/${url}/" ${scriptDir}/local_setup_files/vhost_template.txt.swp
            sed -i "s/subfolder/${regexSubfolder}/" ${scriptDir}/local_setup_files/vhost_template.txt.swp
            sed -i "s/\~/${userDir//\//\\\/}/" ${scriptDir}/local_setup_files/vhost_template.txt.swp
            cat ${scriptDir}/local_setup_files/vhost_template.txt.swp >> ${httpdvhosts};
            # rm ${scriptDir}/local_setup_files/vhost_template.txt.swp

            restart="true";
        fi
      else 
        echo "--> vhosts file \"${httpdvhosts}\" not writable"
      fi

      if [ "${https_vhosts}" != "" ] && [ -w "${https_vhosts}" ] 
      then
        # https (ssl) connection
        if grep -q "${url}" ${https_vhosts} ; then
            echo "--> no need to update https vhosts file"
        else
            if [ -z "${https_vhosts}" ]; then
              echo "--> no https vhosts file found"
            else
                echo "--> updating https vhosts file"
                eval userDir=~$(whoami); # get user folder location

                # standard connection
                cp ${scriptDir}/local_setup_files/vhost_ssl_template.txt ${scriptDir}/local_setup_files/vhost_ssl_template.txt.swp
                sed -i "s/myurl/${url}/" ${scriptDir}/local_setup_files/vhost_ssl_template.txt.swp
                sed -i "s/subfolder/${regexSubfolder}/" ${scriptDir}/local_setup_files/vhost_ssl_template.txt.swp
                sed -i "s/\~/${userDir//\//\\\/}/" ${scriptDir}/local_setup_files/vhost_ssl_template.txt.swp
                cat ${scriptDir}/local_setup_files/vhost_ssl_template.txt.swp >> ${https_vhosts};
                # rm ${scriptDir}/local_setup_files/vhost_ssl_template.txt.swp

                restart="true";
            fi
        fi
      else 
        echo "--> https vhosts \"${https_vhosts}\" file not writable"
      fi

      if [ "${restart}" = "false" ] ; then
         echo "--> no need to restart server"
      else
         echo "--> restarting server"
         sudo apachectl restart
         echo 'mamp users: please restart mamp'
      fi
    fi  
}

#######################################
# list all my vhosts in hosts file that are local
#######################################
function listhosts(){
  local hosts_file_location string
  hosts_file_location='/etc/hosts';
  if [ -z $1 ] ; then
    string=$( grep '127.0.0.1' ${hosts_file_location} | sed -e"s/127\.0\.0\.1//g" | sort);
  else
    string=$( grep '127.0.0.1' ${hosts_file_location} | grep ${1} | sed -e"s/127\.0\.0\.1//g" | sort);
  fi
  string=$(echo ${string} | sed -e"s/\s/ /g");
  echo ${string};
}
