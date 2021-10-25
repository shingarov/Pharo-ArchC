#!/bin/sh

set -e

path=pdl
repo=https://github.com/janvrany/Pharo-ArchC-PDL.git
branch=master

if [ ! -d "$path" ]; then
	mkdir -p "$path"
	git clone --branch "$branch" "$repo" "$path"
elif [ -d "$path/.git" ]; then
	echo "$path"
	git -C "$path" pull
fi
