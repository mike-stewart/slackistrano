require 'slackistrano/version'
require 'net/http'
require 'json'

load File.expand_path("../slackistrano/tasks/slack.rake", __FILE__)

module Slackistrano

  #
  #
  #
  def self.post(team = nil, token = nil, webhook = nil, via_slackbot = false, payload = {})
    if via_slackbot
      post_as_slackbot(team, token, webhook, payload)
    else
      post_as_webhook(team, token, webhook, payload)
    end
  rescue => e
    puts "There was an error notifying Slack."
    puts e.inspect
  end

  #
  #
  #
  def self.post_as_slackbot(team = nil, token = nil, webhook = nil, payload = {})
    uri = URI(URI.encode("https://#{team}.slack.com/services/hooks/slackbot?token=#{token}&channel=#{payload[:channel]}"))

    text = payload[:attachments].collect { |a| a[:text] }.join("\n")

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request_post uri.request_uri, text
    end
  end

  #
  #
  #
  def self.post_as_webhook(team = nil, token = nil, webhook = nil, payload = {})
    params = {'payload' => payload.to_json}

    if webhook.nil?
      webhook = "https://#{team}.slack.com/services/hooks/incoming-webhook"
      params.merge!('token' => token)
    end

    uri = URI(webhook)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path)
    request.add_field('Content-Type', 'application/json')
    request.body = payload.to_json
    http.request(request)
  end


end

