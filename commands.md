Git

|command|details|example|requirements
|-------------|-------------|-------------|-------------
|git_current_branch | return current branch name |  |  
|git_branch_name_without_remote|||
|git_merge_branchs|  |  |  
|gm2b| merge two branches | gm2b test123 staging |  
|gmm| merge branch to master | gmm test123 |  
|gmd| merge branch to develop | gmd test123 |  
|gk| git remote update and open gitk with all branches |  |  
|gx| git remote update and open gitx with all branches |  |  
|gb2b| transfer branch from a remote called beanstalk to one called bitbucket | gb2b master |  
|gitMoveToNewRepo| move whole repo to new repo | moveToNewRepo git@bitbucket.org:test/myoldrepo.git git@bitbucket.org:test/myrepo.git |  
|g| git |  |  
|ga| git add |  |  
|gc| git commit |  |  
|gco| git checkout | gco master |  
|gcm| git checkout master |  |  
|gcd| git checkout develop |  |  
|gcs| git checkout staging |  |  
|gcob| git checkout branch||
|gcp| git cherry-pick |  |  
|gb| git branch |  |  
|gst| git status |  |  
|gl| git pull |  |  
|gm| git merge |  |  
|grup| git remote update |  |  
|gmt| git mergetool |  |  
|gdf|show list of files that have conflicts ||

Local Setup

| command | details | example | requirements 
|-------------|-------------|-------------|-------------
| listdbs | list dbs |  |  
| import2mysql | uncompress database, create database, import database and update base urls and email |  |  
| mkvhost | make new vhost |  |  
| listhosts | list vhosts on your local (that have 127.0.0.1 as the ip in /etc/hosts)  |  |  
|createDatabaseName|create a valid sql database name from a string||
|getVhostLocation|get vhost folder location from a url||

Magento 1

|command|details|example|requirements
|-------------|-------------|-------------|-------------
|echoHtaccessMage1| echo .htaccess template content |  |  
|copyHtaccessMage1| copy .htaccess template code to clipboard |  |  
|echoLocalXmlTemplate| echo local.xml template content |  |  
|copyLocalXmlTemplate|  copy local.xml template code to clipboard|  |  
|update_localxml| update local xml |  |  
|setupLocalMagento1| setup local version of magento 2 site |  |  
|setupNewLocalMagento1| clone repo and setup local version of magento 2 site |  |  
|n98| n98-magerun.phar |  |  
|n98fl| flush cache |  |  
|n98list| list admin users |  |  
|n98nu| create admin user |  |  
|n98pass| change password for admin user |  |  
|n98re| reindex |  |  
|n98dis| disable cache |  |  
|rmcache| empties cache and session "rm -rf var/cache/* var/session/*" |  |  
|setupMage1|setup a new magento site. Downloading a repo, importing a database, setting up a vhost and getting ready for development use|  |  
|updateMage1Db|import a new database for a magento 1 which is already setup||

Magento 2

|command|details|example|requirements
|-------------|-------------|-------------|-------------
|update_envphp|update the env.php file|  |  
|setupLocalMagento2| setup local version of magento 2 site |  |  
|echoConfigMage2| echo contents of config file template |  |  
|copyConfigMage2| copy to clipboard contents of config file template |  |  
|echoEnvMage2| echo contents of env file template |  |  
|copyEnvMage2| copy to clipboard contents of env file template |  |  
|m2composer|run composer update and run the relavent magento 2 commands||
|m2static|build statics the supplied language or builds for en_GB and the backend for en_US||
|m2staticAll|build the statics for the us backend and all the frontend languages||
|m2|||
|m2re|reindex||
|m2st|cache status||
|m2fl|cache flush||
|m2en|enable cache||
|m2dis|disable cache||
|m2en_without_full_page|enable cache without the full-page cache||
|m2dev|start developer mode||
|m2prod|start production mode||
|m2modules|modules||
|m2compile|di compile||
|m2upgrade|Run magento upgrade||
|m2upgradeNstatic|Run magento upgrade, create the statics and clean the cache||
|updateMage2Db|import a new database for a magento 1 which is already setup||
|setupMage2|setup a new magento site. Downloading a repo, importing a database, setting up a vhost and getting ready for development use|  |  
|importMage2mysql|import sql file into sql database it creates and setup for a given url||
|n982| n98-magerun.phar shortcut |  |  
|n982nu| create new admin user |  |  
|n982hintsEnable|enable path hints direct in the database, for all ip’s||
|n982hintsDisable|disable path hints direct in the database||
|n982fl| flush magento cache |  |  
|n982pass| update admin user's password |  |  
|n982re| reindex magento |  |  
|n982st|cache status||
|n982en|enable cache||
|n982dis| disable cache |  |  


Misc

|command|details|example|requirements
|-------------|-------------|-------------|-------------
| phpDebug | run file with php with xdebug | phpDebug index.php | php must be able to be run from the terminal with the command 'php' 
|listcustomcommands| list the custom commands |  |  
|listCustomCommands| list the custom commands |  |  
|dbs| cd into dbs folder |  |  
|dropDb|drop a database||
|dbTablesSizes|List the database tables ordered by size in mb||
|repo| cd into repositories folder |  |  
|sites| cd into sites folder |  |  
|open| run nautilus file explorer at location given | open folder/name |  
|dbsLocation| echo dbs folder location |  |  
|repoLocation| echo repositories folder location |  |  
|sitesLocation| echo sites folder location |  |  
|compup|composer update –no-dev||
|safestring|returns a lower case string of the arguments passed, with spaces replaced with _||
|localMysqlConnection|uses the details in mysql-connection-details.txt to login to mysql. This is useful in local environments where quickly loggin into mysql is advantageous and security isnt an issue||
