# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rsspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separetly)
#  * 'just' rspec: 'rspec'

require 'active_support/inflector'


guard :rspec, cmd: 'spring rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }

  # model
  watch(%r{^app/models/(.+)\.rb$}) { |m| [
    "spec/models/#{m[1]}_spec.rb",
    "spec/features/#{m[1].pluralize}_spec.rb"
  ] }

  # controllers
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| [
    "spec/routing/#{m[1]}_routing_spec.rb",
    "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb",
    "spec/acceptance/#{m[1]}_spec.rb",
    "spec/features/#{m[1]}_spec.rb"
  ] }

  # views
  watch(%r{^app/views/(.+)(\.erb|\.haml|\.slim)$}) { |m|
    "spec/views/#{m[1]}#{m[2]}_spec.rb"
  }
  watch(%r{^app/views/(.+?)/(.+)(\.erb|\.haml|\.slim)}) { |m|
    "spec/features/#{m[1]}_spec.rb"
  }
  watch(%r{^app/views/layouts/(.+)(\.erb|\.haml|\.slim)$/}) { |m|
    'spec/features'
  }

  # other files
  watch(%r{^spec/support/(.+)\.rb$})                  { 'spec' }
  watch('config/routes.rb')                           { 'spec/routing' }
  watch('app/controllers/application_controller.rb')  { 'spec/controllers' }
  watch('spec/rails_helper.rb')                       { 'spec' }

  watch('config/application.rb') { 'spec' }
  watch('config/environment.rb') { 'spec' }
  watch(%r{^config/environments/.+\.rb$}) { 'spec' }
  watch(%r{^config/initializers/.+\.rb$}) { 'spec' }

end
