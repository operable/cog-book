#!/bin/bash

declare -a ARGUMENTS # <1>
if [ -n "${COG_ARGC}" ]
then
    for ((i=0;i<${COG_ARGC};i++)); do
        var="COG_ARGV_${i}"
        ARGUMENTS[$i]=${!var}
    done
fi

output=$(bundle exec ./stats.rb ${ARGUMENTS[*]} <&0) # <2>

url=$(echo "$output" | grep "URL: " | sed -e 's/^URL: *//') # <3>
favorites=$(echo "$output" | grep "Favorites: " | sed -e 's/^Favorites: *//')
retweets=$(echo "$output" | grep "Retweets: " | sed -e 's/^Retweets: *//')

echo "COG_TEMPLATE: tweet-stats"
echo "JSON"
echo "{"
echo " \"url\": \"${url}\","
echo " \"favorites\": \"${favorites}\","
echo " \"retweets\": \"${retweets}\""
echo "}"
