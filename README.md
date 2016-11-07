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