require_relative '../config/environment'
require 'rake'
load './Rakefile'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    begin
      DatabaseCleaner.clean_with(:truncation)
    rescue
      puts "Database not yet created in config/environment.rb!"
    end
  end

  config.around(:each) do |example|
    begin
      DatabaseCleaner.cleaning do
        example.run
      end
    rescue
      puts "Database not yet created in config/environment.rb!"
    end
  end

  config.order = 'default'
end
