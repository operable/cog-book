#!/bin/bash

if [ -n "${COG_OPT_AS}" ]
then
    account=${COG_OPT_AS}
else
    account=${TWITTER_DEFAULT_ACCOUNT}
fi
account=$(echo $account | tr '[a-z]' '[A-Z]')

# <3>
export TWITTER_CONSUMER_KEY=$(eval "echo \$$(echo TWITTER_CONSUMER_KEY_${account})")
export TWITTER_CONSUMER_SECRET=$(eval "echo \$$(echo TWITTER_CONSUMER_SECRET_${account})")
export TWITTER_ACCESS_TOKEN=$(eval "echo \$$(echo TWITTER_ACCESS_TOKEN_${account})")
export TWITTER_ACCESS_TOKEN_SECRET=$(eval "echo \$$(echo TWITTER_ACCESS_TOKEN_SECRET_${account})")

declare -a STATS_ARGUMENTS # <1>
if [ -n "${COG_ARGC}" ]
then
    for ((i=0;i<${COG_ARGC};i++)); do
        var="COG_ARGV_${i}"
        STATS_ARGUMENTS[$i]=${!var}
    done
fi

output=$(bundle exec ./stats.rb ${STATS_ARGUMENTS[*]} <&0) # <2>

message=$(echo "$output" | grep "Message: " | cut -d":" -f2 | sed -e 's/^ *//')
url=$(echo "$output" | grep "URL: " | sed -e 's/^URL: *//') # <3>
favorites=$(echo "$output" | grep "Favorites: " | sed -e 's/^Favorites: *//')
retweets=$(echo "$output" | grep "Retweets: " | sed -e 's/^Retweets: *//')

echo "COG_TEMPLATE: stats"
echo "JSON"
echo "{"
echo " \"message\": \"${message}\","
echo " \"url\": \"${url}\","
echo " \"favorites\": \"${favorites}\","
echo " \"retweets\": \"${retweets}\""
echo "}"
