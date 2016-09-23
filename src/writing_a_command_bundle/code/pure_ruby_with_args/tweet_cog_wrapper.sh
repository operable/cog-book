#!/bin/bash

declare -a TWEET_ARGUMENTS # <1>
for ((i=0;i<${COG_ARGC};i++)); do
    var="COG_ARGV_${i}"
    TWEET_ARGUMENTS[$i]=${!var}
done

./tweet.rb ${TWEET_ARGUMENTS[*]} # <2>
