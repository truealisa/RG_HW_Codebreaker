require 'spec_helper'

module RgHwCodebreaker
  RSpec.describe ResultsAccessor do
    subject { ResultsAccessor }

    describe '::write_result_to_file' do
      let(:current_result) { ['test_username', Date.today, 5] }
      let(:results) { YAML.load_file('lib/rg_hw_codebreaker/results.yml') }

      after(:all) do
        result_file = YAML.load_file('lib/rg_hw_codebreaker/results.yml')
        result_file.slice!(-2, 2)
        File.open('lib/rg_hw_codebreaker/results.yml', 'w') do |file|
          YAML.dump(result_file, file)
        end
      end

      it 'rewrites results.yml with current result included' do
        subject.write_result_to_file(current_result)
        expect(results).to include(current_result)
      end

      it 'does not mutate previous results in the file' do
        previous_results = YAML.load_file('lib/rg_hw_codebreaker/results.yml')
        subject.write_result_to_file(current_result)
        previous_results.each do |result_record|
          expect(results).to include(result_record)
        end
      end
    end

    describe '::load_results_file' do
      it 'checks results file existance' do
        expect(File).to receive(:exist?)
        subject.load_results_file
      end

      context 'results file does not exist' do
        let(:results) { YAML.load_file('lib/rg_hw_codebreaker/results.yml') }

        before do
          allow(File).to receive(:exist?).and_return(false)
          subject.load_results_file
        end

        it 'creates new results file' do
          expect(YAML.load_file('lib/rg_hw_codebreaker/results.yml')).to be_truthy
        end

        it 'fills results file with heading line data' do
          expect(results).to include(%w[Player Date Turns])
        end
      end

      it 'returns results file' do
        expect(File).to receive(:read)
        subject.load_results_file
      end
    end
  end
end
