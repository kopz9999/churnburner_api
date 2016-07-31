source 'https://rubygems.org'
ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# App
gem 'intercom', "~> 3.5.1"
gem 'sidekiq'
gem 'figleaf'
gem 'slack-ruby-client'
# Use PostgresSQL as the database for Active Record
gem 'pg'
# gem 'faraday', '0.8.11'
gem 'her',
    git: 'https://github.com/kopz9999/her.git',
    branch: 'feature/activemodel-5.0.x'
gem 'fub_client', '0.1.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rspec-rails'
  gem 'byebug', platform: :mri
  gem 'pry-byebug'
  gem 'dotenv-rails'
end

group :test do
  gem 'vcr', '3.0.3'
  gem 'webmock'
  gem 'database_cleaner'
  gem "factory_girl_rails"
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
  gem 'thin'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
