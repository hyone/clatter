require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

# capybara
Capybara.javascript_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    js_errors: false,
    timeout: 60,
    window_size: [1920, 6000]
  )
end

RSpec.configure do |config|
  # locales for poltergeist
  config.before(:each, js: true) do
    # I18n.locale = :ja
    page.driver.headers = { 'Accept-Language' => "#{ I18n.locale }" }
  end
end
