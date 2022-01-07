# RSpecFixtureFile

The RSpecFixtureFile gem makes it easier to load test fixture data from files
stored in the project.

This gem enables defining of fixture file paths to for each example group
or example.

This helps if you have a lot of fixture files that are reused for many/most
tests but you need to change a file here or there based on the context or the
example.

## Installation

Add the 'rspec_fixture_file' gem to your Gemfile or gemspec and then execute:

And then execute:

```Shell
$ bundle install
```

Or install it using the gem command:

```Shell
$ gem install rspec_fixture_file
```

## Usage

To get started, `require 'rspec_fixture_file'` in your spec_helper.rb file and including
`RSpecFixtureFile` in an `RSpec.configuration` block.

See the "Configuring RSpecFixtureFile" section below.

Use the `fixture_file(file_name)` method in your examples (in an `it`, `let`, or
`subject` block) to load fixture data.

See the "fixture_file" section below.

By default `file_name` is relative to the `spec/fixtures` directory. Set
`base_fixture_path` in an `RSpec.configuration` block to change the default path
from which all fixtures are loaded from.

You can define multiple paths to search by adding `fixture_path` metadata to an
example or example group.

`fixture_path` on nested example groups adds those paths to the paths that are
searched by the `fixture_file` method.

See the "fixture_path" section below.

### Configuring RSpecFixtureFile

To enable RSpecFixtureFile, include the following in your spec_helper.rb:

```Ruby
require 'rspec_fixture_file'

RSpec.configure do |config|
  config.include RSpecFixtureFile
end
```

All fixtures will be found relative to `RSpec.configuration.base_fixture_path` which is
`spec/fixtures` by default.

```Ruby
RSpec.configure do |config|
  # This is the defaut but can be set to something else
  config.add_setting(:base_fixture_path, default: File.join(config.default_path, 'fixtures'))
end
```

### fixture_file: find a fixture file

Within your tests, get a Pathname that references a fixture file using the `fixture_file`
method. This method takes a relative path to the fixture file (as a String) and returns
an Pathname that represents the path to the fixture file. `fixture_file` returns `nil` if
no fixture file can be found that matches the relative path.

```Ruby
RSpec.describe MyClass do
  # Read the method arg from a fixture file
  describe '#method' do
    subject { described_class.new.method(test_data) }
    # Read a fixture file `spec/fixtures/test_data.txt` into `test_data`
    let(:test_data) { fixture_file("test_data.txt").read }
    it 'should not throw an error' do
      expect { subject }.not_to raise_error
    end
  end
end
```

### fixture_path: add paths for fixture_file to search

RSpecFixtureFile always checks in `RSpec.configuration.base_fixture_path` for fixture files.
You can instruct it to look in other directories as well by adding `fixture_path`
metadata to an example group or an example.

`fixture_file` will look for the specified fixture file relative to these paths in this order:

* The `fixture_path` metadata given for the example block that `fixture_file` is
  called from.
* The `fixture_path` metadata given in the nested example groups that `fixture_file`
  is called from starting with the parent example group and traversing to the root
  example group.
* The path given by `RSpec.configuration.base_fixture_path`

The `fixture_search_paths` method shows all the paths which are searched for a fixure file
within the context it is called from.

Here is a simple example of using `fixture_file`.  This example assumes that
'spec/fixtures/object_fixtures/test.txt' exists and contains the string 'fixture
content'):

```Ruby
RSpec.describe Object, fixture_path: 'object_fixtures' do
  let(:test_data) { fixture_file('test.txt') }

  it 'should find the fixture file' do
    expect(test_data).to be_a(Pathname)
    expect(test_data.to_path).to eq('spec/fixtures/object_fixtures/test.txt')
    expect(test_data.read).to eq('fixture content')
  end
end
```

A more complex example that shows how `fixture_path` metadata on example groups and
examples adds to the `fixture_search_paths`:

```Ruby
RSpec.describe Object, fixture_path: 'object_fixtures' do
  it "should add 'object_fixtures' to the search path" do
    expect(fixture_search_paths).to eq %w[
      spec/fixtures/object_fixtures
      spec/fixtures
    ]
  end

  describe '#method', fixture_path: 'object_fixtures/method' do
    it "should add the 'method' context" do
      expect(fixture_search_paths).to eq %w[
        spec/fixtures/object_fixtures/method
        spec/fixtures/object_fixtures
        spec/fixtures
      ]
    end

    it "should add the 'method' and 'example1' context", fixture_path: 'object_fixtures/method/example1' do
      # Note: does not include 'object_fixtures/method/example2'
      expect(fixture_search_paths).to eq %w[
        spec/fixtures/object_fixtures/method/example1
        spec/fixtures/object_fixtures/method
        spec/fixtures/object_fixtures spec/fixtures
      ]
    end

    it "should add the 'method' and 'example2' context", fixture_path: 'object_fixtures/method/example2' do
      # Note: does not include 'object_fixtures/method/example1'
      expect(fixture_search_paths).to eq %w[
        spec/fixtures/object_fixtures/method/example2
        spec/fixtures/object_fixtures/method
        spec/fixtures/object_fixtures spec/fixtures
      ]
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jcouball/rspec_fixture_file.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
