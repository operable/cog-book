#!/usr/bin/env ruby

require 'bundler/setup'
require 'twitter'
require 'json'

account = ENV['TWITTER_DEFAULT_ACCOUNT'].upcase # <1>
client = Twitter::REST::Client.new(
  consumer_key: ENV["TWITTER_CONSUMER_KEY_#{account}"],
  consumer_secret: ENV["TWITTER_CONSUMER_SECRET_#{account}"],
  access_token: ENV["TWITTER_ACCESS_TOKEN_#{account}"],
  access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET_#{account}"])

tweet = if ENV['COG_ARGC'] == "1" # <2>
          ENV['COG_ARGV_0']
        else
          tweet = JSON.parse(STDIN.read) # <3>
          tweet["url"]
        end

tweet = client.status(tweet) # <4>

puts "COG_TEMPLATE: stats"
puts "JSON"
puts JSON.generate({message: tweet.full_text,
                    favorites: tweet.favorite_count,
                    retweets: tweet.retweet_count})
