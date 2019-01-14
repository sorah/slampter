#!/usr/bin/env ruby
require 'slampter'

store = Slampter::Store.new(Aws::DynamoDB::Client.new, ENV['SLAMPTER_DYNAMODB_TABLE'] || 'slampter')
puts Slampter::SlashCommand.new(
  command: '/pt',
  enterprise_id: ENV['SLAMPTER_ENTERPRISE_ID'],
  team_id: ENV['SLAMPTER_TEAM_ID'] || 'cli',
  channel_id: ENV['SLAMPTER_CHANNEL'] || 'cli',
  text: ARGV.join(' '),
  store: store,
  base_url: 'http://localhost:3000',
).json

