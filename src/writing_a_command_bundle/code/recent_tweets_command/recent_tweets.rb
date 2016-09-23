#!/usr/bin/env ruby

require 'twitter'
require 'json'

client = Twitter::REST::Client.new(
  consumer_key: ENV["TWITTER_CONSUMER_KEY"],
  consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
  access_token: ENV["TWITTER_ACCESS_TOKEN"],
  access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"])

tweets = client.user_timeline(count: 5).map do |tweet| # <1>
  {message: tweet.full_text, url: tweet.url}
end

puts "COG_TEMPLATE: tweet" # <2>
puts "JSON"
puts JSON.generate(tweets) # <3>
