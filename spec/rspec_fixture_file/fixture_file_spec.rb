# frozen_string_literal: true

require 'pp'
require 'binding_of_caller'

RSpec.describe RSpecFixtureFile do
  include FakeFS::SpecHelpers

  describe '#fixture_file' do
    subject { fixture_file(fixture_file_name) }

    context "when 'RSpec.configration.base_fixture_path' is not set" do
      # Use the default base_fixture_path instead of setting it explicitly
      # before do
      #   allow(RSpec.configuration).to receive(:base_fixture_path).and_return('spec/fixtures')
      # end

      context "when the file 'spec/fixtures/fixture.txt' DOES NOT exist" do
        context "when called with 'fixture.txt'" do
          let(:fixture_file_name) { 'fixture.txt' }
          it { is_expected.to be_nil }
        end
      end

      context "when the file 'spec/fixtures/fixture.txt' exists" do
        before do
          FileUtils.mkdir_p('spec/fixtures')
          File.write('spec/fixtures/fixture.txt', 'fixture content')
        end

        context "when called with 'fixture.txt'" do
          let(:fixture_file_name) { 'fixture.txt' }
          it { is_expected.to be_the_fixture('spec/fixtures/fixture.txt', 'fixture content') }
        end
      end

      context 'when specifying a fixture path' do
        fixtures = [
          { path: 'spec/fixtures/fixture1.txt', content: 'fixture1A content' },
          { path: 'spec/fixtures/base_fixtures/fixture1.txt', content: 'fixture1B content' },
          { path: 'spec/fixtures/base_fixtures/fixture2.txt', content: 'fixture2 content' }
        ]

        context "when the files '#{fixtures.map { |f| f[:path] }.join("', '")}' exist", fixtures: fixtures do
          before(:each) do |example|
            example.metadata[:fixtures].each do |fixture|
              FileUtils.mkdir_p(File.dirname(fixture[:path]))
              File.write(fixture[:path], fixture[:content])
            end
          end

          context 'when nothing is added to the fixture_path' do
            context "when called with 'fixture1.txt'" do
              let(:fixture_file_name) { 'fixture1.txt' }
              it { is_expected.to be_the_fixture('spec/fixtures/fixture1.txt', 'fixture1A content') }
            end
            context "when called with 'fixture2.txt'" do
              let(:fixture_file_name) { 'fixture2.txt' }
              it { is_expected.to be_nil }
            end
          end

          context "when 'base_fixtures' is added to the fixture_path", fixture_path: 'base_fixtures' do
            context "when called with 'fixture1.txt'" do
              let(:fixture_file_name) { 'fixture1.txt' }
              it { is_expected.to be_the_fixture('spec/fixtures/base_fixtures/fixture1.txt', 'fixture1B content') }
            end
            context "when called with 'fixture2.txt'" do
              let(:fixture_file_name) { 'fixture2.txt' }
              it { is_expected.to be_the_fixture('spec/fixtures/base_fixtures/fixture2.txt', 'fixture2 content') }
            end
          end

          context "when 'no_fixtures_here' is added to the fixture_path", fixture_path: 'no_fixtures_here' do
            context "when called with 'fixture1.txt'" do
              let(:fixture_file_name) { 'fixture1.txt' }
              it { is_expected.to be_the_fixture('spec/fixtures/fixture1.txt', 'fixture1A content') }
            end
            context "when called with 'fixture2.txt'" do
              let(:fixture_file_name) { 'fixture2.txt' }
              it { is_expected.to be_nil }
            end
          end
        end
      end

      context 'when specifying nested fixture paths' do
        fixtures = [
          { path: 'spec/fixtures/fixture1.txt', content: 'fixture1 content' },
          { path: 'spec/fixtures/fixture2.txt', content: 'fixture2 content' },
          { path: 'spec/fixtures/fixture3.txt', content: 'fixture3 content' },
          { path: 'spec/fixtures/dir1/fixture1.txt', content: 'dir1/fixture1 content' },
          { path: 'spec/fixtures/dir1/fixture2.txt', content: 'dir1/fixture2 content' },
          { path: 'spec/fixtures/dir2/fixture2.txt', content: 'dir2/fixture2 content' }
        ]

        context "when the files '#{fixtures.map { |f| f[:path] }.join("', '")}' exist", fixtures: fixtures do
          before(:each) do |example|
            example.metadata[:fixtures].each do |fixture|
              FileUtils.mkdir_p(File.dirname(fixture[:path]))
              File.write(fixture[:path], fixture[:content])
            end
          end

          context "when 'dir1' has been added to the fixture_path", fixture_path: 'dir1' do
            context "when 'dir2' has been added to the fixture_path", fixture_path: 'dir2' do
              context "when called with 'fixture1.txt'" do
                let(:fixture_file_name) { 'fixture1.txt' }
                it { is_expected.to be_the_fixture('spec/fixtures/dir1/fixture1.txt', 'dir1/fixture1 content') }
              end
              context "when called with 'fixture2.txt'" do
                let(:fixture_file_name) { 'fixture2.txt' }
                it { is_expected.to be_the_fixture('spec/fixtures/dir2/fixture2.txt', 'dir2/fixture2 content') }
              end
              context "when called with 'fixture3.txt'" do
                let(:fixture_file_name) { 'fixture3.txt' }
                it { is_expected.to be_the_fixture('spec/fixtures/fixture3.txt', 'fixture3 content') }
              end
            end
          end
        end
      end
    end

    context "when 'RSpec.configration.base_fixture_path' is set to 'fixtures_dir'" do
      before do
        allow(RSpec.configuration).to receive(:base_fixture_path).and_return('fixtures_dir')
      end

      context 'when fixtures_dir/fixture.txt exists' do
        before do
          FileUtils.mkdir_p('fixtures_dir')
          File.write('fixtures_dir/fixture.txt', 'fixture content')
        end
        context "when called with 'fixture.txt'" do
          let(:fixture_file_name) { 'fixture.txt' }
          it { is_expected.to be_the_fixture('fixtures_dir/fixture.txt', 'fixture content') }
        end
      end
    end

    context 'when a `let` block is evaluated from different contexts' do
      let(:test_data) { fixture_file('test_data.txt').read }

      fixtures = [
        { path: 'spec/fixtures/test_data.txt', content: 'test_data.txt content' },
        { path: 'spec/fixtures/context1/test_data.txt', content: 'context1/test_data.txt content' },
        { path: 'spec/fixtures/context2/test_data.txt', content: 'context2/test_data.txt content' }
      ]

      context "when the files '#{fixtures.map { |f| f[:path] }.join("', '")}' exist", fixtures: fixtures do
        before do |example|
          example.metadata[:fixtures].each do |fixture|
            FileUtils.mkdir_p(File.dirname(fixture[:path]))
            File.write(fixture[:path], fixture[:content])
          end
        end

        it 'should find test_data in spec/fixtures/test_data.txt' do
          expect(test_data).to eq('test_data.txt content')
        end

        context "when fixture_path is set to 'context1'", fixture_path: 'context1' do
          it 'should do this' do
            expect(test_data).to eq('context1/test_data.txt content')
          end
        end

        context "when fixture_path is set to 'context2'", fixture_path: 'context2' do
          it 'should do that' do
            expect(test_data).to eq('context2/test_data.txt content')
          end
        end
      end
    end

    context 'when a `let` block is evaluated from different examples' do
      let(:test_data) { fixture_file('test_data.txt').read }

      fixtures = [
        { path: 'spec/fixtures/test_data.txt', content: 'test_data.txt content' },
        { path: 'spec/fixtures/example1/test_data.txt', content: 'example1/test_data.txt content' },
        { path: 'spec/fixtures/example2/test_data.txt', content: 'example2/test_data.txt content' }
      ]

      context "when the files '#{fixtures.map { |f| f[:path] }.join("', '")}' exist", fixtures: fixtures do
        before do |example|
          example.metadata[:fixtures].each do |fixture|
            FileUtils.mkdir_p(File.dirname(fixture[:path]))
            File.write(fixture[:path], fixture[:content])
          end
        end

        it 'should find test_data in spec/fixtures/test_data.txt' do
          expect(test_data).to eq('test_data.txt content')
        end

        it 'should do this', fixture_path: 'example1' do
          # let(:test_data) { fixture_file("test_data.txt").read }
          expect(test_data).to eq('example1/test_data.txt content')
        end

        it 'should do that', fixture_path: 'example2' do
          # let(:test_data) { fixture_file("test_data.txt").read }
          expect(test_data).to eq('example2/test_data.txt content')
        end
      end
    end
  end
end
