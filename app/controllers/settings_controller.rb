class SettingsController < Devise::RegistrationsController
  layout 'settings'

  before_action :require_user
  before_action :set_user
  before_action :get_resource

  def account
  end

  def password
  end

  def profile
  end

  def update_with_password
    update_process { update_resource(resource, params_require_password) }
  end

  def update_without_password
    update_process { resource.update_without_password(params_without_password) }
  end

  def update_password
    _params = params_change_password
    # validations
    [:password, :password_confirmation].each do |field|
      resource.errors.add(field, :blank) if _params[field].blank?
    end

    update_process('password') {
      resource.errors.empty? and update_resource(resource, _params)
    }
  end


  private

  def get_resource
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
  end

  def set_user
    @user = current_user
  end

  def update_process(page = params[:section], &update)
    if update.call
      flash[:notice] = t('devise.registrations.updated')
      redirect_to :back
    else
      render page
    end
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
    :screen_name, :email, :password, :time_zone,
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
