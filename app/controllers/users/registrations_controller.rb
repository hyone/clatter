class Users::RegistrationsController < Devise::RegistrationsController
  private

  # Override Devise::RegistrationsController#update_resource
  # to update user resource by the rule below:
  # - when you have current password and try to change password,
  #   we require current password
  # - when you have not current password (only oauth login) and try to add new password,
  #   we do not require current password
  # - when password is not supplied, we do not require current password
  def update_resource(resource, params, *options)
    result =
      case
      when needs_current_password?(resource, params)
        resource.update_with_password(params)
      when new_password?(resource, params)
        params.delete(:current_password)
        resource.update_attributes(params)
      else
        params.delete(:current_password)
        params.delete(:password)
        params.delete(:password_confirmation)
        resource.update_without_password(params)
      end

    clean_up_passwords resource
    result
  end

  # when you have already had the password and try to change it to new one.
  def needs_current_password?(user, params)
    !user.encrypted_password.blank? and !params[:password].blank?
  end

  # when you have not had a password yet and try to add it.
  def new_password?(user, params)
      user.encrypted_password.blank? and !params[:password].blank?
  end


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
