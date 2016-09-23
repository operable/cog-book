#!/usr/bin/env ruby

require 'twitter'

client = Twitter::REST::Client.new(
  consumer_key: ENV["TWITTER_CONSUMER_KEY"],
  consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
  access_token: ENV["TWITTER_ACCESS_TOKEN"],
  access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"])

message = ARGV.join(" ")

tweet = client.update(message)

puts <<-EOM
Message: #{message}
URL:     #{tweet.url}
EOM
