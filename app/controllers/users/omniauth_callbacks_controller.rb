class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :get_omniauth
  before_action :dump_omniauth, if: ->(c) { Rails.env.development? }

  # to avoid InvalidAuthenticityToken exception
  protect_from_forgery with: :exception, except: :developer

  def developer
    # '_account_name' key must be set value on every provider
    @omniauth['info']['_account_name'] = @omniauth['info']['name']
    create_authentication_and_redirect
  end

  def twitter
    @omniauth['info']['_account_name'] = @omniauth['info']['nickname']
    @omniauth['info']['_url']          = @omniauth['info']['urls']['Twitter']
    create_authentication_and_redirect
  end

  def github
    @omniauth['info']['_account_name'] = @omniauth['info']['nickname']
    @omniauth['info']['_url']          = @omniauth['info']['urls']['GitHub']
    create_authentication_and_redirect
  end

  def google_oauth2
    @omniauth['info']['_account_name'] = @omniauth['info']['email']
    @omniauth['info']['_url']          = @omniauth['info']['urls']['Google']
    create_authentication_and_redirect
  end


  private

  def get_omniauth
    @omniauth = request.env['omniauth.auth']
  end

  def dump_omniauth
    puts @omniauth.to_yaml
  end

  def create_authentication_and_redirect
    authentication = Authentication.find_by(
      provider: @omniauth['provider'],
      uid: @omniauth['uid']
    )

    case
    when authentication
      success_and_redirect with: authentication.user
    when current_user
      current_user.apply_omniauth(@omniauth).save!
      success_and_redirect
    else
      user = User.new
      user.apply_omniauth(@omniauth)
      if user.save
        success_and_redirect with: user
      else
        session[:omniauth] = @omniauth.except('extra')
        redirect_to new_user_registration_url
      end
    end
  end

  def success_and_redirect(with: nil)
    flash[:notice] = t('devise.omniauth_callbacks.success', kind: @omniauth['provider'])
    sign_in with if with
    redirect_to get_and_reset_return_url
  end
end
