require 'database_cleaner'

# Load rake tasks
ChurnburnerApi::Application.load_tasks

# spec/support/factory_girl.rb
RSpec.configure do |config|
  config.around :each do |example|
    DatabaseCleaner.cleaning do
      title  = example.metadata[:full_description]
      source =  example.metadata[:block].source_location.join ":"
      $0 = %{rspec #{source} "#{title}"}
      example.run
    end
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    Rake::Task['db:seed'].invoke
  end
end
