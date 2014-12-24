module ActionsHelper
  def require_user
    unless user_signed_in?
      redirect_to new_user_session_path, notice: t('views.generic.please_sign_in')
    end
  end
end
