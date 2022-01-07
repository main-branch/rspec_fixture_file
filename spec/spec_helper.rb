# frozen_string_literal: true

require 'pp'
require 'fakefs/spec_helpers'
require 'simplecov'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Setup simplecov

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter
]

SimpleCov.at_exit do
  unless RSpec.configuration.dry_run?
    SimpleCov.result.format!
    if SimpleCov.result.covered_percent < 100
      warn 'FAIL: RSpec Test coverage fell below 100%'
      exit 1
    end
  end
end

RSpec::Matchers.define :be_the_fixture do |expected_path, expected_content|
  match do |actual|
    expect(actual).to be_a(Pathname)
    expect(actual).to have_attributes(to_path: expected_path)
    expect(actual.read).to eq(expected_content)
  end
  failure_message do |actual|
    return "expected #{actual} to be a Pathname" unless actual.is_a?(Pathname)

    unless actual.to_s == expected_path
      return "expected #{actual.pretty_inspect.chomp} to be a path to '#{expected_path}'"
    end

    unless actual.read == expected_content
      "expected #{actual} to have content '#{expected_content}' but was '#{actual.read}'"
    end
  end
  description do
    "be the fixture '#{expected_path}' with content '#{expected_content}'"
  end
end

SimpleCov.start

require 'rspec_fixture_file'

RSpec.configure do |config|
  # This is the defaut but can be overridden
  # config.add_setting(:base_fixture_path, default: File.join(config.default_path, 'fixtures'))

  config.include RSpecFixtureFile
end
