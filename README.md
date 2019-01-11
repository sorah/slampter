# Slampter

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/slampter`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Setup

### DynamoDB Table

- primary key: `view_key` (string)
- primary sort key: `ts` (string)
- GSIs:
  - `channel-ts-index`:
    - partition `channel` (string)
    - sort `ts` (string)

## Usage

### Slash Command

- url and help: `/pt`
- headline: `/pt headline aaa aaaa`
- message: `/pt message fooo barrr`
- blink:
  - `/pt blink` (5s)
  - `/pt blink 15s`
  - `/pt blink off`
- cue:
  - `/pt cue 45s 1h HEADLINE`
- timer:
  - `/pt timer 1h`
  - `/pt timer off`
- schedule:
  - `/pt schedule 1m blink 15s`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/slampter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
