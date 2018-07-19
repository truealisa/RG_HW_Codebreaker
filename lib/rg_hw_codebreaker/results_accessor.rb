require 'yaml'
require 'date'

module RgHwCodebreaker
  class ResultsAccessor
    class << self
      def write_result_to_file(current_result)
        best_results = YAML.load(load_results_file)
        best_results << current_result
        File.open(File.join(__dir__, 'results.yml'), 'w') do |file|
          YAML.dump(best_results, file)
        end
      end

      def load_results_file
        unless File.exist?(File.join(__dir__, 'results.yml'))
          results_file = File.open(File.join(__dir__, 'results.yml'), 'w')
          results_file.write([%w[Player Date Turns]].to_yaml)
          results_file.close
        end
        File.read(File.join(__dir__, 'results.yml'))
      end
    end
  end
end
