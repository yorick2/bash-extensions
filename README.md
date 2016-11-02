-----------------------   
   work in progress 
-----------------------

My bash extensions.

------------
installation
------------
Add these lines into ~/.bashrc, replacing ```<<<you repo location>>>``` with the location of your repo

```bash
if [ -d <<<you repo location>>> ]; then
    for file in <<<you repo location>>>/*.sh ; do
         . ${file}
    done
fi
```

make a vhosts file called httpd-vhosts.conf in your apache installation
make the vhosts file and  /etc/hosts is editable by your user without sudo