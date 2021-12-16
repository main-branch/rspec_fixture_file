# frozen_string_literal: true

# Example from the README

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
      expect(fixture_search_paths).to eq %w[
        spec/fixtures/object_fixtures/method/example1
        spec/fixtures/object_fixtures/method
        spec/fixtures/object_fixtures spec/fixtures
      ]
    end

    it "should add the 'method' and 'example2' context", fixture_path: 'object_fixtures/method/example2' do
      expect(fixture_search_paths).to eq %w[
        spec/fixtures/object_fixtures/method/example2
        spec/fixtures/object_fixtures/method
        spec/fixtures/object_fixtures spec/fixtures
      ]
    end
  end
end
