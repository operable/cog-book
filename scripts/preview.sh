#!/bin/bash

set -x

all_docs="./cog-book ./style-guide"

function verify_fswatch {
  cmdpath=`which fswatch`
  if [ "${cmdpath}" == "" ]; then
    printf "fswatch command not found\n" 1>&2
    exit 1
  fi
}

trap "echo Done;exit 0" SIGINT SIGTERM

verify_fswatch

watched_paths=""
while [ $# -gt 0 ]
do
  watched_paths="${watched_paths} ${1}"
  shift
done

if [ "${watched_paths}" == "" ]; then
  watched_paths=${all_docs}
fi

while [ 1 ]
do
  fswatch -L -0 -1 ${watched_paths} | make all
done
