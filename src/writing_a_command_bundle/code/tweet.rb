require 'twitter'

client = Twitter::REST::Client.new(
  consumer_key: ENV["TWITTER_CONSUMER_KEY"],                # <1>
  consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
  access_token: ENV["TWITTER_ACCESS_TOKEN"],
  access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"])

client.update("This is an interesting tweet")               # <2>
