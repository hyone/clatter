class ApplicationController < ActionController::Base
  include ActionsHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  concerning :Authenticatable do
    included do
      before_action :configure_permitted_parameters, if: :devise_controller?

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

      # redirect back when login succeeded
      # https://github.com/plataformatec/devise/wiki/How-To:-redirect-to-a-specific-page-on-successful-sign-in
      def after_sign_in_path_for(resource)
        to_url = get_and_reset_return_url
        if to_url == new_user_session_path
          super
        else
          stored_location_for(resource) || to_url
        end
      end

      def get_and_reset_return_url()
        to_url = session[:return_to] || root_path
        session[:return_to] = nil
        to_url
      end
    end
  end
end
