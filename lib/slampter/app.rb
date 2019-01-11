require 'securerandom'

require 'sinatra/base'
require 'aws-sdk-dynamodb'

require 'slampter/store'
require 'slampter/slash_command'

module Slampter
  def self.app(*args)
    App.rack(*args)
  end

  class App < Sinatra::Base
    CONTEXT_RACK_ENV_NAME = 'slampter.ctx'

    def self.initialize_context(config)
      {
        config: config,
      }
    end

    def self.rack(config={})
      klass = App

      context = initialize_context(config)
      lambda { |env|
        env[CONTEXT_RACK_ENV_NAME] = context
        klass.call(env)
      }
    end

    configure do
      enable :logging
    end

    set :root, File.expand_path(File.join(__dir__, '..', '..'))

    helpers do
      def context
        request.env[CONTEXT_RACK_ENV_NAME]
      end

      def conf
        context[:config]
      end

      def dynamodb
        context[:dynamodb] ||= Aws::DynamoDB::Client.new
      end

      def store
        context[:store] ||= Slampter::Store.new(dynamodb, conf.fetch(:dynamodb_table_name))
      end
    end

    get '/' do
      text '...'
    end

    post '/slash' do
      if conf[:token] && conf[:token] != params[:token]
        halt 403
      end
      content_type :json
      Slampter::SlashCommand.new(
        enterprise_id: params[:enterprise_id],
        team_id: params[:team_id],
        channel_id: params[:channel_id],
        text: params[:text],
        store: store,
        base_url: request.base_url,
      ).json
    end

    HTML_FILE = File.join(__dir__, '..', '..', 'public', 'index.html')
    get '/p/:view_key' do
      data = store.get_by_key(params[:view_key])
      halt 404 unless data
      content_type :html
      File.read HTML_FILE
    end

    get '/data/:view_key' do
      content_type :json
      data = store.get_by_key(params[:view_key])
      halt 404 unless data
      data.as_json.merge(st: Time.now.to_i).to_json
    end
  end
end
