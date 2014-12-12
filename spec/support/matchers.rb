RSpec::Matchers.define :have_message do |type, text = nil|
  match do |page|
    Capybara.string(page.body).has_selector?("div.alert-#{type}", text: text)
  end

  description { "have #{type} message #{text ? "'#{text}'" : ''}" }
end
