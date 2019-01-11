#!/usr/bin/env ruby
if ENV['SLAMPTER_SKIP_ASSET_BUILD']
  exit 0
end

# dummy. this is to build if needed.
if File.exist?(File.join(__dir__, "public"))
  exit 0
end

Dir.chdir(__dir__)

ENV['NODE_ENV'] = 'production'
system 'yarn' or raise
system './node_modules/.bin/webpack' or raise
