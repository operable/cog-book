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

bundle exec ./recent_tweets.rb
