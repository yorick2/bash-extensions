alias g='git'
alias ga='git add'
alias gc='git commit'
alias gcm='git checkout master'
alias gcd='git checkout develop'
alias gcs='git checkout staging'
alias gcp='git cherry-pick'
alias gb='git branch'
alias gst='git status'
alias gl='git pull'
alias gm='git merge --no-ff '
alias grup='git remote update'
alias gmt='git mergetool'

export PATH="/usr/local/mysql/bin:$PATH"

alias gcd='git checkout develop'

# show list of files that have conflicts
gdf="git diff --name-only --diff-filter=U"

# display current branch name e.g. master
function git_current_branch(){
  git symbolic-ref --short HEAD
}

# remove remote from name and echo out result
# expected formats :
# remotes/origin/....
# /remotes/origin/....
# origin/....
# /origin/....
function git_branch_name_without_remote(){
  if  [[ ${1} == \/remotes* ]] ; then
    echo ${1/#\/remotes\/.*\//}
  elif  [[ ${1} == remotes* ]] ; then
    echo ${1/#remotes\/.*\//}
  elif [[ ${1} == \/origin* ]] ; then
    echo ${1/#\/origin\//}
  elif [[ ${1} == origin* ]] ; then
    echo ${1/#origin\//}
  else
    echo ${1}
  fi
}

function gco () {
  arguments="";
  lastArgument="";
  for arg in "$@"
  do
    echo ${arg}
    arguments="${arguments} ${lastArgument}"
    lastArgument=${arg};
  done;
  branch=$(git_branch_name_without_remote ${lastArgument});
  echo git checkout ${arguments} ${branch};
  git checkout ${arguments} ${branch};
}

# pull and merge a branch into another branch
function git_merge_branchs() {
  git rev-parse --show-toplevel #first line has to be a git command for auto complete o work
  if [ -z $2 ]
    then
    echo "merge one branch into another"
    echo "git_merge_branchs <<source branch>> <<destination branch>>"
    echo "e.g. git_merge_branchs branch1 master"
    return
  else
    echo "-------remote update-------" \
    && git remote update  \
    && echo "-------checkout $1-------"  \
    && git checkout $1 \
    && echo "-------pull $1-------"  \
    && git pull \
    && echo "-------checkout $2-------"  \
    && git checkout $2 \
    && echo "-------pull $2-------"  \
    && git pull   \
    && echo "-------merge $1 into $2-------"  \
    && git merge --no-ff $1
  fi
}
function gm2b(){
  if [ -z $2 ] || [ "$1" = "-help" ]
  then
    echo "merge one branch into another"
    echo "gm2b <<source branch>> <<destination branch>>"
    echo "use . to select current branch"
    echo "e.g. gmm branch1 branch2"
    return
  fi
  if [ "$1" = "." ]
    then
      target=$(git_current_branch)
    else
      target=$(git_branch_name_without_remote ${1})
  fi
  if [ "${2}" = "." ]
    then
      destination=$(git_current_branch)
    else
      destination=$(git_branch_name_without_remote ${2})
  fi
  echo "merge ${target} into ${destination}? (y/n)";
  read sure;
  if  [[ $sure == "y" ]];
  then
    git_merge_branchs ${target} ${destination};
  fi
}

# pull branch specified and merge to master
function gmm (){
  if [ "$1" = "-help" ]
  then
    echo "merge one branch into another, then into master if a second branch defined"
    echo "merge current branch to master: 'gmm' or 'gmm .'"
    echo "merge a branch to master:'gmm <<source branch>>'"
    echo "merge one branch into another, then into master: 'gmm <<source branch>> <<destination branch>>'"
    echo "e.g. gmm branch1 branch2"
    return
  fi
  git rev-parse --show-toplevel #first line has to be a git command for auto complete o work
  BRANCH=$1;
  if [  -z $1  ] || [ "$1" = "." ] 
  then
    git_merge_branchs $(git_current_branch) master;
  else
    if [ -z $2 ] ; then
      target=$(git_branch_name_without_remote ${1})
      echo "merge ${target} into master? (y/n)";
      read sure;
      if  [[ $sure == "y" ]] ; then
        git_merge_branchs ${target} master;
      fi
    else
      target=$(git_branch_name_without_remote ${1})
      destination=$(git_branch_name_without_remote ${2})
      echo "merge ${target} into ${destination} into master? (y/n)" ;
      read sure;
      if [[ ${sure} == "y" ]] ; then
        git_merge_branchs ${target} ${destination} \
        && git_merge_branchs ${destination} master;
      fi
    fi
  fi
}

# pull branch specified and merge to develop
function gmd (){
  if [ "$1" = "-help" ]
  then
    echo "merge one branch into another, then into develop if a second branch defined"
    echo "merge current branch to develop: 'gmd' or 'gmd .'"
    echo "merge a branch to develop:'gmd <<source branch>>'"
    echo "merge one branch into another, then into develop: 'gmd <<source branch>> <<destination branch>>'"
    echo "e.g. gmd branch1 branch2"
    return
  fi
  #git rev-parse --show-toplevel #first line has to be a git command for auto complete o work
  if [  -z $1  ] || [ "$1" = "." ] 
  then
     git_merge_branchs $(git_current_branch) develop;
  else
    if [ -z $2 ] ; then
      target=$(git_branch_name_without_remote ${1})
      echo "merge ${target} into develop? (y/n)";
      read sure;
      if  [[ $sure == "y" ]] ; then
        git_merge_branchs ${target} develop;
      fi
    else
      target=$(git_branch_name_without_remote ${1})
      target=$(git_branch_name_without_remote ${1})
      destination=$(git_branch_name_without_remote ${2})
      echo "merge ${target} into ${destination} into develop? (y/n)" ;
      read sure;
      if [[ ${sure} == "y" ]] ; then
        git_merge_branchs ${target} ${destination} \
        && git_merge_branchs ${destination} develop;
      fi
    fi
  fi
}

# remote update and open gitk
function gk() {
  if [ -z $1 ]
  then
    git remote update \
    && echo "git remote updated" \
    && echo "running gitk --all --branches" \
    && gitk --all --branches
  else
    cd $1 \
    && echo "moved folder to $1" \
    && git remote update \
    && echo "git remote updated" \
    && echo "running gitk --all --branches" \
    && gitk --all --branches 
  fi
}

# remote update and open gitx
function gx() {
  if [ -z $1 ]
  then
    git remote update \
    && echo "git remote updated" \
    && echo "running gitx --all" \
    && gitx --all
  else
    cd $1 \
    && echo "moved folder to $1" \
    && git remote update \
    && echo "git remote updated" \
    && echo "running gitx --all" \
    && gitx --all 
  fi
}


function gb2b() {
  if [ -z $1 ]
  then
    echo "transfer branch from a remote called beanstalk to one called bitbucket"
    echo "gb2b <<<branch>>>"
    echo "e.g. gb2b master"
  else
    target=$(git_branch_name_without_remote ${1})
    echo "transfer ${target}? (y/n)" ;
    read sure;
    if [[ ${sure} == "y" ]] ; then
      echo "-------remote update-------" \
      && git remote update  \
      && echo "-------checkout beanstalk/${target}-------"  \
      && git checkout beanstalk/${target} \
      && echo "-------pull changes from bitbucket -------"  \
      && git pull bitbucket ${target} \
      && echo "-------push changes to bitbucket-------"  \
      && git push beanstalk ${target}
    fi
  fi
}

function gitMoveToNewRepo(){
  if [ -z $2 ]
  then
    echo "transfer whole repo to new repo"
    echo "Warning: it clones a repo in a subfolder of the current location"
    echo "moveToNewRepo <<<old repo>>> <<<new repo>>>"
    echo "e.g. moveToNewRepo git@bitbucket.org:yorick/myoldrepo.git git@bitbucket.org:yorick/myrepo.git"
  else
    oldRepo=${1}
    newRepo=${2}
    git clone --bare ${oldRepo} temp-repo
    cd temp-repo
    git remote add origin-new ${newRepo}
    git push --mirror origin-new
  fi
}

# if git auto complete not set and is installed 
if [ -z "$(type -t __git_complete)" ] && [ -f ~/.git-completion.bash ]; then
  #set git auto complete
  . ~/.git-completion.bash;
fi;
# git autocompletes
__git_complete g __git_main
__git_complete ga _git_add
__git_complete gc _git_commit
__git_complete gco _git_checkout
__git_complete gcp _git_cherry_pick
__git_complete gb _git_branch
__git_complete gst _git_status
__git_complete gl _git_pull
__git_complete gm _git_merge
__git_complete gm2b _git_merge
__git_complete gmm _git_merge
__git_complete gmd _git_merge
__git_complete gmb2b _git_merge
__git_complete grup _git_remotes





















































