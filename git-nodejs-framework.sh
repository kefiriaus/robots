#!/bin/bash

WWW="/var/www"
BUFFER="$WWW/.buffer"
FRAMEWORK="$WWW/nodejs-framework"

GIT_EXCLUDE=".git/info/exclude"
EXCLUDE="$BUFFER/nodejs_framework_exclude"

AR_BRANCH=( "master" "dev-work" "dev-home" )
AR_EXCLUDE=( "framework/configs/" "data/logs/"  "node_modules/" ".idea/" )

AR_COMMIT_TIME=()
AR_COMMIT_BRANCH=()

#cd "$FRAMEWORK"
#> "$GIT_EXCLUDE"

COMMIT_TIME_I=0
cmp(){
	local n="$1"
	local k=0
	for i in "${AR_COMMIT_TIME[@]}"; do
		if [[ "$i">"$n" ]]; then
			let "COMMIT_TIME_I=$k"
			cmp "$i"
		fi
		let "k=$k+1"
	done
#echo "$COMMIT_TIME_I"
	MERGE_BRANCH="${AR_COMMIT_BRANCH[$COMMIT_TIME_I]}"
}

merge(){
	local BRANCH="$1"
	local DIR="$FRAMEWORK/$BRANCH"
	cd "$DIR"
	> "$DIR/$GIT_EXCLUDE"

	j=0
	for branch in "${AR_BRANCH[@]}"; do
        	#getting updates from github
	        sudo -u git git checkout -f "$branch"
	        sudo -u git git pull origin "$branch"

	        #write git exclude file
	        sudo -u git cat "$EXCLUDE" > "$DIR/$GIT_EXCLUDE"

	        #exclude dirs from commiting
	        for exclude in "${AR_EXCLUDE[@]}"; do
	                sudo -u git git rm -r --cached "$exclude" &> /dev/null
	        done

	        AR_COMMIT_TIME["$j"]=`sudo -u git git log -n1 --pretty=format:\"%at\"`
		AR_COMMIT_BRANCH["$j"]="$branch"

        	#commite delete
		sudo -u git git add . &> /dev/null
	        sudo -u git git commit -a -m "exclude from $branch"

		let "j=$j+1"
	done

	#compare timestamp of last commit from every branch
	cmp 0
echo "$MERGE_BRANCH"
	#merge latest branch with others
	for branch in "${AR_BRANCH[@]}"; do
		if [[ "$branch" != "$MERGE_BRANCH" ]]; then
			sudo -u git git checkout -f "$branch"
			sudo -u git git merge "$MERGE_BRANCH" &> /dev/null
		fi
	done

	#clear exclude file
	> "$DIR/$GIT_EXCLUDE"

	#include excluded files and push dir branch
	for branch in "${AR_BRANCH[@]}"; do
		sudo -u git git checkout -f "$branch"
		sudo -u git git add . &> /dev/null
                sudo -u git git commit -a -m "include excluded to $branch"

#		sudo -u git git push origin "$BRANCH"
	done
}


for branch in "${AR_BRANCH[@]}"; do
	merge "$branch"
done
