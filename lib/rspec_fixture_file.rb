# frozen_string_literal: true

require_relative 'rspec_fixture_file/version'

require 'binding_of_caller'

# Help with loading fixtures for RSpec
#
# @api public
module RSpecFixtureFile
  # An array of directories where fixture files can be found
  #
  # When searching for a fixture file, check these directories in the order they
  # appear in the array.
  #
  # @example the default search path includes the single directory `spec/fixtures`
  #   it 'should succeed' do
  #     expect(fixture_search_paths).to eq(['spec/fixtures'])
  #   end
  #
  # @example add to the search path using `fixture_path` metadata
  #   describe Object, fixture_path: 'object_fixtures' do
  #     it 'should add the fixture_path to the fixture search path' do
  #       expect(fixture_search_paths).to eq(%w[spec/fixtures/object_fixtures spec/fixtures])
  #     end
  #   end
  #
  # @return [Array<String>]
  #
  def fixture_search_paths
    [].tap do |search_paths|
      # If self is an Example and it has a fixture_path, add that to the search_paths.
      fixture_path = example_fixture_path
      search_paths << fixture_path if fixture_path

      # Visit the current example group and all its ancestors, adding any
      # fixture_paths to search_paths.
      self.class.ancestors.each do |example_group_class|
        fixture_path = example_group_fixture_path(example_group_class)
        # Duplicate fixture_paths should be ignored
        search_paths << fixture_path if fixture_path && !search_paths.include?(fixture_path)
      end

      # Lastly, add the base_fixture_path to search_paths.
      search_paths << base_fixture_path
    end
  end

  # Searches for the named fixture file in the fixture_search_paths
  #
  # @example Use in an `it` block
  #   it 'should succeed' do
  #     path = fixture_file('example.txt') #=> 'spec/fixtures/example.txt'
  #     data = fixture_file('example.txt').read
  #   end
  #
  # @example Use in a `let` block
  #   let(:test_data) { fixture_file('example.txt').read }
  #
  # @return [Pathname, nil] the path to the fixture file, or nil if not found
  #
  def fixture_file(file_name)
    fixture_search_paths.each do |fixture_path|
      path = File.join(fixture_path, file_name)
      return Pathname.new(path) if File.exist?(path)
    end
    nil
  end

  # Return the directory under which all fixture files are stored
  #
  # @return [String] the directory under which all fixture files are stored
  #   relative to the current directory
  #
  # @api private
  def base_fixture_path
    return RSpec.configuration.base_fixture_path if RSpec.configuration.respond_to?(:base_fixture_path)

    File.join(RSpec.configuration.default_path, 'fixtures')
  end

  # Constructs the path to the fixture file
  #
  # The path is constructed by concatinating the base_fixture_path,
  # a fixture search path, and the fixture file name.
  #
  # @return [String] the path to the fixture file
  #
  # @api private
  def full_fixture_path(fixture_path)
    return nil if fixture_path.nil?

    File.join(base_fixture_path, fixture_path)
  end

  # Return the fixture_path if one is given on the calling Example
  #
  # Search up the call stack to find the Example this was called from.
  #
  # Return nil if either: this not called from an Example or :fixture_path was not set on the Example.
  #
  # @return [String, nil] the full fixture_path or nil
  #
  # @api private
  #
  def example_fixture_path
    example_binding = binding.callers.find { |binding| binding.receiver.is_a?(RSpec::Core::Example) }
    full_fixture_path(example_binding&.receiver&.metadata&.[](:fixture_path))
  end

  # Return the fixture_path if one is given on the specified ExampleGroup class
  #
  # Return nil if the class does not have a @metadata variable or if :fixture_path
  # was not set on the ExampleGroup.
  #
  # @param example_group_class [Class] the ExampleGroup class to check
  #
  # @return [String, nil] the full fixture_path or nil
  #
  # @api private
  #
  def example_group_fixture_path(example_group_class)
    full_fixture_path(example_group_class.instance_variable_get(:@metadata)&.[](:fixture_path))
  end
end
