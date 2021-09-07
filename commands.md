Custom

|command|details|example|requirements|
|-------------|-------------|-------------|-------------|
| customBashExtensionsFolder | this folder location |  |  |
| echoAndRun | echo the command and run it | echoAndRun ls some/folder/path |  |
| cheat | access the an online cheat sheet for the linux terminal | cheat curl |  |
| compup | composer update production |  |  |
| dbsLocation | databases folder (~/Documents/Databases) |  |  |
| repoLocation | repositries folder (~/Documents/Repositories) |  |  |
| sitesLocation | sites folder (~/Documents/Repositories/sites) |  |  |
| dbs | go to dbs folder |  |  |
| repo | go to repositories folder | repo myrepo |  |
| sites | go to sites folder | sites mysite |  |
| localMysqlConnection | connect to mysql using connectrion set in ./mysql-connection-details.txt |  |  |
| dbExists | check if db exits |  |  |
| dropDb | drop database |  |  |
| dbTablesSizes | List the database tables ordered by size in mb |  |  |
| phpDebug | run php through a shell for xdebug | phpDebug index.php | php must be able to be run from the terminal with the command 'php' |
| open | open folder in nautilus | open folder/name | nautilus |
| safestring | returns a lower case string of the arguments passed, with spaces replaced with _ |  |  |
| listcustomcommands | runs listCustomCommands |  |  |
| listCustomCommands | lists the custom commands. note prompt,git,docker,local,custom,laravel,mage1 or mage2 can be specified to filter only those commands |  |  |


Git Prompt

|command|details|example|requirements|
|-------------|-------------|-------------|-------------|
| branch_data | get branch data |  |  |
| enableGitPrompt | enable showing git details in shell prompt |  |  |
| disableGitPrompt | disable showing git details in shell prompt |  |  |
| reloadYorickPrompt | reload yorick shell prompt with new settings |  |  |


Git

|command|details|example|requirements|
|-------------|-------------|-------------|-------------|
| g | git |  |  |
| ga | git add |  |  |
| gc | git commit |  |  |
| gcm | git checkout master |  |  |
| gcd | git checkout develop |  |  |
| gcs | git checkout staging |  |  |
| gcp | git cherry-pick | gcp 7f9ead6b5c3ec |  |
| gb | git branch |  |  |
| gst | git status |  |  |
| gl | git pull |  |  |
| gm | git merge --no-ff |  |  |
| grup | git remote update |  |  |
| gmt | git mergetool |  |  |
| gref | git commit reference |  |  |
| gcd | git checkout develop |  |  |
| gdf | show list of files that have conflicts |  |  |
| git_current_branch | display current branch name e.g. master |  |  |
| git_branch_name_without_remote | remove remote from name and echo out result | git_branch_name_without_remote remotes/origin/master |  |
| gco  | git checkout | gco develop |  |
| git_merge_branchs | pull and merge a branch into another branch, updating remotes |  |  |
| gm2b | pull and merge a branch into another branch, updating remotes | gm2b feature-1 master |  |
| gmm  | pull branch specified and merge to master | gmm feature-1 |  |
| gmd  | pull branch specified and merge to develop | gmd feature-1 |  |
| gk | remote update and open gitk showing all branches |  |  |
| gx | remote update and open gitx |  |  |
| gitMoveToNewRepo | transfer whole repo to new repo, from two remote sources | gitMoveToNewRepo git@bitbucket.org:test/myoldrepo.git git@bitbucket.org:test/myrepo.git |  |
| gcob | checkout a new git branch with a name, which is sanitized here | gcob feature-1 |  |


Local Setup

|command|details|example|requirements|
|-------------|-------------|-------------|-------------|
| getCurrentFolderName |  get the name of the current folder without full folder path |  |  |
| createDatabaseName | create safe db name from filename | folder/myWebsite-name.database.tar.gz |  |
| listdbs | lists databases in mysql | listdbs example.c |  |
| tar2mysql | import sql file inside a tar.gz file into sql database it creates (only works for ***.tar.gz files not ***.sql.tar.gz) |  |  |
| gz2mysql | import sql file inside a gz file into sql database it creates |  |  |
| zip2mysql | import sql file inside a gz file into sql database it creates |  |  |
| sanitizeSqlFile | attempts  to fix known (sanitize) sql issues in a file ready to import |  |  |
| sql2mysql | import sql file into sql database it creates |  |  |
| import2mysql | import sql file into sql database it creates |  |  |
| get_vhost_location_file | attempt to find vhost file |  |  |
| getVhostLocation | get vhost location |  |  |
| mkvhost | make vhost |  |  |
| listhosts | list all my vhosts in hosts file that are local |  |  |


