# note the () suround the code so it runs them in a new subshell. This means the functions are nopt availiable to the shell afterwords
(
	function clearOurVars(){
		command='';
		details=''
		example=''
		requirements=''
	}
	function extractInfo (){
		# example line
		if [[ $line == \#\ example:* ]] ; then
			example="$(echo ${line} | sed -e's/\s*#\s*example:\s*//' | cut -f1 -d'(' )"
			return
		fi
		# requirements line
		if [[ $line == \#\ requirements:* ]] ; then
			requirements="$(echo ${line} | sed -e's/\s*#\s*requirements:\s*//' | cut -f1 -d'(' )"
			return
		fi
		# details line
		if [[ $line == \#* ]] && [ -n "$(echo "$prevLine" | egrep '#####')" ]; then
			details="${line#"# "}"
			return
		fi
		# functions
		if [[ $line == *function* ]] ; then
			command="$(echo ${line} | sed -e's/\s*function\s*//' | cut -f1 -d'(' )"
			output="${output}\n| ${command} | ${details} | ${example} | ${requirements} |"
			clearOurVars
			return
		fi
		# alias's
		if [[ $line == *alias* ]] ; then
			command="$(echo ${line} | sed -e's/\s*alias\s*//' | cut -f1 -d'=' )"
			output="${output}\n| ${command} | ${details} | ${example} | ${requirements} |"
			clearOurVars
			return
		fi
	}
	function createTable(){
		file="${1}"
		clearOurVars
		output='|command|details|example|requirements|\n|-------------|-------------|-------------|-------------|';
		prevLine='';
		while read -r line; do
			extractInfo
		  	prevLine=$line;
		done <<< $(egrep '^\s*function|^\s*alias|^#' ${file} | grep -v '#!')
		printf "${output}\n"
	}
	function createContent(){
		echo Custom
		echo
		createTable custom_misc.sh
		echo
		echo
		echo Git Prompt
		echo
		createTable gitprompt.sh
		echo
		echo
		echo Git
		echo
		createTable gitextension.sh
		echo
		echo
		echo Local Setup
		echo
		createTable local_setup.sh
		echo
		echo
		echo Docker
		echo
		createTable docker.sh
		echo
		echo
		echo Laravel
		echo
		createTable laravel.sh
		echo
		echo
		echo Magento 1
		echo
		createTable magento1.sh
		echo
		echo
		echo Magento 2
		echo
		createTable magento2.sh
	}
	createContent > commands.md
)
