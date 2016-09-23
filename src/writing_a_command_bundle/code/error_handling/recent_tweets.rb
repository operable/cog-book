#!/usr/bin/env ruby

require 'twitter'
require 'json'

begin # <1>
  client = Twitter::REST::Client.new(
    consumer_key: ENV["TWITTER_CONSUMER_KEY"],
    consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
    access_token: ENV["TWITTER_ACCESS_TOKEN"],
    access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"])

  tweets = client.user_timeline(count: 5).map do |tweet|
    {message: tweet.full_text, url: tweet.url}
  end

  puts "COG_TEMPLATE: tweet"
  puts "JSON"
  puts JSON.generate(tweets)
rescue Twitter::Error::Unauthorized # <2>
  STDERR.puts "Could not authenticate with Twitter API; check your authentication tokens!"
  exit 1 # <3>
end
