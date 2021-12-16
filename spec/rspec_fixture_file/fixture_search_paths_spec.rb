# frozen_string_literal: true

RSpec.describe RSpecFixtureFile do
  describe '#fixture_search_paths' do
    subject { fixture_search_paths }

    context 'when no other fixture_path are added to the search paths' do
      context "when 'RSpec.configration.base_fixture_path' is not set" do
        it "should return the default base_fixture_path ['spec/fixtures']" do
          expect(subject).to eq(['spec/fixtures'])
        end
      end

      context "when 'RSpec.configration.base_fixture_path' is set to 'my_fixtures'" do
        before do
          allow(RSpec.configuration).to receive(:base_fixture_path).and_return('my_fixtures')
        end
        it "should return the base_fixture_path ['my_fixtures']" do
          expect(subject).to eq(['my_fixtures'])
        end
      end
    end

    context "in an example group sets fixture_path to 'dir1'", fixture_path: 'dir1' do
      let(:expected_paths) { %w[spec/fixtures/dir1 spec/fixtures] }
      it { is_expected.to eq(expected_paths) }

      context "in a nested example group that sets fixture_path to 'dir2'", fixture_path: 'dir2' do
        let(:expected_paths) { %w[spec/fixtures/dir2 spec/fixtures/dir1 spec/fixtures] }
        it { is_expected.to eq(expected_paths) }

        it 'should be able to add fixture_path on an example', fixture_path: 'dir3' do
          expected_paths = %w[spec/fixtures/dir3 spec/fixtures/dir2 spec/fixtures/dir1 spec/fixtures]
          expect(subject).to eq(expected_paths)
        end
      end
    end
  end
end
