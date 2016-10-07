#!/usr/bin/env ruby

require 'bundler/setup'
require 'twitter'
require 'json'

account = (ENV['COG_OPT_AS'] ? ENV['COG_OPT_AS'] : ENV['TWITTER_DEFAULT_ACCOUNT']).upcase # <1>
client = Twitter::REST::Client.new(
  consumer_key: ENV["TWITTER_CONSUMER_KEY_#{account}"],
  consumer_secret: ENV["TWITTER_CONSUMER_SECRET_#{account}"],
  access_token: ENV["TWITTER_ACCESS_TOKEN_#{account}"],
  access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET_#{account}"])

tweets = client.user_timeline(count: 5).map do |tweet| # <2>
  {message: tweet.full_text, url: tweet.url}
end

puts "COG_TEMPLATE: tweet" # <3>
puts "JSON"
puts JSON.generate(tweets) # <4>
