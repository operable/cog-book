#!/bin/bash

declare -a TWEET_ARGUMENTS
for ((i=0;i<${COG_ARGC};i++)); do
    var="COG_ARGV_${i}"
    TWEET_ARGUMENTS[$i]=${!var}
done

if [ -n "${COG_OPT_AS}" ] # <1>
then
    account=${COG_OPT_AS}
else
    account=${TWITTER_DEFAULT_ACCOUNT}
fi
account=$(echo $account | tr '[a-z]' '[A-Z]') # <2>

# <3>
export TWITTER_CONSUMER_KEY=$(eval "echo \$$(echo TWITTER_CONSUMER_KEY_${account})")
export TWITTER_CONSUMER_SECRET=$(eval "echo \$$(echo TWITTER_CONSUMER_SECRET_${account})")
export TWITTER_ACCESS_TOKEN=$(eval "echo \$$(echo TWITTER_ACCESS_TOKEN_${account})")
export TWITTER_ACCESS_TOKEN_SECRET=$(eval "echo \$$(echo TWITTER_ACCESS_TOKEN_SECRET_${account})")

output=$(bundle exec $(dirname ${0})/tweet.rb ${TWEET_ARGUMENTS[*]})

message=$(echo "$output" | grep "Message: " | cut -d":" -f2 | sed -e 's/^ *//')
url=$(echo "$output" | grep "URL: " | sed -e 's/^URL: *//')

echo "COG_TEMPLATE: tweet"
echo "JSON"
echo "{\"message\": \"${message}\", \"url\": \"${url}\"}"
