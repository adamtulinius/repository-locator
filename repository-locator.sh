#!/bin/bash

if [ -z "$1" ]; then
	dir="$(pwd)"
else
	dir="$1"
fi

echo "Looking for git, svn and cvs repositories in $dir ..."

repositories=""

for dir in $(find $1 -type d -name "\.svn" -o -name "\.git" -o -name "CVS"); do
	dirBasename=$(basename $dir)
	if [ "$dirBasename" == ".git" ]; then
		remotes=$(git --git-dir=$dir remote -v | grep ^origin)
		if [ "$remotes" != "" ]; then
			echo "Found git repository in $dir"
			repositories="$repositories$(git --git-dir=$dir remote -v | grep ^origin | cut -f2 | cut -d " " -f1 | uniq)\\n"
		else
			echo "Found git repository without remotes in $dir (ignored)"
		fi
	elif [ "$dirBasename" == ".svn" ]; then
		echo "Found svn repository in $dir"
		repositories="$repositories$(svn info $(dirname $dir) | grep ^URL | cut -d " " -f2)\\n"
	elif [ "$dirBasename" == "CVS" ]; then
		if [ -e "$dir/Root" ]; then
			echo "Found CVS repository in $dir"
			repositories="$repositories"$(cat $dir/Root)"\\n"
		fi
	fi
done

echo -e "\\nThis is what I found:"

echo -e $repositories | head -n-1  | sort -u
