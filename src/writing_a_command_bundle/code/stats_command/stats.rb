#!/usr/bin/env ruby

require 'twitter'
require 'json'

client = Twitter::REST::Client.new(
  consumer_key: ENV["TWITTER_CONSUMER_KEY"],
  consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
  access_token: ENV["TWITTER_ACCESS_TOKEN"],
  access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"])

tweet = if ARGV.length == 1 # <1>
           ARGV[0]
         else
           tweet = JSON.parse(STDIN.read) # <2>
           tweet["url"]
         end

tweet = client.status(tweet) # <3>
puts <<-EOM
URL: #{tweet.url}
Favorites: #{tweet.favorite_count}
Retweets: #{tweet.retweet_count}
EOM
