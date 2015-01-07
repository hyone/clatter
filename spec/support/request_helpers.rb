include Warden::Test::Helpers

module RequestHelpers
  def signin(user)
    login_as user, scope: :user
  end

  def click_signin_button
    click_button I18n.t('views.users.form.signin')
  end

  def click_signup_button
    click_button I18n.t('views.users.form.signup')
  end

  def setup_omniauth(service = :twitter)
    username = 'hoge'

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[service] = OmniAuth::AuthHash.new({
      provider: "#{service}",
      uid: '12345'
    })

    case service.to_s
    when 'developer'
      OmniAuth.config.add_mock(service, {
        info: {
          name: username,
          email: "#{username}@example.com"
        }
      })
    when 'twitter'
      OmniAuth.config.add_mock(service, {
        info: {
          name: username.titleize,
          nickname: username,
          urls: {
            Twitter: "http://www.twitter.com/#{username}"
          }
        }
      })
    when 'github'
      OmniAuth.config.add_mock(service, {
        info: {
          name: username.titleize,
          nickname: username,
          urls: {
            GitHub: "http://github.com/#{username}"
          }
        }
      })
    when 'google_oauth2'
      OmniAuth.config.add_mock(service, {
        info: {
          name: username.titleize,
          email: "#{username}@example.com",
          urls: {
            Google: "http://www.google.com/#{username}"
          }
        }
      })
    end
  end

  def post_message(p)
    post messages_path, {
      message: { text: p.text }
    }
  end

  # wait to ajax proccess have finished

  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end
