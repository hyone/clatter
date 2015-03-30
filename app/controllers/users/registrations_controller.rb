class Users::RegistrationsController < Devise::RegistrationsController
  private

  # apply information from omniauth authentication when a User object builds
  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      # @user.valid?
    end
  end

  protected

  # to avoid redirect loops
  # https://github.com/plataformatec/devise/wiki/How-To:-redirect-to-a-specific-page-on-successful-sign-in

  def after_sign_up_path_for(resource)
    signed_in_root_path(resource)
  end

  def after_update_path_for(resource)
    signed_in_root_path(resource)
  end
end
