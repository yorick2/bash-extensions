alias listdbs="mysql -uroot -proot -e'show databases'";


# import sql file inside a tar.gz file into sql database it creates
# only works fro ***.tar.gz files not ***.sql.tar.gz
function tar2mysql() {
  if [  -z $1  ] || [  -z $2 ] ; then
    echo ;
    echo 'arguments missing'
    echo 'tar2mysql <<file>> <<url>> or tar2mysql <<file>> <<url>> <<db>>'
    echo 'please try again'
  else
    file=$1
    url=$2
    db=$3
    echo ${db}
    echo '-->uncompressing file'
    tar -xzvf ${file} &&
    file=${file%.gz} &&
    file=${file%.tar} &&
    file=${file%.sql} &&
    file=${file##*/} &&
    sql2mysql ${file}.sql ${url} ${db}  &&
    echo '-->removing sql' &&
    rm ${file} # $file redefined in sql2mysql()
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
    file=$1
    url=$2
    db=$3
    echo ${db}
    echo '-->uncompressing file'
    gunzip ${file} &&
    file=${file%.*} &&
    file=${file##*/} &&
    sql2mysql ${file}.sql ${url} ${db} &&
    echo '-->removing sql' &&
    rm ${file} # $file redefined in sql2mysql()
  fi
}

# inport sql file into sql database it creates
function sql2mysql() {
    user=root
    password=root
    if [  -z $1  ] || [  -z $2 ] ; then
      echo ;
      echo 'arguments missing'
      echo 'sql2mysql <<file>> <<url>>  or sql2mysql <<file>> <<url>> <<db>>'
      echo 'please try again'
    else
      file=$1;
      url=$2;
      if [  -z $3  ]; then
        db=${file%.sql};
        db=${db##*/};
        db=${db//[-.]/_}; #make db name valid when created from filenames not valid db names
      else
        db=$3;
      fi
        dbexists=$(mysql -u${user} -p${password} --batch --skip-column-names -e "SHOW DATABASES LIKE '"${db}"';" | grep "${db}" > /dev/null; echo "$?")
      if [ ${dbexists} -eq 1 ]; then
        echo '-->creating db'
        mysql -u${user} -p${password} -e"create database ${db}"
        echo '-->importing db'
        mysql -u${user} -p${password} ${db} < $file
        echo "mysql -u${user} -p${password} ${db} < $file"
        echo '-->updating db'
        table='core_config_data' 
        cmd="update ${db}.${table} set value='http://${url}/' where path='web/unsecure/base_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set value='http://${url}/' where path='web/secure/base_url';"
        mysql -u${user} -p${password} -e"${cmd}"
	echo "your database ${db} is imported"
      else
        echo "error: database name ${db} used"
      fi
    fi
}

# import sql file into sql database it creates
function import2mysql(){
  if [  -z $1  ] ; then
    echo ;
    echo 'arguments missing';
    echo 'import2mysql <<db file>> <<url>> or import2mysql <db file>> <<url>> <<db>>';
    echo 'please try again';
  else 
    file=$1;
    url=$2;
    db=$3;
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
        if [[ -z db ]]; then
            echo "--> tar.gz file detected"
            db=${file%.tar.gz};
        fi;
        tar2mysql ${file} ${url} ${db};
      else
        echo "--> gz file detected"
        db=${file%.gz};
        gz2mysql ${file} ${url} ${db};
      fi
    else
      echo "error: unrecognised file format";
      return 1;
    fi
  fi
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
  url=$1
  
  vhost_file_location='/Applications/MAMP/conf/apache/extra/httpd-vhosts.conf'
  if [ ! -a "${vhost_file_location}" ]; then
  	vhost_folder_location='/etc/apache2/extra';
  	if [ ! -d "${vhost_folder_location}" ]; then
  		vhost_folder_location='/etc/apache2/sites-available';
  	fi
  	vhost_file_location=$( grep --files-with-matches "${url}" $vhost_folder_location/* )
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

# update local.xml with new db details (for magento 1.**)
function update_localxml() {
   vhost_file_location='/Applications/MAMP/conf/apache/extra/httpd-vhosts.conf';
    if [ ! -a "${vhost_file_location}" ]; then
      vhost_file_location = '/etc/apache2/extra/httpd-vhosts.conf';
    fi
    if [ ! -a "${vhost_file_location}" ]; then
      vhost_file_location = '/etc/apache2/sites-enabled/httpd-vhosts.conf';
    fi  
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

# make vhost but dont setup magento
function mkvhost() {
    scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    # file locations
    httpdvhosts='/Applications/MAMP/conf/apache/extra/httpd-vhosts.conf';
    if [ ! -e "${httpdvhosts}" ]; then
      httpdvhosts='/etc/apache2/extra/httpd-vhosts.conf';
    fi
    if [ ! -e "${httpdvhosts}" ]; then
      httpdvhosts='/etc/apache2/sites-enabled/httpd-vhosts.conf';
    fi
    hostsfile='/etc/hosts'
    setupfile='${scriptDir}/local_setup_files/vhost_template.txt'
    if [  -z $1  ] || [  -z $2 ] ; then
      echo ;
      echo 'sets up a vhost (adds to hotst file and httpd-vhosts.conf file)'
      echo ''
      echo 'arguments missing'
      echo 'mkvhost <<sub folder>> <<url>>'
      echo 'please try again'
    else
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



      if grep -q "${url}" ${httpdvhosts} ; then
          echo "--> no need to update vhosts file"
      else
          echo "--> updating vhosts file"
          eval userDir=~$(whoami); # get user folder location

          #vhostdefault=$( cat "${setupfile}" );
          
          #vhostdefault=$(cat ~/Documents/oh-my-zsh-extensions/local_setup_files/vhost_template.txt );
         # vhostdetails=$( echo "${vhostdefault}" | sed -e"s/myurl/${url}/" | sed -e"s/subfolder/${subfolder}/" );
          #echo  $vhostdetails >> ${httpdvhosts};
          
          cp ${scriptDir}/local_setup_files/vhost_template.txt ${scriptDir}/local_setup_files/vhost_template.txt.swp
          sed -i "s/myurl/${url}/" ${scriptDir}/local_setup_files/vhost_template.txt.swp
          sed -i "s/subfolder/${regexSubfolder}/" ${scriptDir}/local_setup_files/vhost_template.txt.swp
          sed -i "s/\~/${userDir//\//\\\/}/" ${scriptDir}/local_setup_files/vhost_template.txt.swp
          cat ${scriptDir}/local_setup_files/vhost_template.txt.swp >> ${httpdvhosts};
          # rm ${scriptDir}/local_setup_files/vhost_template.txt.swp

           echo ------
           echo ${httpdvhosts}
           echo ------

          restart="true";
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
  hosts_file_location='/etc/hosts';
  string=$( grep '127.0.0.1' ${hosts_file_location} | sed -e"s/127\.0\.0\.1//g" | sort);
  if [ -z $1 ] ; then
    string=$(echo ${string} | sed -e"s/\s/ /g");
  else
    string=$( echo ${string} | grep $1 );
    string=$(echo ${string} | sed -e"s/\s/ /g");
  fi
  echo ${string};
}
