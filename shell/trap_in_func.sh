#!/usr/bin/env bash
# This is a part of:
# https://github.com/KazKobara/tips-jp/blob/gh-pages/shell/trap_in_func.sh
# https://kazkobara.github.io/tips-jp/shell/tips_of_shell.html

set -e
set -o errtrace  # To trap in a function.
trap 'echo "Error: line $LINENO returned $?!"' ERR

false_in_func () {
  echo "Before false"
  false
  echo "After false"
}

false_in_func

echo "Done"
