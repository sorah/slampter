require 'json'

module Slampter
  class SlashCommand
    def initialize(command: nil, enterprise_id: nil, team_id:, channel_id:, text:, store:, base_url:)
      @slash_command_name = command
      @enterprise_id = enterprise_id
      @team_id = team_id
      @channel_id = channel_id

      @text = text

      @store = store
      @base_url = base_url
    end

    attr_reader :enterprise_id, :team_id, :channel_id, :text, :store, :base_url
    attr_reader :slash_command_name

    def result
      return @result if defined? @result
      @result = __send__(command)
      if defined? @candidate && current != candidate
        store.put(candidate)
      end
      @result
    end

    def json
      result.to_json
    end

    def command_and_arguments
      @command_and_arguments ||= text.split(/\s+/, 2)
    end

    def arguments_text
      command_and_arguments[1]
    end

    def command
      @command ||= {
        nil => :cmd_help,
        'message' => :cmd_message,
        'clear' => :cmd_clear,
        'headline' => :cmd_headline,
        'blink' => :cmd_blink,
        'timer' => :cmd_timer,
        'cue' => :cmd_cue,
        'timer-override' => :cmd_timer_override,
        '-regenerate' => :cmd_regenerate,
      }.fetch(command_and_arguments[0], :cmd_default_message)
    end

    def current
      @current ||= store.get_by_channel(channel_specifier) || store.create(channel_specifier)
    end

    def candidate
      @candidate ||= current.dup
    end

    def cmd_help
      url = "#{base_url}/p/#{current.view_key}"
      {text: <<~EOF, response_type: "in_channel"}
      *URL:* #{url}

      `#{slash_command_name}` Help and URL
      `#{slash_command_name} headline HEADLINE` Update headline
      `#{slash_command_name} message MESSAGE` Update message
      `#{slash_command_name} clear` Clear message
      `#{slash_command_name} blink [DURATION]` Blink message
      `#{slash_command_name} timer DURATION` Set timer
      `#{slash_command_name} timer off` Reset timer to off
      `#{slash_command_name} cue STBY REMAIN HEADLINE` Set timer with standby & headline
      `#{slash_command_name} timer-override DURATION HEADLINE` Override timer temporarily

      _DURATION, STBY, REMAIN_ can be specified in `1h2m5s` (relative) `@21:22:23` (UTC absolute) format. 
      EOF
    end

    def cmd_regenerate
      record = store.create(channel_specifier)
      store.put(record)

      url = "#{base_url}/p/#{record.view_key}"
      {text: <<~EOF, response_type: "in_channel"}
      *URL:* #{url}
      EOF
    end

    def cmd_default_message
      cmd_message(message: command_and_arguments.join(' '))
    end

    def cmd_message(message: arguments_text)
      candidate.message = message
      {text: "Message sent", response_type: "in_channel"}
    end

    def cmd_clear
      candidate.message = nil
      {text: "Message cleared", response_type: "in_channel"}
    end

    def cmd_headline
      candidate.headline = arguments_text
      {text: "Headline updated", response_type: "in_channel"}
    end

    def cmd_blink
      if arguments_text&.strip == 'off'
        candidate.blink_end = nil
        {text: "stopped blinking", response_type: "in_channel"}
      else
        candidate.blink_end = parse_time(arguments_text&.strip) || (Time.now.utc + 10)
        {text: "Triggered blink until #{format_time(candidate.blink_end)}", response_type: "in_channel"}
      end
    end

    def cmd_timer
      if arguments_text&.strip == 'off'
        candidate.timer_start = nil
        candidate.timer_end = nil
        {text: "timer off", response_type: "in_channel"}
      else
        duration_str, headline = arguments_text.strip.split(/\s+/, 2)
        candidate.timer_end = parse_time(duration_str)
        if candidate.timer_end
          candidate.headline = headline
          {text: "Timer set to #{format_time(candidate.timer_end)}", response_type: "in_channel"}
        else
          {text: "Error: cannot parse time specification", response_type: "in_channel"}
        end
      end
    end

    def cmd_timer_override
      cmd_timer
      if current.timer_end != candidate.timer_end
        store.put(current, ts: candidate.timer_end)
        {text: "Timer overridden until #{format_time(candidate.timer_end)}", response_type: "in_channel"}
      else
          {text: "Error: cannot parse time specification", response_type: "in_channel"}
      end
    end

    def cmd_cue
      arguments = arguments_text.strip.split(/\s+/, 3)
      if arguments.size < 2
        return {text: "Error: missing arguments (stby live [headline])", response_type: "in_channel"}
      end
      stby, live, headline = arguments

      timer_start = parse_time(stby)
      timer_end = parse_time(live, base: candidate.timer_start)

      unless timer_start && timer_end
        return {text: "Error: cannot parse time specification", response_type: "in_channel"}
      end

      candidate.headline = headline if headline
      candidate.message = nil
      candidate.timer_start = timer_start
      candidate.timer_end = timer_end

      {text: "Cue: Starts at #{format_time(candidate.timer_start)}, Ends at #{format_time(candidate.timer_end)}", response_type: "in_channel"}
    end


    private

    def channel_specifier
      # channel_id is not guaranteed unique within a enterprise_id, but we don't have a way to know the channel is shared or not
      "#{enterprise_id || team_id}/#{channel_id}"
    end

    def format_time(time)
      time.strftime('%H:%M:%S')
    end

    def parse_time(string, base: nil)
      return nil unless string
      now = base || Time.now.utc
      case string
      when /\A@(\d+):(\d+)(?::(\d+))\z/
        begin
          ts = Time.utc(now.year, now.month, now.day, $1.to_i, $2.to_i, $3.to_i)
        rescue ArgumentError
          return nil
        end
        if ts < now
          ts + 86400
        else
          ts
        end
      when /\A(\d+[hms]?)+\z/
        d = string.scan(/(\d+)([hms]?)/).map do |(duration, unit)|
          unit_multiplier = {'h' => 3600, 'm' => 60, 's' => 1}.fetch(unit, 1)
          duration.to_i * unit_multiplier
        end.inject(:+)
        now + d
      else
        nil
      end
    end
  end
end
