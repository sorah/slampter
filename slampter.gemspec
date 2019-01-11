
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "slampter/version"

Gem::Specification.new do |spec|
  spec.name          = "slampter"
  spec.version       = Slampter::VERSION
  spec.authors       = ["Sorah Fukumori"]
  spec.email         = ["sorah@cookpad.com"]

  spec.summary       = %q{Prompter via Slack slash command}
  spec.homepage      = "https://github.com/sorah/slampter"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ['extconf.rb']

  spec.add_dependency "sinatra"
  spec.add_dependency "aws-sdk-dynamodb"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