Docker

|command|details|example|requirements|
|-------------|-------------|-------------|-------------|
| listdocker | List running docker containers |  |  |
| dockerList | list all docker elements i.e. containers, volumes, networks and images |  |  |
| dockerssh | open a shell terminal inside a given container |  |  |
| dockerDestroyAllContainersAndImages | destroy all containers and images completely |  |  |
| dockerDestroyAllVolumesNotUsed | destroy all volumes not being used |  |  |
| dockerDestroyAllUnused | destroy all unused containers, images and volumes |  |  |
| dockerComposeUpNoCache | docker compose rebuild without cache and start |  |  |


Laravel

|command|details|example|requirements|
|-------------|-------------|-------------|-------------|
| sail | ./vendor/bin/sail | sail artisan |  |


Magento 1

|command|details|example|requirements|
|-------------|-------------|-------------|-------------|
| n98 | n98-magerun.phar |  |  |
| n98fl | flush cache |  |  |
| n98list | list admin users |  |  |
| n98nu | create user |  |  |
| n98pass | change poassword |  |  |
| n98re | reindex |  |  |
| n98dis | disable cache |  |  |
| rmcache | clear cache manually (using rm -rf) |  |  |
| echoHtaccessMage1 | show htaccess template code |  |  |
| copyHtaccessMage1 | copy htaccess template to clipboard |  |  |
| echoLocalXmlTemplate | show local.xml template code |  |  |
| copyLocalXmlTemplate | copy local.xml template to clipboard |  |  |
| update_localxml | update local.xml with new db details (for magento 1.**) |  |  |
| setupNewLocalMagento1 | setup new local magento 1 vhost development environment |  |  |
| setupLocalMagento1 | import database, make into vhost, add .htaccess, copy local.xml |  |  |
| setupMage1 | see setupLocalMagento1 |  |  |
| updateMage1Db | update  magento 1 environment with a new database |  |  |


Magento 2

|command|details|example|requirements|
|-------------|-------------|-------------|-------------|
| update_envphp | update env.php with new db details (for magento 2.**) |  |  |
| setupNewLocalMagento2 | git clone, import database, make into vhost, copy env.php & config.php |  |  |
| setupLocalMagento2 | import database, make into vhost, copy env.php & config.php |  |  |
| setupMage2 | see setupLocalMagento2 |  |  |
| echoConfigMage2 | show config.php template code |  |  |
| copyConfigMage2 | copy config.php template code to clipboard |  |  |
| echoEnvMage2 | show env.php template code |  |  |
| copyEnvMage2 | copy env.php template code to clipboard |  |  |
| n982 | n98-magerun2.phar |  |  |
| n982pass | n98: change user password |  |  |
| n982re | n98: reindex |  |  |
| n982st | n98: cache status |  |  |
| n982fl | n98: flush cache |  |  |
| n982en | n98: enable cache |  |  |
| n982dis | n98: disable cache |  |  |
| m2 | php bin/magento |  |  |
| m2re | bin/magento: indexer:reindex |  |  |
| m2st | bin/magento: cache status |  |  |
| m2fl | bin/magento: flush cache |  |  |
| m2en | bin/magento: enable cache |  |  |
| m2dis | bin/magento: disable cache |  |  |
| m2en_without_full_page | bin/magento: enable cache, except full_page cache |  |  |
| m2dev | bin/magento: set developer mode |  |  |
| m2prod | bin/magento: set production mode |  |  |
| m2modules | bin/magento: module status list |  |  |
| m2composerupdate | composer update, compile & clear caches |  |  |
| m2composerinstall | composer install, compile & clear caches |  |  |
| m2composer | composer update/install |  |  |
| m2compile | compile |  |  |
| m2upgrade | upgrade setup |  |  |
| m2upgradeNstatic | newer versions claim static deploy is not required but it dosnt work, so we need to run with -f to force it to run |  |  |
| m2static | newer versions claim static deploy is not required but it dosnt work, so we need to run with -f to force it to run |  |  |
| m2staticAll | newer versions claim static deploy is not required but it dosnt work, so we need to run with -f to force it to run |  |  |
| n982nu  | n98: create new user |  |  |
| n982hintsEnable  | enable store front hints |  |  |
| n982hintsDisable  | disable store front hints |  |  |
| updateMage2Db | import database and set to current database in magento setting file |  |  |
| importMage2mysql | import sql file into sql database it creates and setup for magento |  |  |
