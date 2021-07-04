#!/bin/bash
#
# Password Prompter ver. 0.0.0
#
# How to use (in Japanese):
# https://github.com/KazKobara/tips-jp/blob/gh-pages/linux/password_prompter.md in Japanese

# @brief Read password and store it to $pw.
# @param $1 string to prepend to "password: " in the password prompt,
# @param    e.g. "user " makes it "Enter user password: ".
# @param    The string is restricted to "a-zA-Z0-9_ ".
# @return 0 on success, 1 on error. 
read_password () {
    ## restrict_char=
    ##  1: restrict input password to "a-zA-Z0-9"
    ##  0: not restrict but additional sanitization is needed!!
    local local_restrict_char=1
    local local_pw=""
    local local_char=""
    echo -n "Enter ${1//[^a-zA-Z0-9_ ]/}password: "
    while read -rsn 1 local_char; do
        if [ "$local_char" == "" ]; then
            break
        fi
        if [ "$local_restrict_char" == "1" ]; then
            # Restrict allowed characters
            if [ "${local_char//[^a-zA-Z0-9]/}" == "" ]; then
                echo
                echo "'$local_char' is not allowed!!"
                return 1
            fi
        fi
        echo -n "*"
        local_pw="$local_pw$local_char"
    done
    echo
    pw="$local_pw"
    return 0
}

## Chars of "$1" is restricted to "a-zA-Z0-9_ ".
read_password "${1//[^a-zA-Z0-9_ ]/}"

