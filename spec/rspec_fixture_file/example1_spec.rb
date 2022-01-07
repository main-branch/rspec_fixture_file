# frozen_string_literal: true

# Example from the README

RSpec.describe Object, fixture_path: 'object_fixtures' do
  include FakeFS::SpecHelpers

  before do
    FileUtils.mkdir_p 'spec/fixtures/object_fixtures'
    File.write 'spec/fixtures/object_fixtures/test.txt', 'fixture content'
  end

  let(:test_data) { fixture_file('test.txt') }

  it 'should find the fixture file' do
    expect(test_data).to be_a(Pathname)
    expect(test_data.to_path).to eq('spec/fixtures/object_fixtures/test.txt')
    expect(test_data.read).to eq('fixture content')
  end
end
