# frozen_string_literal: true

# By default, run all the CI tasks
task default: %w[spec rubocop yardstick:audit yardstick:coverage yard bundle:audit build]

# Bundler Audit

require 'bundler/audit/task'
Bundler::Audit::Task.new

# Bundler Gem Build

require 'bundler'
require 'bundler/gem_tasks'

CLOBBER << 'Gemfile.lock'

# Bump

require 'bump/tasks'

# RSpec

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

CLEAN << 'coverage'
CLEAN << '.rspec_status'
CLEAN << 'rspec-report.xml'

# Rubocop

require 'rubocop/rake_task'

RuboCop::RakeTask.new

CLEAN << 'rubocop-report.json'

# YARD

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = %w[lib/**/*.rb examples/**/*]
end

CLEAN << '.yardoc'
CLEAN << 'doc'

# Yardstick

desc 'Run yardstick to show missing YARD doc elements'
task :'yardstick:audit' do
  sh "yardstick 'lib/**/*.rb'"
end

# Yardstick coverage

require 'yardstick/rake/verify'

Yardstick::Rake::Verify.new(:'yardstick:coverage') do |verify|
  verify.threshold = 100
end

# Changelog

require 'github_changelog_generator/task'

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.header = '# Change Log'
  config.user = 'main-branch'
  config.project = 'rspec_fixture_file'
  config.future_release = "v#{RSpecFixtureFile::VERSION}"
  config.release_url = 'https://github.com/main-branch/ruby_git/releases/tag/%s'
  config.author = true
end
