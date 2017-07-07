-----------------------   
   work in progress 
-----------------------

My bash extensions.


#Installation
####Main
Add these lines into ~/.bashrc, replacing ```<<<you repo location>>>``` with the location of your repo

```bash
if [ -d <<<you repo location>>> ]; then
    for file in <<<you repo location>>>/*.sh ; do
         . ${file}
    done
fi
```

####Vhosts
make a vhosts file called httpd-vhosts.conf in your apache installation
make the vhosts file and  /etc/hosts is editable by your user without sudo

####Git auto complete
This is not written by me but is really useful

To allow git autocomplete to work run
```
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
```

and add the bellow code just above the code we added in ~/.bashrc
```bash
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
```

#### Command list
Git
|command|details|example|requirements|
|..............|..................|..............|..................|
| git_current_branch | return current branch name |  |  |
|gco| git checkout | gco master |  |
|git_merge_branchs|  |  |  |
|gm2b| merge two branches | gm2b test123 staging |  |
|gmm| merge branch to master | gmm test123 |  |
|gmd| merge branch to develop | gmd test123 |  |
|gk| git remote update and open gitk with all branches |  |  |
|gx| git remote update and open gitx with all branches |  |  |
|gb2b| transfer branch from a remote called beanstalk to one called bitbucket | gb2b master |  |
|gitMoveToNewRepo| move whole repo to new repo | moveToNewRepo git@bitbucket.org:test/myoldrepo.git git@bitbucket.org:test/myrepo.git |  |
|g| git |  |  |
|ga| git add |  |  |
|gc| git commit |  |  |
|gcm| git checkout master |  |  |
|gcd| git checkout develop |  |  |
|gcs| git checkout staging |  |  |
|gcp| git cherry-pick |  |  |
|gb| git branch |  |  |
|gst| git status |  |  |
|gl| git pull |  |  |
|gm| git merge |  |  |
|grup| git remote update |  |  |
|gmt| git mergetool |  |  |

Local Setup
|command|details|example|requirements|
|..............|..................|..............|..................|
|listdbs| list dbs |  |  |
|import2mysql| uncompress database, create database, import database and update base urls and email |  |  |
|mkvhost| make new vhost |  |  |
|listhosts| list vhosts on your local (that have 127.0.0.1 as the ip in /etc/hosts)  |  |  |

Magento 1
|command|details|example|requirements|
|..............|..................|..............|..................|
|echoHtaccessMage1| echo .htaccess template content |  |  |
|copyHtaccessMage1| copy .htaccess template code to clipboard |  |  |
|echoLocalXmlTemplate| echo local.xml template content |  |  |
|copyLocalXmlTemplate|  copy local.xml template code to clipboard|  |  |
|update_localxml| update local xml |  |  |
|setupLocalMagento1| setup local version of magento 2 site |  |  |
|setupNewLocalMagento1| clone repo and setup local version of magento 2 site |  |  |
|n98| n98-magerun.phar |  |  |
|n98fl| flush cache |  |  |
|n98list| list admin users |  |  |
|n98nu| create admin user |  |  |
|n98pass| change password for admin user |  |  |
|n98re| reindex |  |  |
|n98dis| disable cache |  |  |
|rmcache| empties cache and session "rm -rf var/cache/* var/session/*" |  |  |
|setupMage1|  |  |  |


Magento 2
|command|details|example|requirements|
|..............|..................|..............|..................|
|update_envphp|  |  |  |
|setupLocalMagento2| setup local version of magento 2 site |  |  |
|echoConfigMage2| echo contents of config file template |  |  |
|copyConfigMage2| copy to clipboard contents of config file template |  |  |
|echoEnvMage2| echo contents of env file template |  |  |
|copyEnvMage2| copy to clipboard contents of env file template |  |  |
|n982nu| create new admin user |  |  |
|setupMage2|  |  |  |
|n982| n98-magerun.phar shortcut |  |  |
|n982fl| flush magento cache |  |  |
|n982pass| update admin user's password |  |  |
|n982re| reindex magento |  |  |
|n982dis| disable cache |  |  |
|mage2DevMode| set magento 2 into dev mode |  |  |
|mage2ProdMode| set magento 2 into production mode |  |  |
|mage2modules| list magento 2 modules |  |  |
|mage2UpgradeNStatic| "php bin/magento setup:upgrade  && php bin/magento setup:static-content:deploy && php bin/magento cache:clean"  |  |  |
|mage2staticFlush| deploy statics "php bin/magento setup:static-content:deploy" |  |  |

Misc
|command|details|example|requirements|
|..............|..................|..............|..................|
| phpDebug | run file with php with xdebug | phpDebug index.php | php must be able to be run from the terminal with the command 'php' |
|listcustomcommands| list the custom commands |  |  |
|listCustomCommands| list the custom commands |  |  |
|dbs| cd into dbs folder |  |  |
|repo| cd into repositories folder |  |  |
|sites| cd into sites folder |  |  |
|open| run nautilus file explorer at location given | open folder/name |  |
|dbsLocation| echo dbs folder location |  |  |
|repoLocation| echo repositories folder location |  |  |
|sitesLocation| echo sites folder location |  |  |
