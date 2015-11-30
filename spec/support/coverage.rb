# Test Coverage
require 'simplecov'
require 'coveralls'

if ENV['COVERAGE']
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter
  ]
  SimpleCov.start 'rails'
  # SimpleCov.start do
  #   add_filter '/config/'
  #   add_filter '/db/'
  #   add_filter '/vendor/bundle/'
  #   add_filter '/spec/'
  #
  #   add_group 'Controllers', 'app/controllers'
  #   add_group 'Models', 'app/models'
  #   add_group 'Helpers', 'app/helpers'
  #   add_group 'Libraries', 'lib'
  # end
end

# coveralls
if ENV['CI']
  Coveralls.wear!
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start 'rails'
end
