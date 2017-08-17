#! /bin/bash

# Generate code HTML by woboq using compile_commands.json
# Dependence:
#   - compile_commands.json exist
#   - woboq has been built (which means clang environment is available)
# see: https://github.com/woboq/woboq_codebrowser
#
# Author: Yantao Zhao
# Update: 2017.08.01


function Usage() {
    echo "Usage:    $0  woboqRoot  codeRoot  outputRoot  projectName"
    echo "Example:  $0  ~/woboq_codebrowser-2.1/  ~/linux-3.18.65/  ~/public_html/  linuxkernel"
}

## check params
if [[ $# -lt 4 ]]; then
    Usage
    exit
fi

woboqRoot=${1%/}
# codeRoot=$2
outputRoot=${3%/}
projectName=$4

OUTPUTDIRECTORY=$outputRoot/${projectName}
DATADIRECTORY=$OUTPUTDIRECTORY/../data
BUILDIRECTORY=${2%/}
# VERSION=`git describe --always --tags`


## check the woboq binary
if ! [[ -x $woboqRoot/generator/codebrowser_generator && -x $woboqRoot/indexgenerator/codebrowser_indexgenerator ]]; then
    echo -e "woboq binary not exist!\nexit"
    exit
fi

## check the output directory
if [[ -d $OUTPUTDIRECTORY ]]; then
    echo "Warning: output directory '$OUTPUTDIRECTORY' already exist!"
    read -p "Backup it automatically and continue? [Y/n]" bkup
    case $bkup in
        [yY] | [yY][eE][sS] | '' )
            mv -fv $OUTPUTDIRECTORY $OUTPUTDIRECTORY.backup.$(date +%Y%m%d_%H%M%S)
            if [[ $? -ne 0 ]]; then exit; fi
            ;;
        * )
            echo "Nothing done, exit"
            exit
            ;;
    esac
fi

mkdir -pv $OUTPUTDIRECTORY
sleep 1


pushd .
cd $woboqRoot
./generator/codebrowser_generator -b $BUILDIRECTORY -a -o $OUTPUTDIRECTORY -p ${projectName}:$BUILDIRECTORY
./indexgenerator/codebrowser_indexgenerator $OUTPUTDIRECTORY
cp -rv ./data $DATADIRECTORY
popd

echo "Result at: $OUTPUTDIRECTORY"
