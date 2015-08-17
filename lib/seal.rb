#!/usr/bin/env ruby

require 'yaml'

require './lib/github_fetcher.rb'
require './lib/message_builder.rb'
require './lib/slack_poster.rb'

# Entry point for the Seal!
class Seal
  ORGANISATION ||= ENV['SEAL_ORGANISATION']

  def initialize(team, mood)
    @team = team
    @mood = mood
  end

  def bark
    message_builder = MessageBuilder.new(pull_requests, mood)
    # require 'pry';binding.pry
    message = message_builder.build
    slack = SlackPoster.new(ENV['SLACK_WEBHOOK'], config['channel'], message_builder.poster_mood)
    slack.send_request(message)
  end

  private

  attr_accessor :team, :mood

  def config
    @config ||= YAML.load_file("./config/#{ORGANISATION}.yml")[team]
  end

  def pull_requests
    git = GithubFetcher.new(config['members'],
                            config['repos'],
                            config['use_labels'],
                            config['exclude_labels'],
                            config['exclude_titles']
                           )
    git.list_pull_requests
  end
end
