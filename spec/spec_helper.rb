require 'simplecov'
SimpleCov.start

require 'bundler/setup'
require 'rg_hw_codebreaker'
require 'stringio'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  original_stderr = $stderr
  original_stdout = $stdout
  config.before(:all) do
    # Redirect stderr and stdout
    $stdout = StringIO.new
    $stdout = StringIO.new
  end
  config.after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end
end
