class ApplicationController < ActionController::Base
  include ActionsHelper

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # when authroized denied error
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u|
      u.permit(
        :screen_name, :email, :name, :description, :url,
        :password, :password_confirmation, :remeber_me,
        :profile_image, :profile_image_cache, :remove_profile_image
      )
    }
    devise_parameter_sanitizer.for(:sign_in) { |u|
      u.permit(:login, :screen_name, :email, :password, :remeber_me)
    }
    devise_parameter_sanitizer.for(:account_update) { |u|
      u.permit(
        :screen_name, :email, :name, :description, :url,
        :password, :password_confirmation, :current_password,
        :profile_image, :profile_image_cache, :remove_profile_image
      )
    }
  end
end
