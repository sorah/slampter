require 'bundler/setup'
require 'securerandom'

require 'slampter'

run Slampter.app(
  dynamodb_table_name: ENV.fetch('SLAMPTER_DYNAMODB_TABLE', 'slampter'),
  token: ENV.fetch('SLAMPTER_SLACK_COMMAND_TOKEN', nil),
)
