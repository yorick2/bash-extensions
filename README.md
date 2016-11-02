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
