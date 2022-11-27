#!/bin/bash
#
# PyPI Registration Script
#
# This script requires ​setup.py, setup.cfg, and ~/.pypirc explained in 
# https://github.com/KazKobara/tips-jp/blob/gh-pages/python/PyPI.md
# (in Japanese).

### Params ###
VER=0.0.0
COMMAND=$(basename "$0")

### Functions ###
usage () {
    echo "PyPI Registration Script ${VER}"
    echo "Usage:"
    echo "  ./${COMMAND} <package_name> <package_ver>"
}

# @brief Read 'y' or 'n' and then return 0 or 1, respectively.
# @return 0 for 'y' and 1 for 'n'.
y_or_n () {
    while read -r ans; do
        if [ "$ans" == "y" ]; then
            return 0
        elif [ "$ans" == "n" ]; then
            return 1
        fi
        echo -n "Enter either 'y' or 'n':"
    done
}

# @brief Remove files then exit 1.
# @param $1 package_name
# @param $2 version
# @exit 1
rm_exit1 (){
    echo "Edit files so that the tests should pass."
    rm -f dist/"$1"-"$2"{-py*,.tar.gz}
    exit 1
}

# @brief Show upload-check message 1.
# @param $1 package_name
# @param $2 version
upload_check_message1 () {
    echo
    echo "In a test environment, run the following commands, then test it!"
    echo " \$ pip uninstall $1"
    echo " \$ pip install $3 $1==$2"
}

# @brief Show upload-check message 2.
# @param $1 package_name
# @param $2 version
# @exit 1
upload_check_message2 () {
    echo
    echo -n "Are the tests passed? [y/n]:"
    if ! y_or_n; then
        # if no
        echo
        echo "Assign '$1.__version__' a new version number, such as '1.0.0a1',"
        echo "(since the same version number cannot be uploaded)."
        rm_exit1 "$1" "$2"
    fi
    echo
}

### Body ###

# Setup and check
if [ "$1" == "" ] || [ "$2" == "" ]; then
    usage
    exit 1
fi

python setup.py sdist bdist_wheel && echo && twine check dist/"$1"-"$2"{-py*,.tar.gz}

echo
echo -n "Have the checks 'PASSED'? [y/n]:"
if ! y_or_n; then
    # if no
    echo
    rm_exit1 "$1" "$2"
fi

# Local test
upload_check_message1 "$1" "$2" "--no-index --find-links=$(pwd)/dist"
echo
echo -n "Are the tests passed? [y/n]:"
if ! y_or_n; then
    # if no
    echo
    rm_exit1 "$1" "$2"
fi

echo
echo "====== Uploading to testpypi ========="
twine upload -r testpypi dist/"$1"-"$2"{-py*,.tar.gz}
# Test using testpypi
upload_check_message1 "$1" "$2" "-i https://test.pypi.org/simple/"
upload_check_message2 "$1" "$2"

echo
echo "====== Uploading to pypi ========="
twine upload -r pypi dist/"$1"-"$2"{-py*,.tar.gz}
# Test using pypi
upload_check_message1 "$1" "$2"
upload_check_message2 "$1" "$2"

echo "Done!!"
exit 0
