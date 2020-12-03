#!/usr/bin/env bash

# if git auto complete not set and is installed
if [ -z "$(type -t __git_complete)" ] && [ -f ~/.git-completion.bash ]; then
  #set git auto complete
  . ~/.git-completion.bash;
fi;

# if __git_complete  commandexists
if [ "$(type -t __git_complete)" ]; then 
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

	__git_complete git_merge_branchs _git_checkout
	__git_complete gb2b _git_checkout
fi
