class ApplicationController
  module Authenticatable
    extend ActiveSupport::Concern

    included do
      before_action :configure_permitted_parameters, if: :devise_controller?
    end

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(
          :screen_name, :email, :name, :description, :url,
          :password, :password_confirmation, :remeber_me,
          :profile_image, :profile_image_cache, :remove_profile_image
        )
      end
      devise_parameter_sanitizer.for(:sign_in) do |u|
        u.permit(:login, :screen_name, :email, :password, :remeber_me)
      end
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(
          :screen_name, :email, :name, :description, :url,
          :password, :password_confirmation, :current_password,
          :profile_image, :profile_image_cache, :remove_profile_image
        )
      end
    end

    # redirect back when login succeeded
    # https://github.com/plataformatec/devise/wiki/How-To:-redirect-to-a-specific-page-on-successful-sign-in
    def after_sign_in_path_for(resource)
      to_url = delete_return_to || root_path
      if to_url == new_user_session_path
        super
      else
        stored_location_for(resource) || to_url
      end
    end

    def delete_return_to
      to_url = session[:return_to]
      session[:return_to] = nil
      to_url
    end
  end
end
