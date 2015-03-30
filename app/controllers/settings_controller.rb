class SettingsController < Devise::RegistrationsController
  layout 'settings'

  before_action :require_user
  before_action :set_user

  def account
  end

  def password
  end

  def profile
  end

  def update_with_password
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if update_resource(resource, params_require_password)
      flash[:notice] = t('devise.registrations.updated')
      redirect_to :back
    else
      render params[:section]
    end
  end

  def update_without_password
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if resource.update_without_password(params_without_password)
      flash[:notice] = t('devise.registrations.updated')
      redirect_to :back
    else
      render params[:section]
    end
  end

  def update_password
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    _params = params_change_password
    # validations
    [:password, :password_confirmation].each do |field|
      if _params[field].blank?
        resource.errors.add(field, :blank)
      end
    end

    if resource.errors.empty? and update_resource(resource, _params)
      flash[:notice] = t('devise.registrations.updated')
      redirect_to :back
    else
      render 'password'
    end
  end


  private
  def set_user
    @user = current_user
  end


  # - when password is not supplied, we do not require current password
  # - when you have not current password (only oauth login) and try to add new password,
  #   we do not require current password
  # - when you have current password, we require current password
  def update_resource(resource, params, *options)
    result =
      case
      when new_password?(resource, params)
        params.delete(:current_password)
        resource.update_attributes(params)
      else
        resource.update_with_password(params)
      end

    clean_up_passwords resource
    result
  end

  def has_password?(resource)
    !resource.encrypted_password.blank?
  end

  # when you have not had a password yet and try to add it.
  def new_password?(resource, params)
    not has_password?(resource) and not params[:password].blank?
  end


  PARAMS_REQUIRE_PASSWORD = [
    :screen_name, :email, :password,
    :current_password,
  ]
  PARAMS_WITHOUT_PASSWORD = [
    :name, :url, :description,
    :profile_image, :profile_image_cache, :remove_profile_image,
  ]

  def params_require_password
    params.require(:user).permit(*(PARAMS_REQUIRE_PASSWORD + PARAMS_WITHOUT_PASSWORD))
  end

  def params_without_password
    params.require(:user).permit(*PARAMS_WITHOUT_PASSWORD)
  end

  def params_change_password
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
