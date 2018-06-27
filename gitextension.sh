#!/usr/bin/env bash

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
alias gref="echo 'git rev-parse --verify HEAD'; git rev-parse --verify HEAD"

export PATH="/usr/local/mysql/bin:$PATH"

alias gcd='git checkout develop'

# show list of files that have conflicts
alias gdf="git diff --name-only --diff-filter=U"

# display current branch name e.g. master
function git_current_branch(){
  git symbolic-ref --short HEAD
}

# remove remote from name and echo out result
# expected formats :
# remotes/....
# /remotes....
function git_branch_name_without_remote(){
  if  [[ "${1}" == \/remotes* ]] ; then
    echo "${1#\/remotes\/[a-zA-Z]*?\/}"
  elif  [[ "${1}" == remotes* ]] ; then
    echo "${1#remotes\/[a-zA-Z]*?\/}"
  else
    echo "${1}"
  fi
}

function gco () {
  local arguments lastArgument branch
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
  if [ -z $2 ] || [ "$1" = "--help" ]
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
  if [ -z $2 ] || [ "$1" = "--help" ]
  then
    echo "merge one branch into another"
    echo "gm2b <<source branch>> <<destination branch>>"
    echo "use . to select current branch"
    echo "e.g. gmm branch1 branch2"
    return
  fi
  local target destination sure
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
  local BRANCH target sure destination
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
  local target sure destination
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


function gitMoveToNewRepo(){
  if [ -z $2 ] || [ "$1" = "--help" ]
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

function gcob(){
 if [[ -z $1 ]] || [[ "$1" = "--help" ]]
  then
    echo "checkout a new git branch with a name, which is sanitized here"
    echo "gnb <<<branch name>>>"
    echo "e.g. gcob"
  else
    string="$@" # all argruments
    string="${string## }" # trim start
    string="${string%% }" # trim end
    string=${string,,} # convert to lower case
    git checkout -b ${string//[^a-zA-Z0-9_-]/-}
  fi
}
















































