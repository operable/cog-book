require 'cog/command' # <1>
require 'twitter'

class CogCmd::Twitter::Tweet < Cog::Command # <2>

  def run_command # <3>
    client = Twitter::REST::Client.new(
      consumer_key: ENV["TWITTER_CONSUMER_KEY"],
      consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
      access_token: ENV["TWITTER_ACCESS_TOKEN"],
      access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"])

    client.update("I'm figuring out how to use cog-rb")
  end

end
