#!/usr/bin/env bash
function _createDatabaseName(){
    if [  -z $1  ] ; then
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
    dbname=${dbname%.tar};
    dbname=${dbname%.sql};
    dbname=${dbname##*:};
    dbname=${dbname##*/};
    dbname=${dbname//[-.]/_}; #make db name valid when created from filenames not valid db names
    echo "${dbname}"
}

function listdbs() {
  if [  -z $1  ] ; then
    mysql -uroot -proot -e'show databases'
  else
    mysql -uroot -proot -e'show databases' | grep "${1}"
  fi
}

testSshConnection () {
    if [  -z $1  ] ; then
        echo ;
        echo 'arguments missing'
        echo 'testSshConnection <<ssh details>>'
        echo 'e.g.'
        echo 'testSshConnection root@test.com'
        echo 'please try again'
        return;
    fi
    local testSshConnection=$( ( ssh $1 "echo true;" ) & sleep 5 ; kill $! 2>/dev/null; )
    if [ "${testSshConnection}" != "true" ]; then
        echo 'ssh connection failed'
        return;
    fi
    echo 'true';
}

# import sql file inside a tar.gz file into sql database it creates
# only works fro ***.tar.gz files not ***.sql.tar.gz
function tar2mysql() {
  if [  -z $1  ] || [  -z $2 ] ; then
    echo ;
    echo 'arguments missing'
    echo 'tar2mysql <<file>> <<url>> or tar2mysql <<file>> <<url>> <<db>>'
    echo 'please try again'
    echo '';
  else
    local file url db
    file=$1
    url=$2
    db=$3
    echo '-->uncompressing file'
    tar -xzvf ${file} &&
    file=${file%.gz} &&
    file=${file%.tar} &&
    file=${file%.sql} &&
    file=${file##*/} &&
    sql2mysql ${file}.sql ${url} ${db}  &&
    echo '-->removing sql' &&
    rm ${file}.sql
  fi
}

# import sql file inside a gz file into sql database it creates
function gz2mysql() {
  if [  -z $1  ] || [  -z $2 ] ; then
    echo ;
    echo 'arguments missing'
    echo 'gz2mysql <<file>> <<url>> or tar2mysql <<file>> <<url>> <<db>>'
    echo 'please try again'
  else
    local file url db
    file=$1
    url=$2
    db=$3
    echo ${db}
    echo '-->uncompressing file'
    gunzip ${file} &&
    file=${file%.gz} &&
    file=${file%.sql} &&
    sql2mysql ${file}.sql ${url} ${db} &&
    echo '-->removing sql' &&
    gzip ${file}.sql
  fi
}

# import sql file into sql database it creates
function sql2mysql() {
    if [  -z $1  ] || [  -z $2 ] ; then
      echo ;
      echo 'arguments missing'
      echo 'sql2mysql <<file>> <<url>>  or sql2mysql <<file>> <<url>> <<db>>'
      echo 'please try again'
    else
      local user password file url filecopy db dbexists table cmd
      user=root
      password=root
      file=$1;
      url=$2;
      filecopy=""
      if [  -z $3  ]; then
        db=$(_createDatabaseName "${file}")
      else
        db=$3;
      fi
      dbexists=$(mysql -u${user} -p${password} --batch --skip-column-names -e "SHOW DATABASES LIKE '"${db}"';" | grep "${db}" > /dev/null; echo "$?")
      if [ ${dbexists} -eq 1 ]; then
        if [ -n "$(cat ${file} | grep ROW_FORMAT=FIXED)" ] ; then
          echo 'creating sanitised file'
          filecopy="${file}.sanitized"
          cp ${file} ${filecopy}
          sed -i -e 's/ROW_FORMAT=FIXED//g' ${filecopy} ; # use -i -e not -ie, as -i uses next character if set.
          file=${filecopy}
        fi
        echo '-->creating db'
        mysql -u${user} -p${password} -e"create database ${db}"
        echo '-->importing db'
        echo "mysql -u${user} -p${password} ${db} < ${file}"
        mysql -u${user} -p${password} ${db} < ${file}
        echo '-->updating db'
        table='core_config_data'

        # for magento 1 & 2
        cmd="update ${db}.${table} set value='http://${url}/' where path='web/secure/base_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set value='http://${url}/' where path='web/unsecure/base_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set VALUE='test@test.com' where PATH like '%email%' AND VALUE like '%@%';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set VALUE='31536000' where path='admin/security/session_lifetime';"
        mysql -u${user} -p${password} -e"${cmd}"


        # for magento 1
        cmd="update ${db}.${table} set value='{{secure_base_url}}' where path='web/secure/base_link_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set value='{{secure_base_url}}js/' where path='web/secure/base_js_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set value='{{secure_base_url}}media/' where path='web/secure/base_media_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set value='{{secure_base_url}}skin/' where path='web/secure/base_skin_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set value='{{unsecure_base_url}}' where path='web/unsecure/base_link_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set value='{{unsecure_base_url}}js/' where path='web/unsecure/base_js_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set value='{{unsecure_base_url}}media/' where path='web/unsecure/base_media_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set value='{{unsecure_base_url}}skin/' where path='web/unsecure/base_skin_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="delete from ${db}.${table} where path='web/cookie/cookie_domain';"
        mysql -u${user} -p${password} -e"${cmd}"
        # check/money order
        cmd="update ${db}.${table} set VALUE='1' where PATH='payment/checkmo/active'"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set VALUE='0' where PATH='payment/checkmo/allowspecific'"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set VALUE='0' where PATH='system/guidance_cachebuster/is_enabled'"
        mysql -u${user} -p${password} -e"${cmd}"

        # for magento 2
        cmd="update ${db}.${table} set VALUE='0' where PATH='web/secure/use_in_frontend';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set VALUE='0' where PATH='web/secure/use_in_admin';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set VALUE='0' where PATH='dev/css/merge_css_files';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set VALUE='0' where PATH='dev/js/merge_files';"
        mysql -u${user} -p${password} -e"${cmd}"

        echo "your database ${db} is imported"
        if [ -n "${filecopy}" ] && [ -e "${filecopy}" ]; then
          echo 'removing sanitised file'
          rm ${filecopy}
        fi
      else
        echo "error: database name ${db} used"
      fi
    fi
}

# import sql file into sql database it creates
function import2mysql(){
  if [  -z $2  ] ; then
    echo ;
    echo 'arguments missing';
    echo 'import2mysql <<db file>> <<url>> or import2mysql <db file>> <<url>> <<db>>';
    echo 'for files on remote server ';
    echo 'import2mysql <<login details>>:<<db file>> <<url>> or import2mysql <db file>> <<url>> <<db>>';
    echo 'eg. import2mysql user@example.com:~/example.sql l.example';
    echo 'please try again';
  else
    local file url db fileextension prevfileextension testSshConnection
    file=$1;
    url=$2;
    db=$3;
    if [[ ${file} == *':'* ]] ; then
        echo '-->  testing ssh connection'
        testSshConnection=$(testSshConnection ${file%:*});
        if [[ "$testSshConnection" != 'true' ]]; then
            echo 'unable to download database: connection failed'
            return;
        fi
        echo '-->  downloading db file'
        rsync -ahz ${file} $(dbsLocation) &&
        file=${file##*:} &&
        file=${file##*/}
        file="$(dbsLocation)/${file}"
    fi
    fileextension="${file##*.}"; # last file extension if example.sql.tar.gz it returns gz if example.sql returns sql
    # if sql file
    if [[ ${fileextension} == "sql" ]]; then
      echo "--> sql file detected"
      sql2mysql ${file} ${url} ${db};
    # if ****.gz file
    elif [[ ${fileextension} == "gz" ]]; then
      prevfileextension=${file%.gz};
      prevfileextension=${prevfileextension##*.};
      # if tar.gz file
      if [[ ${prevfileextension} == "tar" ]]; then
        echo "--> tar.gz file detected"
        if [[ -z db ]]; then
            db=${file%.tar.gz};
        fi;
        tar2mysql ${file} ${url} ${db};
      else
        echo "--> gz file detected"
        if [[ -z db ]]; then
          db=${file%.gz};
        fi;
        gz2mysql ${file} ${url} ${db};
      fi
    else
      echo "error: unrecognised file format";
      return 1;
    fi
  fi
}

function get_vhost_location_file(){
  if [  -z $1  ] ; then
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

# get vhost location
######## needs work ########
function getVhostLocation() {
   if [  -z $1  ]; then
     echo ;
     echo 'arguments missing';
     echo 'getVhostLocation <<url>>';
     echo 'please try again';
     return 1;
  fi
  local url vhost_file_location string delimter documentRoot
  url=$1
  
  vhost_file_location=$(get_vhost_location_file "${url}")
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



# make vhost but dont setup magento
function mkvhost() {
    if [  -z $1  ] || [  -z $2 ] ; then
      echo ;
      echo 'sets up a vhost (adds to hotst file and httpd-vhosts.conf file)'
      echo ''
      echo 'arguments missing'
      echo 'mkvhost <<sub folder>> <<url>>'
      echo 'please try again'
    else
      local scriptDir httpdvhosts https_vhosts hostsfile setupfile magentoSubfolder url restart regexSubfolder userDir

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


      magentoSubfolder=$1;
      url=$2;
      restart="false";
      regexSubfolder=${magentoSubfolder/\//\\\/}

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


      # standard http connection
      if grep -q "${url}" ${httpdvhosts} ; then
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

      if [ "$restart" = "false" ] ; then
         echo "--> no need to restart server"
      else
         echo "--> restarting server"
         sudo apachectl restart
         echo 'mamp users: please restart mamp'
      fi
    fi  
}

# list all my vhosts in hosts file that are local
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
