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
| git_current_branch |  |
|git_branch_name_without_remote|  |
|gco|  |
|git_merge_branchs|  |
|gm2b|  |
|gmm|  |
|gmd|  |
|gk|  |
|gx|  |
|gb2b|  |
|gitMoveToNewRepo|  |
|g|  |
|ga|  |
|gc|  |
|gcm|  |
|gcd|  |
|gcs|  |
|gcp|  |
|gb|  |
|gst|  |
|gl|  |
|gm|  |
|grup|  |
|gmt|  |
|gcd|  |

Local Setup
|listdbs|  |
|tar2mysql|  |
|gz2mysql|  |
|sql2mysql|  |
|import2mysql|  |
|get_vhost_location_file|  |
|getVhostLocation|  |
|mkvhost|  |
|listhosts|  |

Magento 1
|echoHtaccessMage1|  |
|copyHtaccessMage1|  |
|echoLocalXmlTemplate|  |
|copyLocalXmlTemplate|  |
|update_localxml|  |
|setupLocalMagento1|  |
|n98|  |
|n98fl|  |
|n98list|  |
|n98nu|  |
|n98pass|  |
|n98re|  |
|n98dis|  |
|rmcache|  |
|setupMage1|  |


Magento 2
|update_envphp|  |
|setupLocalMagento2|  |
|echoConfigMage2|  |
|copyConfigMage2|  |
|echoEnvMage2|  |
|copyEnvMage2|  |
|n982nu|  |
|setupMage2|  |
|n982|  |
|n982fl|  |
|n982pass|  |
|n982re|  |
|n982dis|  |
|mage2DevMode|  |
|mage2ProdMode|  |
|mage2modules|  |
|mage2UpgradeNStatic|  |
|mage2staticFlush|  |

Misc
|listcustomcommands|  |
|dbs|  |
|repo|  |
|sites|  |
|open|  |
|listCustomCommands|  |
|dbsLocation|  |
|repoLocation|  |
|sitesLocation|  |
