RSpec::Matchers.define :have_alert do |type, text = nil|
  match do |page|
    Capybara.string(page.body).has_selector?("div.alert-#{type}", text: text)
  end

  description { "have an alert of type '#{type}'#{text ? " with text '#{text}'" : ''}" }
end


RSpec::Matchers.define :have_message do |message|
  match do |page|
    Capybara.string(page.body).has_selector?("li#message-#{message.id}")
  end

  description { "have message of id #{message.id}" }
end


RSpec::Matchers.define :have_user do |user|
  match do |page|
    Capybara.string(page.body).has_selector?("li#user-#{user.id}")
  end

  description { "have user of id #{user.id}" }
end
