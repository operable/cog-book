require 'cog/command'
require 'twitter'

class CogCmd::Twitter::Tweet < Cog::Command

  def run_command
    client = Twitter::REST::Client.new(
      consumer_key: ENV["TWITTER_CONSUMER_KEY"],
      consumer_secret: ENV["TWITTER_CONSUMER_SECRET"],
      access_token: ENV["TWITTER_ACCESS_TOKEN"],
      access_token_secret: ENV["TWITTER_ACCESS_TOKEN_SECRET"])

    message = request.args.join(" ") # <1>
    client.update(message)
  end

end
