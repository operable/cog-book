#!/bin/bash

declare -a ARGUMENTS # <1>
for ((i=0;i<${COG_ARGC};i++)); do
    var="COG_ARGV_${i}"
    ARGUMENTS[$i]=${!var}
done

./tweet.rb ${ARGUMENTS[*]} # <2>
