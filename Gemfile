source 'https://rubygems.org'
ruby '2.2.1'

gem 'rails', '4.2.1'
gem 'pg'

# views
gem 'bower-rails'
gem 'coffee-rails', '~> 4.1.0'
gem 'coffee-script-source', '~> 1.8.0'
gem 'i18n-js'
gem 'jbuilder', '~> 2.0'
gem 'sass-rails', '~> 5.0'
gem 'slim-rails'
gem 'therubyracer',  platforms: :ruby
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

# auth
gem 'cancancan'
gem 'devise'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'

# others
gem 'annotate'
gem 'fog', require: 'fog/aws/storage' # MUST require before carrierwave
gem 'excon', '>= 0.44.4'
gem 'carrierwave'
gem 'counter_culture', '~> 0.1.30'
gem 'egison'
gem 'factory_girl_rails'
gem 'faker'
gem 'friendly_id'
gem 'kaminari'
gem 'kaminari-bootstrap'
gem 'mini_magick'
gem 'ransack'
gem 'responders', '~> 2.0'

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :production do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'capybara'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rubocop', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'byebug'
  gem 'coffee-rails-source-maps'
  gem 'foreman'
  gem 'guard-rspec'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'pry-rails'
  gem 'awesome_print'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'terminal-notifier-guard'
  gem 'web-console', '~> 2.0'
  gem 'view_source_map'
end

group :test do
  gem 'coveralls', require: false
  gem 'database_rewinder'
  gem 'poltergeist'
  gem 'rake_shared_context'
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
end
