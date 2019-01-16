require 'time'
require 'securerandom'

module Slampter
  class Store
    ATTRS = %i(
      channel
      timer_start
      timer_end
      headline
      standby_headline
      message
      blink_end
    )
    UPDATE_EXPRESSION = "SET #{ATTRS.map { |_| "#{_} = :#{_}" }.join(', ')}"
    Record = Struct.new(:ts, :view_key, *ATTRS, keyword_init: true) do 
      def to_expression_attribute_values
        ATTRS.map do |k|
          v = self[k]
          v = v.is_a?(Time) ? v.xmlschema : v
          [":#{k}", v]
        end.to_h
      end

      alias _ts ts
      alias _timer_start timer_start
      alias _timer_end timer_end
      alias _blink_end blink_end

      def ts; time(:ts); end
      def timer_start; time(:timer_start); end
      def timer_end; time(:timer_end); end
      def blink_end; time(:blink_end); end

      def as_json
        to_h.merge(
          ts: ts&.to_i,
          timer_start: timer_start&.to_i,
          timer_end: timer_end&.to_i,
          blink_end: blink_end&.to_i,
        )
      end

      private

      def time(k)
        if self[k].is_a?(String) 
          self[k] = Time.parse(self[k]) rescue nil
        else
          self[k]
        end
      end
    end

    def initialize(dynamodb, table_name)
      @dynamodb = dynamodb
      @table_name = table_name
    end

    attr_reader :dynamodb, :table_name

    def get_by_key(key)
      item = dynamodb.query(
        table_name: table_name,
        limit: 1,
        select: 'ALL_ATTRIBUTES',
        key_condition_expression: 'view_key = :view_key AND ts < :ts',
        expression_attribute_values: {":view_key" => key, ":ts" => format_ts(Time.now)},
        scan_index_forward: false,
      ).items.first

      make_record(item)
    end

    def get_by_channel(channel)
      item = dynamodb.query(
        table_name: table_name,
        index_name: 'channel-ts-index',
        limit: 1,
        select: 'ALL_ATTRIBUTES',
        key_condition_expression: 'channel = :channel AND ts < :ts',
        expression_attribute_values: {":channel" => channel, ":ts" => format_ts(Time.now)},
        scan_index_forward: false,
      ).items.first

      make_record(item)
    end

    def create(channel)
      retries = 0
      begin
        view_key = SecureRandom.urlsafe_base64(48)
        dynamodb.update_item(
          table_name: table_name,
          key: {
            'view_key' => view_key,
            'ts' => '0000-00-00T00:00:00Z',
          },
          update_expression: 'SET channel = :channel',
          condition_expression: 'attribute_not_exists(view_key)',
          expression_attribute_values: {
            ':channel' => channel,
          },
        )
        return Record.new(view_key: view_key, channel: channel)
      rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
        retries += 1
        raise if retries > 3
        sleep 0.1
        retry
      end
    end

    def put(record, ts: Time.now)
      dynamodb.update_item(
        table_name: table_name,
        key: {
          'view_key' => record.view_key,
          'ts' => format_ts(ts || record.ts),
        },
        update_expression: UPDATE_EXPRESSION,
        expression_attribute_values: record.to_expression_attribute_values,
      )
    end

    private

    def make_record(item)
      return nil unless item
      Record.new.tap do |r|
        r.view_key = item['view_key']
        r.ts = item['ts']
        ATTRS.map do |k|
          r[k] = item[k.to_s]
        end
      end
    end

    def format_ts(time)
      time.utc.xmlschema
    end
  end
end
