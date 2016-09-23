#!/bin/sh

declare -a TWEET_ARGUMENTS
for ((i=0;i<${COG_ARGC};i++)); do
    var="COG_ARGV_${i}"
    TWEET_ARGUMENTS[$i]=${!var}
done

output=$(bundle exec $(dirname ${0})/tweet.rb ${TWEET_ARGUMENTS[*]})

message=$(echo "$output" | grep "Message: " | cut -d":" -f2 | sed -e 's/^ *//')
url=$(echo "$output" | grep "URL: " | sed -e 's/^URL: *//')

echo "COG_TEMPLATE: tweet" # <1>
echo "JSON"
echo "{\"message\": \"${message}\", \"url\": \"${url}\"}"
