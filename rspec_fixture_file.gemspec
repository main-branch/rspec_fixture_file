# Copyright (c) 2021 Verizon

# frozen_string_literal: true

require_relative 'lib/rspec_fixture_file/version'

Gem::Specification.new do |spec|
  spec.name = 'rspec_fixture_file'
  spec.version = RSpecFixtureFile::VERSION
  spec.authors = ['James Couball']
  spec.email = ['jcouball@yahoo.com']

  spec.summary = 'A gem to make loading fixtures for RSpec easier'
  spec.description = <<~DESCRIPTION
    The RSpecFixtureFile gem makes it easier to load test fixture data from files
    stored in the project.

    This gem enables defining of fixture file paths to for each example group
    or example.

    This helps if you have a lot of fixture files that are reused for many/most
    tests but you need to change a file here or there based on the context or the
    example.
  DESCRIPTION

  spec.homepage = 'http://github.com/jcouball/rspec_fixture_file'
  spec.licenses = ['MIT']
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'binding_of_caller', '~> 1.0'
  spec.add_runtime_dependency 'rspec', '~> 3.10'

  spec.add_development_dependency 'bump', '~> 0.10'
  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'fakefs', '~> 1.4'
  spec.add_development_dependency 'github_changelog_generator', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.23'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'yardstick', '~> 0.9'

  spec.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
