#!/bin/sh

declare -a TWEET_ARGUMENTS
for ((i=0;i<${COG_ARGC};i++)); do
    var="COG_ARGV_${i}"
    TWEET_ARGUMENTS[$i]=${!var}
done

output=$(bundle exec $(dirname ${0})/tweet.rb ${TWEET_ARGUMENTS[*]})     # <1>

message=$(echo "$output" | grep "Message: " | cut -d":" -f2 | sed -e 's/^ *//') # <2>
url=$(echo "$output" | grep "URL: " | sed -e 's/^URL: *//')

echo "JSON"                                                  # <3>
echo "{\"message\": \"${message}\", \"url\": \"${url}\"}"
