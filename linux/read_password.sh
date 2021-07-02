#!/bin/bash

# https://github.com/KazKobara/tips-jp/blob/gh-pages/linux/password_prompt.md in Japanese

# Read password and store it to given variable.
# @param $1 variable to store the read password
read_password () {
    local local_pw=""
    local local_char=""
    echo -n "Enter password: "
    while read -rsn 1 local_char
    do
	if [ "$local_char" == "" ]; then
	    break
	fi
	echo -n "*"
	local_pw="$local_pw$local_char"
    done
    echo
    local local_ret=$1
    eval "$local_ret=$local_pw"
}

read_password pw;
