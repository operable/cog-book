#!/usr/bin/env ruby

require 'twitter'
require 'json'

puts "COGCMD_WARN: Starting" # <1>

client = Twitter::REST::Client.new(
  consumer_key: ENV["TWITTER_CONSUMER_KEY"],
  consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
  access_token: ENV["TWITTER_ACCESS_TOKEN"],
  access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"])

puts "COGCMD_INFO: Authenticated" # <2>

tweets = client.user_timeline(count: 5).map do |tweet|
  puts "COGCMD_DEBUG: Tweet - #{tweet.full_text}" # <3>
  {message: tweet.full_text, url: tweet.url}
end

puts "COGCMD_ERROR: Generating final output" # <4>
puts "COG_TEMPLATE: tweet"
puts "JSON"
puts JSON.generate(tweets)
