#!/bin/sh
# Backup and restore script for GnuPG 2.
set -e

VERSION=0.0.0

: <<'COMMENT_EOF'
=== How to install this script ===

# Download
$ cd "${HOME}/.gnupg"
$ curl -O "https://raw.githubusercontent.com/KazKobara/tips-jp/gh-pages/linux/gnupg_backup_restore.sh"

# Review and check the behavior!!
$ cat ./gnupg_backup_restore.sh
$ chmod 700 ./gnupg_backup_restore.sh

# See usage:
$ ./gnupg_backup_restore.sh -h
COMMENT_EOF

### functions ###

show_info() {
cat <<EOF
Maintained at:
 https://github.com/KazKobara/tips-jp/tree/gh-pages/linux/gnupg_backup.sh
 https://kazkobara.github.io/tips-jp/linux/gpg_failed_to_sign_the_data_in_git_on_wsl.html
EOF
# Do not exit since called in usage. 
}

show_version() {
cat <<VERSION_EOF
GnuPG 2 backup and restore script ${VERSION}.
VERSION_EOF
# Do not exit since called in usage. 
}

usage() {
show_version
cat <<USAGE_EOF

Usage:

----- Backup to <dest_dir> -----------
In "${HOME}/.gnupg, run:

./$(basename "${0}") -b <dest_dir>

---- Restore to ${HOME}/.gnupg -------
In the <dest_dir>, run:

./$(basename "${0}") -r

--------------------------------------

Options:
  -h : help
  -v : version
  -b dest_dir : direcotry to make backup copies.
  -r: restore to ${HOME}/.gnupg

USAGE_EOF
show_info
exit 0
}

# @param $1 Direcotry to check
# @param "text" Explanation text of the directory 
check_dir () {
  if [ -e "$1" ]; then
    if [ -d "$1" ]; then
      echo -n "$2 '$1' exists"
      if [ "$(find "$1" | wc -l)" = "1" ]; then 
        echo " with empty."
      else
        echo " with the following files and/or directories:"
        echo "---------------------------------------------"
        ls -A --color --file-type "$1"
        echo "---------------------------------------------"
      fi
      echo  
    else
      echo "Error: $1 is not a directory!!"
      exit 1
    fi
  else
    echo "$2 '$1' will be created."
    echo
  fi
  return 0
}

password_explanation () {
  echo "In the next step, the password for your private key is required to see if you know it."
  echo "The backup file of your private key will stay encrypted since it is required again to restore it."
  echo
}

ask_proceed () {
  echo -n "Do you want to proceed? [y]:"
  read -r ans
  case "$ans" in
    "" ) ;;
    [Yy]* ) ;;
    * ) exit 0;;
  esac
}

# @param $1 Direcotry to make backup copies
# https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration.html
backup() {
  # PWD check
  if [ "$(basename "$PWD")" != ".gnupg" ]; then
    echo "Error: run in '${HOME}/.gnupg'!! (you are in '$PWD'.)"
    exit 1
  fi
  # BK dir check
  check_dir "$1" "Back up dir"
  password_explanation
  ask_proceed
  echo "--- backup to '$1' in progress ... ---"
  # mkdir if not exists
  mkdir -p "$1"

  gpg --export-ownertrust > "$1/otrust.lst"
  gpg --export-options backup -o "$1/pubring.gpg" --export --armor
  # gpg --list-secret-keys --keyid-format LONG
  gpg --export-options backup -o "$1/private.gpg" --export-secret-keys --armor
  cp -p "./$(basename "${0}")" "$1/."
  echo
  echo "Contents of '$1':"
  echo "---------------------------------------------"
  ls -A --color --file-type "$1"
  echo "---------------------------------------------"
  echo
  echo "Copy '$1/' to a new machine, and then run in the dir:"
  echo
  echo "\$ ./$(basename "${0}") -r"

  exit 0
}

restore () {
  echo "--- restoring to '$HOME/.gnupg' ---"
  check_dir "$HOME/.gnupg" "Restore dir"
  password_explanation
  ask_proceed

  # gpg --import-options restore --import publickeys.backups
  # gpg --import-options restore --import private.gpg
  gpg --import-options keep-ownertrust --import "./pubring.gpg"
  gpg --import-options keep-ownertrust --import private.gpg
  # seems 'keep-ownertrust' does not work, so run:
  gpg --import-ownertrust "./otrust.lst"
  cp -p "./$(basename "${0}")" "$HOME/.gnupg/."
  echo
  echo "Contents of '$HOME/.gnupg':"
  echo "---------------------------------------------"
  ls -A --color --file-type "$HOME/.gnupg"
  echo "---------------------------------------------"
  echo "--- public-keys ---"
  gpg --list-public-keys
  echo "--- private-keys ---"
  gpg --list-secret-keys
  echo "-------------------"
  echo 
  echo "Restored GnuPG keys as above!!"
  echo
  echo "If the trust of your private key is [unknown], run and respond as follows:"
  echo "$ gpg --edit-key"
  echo "gpg> trust"
  echo "Your decision? 5"
  echo "Do you really want to set this key to ultimate trust? (y/N) y"
  echo "gpg> quit"

  exit 0
}

# If do not want to show "Illegal option", prepend ':' like
# while getopts ":b:rhv" opt
while getopts "rhvb:" opt
do
  case $opt in
    v ) show_version; exit 0 ;;
    h ) usage ;;
    b ) FLAG_B=1; B_ARG="$OPTARG" ;;
    r ) FLAG_R=1; ;;
    * ) usage ;;
  esac
done
# if no short option is allowed
if [ $OPTIND -eq 1 ]; then
  echo "Error: no short option is given!!"
  usage
fi
shift  $((OPTIND - 1))

### check arg ###
if [ "$1" != "" ]; then
  echo
  echo "Error: '$1' is ignored in this command!!"
  echo "NOTE : The string right after '-b' becomes OPTARG, e.g. OPTARG=r for '-br dir'."
  echo
  exit 1
fi

### body ###
if [ "${FLAG_B}" = "1" ] && [ "${FLAG_R}" = "1" ]; then
  echo "Error: do not use both '-b' and '-r' options simultaneously!!"
  exit 1
elif [ "${FLAG_R}" = "1" ]; then
  restore
elif [ "${FLAG_B}" = "1" ]; then
  backup "$B_ARG"
fi

exit 0
