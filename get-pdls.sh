#!/bin/sh

set -e

get_pdl() {
	local path=$1
	local repo=$2
	local branch=$3

	if [ ! -d "$path" ]; then
		mkdir -p "$path"
		git clone --branch "$branch" "$repo" "$path"
	fi	
}

get_pdl pdl/arm 	https://github.com/shingarov/arm.git		master
get_pdl pdl/x86 	https://github.com/shingarov/x86.git		bee
get_pdl pdl/powerpc	https://github.com/shingarov/powerpc.git	good
get_pdl pdl/riscv	https://github.com/shingarov/riscv.git 		master
get_pdl pdl/mips 	https://github.com/shingarov/mips.git		master
get_pdl pdl/sparc	https://github.com/shingarov/sparc.git 		gdb-descriptors


