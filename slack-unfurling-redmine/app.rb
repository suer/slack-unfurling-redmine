# frozen_string_literal: true

require_relative 'lib/slack_unfurling'
require_relative 'lib/redmine_client'

def lambda_handler(event:, context:)
  SlackUnfurling.new(RedmineClient.new).call(event)
end
