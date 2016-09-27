#!/bin/bash

# Asciidoctor currently doesn't have a way to fail a build if there
# are, say, missing include files or images. It does, however, log
# these occurrences when they happen.
#
# This utility will scan the build output (supplied on standard input)
# and if any offending log lines are detected, we can fail.

if egrep "asciidoctor: (WARNING|ERROR)" <&0
then
    echo "Build problems found; failing!"
    exit 1
fi
